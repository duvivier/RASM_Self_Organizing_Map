;***************************************
; PROGRAM DESCRIPTION: This script creates node averages of WRF data
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: NetCDF files of average WRF data
; CREATOR: Alice DuVivier - Sept. 2014
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
nx_input = "7"
ny_input = "5"
fout_string = "199011_201003.wrf.sfc"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations by month")
months = (/"11","12","01","02","03"/)
times = dimsizes(months)

;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
datefile = dir+"wrf50_199011_201003_dates.txt"
visfile  = dir+"wrf50_199011_201003_wind.vis"
dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
ndates = dimsizes(dates)
dateschar = stringtochar(dates)
yy = chartostring(dateschar(:,0:3))
mm = chartostring(dateschar(:,5:6))
dd = chartostring(dateschar(:,8:9))

vis = new((/ndates,3/),integer)
vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

; create filenames array
files = new((/ndates/),string)
files = "/vardar/data5/duvivier/SOM-RASM/analysis/surface_files/wrf_sfc_files/wrf."+yy+"-"+mm+"-"+dd+".sfc.green.nc"

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

fill = new((/1/),"float")
n = 0
;;;;;;;;;
; calculate Node averages for wrf variables
;;;;;;;;;;
; loop through each month
do m = 0, times -1
mon = months(m)
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   print("node: "+x+","+y)
  ; These are the dates for this particular node:
   dateindices = ind((mm.eq.mon).and.(vis(:,0).eq.x.and.vis(:,1).eq.y))
   if (.not.all(ismissing(dateindices))) then
     files_sub = files(dateindices)
   else
     print("All files missing for node")
   end if

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
   fout_node = "node_"+x+"x_"+y+"y_month-"+mon+"_"+fout_string
   node_avg = addfile("./"+fout_node+".nc","c")

  ; fields that do not need to be averaged
   geo = addfile(files_sub(0),"r")
   lat = geo->lat
   lon = geo->lon
   Z_sfc = geo->Z_sfc
   dims = dimsizes(Z_sfc)
   dim_sn = dims(0)
   dim_we = dims(1)

  ; write to new average file
   node_avg ->lat = lat
   print("latitude")
   node_avg ->lon = lon
   print("longitude") 
   node_avg ->Z_sfc = Z_sfc
   print("Terrain height")
   delete([/geo,lat,lon,Z_sfc,dims/])

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data
  ; Go through each type of surface variable and calculate average and variance

  ;; Wind
   u_tr = new((/dim_files,dim_sn,dim_we/),"float")
   v_tr = new((/dim_files,dim_sn,dim_we/),"float")
   wspd = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     u_tr(f,:,:) = wrf->u_tr
     v_tr(f,:,:) = wrf->v_tr
     wspd(f,:,:) = wrf->wspd
     delete(wrf)
   end do
   ; get averages and variances
   u_tr_avg = dim_avg_n_Wrap(u_tr,0)
   v_tr_avg = dim_avg_n_Wrap(v_tr,0)
   wspd_avg = dim_avg_n_Wrap(wspd,0)
   u_tr_var = dim_variance_n_Wrap(u_tr,0)
   v_tr_var = dim_variance_n_Wrap(v_tr,0)
   wspd_var = dim_variance_n_Wrap(wspd,0)
   ; write to node average file
   node_avg ->u_tr_avg = u_tr_avg
   node_avg ->u_tr_var = u_tr_var
   node_avg ->v_tr_avg = v_tr_avg
   node_avg ->v_tr_var = v_tr_var
   node_avg ->wspd_avg = wspd_avg
   node_avg ->wspd_var = wspd_var
   print("Windspeed and vectors")
   delete([/u_tr,u_tr_avg,u_tr_var,v_tr,v_tr_avg,v_tr_var,wspd,wspd_avg,wspd_var/])

  ;; Pressure at surface
   PSFC = new((/dim_files,dim_sn,dim_we/),"float")
   SLP = new((/dim_files,dim_sn,dim_we/),"float")
   SLP_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     PSFC(f,:,:) = wrf->PSFC
     SLP(f,:,:) = wrf->SLP
     SLP_anom(f,:,:) = wrf->SLP_anom
     delete(wrf)
   end do
   PSFC_avg = dim_avg_n_Wrap(PSFC,0)
   PSFC_var = dim_variance_n_Wrap(PSFC,0)
   SLP_avg = dim_avg_n_Wrap(SLP,0)
   SLP_var = dim_variance_n_Wrap(SLP,0)
   SLP_anom_avg = dim_avg_n_Wrap(SLP_anom,0)
   SLP_anom_var = dim_variance_n_Wrap(SLP_anom,0)
   node_avg ->PSFC_avg = PSFC_avg
   node_avg ->PSFC_var = PSFC_var
   node_avg ->SLP_avg = SLP_avg
   node_avg ->SLP_var = SLP_var
   node_avg ->SLP_anom_avg = SLP_anom_avg
   node_avg ->SLP_anom_var = SLP_anom_var
   print("Surface Pressure and Sea level pressure")
   delete([/PSFC,SLP,PSFC_avg,PSFC_var,SLP_avg,SLP_var,SLP_anom,SLP_anom_avg,SLP_anom_var/])

  ;; Temperatures
   T = new((/dim_files,dim_sn,dim_we/),"float")
   TSK = new((/dim_files,dim_sn,dim_we/),"float")
   Tgrad = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     T(f,:,:) = wrf->T
     TSK(f,:,:) = wrf->TSK
     Tgrad(f,:,:) = wrf->Tgrad
     delete(wrf)
   end do
   ; get averages and variances
   T_avg = dim_avg_n_Wrap(T,0)
   TSK_avg = dim_avg_n_Wrap(TSK,0)
   Tgrad_avg = dim_avg_n_Wrap(Tgrad,0)
   T_var = dim_variance_n_Wrap(T,0)
   TSK_var = dim_variance_n_Wrap(TSK,0)
   Tgrad_var = dim_variance_n_Wrap(Tgrad,0)
   ; write to node average file
   node_avg ->T_avg = T_avg
   node_avg ->T_var = T_var
   node_avg ->TSK_avg = TSK_avg
   node_avg ->TSK_var = TSK_var
   node_avg ->Tgrad_avg = Tgrad_avg
   node_avg ->Tgrad_var = Tgrad_var
   print("Temperatures")
   delete([/T,T_avg,T_var,TSK,TSK_avg,TSK_var,Tgrad,Tgrad_avg,Tgrad_var/])

  ;; Temperature anomalies
   T_anom  = new((/dim_files,dim_sn,dim_we/),"float")
   TSK_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     T_anom(f,:,:)  = wrf->T_anom
     TSK_anom(f,:,:) = wrf->TSK_anom
     delete(wrf)
   end do
   ; get averages and variances
   T_anom_avg = dim_avg_n_Wrap(T_anom,0)
   TSK_anom_avg = dim_avg_n_Wrap(TSK_anom,0)
   T_anom_var = dim_variance_n_Wrap(T_anom,0)
   TSK_anom_var = dim_variance_n_Wrap(TSK_anom,0)
   ; write to node average file
   node_avg ->T_anom_avg = T_anom_avg
   node_avg ->T_anom_var = T_anom_var
   node_avg ->TSK_anom_avg = TSK_anom_avg
   node_avg ->TSK_anom_var = TSK_anom_var
   print("Temperature anomalies")
   delete([/T_anom,T_anom_avg,T_anom_var,TSK_anom,TSK_anom_avg,TSK_anom_var/])

  ;; Moisture
   Q = new((/dim_files,dim_sn,dim_we/),"float")
   QS = new((/dim_files,dim_sn,dim_we/),"float")
   Qgrad = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     Q(f,:,:) = wrf->Q
     QS(f,:,:) = wrf->QS
     Qgrad(f,:,:) = wrf->Qgrad
     delete(wrf)
   end do
   ; get averages and variances
   Q_avg = dim_avg_n_Wrap(Q,0)
   QS_avg = dim_avg_n_Wrap(QS,0)
   Qgrad_avg = dim_avg_n_Wrap(Qgrad,0)
   Q_var = dim_variance_n_Wrap(Q,0)
   QS_var = dim_variance_n_Wrap(QS,0)
   Qgrad_var = dim_variance_n_Wrap(Qgrad,0)
   ; write to node average file
   node_avg ->Q_avg = Q_avg
   node_avg ->Q_var = Q_var
   node_avg ->QS_avg = QS_avg
   node_avg ->QS_var = QS_var
   node_avg ->Qgrad_avg = Qgrad_avg
   node_avg ->Qgrad_var = Qgrad_var
   print("Moisture")
   delete([/Q,Q_avg,Q_var,QS,QS_avg,QS_var,Qgrad,Qgrad_avg,Qgrad_var/])

  ;; Moisture anomalies
   Q_anom  = new((/dim_files,dim_sn,dim_we/),"float")
   QS_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     Q_anom(f,:,:)  = wrf->Q_anom
     QS_anom(f,:,:) = wrf->QS_anom
     delete(wrf)
   end do
   ; get averages and variances
   Q_anom_avg = dim_avg_n_Wrap(Q_anom,0)
   QS_anom_avg = dim_avg_n_Wrap(QS_anom,0)
   Q_anom_var = dim_variance_n_Wrap(Q_anom,0)
   QS_anom_var = dim_variance_n_Wrap(QS_anom,0)
   ; write to node average file
   node_avg ->Q_anom_avg = Q_anom_avg
   node_avg ->Q_anom_var = Q_anom_var
   node_avg ->QS_anom_avg = QS_anom_avg
   node_avg ->QS_anom_var = QS_anom_var
   print("Moisture anomalies")
   delete([/Q_anom,Q_anom_avg,Q_anom_var,QS_anom,QS_anom_avg,QS_anom_var/])
 
  n = n + 1
  ;; delete variables to use again
  delete([/fout_node,node_avg,dim_files,node_files,dateindices,files_sub/])

 end do
end do
delete(mon)
end do
;;;;;;;;;;;;;;;;;;;;;; END script
end
