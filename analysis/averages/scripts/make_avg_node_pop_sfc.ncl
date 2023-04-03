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
nx_input = "4"
ny_input = "3"
fout_string = "199011_201003.pop.sfc"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations by month and persistence")
;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
infile = dir+nx_input+"x_"+ny_input+"y_wrf_199011_201003_dates_persistence.txt"
data = asciiread(infile,-1,"string")
ndates = dimsizes(data)
nx = new((/ndates/),"string")
ny = new((/ndates/),"string")
yy = new((/ndates/),"string")
mm = new((/ndates/),"string")
dd = new((/ndates/),"string")
ng = new((/ndates/),"string")
nne = new((/ndates/),"string")
ned = new((/ndates/),"string")
gne = new((/ndates/),"string")
ged = new((/ndates/),"string")
; load everything as characters for now, will convert to string as necessary
t = 0
do t=0, ndates -1
  dum = stringtochar(data(t))
  nx(t) = chartostring(dum(0))
  ny(t) = chartostring(dum(2))
  ng(t) = chartostring(dum(19))
  yy(t) = chartostring(dum(4:7))
  mm(t) = chartostring(dum(9:10))
  dd(t) = chartostring(dum(12:13))
  nne(t) = chartostring(dum(15))
  ned(t) = chartostring(dum(17))
  gne(t) = chartostring(dum(21))
  ged(t) = chartostring(dum(23))
  delete(dum)
end do

;;;;;;;;;;
; Calculate averages data for filters
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node
; get arrays of months/persistences to loop through
months = (/"11","12","01","02","03","xx"/)
persist = (/"1","2","3","4","5","6","7","x"/)
nm = dimsizes(months)
np = dimsizes(persist)

; create filenames array
files = new((/ndates/),string)
files = "/vardar/data5/duvivier/SOM-RASM/analysis/surface_files/pop_sfc_files/pop."+yy+"-"+mm+"-"+dd+".sfc.green.nc"

n = 0
;;;;;;;;;
; calculate Node averages for pop variables by month
;;;;;;;;;;
; loop through each month
do m = 0, nm -1
mon = months(m)
; loop through each persistence
do p = 0, np -1
per = persist(p)
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   ; Get array of dates based on the month, persistence, and node
   print("node: "+x+","+y+" and month "+mon)
   ; Create new file that corresponds to this node for averages/variances
   fout_node = "node_"+x+"x_"+y+"y_month-"+mon+"_persist-"+per+"d_"+fout_string
   node_avg = addfile("./"+fout_node+".nc","c")

   ; Make loop to calculate averages regardless of persistence and month
   if (mon .eq. "xx")then
     if (per .eq. "x")then
       dateindices = ind((nx.eq.x.and.ny.eq.y))
     else
       dateindices = ind((ned.eq.per).and.(nx.eq.x.and.ny.eq.y)) 
     end if
   else     
     dateindices = ind((mm.eq.mon).and.(ned.eq.per).and.(nx.eq.x.and.ny.eq.y))
   end if

  ; Load files that correspond to this node
   if (.not.all(ismissing(dateindices))) then
     files_sub = files(dateindices)
   else
     print("All files missing for node")
   end if
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; fields that do not need to be averaged
   geo = addfile(files_sub(0),"r")
   TLAT = geo->TLAT
   TLONG = geo->TLONG
   TAREA = geo->TAREA
   dims = dimsizes(TAREA)
   dim_sn = dims(0)
   dim_we = dims(1)

  ; write to new average file
   node_avg ->TLAT = TLAT
   print("latitude")
   node_avg ->TLONG = TLONG
   print("longitude") 
   node_avg ->TAREA = TAREA
   print("Terrain height")
   delete([/geo,TLAT,TLONG,TAREA,dims/])

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data
  ; Go through each type of surface variable and calculate average and variance

  ;; Sea Ice
   ice_frac = new((/dim_files,dim_sn,dim_we/),"float")
   ice_thick = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     ice_frac(f,:,:) = pop->ice_frac
     ice_thick(f,:,:) = pop->ice_thick
     delete(pop)
   end do
   ; get averages and variances
   ice_frac_avg = dim_avg_n_Wrap(ice_frac,0)
   ice_thick_avg = dim_avg_n_Wrap(ice_thick,0)
   ice_frac_var = dim_variance_n_Wrap(ice_frac,0)
   ice_thick_var = dim_variance_n_Wrap(ice_thick,0)
   ice_frac_avg!0 = "nlat"
   ice_frac_avg!1 = "nlon"
   copy_VarCoords(ice_frac_avg, ice_frac_var)
   copy_VarCoords(ice_frac_avg, ice_thick_avg)
   copy_VarCoords(ice_frac_avg, ice_thick_var)
   ; write to node average file
   node_avg ->ice_frac_avg = ice_frac_avg
   node_avg ->ice_frac_var = ice_frac_var
   node_avg ->ice_thick_avg = ice_thick_avg
   node_avg ->ice_thick_var = ice_thick_var
   print("Sea ice")
   delete([/ice_frac,ice_frac_avg,ice_frac_var,ice_thick,ice_thick_avg,ice_thick_var/])

  ;; Windstress curl
   WSC = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     WSC(f,:,:) = pop->WSC
     delete(pop)
   end do
   ; get averages and variances
   WSC_avg = dim_avg_n_Wrap(WSC,0)
   WSC_var = dim_variance_n_Wrap(WSC,0)
   ; write to node average file
   node_avg ->WSC_avg = WSC_avg
   node_avg ->WSC_var = WSC_var
   print("Wind stress curl")
   delete([/WSC,WSC_avg,WSC_var/])

  ;; Sea Surface Height
   SSH = new((/dim_files,dim_sn,dim_we/),"float")
   SSH_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SSH(f,:,:) = pop->SSH
     SSH_anom(f,:,:) = pop->SSH_anom
     delete(pop)
   end do
   ; get averages and variances
   SSH_avg = dim_avg_n_Wrap(SSH,0)
   SSH_var = dim_variance_n_Wrap(SSH,0)
   SSH_anom_avg = dim_avg_n_Wrap(SSH_anom,0)
   SSH_anom_var = dim_variance_n_Wrap(SSH_anom,0)
   ; write to node average file
   node_avg ->SSH_avg = SSH_avg
   node_avg ->SSH_var = SSH_var
   node_avg ->SSH_anom_avg = SSH_anom_avg
   node_avg ->SSH_anom_var = SSH_anom_var
   print("SSH")
   delete([/SSH,SSH_avg,SSH_var,SSH_anom,SSH_anom_avg,SSH_anom_var/])

  ;; Sea Surface Temperature
   SST = new((/dim_files,dim_sn,dim_we/),"float")
   SST_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SST(f,:,:) = pop->SST
     SST_anom(f,:,:) = pop->SST_anom
     delete(pop)
   end do
   ; get averages and variances
   SST_avg = dim_avg_n_Wrap(SST,0)
   SST_var = dim_variance_n_Wrap(SST,0)
   SST_anom_avg = dim_avg_n_Wrap(SST_anom,0)
   SST_anom_var = dim_variance_n_Wrap(SST_anom,0)
   ; write to node average file
   node_avg ->SST_avg = SST_avg
   node_avg ->SST_var = SST_var
   node_avg ->SST_anom_avg = SST_anom_avg
   node_avg ->SST_anom_var = SST_anom_var
   print("SST")
   delete([/SST,SST_avg,SST_var,SST_anom,SST_anom_avg,SST_anom_var/])

  ;; Sea Surface Salinity
   SSS = new((/dim_files,dim_sn,dim_we/),"float")
   SSS_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SSS(f,:,:) = pop->SSS
     SSS_anom(f,:,:) = pop->SSS_anom
     delete(pop)
   end do
   ; get averages and variances
   SSS_avg = dim_avg_n_Wrap(SSS,0)
   SSS_var = dim_variance_n_Wrap(SSS,0)
   SSS_anom_avg = dim_avg_n_Wrap(SSS_anom,0)
   SSS_anom_var = dim_variance_n_Wrap(SSS_anom,0)
   ; write to node average file
   node_avg ->SSS_avg = SSS_avg
   node_avg ->SSS_var = SSS_var
   node_avg ->SSS_anom_avg = SSS_anom_avg
   node_avg ->SSS_anom_var = SSS_anom_var
   print("SSS")
   delete([/SSS,SSS_avg,SSS_var,SSS_anom,SSS_anom_avg,SSS_anom_var/])

  ;; Sea Surface Potential Density
   SPD = new((/dim_files,dim_sn,dim_we/),"float")
   SPD_anom = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SPD(f,:,:) = pop->SPD
     SPD_anom(f,:,:) = pop->SPD_anom
     delete(pop)
   end do
   ; get averages and variances
   SPD_avg = dim_avg_n_Wrap(SPD,0)
   SPD_var = dim_variance_n_Wrap(SPD,0)
   SPD_anom_avg = dim_avg_n_Wrap(SPD_anom,0)
   SPD_anom_var = dim_variance_n_Wrap(SPD_anom,0)
   ; write to node average file
   node_avg ->SPD_avg = SPD_avg
   node_avg ->SPD_var = SPD_var
   node_avg ->SPD_anom_avg = SPD_anom_avg
   node_avg ->SPD_anom_var = SPD_anom_var
   print("SPD")
   delete([/SPD,SPD_avg,SPD_var,SPD_anom,SPD_anom_avg,SPD_anom_var/])

  ;; Mixed Layer Depth
   HMXL = new((/dim_files,dim_sn,dim_we/),"float")
   HMXL_anom = new((/dim_files,dim_sn,dim_we/),"float")
   HMXL_pcnt = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     HMXL(f,:,:) = pop->HMXL
     HMXL_anom(f,:,:) = pop->HMXL_anom
     HMXL_pcnt(f,:,:) = pop->HMXL_pcnt
     delete(pop)
   end do
   ; get averages and variances
   HMXL_avg = dim_avg_n_Wrap(HMXL,0)
   HMXL_var = dim_variance_n_Wrap(HMXL,0)
   HMXL_anom_avg = dim_avg_n_Wrap(HMXL_anom,0)
   HMXL_anom_var = dim_variance_n_Wrap(HMXL_anom,0)
   HMXL_pcnt_avg = dim_avg_n_Wrap(HMXL_pcnt,0)
   HMXL_pcnt_var = dim_variance_n_Wrap(HMXL_pcnt,0)
   ; write to node average file
   node_avg ->HMXL_avg = HMXL_avg
   node_avg ->HMXL_var = HMXL_var
   node_avg ->HMXL_anom_avg = HMXL_anom_avg
   node_avg ->HMXL_anom_var = HMXL_anom_var
   node_avg ->HMXL_pcnt_avg = HMXL_pcnt_avg
   node_avg ->HMXL_pcnt_var = HMXL_pcnt_var
   print("HMXL")
   delete([/HMXL,HMXL_avg,HMXL_var,HMXL_anom,HMXL_anom_avg,HMXL_anom_var,HMXL_pcnt,HMXL_pcnt_avg, HMXL_pcnt_var/])

  ;; Net flux
   flux_net = new((/dim_files,dim_sn,dim_we/),"float")
   SHF = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     flux_net(f,:,:) = pop->flux_net
     SHF(f,:,:) = pop->SHF
     delete(pop)
   end do
   ; get averages and variances
   flux_net_avg = dim_avg_n_Wrap(flux_net,0)
   flux_net_var = dim_variance_n_Wrap(flux_net,0)
   SHF_avg = dim_avg_n_Wrap(SHF,0)
   SHF_var = dim_variance_n_Wrap(SHF,0)
   ; write to node average file
   node_avg ->flux_net_avg = flux_net_avg
   node_avg ->flux_net_var = flux_net_var
   node_avg ->SHF_avg = SHF_avg
   node_avg ->SHF_var = SHF_var
   print("Net Surface Flux")
   delete([/flux_net,flux_net_avg,flux_net_var,SHF,SHF_avg,SHF_var/])

  ;; Net Turbulent flux
   Turb_net = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Turb_net(f,:,:) = pop->Turb_net
     delete(pop)
   end do
   ; get averages and variances
   Turb_net_avg = dim_avg_n_Wrap(Turb_net,0)
   Turb_net_var = dim_variance_n_Wrap(Turb_net,0)
   ; write to node average file
   node_avg ->Turb_net_avg = Turb_net_avg
   node_avg ->Turb_net_var = Turb_net_var
   print("Net Turbulent Flux")
   delete([/Turb_net,Turb_net_avg,Turb_net_var/])

  ;; Sensible Heat Flux
   SH = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SH(f,:,:) = pop->SH
     delete(pop)
   end do
   ; get averages and variances
   SH_avg = dim_avg_n_Wrap(SH,0)
   SH_var = dim_variance_n_Wrap(SH,0)
   ; write to node average file
   node_avg ->SH_avg = SH_avg
   node_avg ->SH_var = SH_var
   print("Sensible Heat Flux")
   delete([/SH,SH_avg,SH_var/])

  ;; Latent Heat Flux
   LH = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     LH(f,:,:) = pop->LH
     delete(pop)
   end do
   ; get averages and variances
   LH_avg = dim_avg_n_Wrap(LH,0)
   LH_var = dim_variance_n_Wrap(LH,0)
   LH_avg!0 = "nlat"
   LH_avg!1 = "nlon"
   copy_VarCoords(LH_avg,LH_var)
   ; write to node average file
   node_avg ->LH_avg = LH_avg
   node_avg ->LH_var = LH_var
   print("Latent Heat Flux")
   delete([/LH,LH_avg,LH_var/])

  ;; Net Radiative flux
   Rad_net = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Rad_net(f,:,:) = pop->Rad_net
     delete(pop)
   end do
   ; get averages and variances
   Rad_net_avg = dim_avg_n_Wrap(Rad_net,0)
   Rad_net_var = dim_variance_n_Wrap(Rad_net,0)
   ; write to node average file
   node_avg ->Rad_net_avg = Rad_net_avg
   node_avg ->Rad_net_var = Rad_net_var
   print("Net Radiative Flux")
   delete([/Rad_net,Rad_net_avg,Rad_net_var/])

  ;; Net Shortwave flux
   SW_net = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SW_net(f,:,:) = pop->SW_net
     delete(pop)
   end do
   ; get averages and variances
   SW_net_avg = dim_avg_n_Wrap(SW_net,0)
   SW_net_var = dim_variance_n_Wrap(SW_net,0)
   ; write to node average file
   node_avg ->SW_net_avg = SW_net_avg
   node_avg ->SW_net_var = SW_net_var
   print("Net shortwave flux")
   delete([/SW_net,SW_net_avg,SW_net_var/])

  ;; Net longwave flux
   LW_net = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     LW_net(f,:,:) = pop->LW_net
     delete(pop)
   end do
   ; get averages and variances
   LW_net_avg = dim_avg_n_Wrap(LW_net,0)
   LW_net_var = dim_variance_n_Wrap(LW_net,0)
   ; write to node average file
   node_avg ->LW_net_avg = LW_net_avg
   node_avg ->LW_net_var = LW_net_var
   print("Net longwave flux")
   delete([/LW_net,LW_net_avg,LW_net_var/])

  ;; Longwave down flux
   LW_dn = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     LW_dn(f,:,:) = pop->LW_dn
     delete(pop)
   end do
   ; get averages and variances
   LW_dn_avg = dim_avg_n_Wrap(LW_dn,0)
   LW_dn_var = dim_variance_n_Wrap(LW_dn,0)
   ; write to node average file
   node_avg ->LW_dn_avg = LW_dn_avg
   node_avg ->LW_dn_var = LW_dn_var
   print("Longwave down flux")
   delete([/LW_dn,LW_dn_avg,LW_dn_var/])

  ;; Longwave up flux
   LW_up = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     LW_up(f,:,:) = pop->LW_up
     delete(pop)
   end do
   ; get averages and variances
   LW_up_avg = dim_avg_n_Wrap(LW_up,0)
   LW_up_var = dim_variance_n_Wrap(LW_up,0)
   ; write to node average file
   node_avg ->LW_up_avg = LW_up_avg
   node_avg ->LW_up_var = LW_up_var
   print("Longwave up flux")
   delete([/LW_up,LW_up_avg,LW_up_var/])

  ;; Buoyancy flux
   Buoy_flux = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux(f,:,:) = pop->Buoy_flux
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_avg = dim_avg_n_Wrap(Buoy_flux,0)
   Buoy_flux_var = dim_variance_n_Wrap(Buoy_flux,0)
   ; write to node average file
   node_avg ->Buoy_flux_avg = Buoy_flux_avg
   node_avg ->Buoy_flux_var = Buoy_flux_var
   print("Buoyancy flux")
   delete([/Buoy_flux,Buoy_flux_avg,Buoy_flux_var/])

  ;; Buoyancy flux - thermal
   Buoy_flux_thermal = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_thermal(f,:,:) = pop->Buoy_flux_thermal
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_thermal_avg = dim_avg_n_Wrap(Buoy_flux_thermal,0)
   Buoy_flux_thermal_var = dim_variance_n_Wrap(Buoy_flux_thermal,0)
   ; write to node average file
   node_avg ->Buoy_flux_thermal_avg = Buoy_flux_thermal_avg
   node_avg ->Buoy_flux_thermal_var = Buoy_flux_thermal_var
   print("Buoyancy flux_thermal")
   delete([/Buoy_flux_thermal,Buoy_flux_thermal_avg,Buoy_flux_thermal_var/])

  ;; Buoyancy flux - haline
   Buoy_flux_haline = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_haline(f,:,:) = pop->Buoy_flux_haline
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_haline_avg = dim_avg_n_Wrap(Buoy_flux_haline,0)
   Buoy_flux_haline_var = dim_variance_n_Wrap(Buoy_flux_haline,0)
   ; write to node average file
   node_avg ->Buoy_flux_haline_avg = Buoy_flux_haline_avg
   node_avg ->Buoy_flux_haline_var = Buoy_flux_haline_var
   print("Buoyancy flux_haline")
   delete([/Buoy_flux_haline,Buoy_flux_haline_avg,Buoy_flux_haline_var/])

  ;; Buoyancy flux - shortwave
   Buoy_flux_SW = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_SW(f,:,:) = pop->Buoy_flux_SW
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_SW_avg = dim_avg_n_Wrap(Buoy_flux_SW,0)
   Buoy_flux_SW_var = dim_variance_n_Wrap(Buoy_flux_SW,0)
   ; write to node average file
   node_avg ->Buoy_flux_SW_avg = Buoy_flux_SW_avg
   node_avg ->Buoy_flux_SW_var = Buoy_flux_SW_var
   print("Buoyancy flux_SW")
   delete([/Buoy_flux_SW,Buoy_flux_SW_avg,Buoy_flux_SW_var/])

  ;; Buoyancy flux - longwave
   Buoy_flux_LW = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_LW(f,:,:) = pop->Buoy_flux_LW
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_LW_avg = dim_avg_n_Wrap(Buoy_flux_LW,0)
   Buoy_flux_LW_var = dim_variance_n_Wrap(Buoy_flux_LW,0)
   ; write to node average file
   node_avg ->Buoy_flux_LW_avg = Buoy_flux_LW_avg
   node_avg ->Buoy_flux_LW_var = Buoy_flux_LW_var
   print("Buoyancy flux_LW")
   delete([/Buoy_flux_LW,Buoy_flux_LW_avg,Buoy_flux_LW_var/])

  ;; Buoyancy flux - sensible heat
   Buoy_flux_SH = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_SH(f,:,:) = pop->Buoy_flux_SH
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_SH_avg = dim_avg_n_Wrap(Buoy_flux_SH,0)
   Buoy_flux_SH_var = dim_variance_n_Wrap(Buoy_flux_SH,0)
   ; write to node average file
   node_avg ->Buoy_flux_SH_avg = Buoy_flux_SH_avg
   node_avg ->Buoy_flux_SH_var = Buoy_flux_SH_var
   print("Buoyancy flux_SH")
   delete([/Buoy_flux_SH,Buoy_flux_SH_avg,Buoy_flux_SH_var/])

  ;; Buoyancy flux - latent heat
   Buoy_flux_LH = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_LH(f,:,:) = pop->Buoy_flux_LH
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_LH_avg = dim_avg_n_Wrap(Buoy_flux_LH,0)
   Buoy_flux_LH_var = dim_variance_n_Wrap(Buoy_flux_LH,0)
   ; write to node average file
   node_avg ->Buoy_flux_LH_avg = Buoy_flux_LH_avg
   node_avg ->Buoy_flux_LH_var = Buoy_flux_LH_var
   print("Buoyancy flux_LH")
   delete([/Buoy_flux_LH,Buoy_flux_LH_avg,Buoy_flux_LH_var/])

  ;; Buoyancy flux - Evaporation
   Buoy_flux_EVAP = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_EVAP(f,:,:) = pop->Buoy_flux_EVAP
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_EVAP_avg = dim_avg_n_Wrap(Buoy_flux_EVAP,0)
   Buoy_flux_EVAP_var = dim_variance_n_Wrap(Buoy_flux_EVAP,0)
   ; write to node average file
   node_avg ->Buoy_flux_EVAP_avg = Buoy_flux_EVAP_avg
   node_avg ->Buoy_flux_EVAP_var = Buoy_flux_EVAP_var
   print("Buoyancy flux_EVAP")
   delete([/Buoy_flux_EVAP,Buoy_flux_EVAP_avg,Buoy_flux_EVAP_var/])

  ;; Buoyancy flux - Precipitation
   Buoy_flux_PREC = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     Buoy_flux_PREC(f,:,:) = pop->Buoy_flux_PREC
     delete(pop)
   end do
   ; get averages and variances
   Buoy_flux_PREC_avg = dim_avg_n_Wrap(Buoy_flux_PREC,0)
   Buoy_flux_PREC_var = dim_variance_n_Wrap(Buoy_flux_PREC,0)
   ; write to node average file
   node_avg ->Buoy_flux_PREC_avg = Buoy_flux_PREC_avg
   node_avg ->Buoy_flux_PREC_var = Buoy_flux_PREC_var
   print("Buoyancy flux_PREC")
   delete([/Buoy_flux_PREC,Buoy_flux_PREC_avg,Buoy_flux_PREC_var/])

  ;; Precipitation
   PREC = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     PREC(f,:,:) = pop->PREC
     delete(pop)
   end do
   ; get averages and variances
   PREC_avg = dim_avg_n_Wrap(PREC,0)
   PREC_var = dim_variance_n_Wrap(PREC,0)
   ; write to node average file
   node_avg ->PREC_avg = PREC_avg
   node_avg ->PREC_var = PREC_var
   print("Precipitation")
   delete([/PREC,PREC_avg,PREC_var/])

  ;; Evaporation
   EVAP = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     EVAP(f,:,:) = pop->EVAP
     delete(pop)
   end do
   ; get averages and variances
   EVAP_avg = dim_avg_n_Wrap(EVAP,0)
   EVAP_var = dim_variance_n_Wrap(EVAP,0)
   ; write to node average file
   node_avg ->EVAP_avg = EVAP_avg
   node_avg ->EVAP_var = EVAP_var
   print("Evaporation")
   delete([/EVAP,EVAP_avg,EVAP_var/])

;;;;;;;;;
; Lag variables
;;;;;;;;;;
   nlag = 8

;  ;; SST lag
;   SST_lag = new((/dim_files,nlag,dim_sn,dim_we/),"float")
;   f = 0
;   do f = 0,dim_files - 1
;     pop = addfile(files_sub(f),"r")
;     SST_lag(f,:,:,:) = pop->SST_lag
;     delete(pop)
;   end do
;   ; get averages and variances
;   SST_lag_avg = new((/nlag,dim_sn,dim_we/),"float") 
;   SST_lag_var = new((/nlag,dim_sn,dim_we/),"float")    
;   l = 0
;   do l = 0, nlag - 1
;     dum = SST_lag(:,l,:,:)
;     SST_lag_avg(l,:,:) = dim_avg_n_Wrap(dum,0)
;     SST_lag_var(l,:,:) = dim_variance_n_Wrap(dum,0)
;     delete(dum)
;   end do
;   SST_lag_avg!0 = "lag"
;   copy_VarCoords(SST_lag_avg, SST_lag_var)
;   ; write to node average file
;   node_avg ->SST_lag_avg = SST_lag_avg
;   node_avg ->SST_lag_var = SST_lag_var
;   print("SST lags")
;   delete([/SST_lag,SST_lag_avg,SST_lag_var/])

;  ;; SSS lag
;   SSS_lag = new((/dim_files,nlag,dim_sn,dim_we/),"float")
;   f = 0
;   do f = 0,dim_files - 1
;     pop = addfile(files_sub(f),"r")
;     SSS_lag(f,:,:,:) = pop->SSS_lag
;     delete(pop)
;   end do
;   ; get averages and variances
;   SSS_lag_avg = new((/nlag,dim_sn,dim_we/),"float") 
;   SSS_lag_var = new((/nlag,dim_sn,dim_we/),"float")    
;   l = 0
;   do l = 0, nlag - 1
;     dum = SSS_lag(:,l,:,:)
;     SSS_lag_avg(l,:,:) = dim_avg_n_Wrap(dum,0)
;     SSS_lag_var(l,:,:) = dim_variance_n_Wrap(dum,0)
;     delete(dum)
;   end do
;   SSS_lag_avg!0 = "lag"
;   copy_VarCoords(SSS_lag_avg, SSS_lag_var)
;   ; write to node average file
;   node_avg ->SSS_lag_avg = SSS_lag_avg
;   node_avg ->SSS_lag_var = SSS_lag_var
;   print("SSS lags")
;   delete([/SSS_lag,SSS_lag_avg,SSS_lag_var/])

  ;; SPD lag
   SPD_lag = new((/dim_files,nlag,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     SPD_lag(f,:,:,:) = pop->SPD_lag
     delete(pop)
   end do
   ; get averages and variances
   SPD_lag_avg = new((/nlag,dim_sn,dim_we/),"float") 
   SPD_lag_var = new((/nlag,dim_sn,dim_we/),"float")    
   l = 0
   do l = 0, nlag - 1
     dum = SPD_lag(:,l,:,:)
     SPD_lag_avg(l,:,:) = dim_avg_n_Wrap(dum,0)
     SPD_lag_var(l,:,:) = dim_variance_n_Wrap(dum,0)
     delete(dum)
   end do
   SPD_lag_avg!0 = "lag"
   copy_VarCoords(SPD_lag_avg, SPD_lag_var)
   ; write to node average file
   node_avg ->SPD_lag_avg = SPD_lag_avg
   node_avg ->SPD_lag_var = SPD_lag_var
   print("SPD lags")
   delete([/SPD_lag,SPD_lag_avg,SPD_lag_var/])


  ;; HMXL lag
   HMXL_lag = new((/dim_files,nlag,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     HMXL_lag(f,:,:,:) = pop->HMXL_lag
     delete(pop)
   end do
   ; get averages and variances
   HMXL_lag_avg = new((/nlag,dim_sn,dim_we/),"float") 
   HMXL_lag_var = new((/nlag,dim_sn,dim_we/),"float")    
   l = 0
   do l = 0, nlag - 1
     dum = HMXL_lag(:,l,:,:)
     HMXL_lag_avg(l,:,:) = dim_avg_n_Wrap(dum,0)
     HMXL_lag_var(l,:,:) = dim_variance_n_Wrap(dum,0)
     delete(dum)
   end do
   HMXL_lag_avg!0 = "lag"
   copy_VarCoords(HMXL_lag_avg, HMXL_lag_var)
   ; write to node average file
   node_avg ->HMXL_lag_avg = HMXL_lag_avg
   node_avg ->HMXL_lag_var = HMXL_lag_var
   print("Mixed layer depth lags")
   delete([/HMXL_lag,HMXL_lag_avg,HMXL_lag_var/])

;;;;;;;;;
; Stability variables
;;;;;;;;;;
;   ndepth= 4

;  ;; CAPE
;   cape = new((/dim_files,ndepth,dim_sn,dim_we/),"float")
;   f = 0
;   do f = 0,dim_files - 1
;     pop = addfile(files_sub(f),"r")
;     cape(f,:,:,:) = pop->cape
;     delete(pop)
;   end do
;   ; get averages and variances
;   cape_avg = new((/ndepth,dim_sn,dim_we/),"float") 
;   cape_var = new((/ndepth,dim_sn,dim_we/),"float")    
;   d = 0
;   do d = 0, ndepth - 1
;     dum = cape(:,d,:,:)
;     cape_avg(d,:,:) = dim_avg_n_Wrap(dum,0)
;     cape_var(d,:,:) = dim_variance_n_Wrap(dum,0)
;     delete(dum)
;   end do
;   cape_avg!0 = "depth"
;   copy_VarCoords(cape_avg, cape_var)
;   ; write to node average file
;   node_avg ->cape_avg = cape_avg
;   node_avg ->cape_var = cape_var
;   print("CAPE")
;   delete([/cape,cape_avg,cape_var/])

;  ;; Stratification
;   strat = new((/dim_files,ndepth,dim_sn,dim_we/),"float")
;   f = 0
;   do f = 0,dim_files - 1
;     pop = addfile(files_sub(f),"r")
;     strat(f,:,:,:) = pop->strat
;     delete(pop)
;   end do
;   ; get averages and variances
;   strat_avg = new((/ndepth,dim_sn,dim_we/),"float") 
;   strat_var = new((/ndepth,dim_sn,dim_we/),"float")    
;   d = 0
;   do d = 0, ndepth - 1
;     dum = strat(:,d,:,:)
;     strat_avg(d,:,:) = dim_avg_n_Wrap(dum,0)
;     strat_var(d,:,:) = dim_variance_n_Wrap(dum,0)
;     delete(dum)
;   end do
;   strat_avg!0 = "depth"
;   copy_VarCoords(strat_avg, strat_var)
;   ; write to node average file
;   node_avg ->strat_avg = strat_avg
;   node_avg ->strat_var = strat_var
;   print("STRAT")
;   delete([/strat,strat_avg,strat_var/])

  n = n + 1
  ;; delete variables to use again
  delete([/fout_node,node_avg,dim_files,node_files,dateindices,files_sub/])

 end do
end do
delete(per)
end do
delete(mon)
end do
;;;;;;;;;;;;;;;;;;;;;; END script
end
