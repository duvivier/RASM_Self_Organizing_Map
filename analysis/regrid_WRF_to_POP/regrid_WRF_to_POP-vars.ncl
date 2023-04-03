;***************************************
; PROGRAM DESCRIPTION: Script to use ESMF weights and interpolate
;                      data from WRF to POP RASM grid (Regional)
; INPUT DATA: WRF netcdf file and ESMF mapping file
; OUTPUT DATA: Netcdf file with WRF data on POP grid
; CREATOR: Alice DuVivier (July 2015)
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes. Otherwise loaded from csh script
; ******************************************************
yy = "2010"
mm = "01"
dd = "01"
dir_in = "./"    ; "./pop_orig_files/"
dir_out = "./"   ;"./pop_sfc_files/"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setfileoption("nc","Format","LargeFile")
setfileoption("nc","SuppressClose",False)

; set input file and load data
fin = "wrf."+yy+"-"+mm+"-"+dd+".sfc.green.nc"
f = addfile(dir_in+fin,"r")
Z_sfc = f->Z_sfc
tgrad = f->Tgrad
qgrad = f->Qgrad

; set output file
fout = "wrf2pop."+yy+"-"+mm+"-"+dd+".sfc.green.nc"
outfile = addfile(dir_out+fout,"c")

; load POP lat/lon data for plotting
fin_geo = "pop_geo_green.nc" 
geo = addfile("./"+fin_geo,"r")
lat_pop = geo->grid_center_lat 
lon_pop = geo->grid_center_lon

; write lat/lon to new file
outfile ->lat_pop = lat_pop
outfile ->lon_pop = lon_pop
print("Wrote lat/lon info")
delete([/lat_pop,lon_pop,geo,f/])

; set Weight File (must be in same directory as script)
WgtFile = "ESMF_wgt-WRF_to_POP.nc"

; regrid data and write to new file
Z_sfc_pop = ESMF_regrid_with_weights(Z_sfc,WgtFile,False)
outfile ->Z_sfc = Z_sfc_pop
print("Regridded terrain")

tgrad_pop = ESMF_regrid_with_weights(tgrad,WgtFile,False)
outfile ->tgrad = tgrad_pop
print("Regridded temperature gradient")

qgrad_pop = ESMF_regrid_with_weights(qgrad,WgtFile,False)
outfile ->qgrad = qgrad_pop
print("Regridded moisture gradient")

print("Completed gridding of WRF to POP gradients for: "+yy+"-"+mm+"-"+dd)
;;;;;;;;;;;;;;;;;;;;;; END script
end

