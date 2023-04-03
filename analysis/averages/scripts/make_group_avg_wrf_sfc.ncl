;***************************************
; PROGRAM DESCRIPTION: This script creates group averages of WRF data
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
ngroup = 8  ; 8 groups total. They're specified below
fout_string = "199011_201003.wrf.sfc"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations")
;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/7x_5y_files/"
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

fill = new((/1/),"float")
n = 0
;;;;;;;;;
; calculate Node averages for wrf variables
;;;;;;;;;;
; loop through each node
do g = 0, ngroup - 1
  g1 = g+1
  print("Group: "+g1)
  ; For each group, set the node values to load in
  ; group1: Nodes("0,0" "1,0" "2,0" "0,1" "1,1" "2,1" "1,2" "2,2")
  if (g .eq. 0) then
    dateindices = ind((vis(:,0).eq.0.and.vis(:,1).eq.0).or.(vis(:,0).eq.1.and.vis(:,1).eq.0).or.(vis(:,0).eq.2.and.vis(:,1).eq.0).or.(vis(:,0).eq.0.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.1).or.(vis(:,0).eq.2.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.2).or.(vis(:,0).eq.2.and.vis(:,1).eq.2))
  end if
  ; group2: Nodes("3,0" "4,0" "3,1" "4,1" "3,2")
  if (g .eq. 1) then
    dateindices = ind((vis(:,0).eq.3.and.vis(:,1).eq.0).or.(vis(:,0).eq.4.and.vis(:,1).eq.0).or.(vis(:,0).eq.3.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.1).or.(vis(:,0).eq.3.and.vis(:,1).eq.2))
  end if
  ; group3: Nodes("5,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.2).or.(vis(:,0).eq.5.and.vis(:,1).eq.2))
  end if
  ; group4: Nodes("5,0" "6,0" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.1).or.(vis(:,0).eq.6.and.vis(:,1).eq.2))
  end if
  ; group5: Nodes("0,2" "0,3" "1,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices = ind((vis(:,0).eq.0.and.vis(:,1).eq.2).or.(vis(:,0).eq.0.and.vis(:,1).eq.3).or.(vis(:,0).eq.1.and.vis(:,1).eq.3).or.(vis(:,0).eq.0.and.vis(:,1).eq.4).or.(vis(:,0).eq.1.and.vis(:,1).eq.4))
  end if
  ; group6: Nodes("2,3" "3,3" "2,4")
  if (g .eq. 5) then
    dateindices = ind((vis(:,0).eq.2.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.3).or.(vis(:,0).eq.2.and.vis(:,1).eq.4))
  end if
  ; group7: Nodes("4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices = ind((vis(:,0).eq.4.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.4).or.(vis(:,0).eq.4.and.vis(:,1).eq.4))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.3).or.(vis(:,0).eq.6.and.vis(:,1).eq.3).or.(vis(:,0).eq.5.and.vis(:,1).eq.4).or.(vis(:,0).eq.6.and.vis(:,1).eq.4))
  end if

  if (.not.all(ismissing(dateindices))) then
    files_sub = files(dateindices)
  else
    print("All files missing for node")
  end if

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
   fout_node = "group_"+g1+"_"+fout_string
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
;;;;;;;;;;;;;;;;;;;;;; END script
end
