;***************************************
; PROGRAM DESCRIPTION: This script plots node or group
;                      average variables
; INPUT DATA: WRF or POP node or group average files
; OUTPUT DATA: Panel plot of node or group averages
; CREATOR: Alice DuVivier - January 2015
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  type = "node"
  varcode = "TAU"
  nx = "4"
  ny = "3"
  mon = "xx"   ; if passed as doing monthly average or not  
; to skip around to sections search for "NEXT"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all plots for "+varcode)

;;;;;;;;;;
; Variable details
;;;;;;;;;;
if (varcode.eq."WS")then
  vartitle = "eta0 wind speed"
  invar = "wspd"
  cmaptype = "wind"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."TAU")then
  vartitle = "surface wind stress"
  invar = "TAU"
  cmaptype = "stress"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SLP")then
  vartitle = "sea level pressure"
  invar = "SLP"
  cmaptype = "pressure"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."SLP_anom")then
  vartitle = "sea level pressure anomaly "
  invar = "SLP_anom"
  cmaptype = "pressure_anom"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."TSK")then
  vartitle = "sea surface temp"
  invar = "TSK"
  cmaptype = "temperature"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."TSK_anom")then
  vartitle = "sea surface temp anomaly "
  invar = "TSK_anom"
  cmaptype = "temperature_anom"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."T")then
  vartitle = "eta0 temp"
  invar = "T"
  cmaptype = "temperature"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."T_anom")then
  vartitle = "eta0 temp anomaly "
  invar = "T_anom"
  cmaptype = "temperature_anom"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."Tgrad")then
  vartitle = "temp gradient (sfc - eta0)"
  invar = "Tgrad"
  cmaptype = "temperature"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."QS")then
  vartitle = "sea surface mix ratio"
  invar = "QS"
  cmaptype = "moisture"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."QS_anom")then
  vartitle = "sea surface mix ratio anomaly "
  invar = "QS_anom"
  cmaptype = "moisture_anom"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."Q")then
  vartitle = "eta0 mix ratio"
  invar = "Q"
  cmaptype = "moisture"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."Q_anom")then
  vartitle = "eta0 mix ratio anomaly "
  invar = "Q_anom"
  cmaptype = "moisture_anom"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."Qgrad")then
  vartitle = "mix ratio gradient (sfc - eta0)"
  invar = "Qgrad"
  cmaptype = "moisture_grad"
  vartype = "2d"
  tag = "wrf"
end if
if (varcode.eq."NetFlx")then
  vartitle = "Net Surface Flux"
  invar = "flux_net"
  cmaptype = "flux_net"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."NetTrb")then
  vartitle = "Net Turbulent Surface Flux"
  invar = "Turb_net"
  cmaptype = "flux_net"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."NetRad")then
  vartitle = "Net Radiative Surface Flux"
  invar = "Rad_net"
  cmaptype = "flux_net"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."NetLW")then
  vartitle = "Net Longwave Radiative Surface Flux"
  invar = "LW_net"
  cmaptype = "flux_rad"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."NetSW")then
  vartitle = "Net Shortwave Radiative Surface Flux"
  invar = "SW_net"
  cmaptype = "flux_rad"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."LH")then
  vartitle = "Surface Latent Heat Flux"
  invar = "LH"
  cmaptype = "flux"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SH")then
  vartitle = "Surface Sensible Heat Flux"
  invar = "SH"
  cmaptype = "flux"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY")then
  vartitle = "Surface Buoyancy flux"
  invar = "Buoy_flux"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_T")then
  vartitle = "Surface Buoyancy flux - thermal term"
  invar = "Buoy_flux_thermal"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_H")then
  vartitle = "Surface Buoyancy flux - haline term"
  invar = "Buoy_flux_haline"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_SW")then
  vartitle = "Surface Buoyancy flux - shortwave component"
  invar = "Buoy_flux_SW"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_LW")then
  vartitle = "Surface Buoyancy flux - longwave component"
  invar = "Buoy_flux_LW"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_SH")then
  vartitle = "Surface Buoyancy flux - sensible heat component"
  invar = "Buoy_flux_SH"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_LH")then
  vartitle = "Surface Buoyancy flux - latent heat component"
  invar = "Buoy_flux_LH"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_PREC")then
  vartitle = "Surface Buoyancy flux - precipitation component"
  invar = "Buoy_flux_PREC"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."BUOY_EVAP")then
  vartitle = "Surface Buoyancy flux - evaporation component"
  invar = "Buoy_flux_EVAP"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."PREC")then
  vartitle = "Precipitation"
  invar = "PREC"
  cmaptype = "prec"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."EMP")then
  vartitle = "Evaporation - Precipitation"
  invar = "EVAP"
  cmaptype = "emp"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."EVAP")then
  vartitle = "Evaporation"
  invar = "EVAP"
  cmaptype = "evap"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."WSC")then
  vartitle = "Wind stress curl"
  invar = "WSC"
  cmaptype = "stresscurl"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."HMXL")then
  vartitle = "mixed layer depth"
  invar = "HMXL"
  cmaptype = "mld"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."HMXL_pcnt")then
  vartitle = "mixed layer depth anomaly as percent of mean mixed layer depth"
  invar = "HMXL_anom"
  cmaptype = "mld_pcnt"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."HMXL_anom")then
  vartitle = "mixed layer depth anomaly "
  invar = "HMXL_anom"
  cmaptype = "mld_anom"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SSH")then
  vartitle = "sea surface height"
  invar = "SSH"
  cmaptype = "height"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SST")then
  vartitle = "sea surface temp"
  invar = "SST"
  cmaptype = "temperature"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SST_anom")then
  vartitle = "sea surface temp anomaly "
  invar = "SST_anom"
  cmaptype = "temperature_anom2"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SSS")then
  vartitle = "sea surface salinity"
  invar = "SSS"
  cmaptype = "salinity"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SSS_anom")then
  vartitle = "sea surface salinity anomaly "
  invar = "SSS_anom"
  cmaptype = "salinity_anom"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SPD")then
  vartitle = "sea surface potential density"
  invar = "SPD"
  cmaptype = "pd"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."SPD_anom")then
  vartitle = "sea surface potential density anomaly "
  invar = "SPD_anom"
  cmaptype = "pd_anom"
  vartype = "2d"
  tag = "pop"
end if
if (varcode.eq."HMXL_1")then
  vartitle = "change in mixed layer depth - 1 day after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 0
  tag = "pop"
end if
if (varcode.eq."HMXL_2")then
  vartitle = "change in mixed layer depth - 2 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 1
  tag = "pop"
end if
if (varcode.eq."HMXL_3")then
  vartitle = "change in mixed layer depth - 3 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 2
  tag = "pop"
end if
if (varcode.eq."HMXL_5")then
  vartitle = "change in mixed layer depth - 5 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 3
  tag = "pop"
end if
if (varcode.eq."HMXL_7")then
  vartitle = "change in mixed layer depth - 7 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 4
  tag = "pop"
end if
if (varcode.eq."HMXL_14")then
  vartitle = "change in mixed layer depth - 14 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 5
  tag = "pop"
end if
if (varcode.eq."HMXL_21")then
  vartitle = "change in mixed layer depth - 21 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 6
  tag = "pop"
end if
if (varcode.eq."HMXL_28")then
  vartitle = "change in mixed layer depth - 28 days after"
  invar = "HMXL_lag"
  cmaptype = "mld_anom"
  vartype = "3d"
  level = 7
  tag = "pop"
end if

;;;;;;;;;;
; Contour intervals
;;;;;;;;;;
; NEXT
if (cmaptype.eq."wind") then
  cmin               = 0.0
  cmax               = 18.0
  clev               = 1.0
  stride             = 1                  
  plotlines          = False              
  spreadstart        = 2   ;2                  
  spreadend          = 129 ;18                 
  colormap           = "MPL_BuPu" ;"SOM_wind_table_mod"
end if
if (cmaptype.eq."stress")then
  cmin               = 0.0
  cmax               = 18.0
  clev               = 1.0
  stride             = 1                  
  plotlines          = False              
  spreadstart        = 2   ;2                  
  spreadend          = 129 ;18                 
  colormap           = "MPL_BuPu" ;"SOM_wind_table_mod"
end if
if (cmaptype.eq."pressure") then
  cmin               = 980.0
  cmax               = 1020.0
  clev               = 2.0
  stride             = 4                  
  plotlines          = False              
  spreadstart        = 2                  
  spreadend          = 74                 
  colormap           = "BlWhRe"
end if
if (cmaptype.eq."pressure_anom") then
  cmin               = -20.0
  cmax               = 20.0
  clev               = 2.0
  stride             = 2                  
  plotlines          = False              
  spreadstart        = 2                  
  spreadend          = 102                
  colormap           = "BlWhRe"
end if
if (cmaptype .eq."temperature")then
  cmin               = -10.0
  cmax               = 10.0
  clev               = 1.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 67
  spreadend          = 106
  colormap           = "temp64_anoms.dave"
end if
if (cmaptype .eq."temperature_anom")then
  cmin               = -6.0
  cmax               = 6.0
  clev               = 0.5
  stride             = 2.0
  plotlines           = False
  spreadstart        = 67
  spreadend          = 106
  colormap           = "temp64_anoms.dave"
end if
if (cmaptype .eq."temperature_anom2")then
  cmin               = -1.5
  cmax               = 1.5
  clev               = 0.1
  stride             = 2.0
  plotlines           = False
  spreadstart        = 67
  spreadend          = 106
  colormap           = "temp64_anoms.dave"
end if
if (cmaptype .eq."moisture")then
  cmin               = 0.0
  cmax               = 8.0
  clev               = 0.5
  stride             = 4.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 85
  colormap           = "BrownBlue_mod"
end if
if (cmaptype .eq."moisture_grad")then
  cmin               = 0
  cmax               = 3.25
  clev               = 0.25
  stride             = 2.0
  plotlines           = False
  spreadstart        = 42
  spreadend          = 85
  colormap           = "BrownBlue_mod"
end if
if (cmaptype .eq."moisture_anom")then
  cmin               = -1.0
  cmax               = 1.0
  clev               = 0.1
  stride             = 4.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 85
  colormap           = "BrownBlue_mod"
end if
if (cmaptype .eq."flux_net")then
  cmin               = 0.0
  cmax               = 500.0
  clev               = 25.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 127
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."flux")then
  cmin               = 0.0
  cmax               = 300.0
  clev               = 25.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 127
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."flux_rad")then
  cmin               = -100.0
  cmax               = 100.0
  clev               = 10.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."flux_b")then
  cmin               = -10.0
  cmax               = 10.0
  clev               = 1.0
  stride             = 2.0
  plotlines          = False
  spreadstart        = 2 ;127
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."prec")then
  cmin               = 0.0
  cmax               = 10.0
  clev               = 0.5
  stride             = 2.0
  plotlines          = False
  spreadstart        = 92
  spreadend          = 2
  colormap           = "BlWhOrRe-pop"
end if
if (cmaptype .eq."evap")then
  cmin               = 0.0
  cmax               = 10.0
  clev               = 0.5
  stride             = 2.0
  plotlines          = False
  spreadstart        = 96
  spreadend          = 186
  colormap           = "BlWhOrRe-pop"
end if
if (cmaptype .eq."emp")then
  cmin               = -15.0
  cmax               = 15.0
  clev               = 1.0
  stride             = 2.0
  plotlines          = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."stresscurl")then
  cmin               = -0.8
  cmax               = 0.8
  clev               = 0.1
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."mld")then
  cmin               = 0.0
  cmax               = 1000.0
  clev               = 50.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 104 ;2
  spreadend          = 208
  colormap           = "MLD"
end if
if (cmaptype .eq."mld_pcnt")then
  cmin               = -100.0
  cmax               = 100.0
  clev               = 10.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."mld_anom")then
  cmin               = -300.0
  cmax               = 300.0
  clev               = 30.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."salinity")then
  cmin               = 0.0345
  cmax               = 0.0350
  clev               = 0.0001
  stride             = 1.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 65
  colormap           = "cmp_b2r"
end if
if (cmaptype .eq."salinity_anom")then
  cmin               = -5.0
  cmax               = 5.0
  clev               = 0.5
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 65
  colormap           = "cmp_b2r"
end if
if (cmaptype .eq."pd")then
  cmin               = 1.0270
  cmax               = 1.0278
  clev               = 0.00002
  stride             = 1.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 65
  colormap           = "temp64_anoms.dave"
end if
if (cmaptype .eq."pd_anom")then
  cmin               = -12.0
  cmax               = 12.0
  clev               = 1.0
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."cape")then
  cmin               = 0.0
  cmax               = 2.0
  clev               = 0.2
  stride             = 2.0
  plotlines           = False
  spreadstart        = 124
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if
if (cmaptype .eq."strat")then
  cmin               = -0.5
  cmax               = 0.5
  clev               = 0.05
  stride             = 2.0
  plotlines           = False
  spreadstart        = 2 ;124
  spreadend          = 250
  colormap           = "BlueYellowRed_mod"
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in data from average files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
; set number of files to load and panels to plot
if (type .eq. "group")then
  npan = 8
  geofile = "group_1"
end if
if (type .eq. "node")then
  nx_node = stringtoint(nx)
  ny_node = stringtoint(ny)
  npan = nx_node*ny_node
  geofile = "node_0x_0y"
end if

; set data input directory and fin suffix
if (type .eq. "group")then
  dir = "/vardar/data5/duvivier/SOM-RASM/analysis/averages/"+type+"_avgs/"
end if
if (type .eq. "node")then
  dir = "/vardar/data5/duvivier/SOM-RASM/analysis/averages/"+nx+"x_"+ny+"y_"+type+"_avgs/"
end if
; set suffix based on if this is monthly sub data or not
if (mon .eq. "xx")then
  ; NOT monthly sub averages
  suffix = "_199011_201003."+tag
  suffix_wind = "_199011_201003.wrf"
  suffix_ice = "_199011_201003.pop"
else
  ; Monthly sub averages
  suffix = "_month-"+mon+"_199011_201003."+tag
  suffix_wind = "_month-"+mon+"_199011_201003.wrf"
  suffix_ice = "_month-"+mon+"_199011_201003.pop"
end if
; set outdir and fout names
outdir = "./"
fout   = varcode+"_"+type+"_avg"+suffix

; Load in lat/lon info for WRF or POP
if (tag .eq. "wrf")then
  geo = addfile(dir+geofile+suffix+".sfc.nc","r")
  lat2d = geo->lat
  lon2d = geo->lon
end if
if (tag .eq. "pop")then
  geo = addfile(dir+geofile+suffix+".sfc.nc","r")
  lat2d = geo->TLAT
  lon2d = geo->TLONG
end if
dims = dimsizes(lat2d)      ; get lat/lon dimensions
n_sn = dims(0)              ; get south/north points
n_we = dims(1)              ; get west/east points
delete([/geo,dims/])

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
; NEXT
; set invar for averages only
invar1 = invar+"_avg"

; create all-node array for node average variable
var1     = new((/npan,n_sn,n_we/),"float")
ndates   = new((/npan/),"integer")
fill = var1@_FillValue

; Load sea ice for masking
geo_p = addfile(dir+geofile+suffix_ice+".sfc.nc","r")
lat_p = geo_p->TLAT
lon_p = geo_p->TLONG
dims = dimsizes(lat_p)
n_sn_p = dims(0)
n_we_p = dims(1)
seaice = new((/npan,n_sn_p,n_we_p/),"float")
insea = "ice_frac_avg"
delete([/geo_p,dims,n_sn_p,n_we_p/]) 

; Load wind vectors for overlay
geo_w = addfile(dir+geofile+suffix_wind+".sfc.nc","r")
lat_w = geo_w->lat
lon_w = geo_w->lon
z_sfc = geo_w->Z_sfc
dims = dimsizes(lat_w)
n_sn_w = dims(0)
n_we_w = dims(1)
u_vect   = new((/npan,n_sn_w,n_we_w/),"float")
v_vect   = new((/npan,n_sn_w,n_we_w/),"float")
invar_u_vec = "u_tr_avg"
invar_v_vec = "v_tr_avg"
delete([/geo_w,dims,n_sn_w,n_we_w/])

; Load precip data if calculating E-P
if (varcode .eq. "EMP")then
  var2   = new((/npan,n_sn,n_we/),"float")
  invar2 = "PREC_avg"
end if
if (varcode .eq. "HMXL_pcnt")then
  var2   = new((/npan,n_sn,n_we/),"float")
  invar2 = "HMXL_avg"
end if

; Group loading
if (type .eq. "group") then
  n = 0
  do n = 0, npan - 1
    g1 = n+1
    print("Loading group "+g1)
    prefix = "group_"+g1
    f1 = addfile(dir+prefix+suffix+".sfc.nc","r")
    f2 = addfile(dir+prefix+suffix_ice+".sfc.nc","r")
    f3 = addfile(dir+prefix+suffix_wind+".sfc.nc","r")
    if (vartype .eq. "2d")then
      var1(n,:,:) = f1->$invar1$(:,:)
      if (varcode .eq. "EMP")then
        var2(n,:,:) = f1->$invar2$(:,:)
      end if
      if (varcode .eq. "HMXL_pcnt")then
      	var2(n,:,:) = f1->$invar2$(:,:)
      end if
    end if
    if (vartype .eq. "3d")then
      var1(n,:,:) = f1->$invar1$(level,:,:)
    end if
    ndates(n)   = f1->number_dates
    seaice(n,:,:) = f2->$insea$(:,:)
    u_vect(n,:,:) = f3->$invar_u_vec$(:,:)
    v_vect(n,:,:) = f3->$invar_v_vec$(:,:)
    delete([/prefix,f1,f2,f3,g1/])
  end do
  delete(n)
end if

; Node loading
if (type .eq. "node") then
  n = 0
  y = 0
  x = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      print("Loading node "+x+"x "+y+"y")
      prefix = "node_"+x+"x_"+y+"y"
      f1 = addfile(dir+prefix+suffix+".sfc.nc","r")
      f2 = addfile(dir+prefix+suffix_ice+".sfc.nc","r")
      f3 = addfile(dir+prefix+suffix_wind+".sfc.nc","r")
      if (vartype .eq. "2d")then
        var1(n,:,:) = f1->$invar1$(:,:)
      	if (varcode .eq. "EMP")then
           var2(n,:,:) = f1->$invar2$(:,:)
      	end if
	if (varcode .eq. "HMXL_pcnt")then
	   var2(n,:,:) = f1->$invar2$(:,:)
	end if
      end if
      if (vartype .eq. "3d")then
        var1(n,:,:) = f1->$invar1$(level,:,:)
      end if
      ndates(n)   = f1->number_dates
      seaice(n,:,:) = f2->$insea$(:,:)
      u_vect(n,:,:) = f3->$invar_u_vec$(:,:)
      v_vect(n,:,:) = f3->$invar_v_vec$(:,:)
      delete([/prefix,f1,f2,f3/])
      n = n+1
    end do
  end do
  delete(n)
end if

;;;;;;;;;;
; Change units as necessary
;;;;;;;;;;
; NEXT
if (varcode.eq."BUOY" .or. varcode.eq."BUOY_T" .or. varcode.eq."BUOY_LW" .or. varcode.eq."BUOY_SW" .or. varcode.eq."BUOY_LH" .or. varcode.eq."BUOY_SH" .or. varcode.eq."BUOY_EVAP" .or. varcode.eq."BUOY_PREC")then
  var1 = var1*10.0^8
  var1@units = "E-8~C~m2 s-3"
end if
if (varcode .eq. "EVAP")then
  var1 = (-var1)*10.0^8
  var1@units = "E-8 m s-1"
end if
if (varcode .eq. "PREC")then
  var1 = var1*10.0^8
  var1@units = "E-8 m s-1"
end if
if (varcode .eq. "HMXL_pcnt")then
  dum = (var1/var2)*100.
  copy_VarMeta(var1,dum)
  dum@long_name = "Mixed layer depth anomaly as percent of mean"
  dum@units = "%"
  delete(var1)
  var1 = dum
  delete([/dum,var2/])
end if
if (varcode .eq. "EMP")then
   dum = var1 - var2
   copy_VarMeta(var1, dum)
   dum@long_name = "Evap - Precip"
   delete(var1)
   var1 = dum
   delete([/dum,var2/])
   var1 = var1*10.0^8
   var1@units = "E-8 m s-1"
end if
if (varcode .eq. "BUOY_H")then
  var1 = var1*10.0^11
  var1@units = "E-11~C~m2 s-3"
end if
if (varcode .eq. "SSS")then
  var1@units = "g kg-1"
end if
if (cmaptype .eq. "pd" .or. cmaptype .eq. "pd_anom")then
    var1 = var1*10.0^5
    var1@units = "E-5 g cm-3"
end if
if (cmaptype .eq. "mld" .or. cmaptype .eq. "mld_anom")then
  var1 = var1/100.
  var1@units = "m"
end if
if (cmaptype .eq. "strat")then
  var1 = var1*10.0^3
  var1@units = "E-3 g cm-3"
end if
if (cmaptype .eq. "salinity_anom")then
  var1 = var1*10.0^5
  var1@units = "E-5  g kg-1"
end if
print("Loaded "+vartitle)
;;;;;;;;;;
; Mask terrain or sea ice
;;;;;;;;;;
; NEXT
print("Masking variable")
n = 0
; loop through each file
do n = 0, npan - 1
  ; mask terrain (wrf files)
  if (tag .eq. "wrf") then
    var1(n,:,:) = where(z_sfc .lt. 25.0, var1(n,:,:), var1@_FillValue)
  end if
  if (tag .eq. "pop") then
    var1(n,:,:) = where(seaice(n,:,:) .lt. 0.15, var1(n,:,:), var1@_FillValue)
  end if
  u_vect(n,:,:) = where(z_sfc .lt. 25.0, u_vect(n,:,:),u_vect@_FillValue)
  v_vect(n,:,:) = where(z_sfc .lt. 25.0, v_vect(n,:,:),v_vect@_FillValue)
end do
delete(n)

; assign lat/lon info
var1@lat2d = lat2d
var1@lon2d = lon2d
seaice@lat2d = lat_p
seaice@lon2d = lon_p
u_vect@lat2d = lat_w
u_vect@lon2d = lon_w
v_vect@lat2d = lat_w
v_vect@lon2d = lon_w

print(varcode+" var min: "+min(var1)+"  max: "+max(var1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
print("Processing all plots for "+varcode)
;;;;;;;;;;
; Set resources for normal plots
;;;;;;;;;;
res                             = True              ; plot mods desired
res@gsnRightString              = ""
res@gsnLeftString               = ""               ; Set this in loop
res@gsnFrame                    = False             ; Do not draw plot 
res@gsnDraw                     = False             ; Do not advance fr
res@gsnAddCyclic                = False             ; regional - not cyclic
res@gsnMaximize                 = True              ; Make it as big as possible
res@mpProjection                = "Stereographic"   ; map projection
res@mpCenterLonF                = -35. ;-30.             ; set the center lat/lon
res@mpCenterLatF                = 63.               
res@mpGridAndLimbOn             = False            ; Turn on lat/lon grid
;res@mpGridLineDashPattern       = 2                ; Change dash pattern
res@mpFillOn                    = True             ; Enables map fill
res@mpGeophysicalLineColor      = "black"          ; Color of continents
res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
if (tag .eq. "pop")then
  res@trGridType                  = "TriangularMesh"
end if 

res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
res@mpMinLatF                   = 56.              ; set the minimum latitude 
res@mpMaxLatF                   = 70.              ; set the maximum latitude 
res@mpMinLonF                   = -54.0            ; set the minimum longitude 
res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

; Resources for contours
res@cnFillMode                  = "AreaFill"
res@cnFillOn                    = True              ; turn on filled contours
res@gsnSpreadColors             = True              ; use full colormap
res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
res@cnLinesOn                   = plotlines         ; contour lines specified above
res@cnLineLabelsOn              = plotlines       
res@cnMissingValFillColor       = "gray85"          ; missing value color
res@cnMissingValFillPattern     = 0                 ; fill in
res@cnMissingValPerimOn         = True
res@cnMissingValPerimColor      = "black"
res@tiMainFontHeightF           = 0.013
res@lbLabelBarOn                = False
res@cnInfoLabelOn               = False

res@gsnSpreadColorStart        = spreadstart      ; start at color specified for each variable above
res@gsnSpreadColorEnd          = spreadend        ; end at color specified above
res@cnMinLevelValF             = cmin             ; set min contour level specified above
res@cnMaxLevelValF             = cmax             ; set max contour level specified above
res@cnLevelSpacingF            = clev             ; set contour spacing specified above
;res@lbLabelStride              = stride

; resources for vector plots if it's a wind plot
vcres                            = True ;res
vcres@gsnDraw                    = False
vcres@gsnFrame                   = False
vcres@vcGlyphStyle               = "LineArrow"
vcres@vcRefMagnitudeF            = 1.0
vcres@vcRefLengthF               = 0.005
vcres@vcMonoLineArrowColor       = True
vcres@vcLineArrowColor           = "black"
vcres@vcMinDistanceF             = 0.07
vcres@vcRefAnnoOn                = False
vcres@gsnLeftString              = ""
vcres@gsnRightString             = ""
;vcres@gsnScalarContour           = True
;vcres@cnInfoLabelOn              = False
;vcres@mpOutlineOn                = True
;vcres@mpOutlineBoundarySets      = "AllBoundaries" 

; set resources for sea ice overlay
res_ice                            = True               ; reset options
res_ice@gsnLeftString              = ""
res_ice@gsnRightString             = ""
res_ice@gsnFrame                   = False             ; Do not draw plot 
res_ice@gsnDraw                    = False             ; Do not advance fr
res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
res_ice@cnFillOn                   = False             ; turn on filled contours
res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
res_ice@cnLinesOn                  = True              ; contour lines specified above
res_ice@cnLineLabelsOn             = False             ; line labels on specified above
res_ice@cnLineColor                = "black"
res_ice@cnLineThicknessF           = 2.0
res_ice@tiXAxisOn                  = False
res_ice@tiYAxisOn                  = False
res_ice@trGridType                 = "TriangularMesh"

; resources for final panel plot
res_pan                            = True
if (mon .eq. "xx")then
  res_pan@txString                 = "1990-2010 winter "+type+ " average "+vartitle         ; main title
else
  res_pan@txString                 = "1990-2010 winter "+type+ " average "+vartitle+" for month "+mon+" subset"         ; main title
end if
res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
res_pan@gsnMaximize                = True	      ; fill the page
res_pan@gsnPanelLabelBar           = True
res_pan@lbTitleString              = var1@units
res_pan@lbLabelStride              = stride

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Winter mean 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(npan, graphic)
dum = new(npan, graphic)

if (type .eq. "node") then
  xpos = 0
  ypos = 0
  n = 0
  do n = 0, npan-1
    print("Plotting graph "+n+" ("+xpos+","+ypos+")")
    var1_2d = var1(n,:,:)
    seaice_2d = seaice(n,:,:)
    U_2d = u_vect(n,:,:)
    V_2d = v_vect(n,:,:) 

    ; Method 1 (works with differing or same grids for U/V and var1)
    cplot = gsn_csm_contour_map(wks,var1_2d,res)
    iplot = gsn_csm_contour(wks,seaice_2d,res_ice)
    vplot = gsn_csm_vector(wks,U_2d,V_2d,vcres)
    overlay(cplot,iplot)
    overlay(cplot,vplot)
    dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)

    ; Method 2 (only works with same grid for U/V and var1)
;    cplot  = gsn_csm_vector_scalar_map(wks,U_2d,V_2d,var1_2d,vcres)
;    cplot2 = gsn_csm_contour(wks,seaice_2d,res_ice)
;    overlay(cplot,cplot2)
;    dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)

    plot(n) = cplot
    delete([/var1_2d,seaice_2d,U_2d,V_2d/])
    ; Update xpos and ypos for next time through:
    xpos = xpos + 1
    if (xpos.eq.nx_node) then
      xpos = 0
      ypos = ypos + 1
    end if
  end do
  ; Panel the group plots
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@lbOrientation              = "Horizontal"
  res_pan@lbTitlePosition            = "right"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@lbLabelFontHeightF         = 0.0095
  res_pan@pmLabelBarWidthF           = 0.975
  res_pan@pmLabelBarHeightF          = 0.075
  res_pan@txFontHeightF              = 0.015
  gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)      ; create final panel plot
end if

if (type .eq. "group") then
  ; This has been modified to use Method 1 (see above in nodes plotting for description)
  ; group 1 
  cplot = gsn_csm_contour_map(wks,var1(0,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(0,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(0,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(0) = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
  plot(0) = cplot

  ; group 2 
  cplot = gsn_csm_contour_map(wks,var1(1,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(1,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(1,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(1) = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
  plot(1) = cplot

  ; group 3 
  cplot = gsn_csm_contour_map(wks,var1(2,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(2,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(2,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(2) = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
  plot(2) = cplot

  ; group 4 
  cplot = gsn_csm_contour_map(wks,var1(3,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(3,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(3,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(3) = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
  plot(3) = cplot

  ; group 5 
  cplot = gsn_csm_contour_map(wks,var1(4,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(4,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(4,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(4) = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
  plot(4) = cplot

  ; group 6 
  cplot = gsn_csm_contour_map(wks,var1(5,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(5,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(5,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(5) = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
  plot(5) = cplot

  ; group 7 
  cplot = gsn_csm_contour_map(wks,var1(6,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(6,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(6,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(6) = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
  plot(6) = cplot

  ; group 8 
  cplot = gsn_csm_contour_map(wks,var1(7,:,:),res)
  iplot = gsn_csm_contour(wks,seaice(7,:,:),res_ice)
  vplot = gsn_csm_vector(wks,u_vect(7,:,:),v_vect(0,:,:),vcres)
  overlay(cplot,iplot)
  overlay(cplot,vplot)
  dum(7) = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
  plot(7) = cplot

  ; Panel the group plots
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbTitlePosition            = "Bottom"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.375
  res_pan@txFontHeightF              = 0.015
  gsn_panel(wks,(/plot/),(/2,4/),res_pan)               ; create final panel plot
end if

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")
print("Completed all plots for "+varcode+". Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
