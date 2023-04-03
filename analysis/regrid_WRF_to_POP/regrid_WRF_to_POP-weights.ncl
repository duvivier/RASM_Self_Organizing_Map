;***************************************
; Script to go through 6-hourly core files and
; interpoLATe to the wrf grid
;
; Mimi Hughes
; 11 June 2012
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;***************************************
begin
setfileoption("nc","Format","LargeFile")
setfileoption("nc","SuppressClose",False)

dirin     = "./"

; load WRF geo file
geo_wrf = "geo_em.50km.green.nc"
f_wrf = addfile(dirin+geo_wrf,"r") 
lat_wrf = f_wrf->XLAT_M(0,:,:)
lon_wrf = f_wrf->XLONG_M(0,:,:)
hgt_wrf = f_wrf->HGT_M(0,:,:)

; load POP geo file
geo_pop = "pop_geo_green.nc" 
f_pop = addfile(dirin+geo_pop,"r") 
lat_pop = f_pop->grid_center_lat 
lon_pop = f_pop->grid_center_lon 
; convert pop lat/lon from radians to degrees
lat_pop = lat_pop*(180.0/3.14159)
lon_pop = lon_pop*(180.0/3.14159)
lat_pop@units = "degrees"
lon_pop@units = "degrees"

; set options for regridding
WgtFile = "ESMF_wgt-WRF_to_POP.nc"
  optESMF                     = True
  optESMF@InterpMethod        = "bilinear"
  optESMF@WgtFileName         = WgtFile
  optESMF@Debug               = False ;True
  optESMF@CopyVarAtts         = False ;True
  optESMF@CopyVarCoords       = False ;True
  optESMF@ForceOverwrite      = False ;True
  optESMF@RemoveSrcFile       = True  ;False   
  optESMF@RemoveDstFile       = True  ;False   
  optESMF@RemoveWgtFile       = False   
  optESMF@SrcGridLat          = lat_wrf
  optESMF@SrcGridLon          = lon_wrf
  optESMF@SrcInputFileName    = geo_wrf
  optESMF@DstGridLat          = lat_pop
  optESMF@DstGridLon          = lon_pop
  optESMF@DstInputFileName    = geo_pop
  optESMF@SrcTitle            = "RASM WRF domain - Greenland subset"
  optESMF@DstTitle            = "RASM POP domain - Greenland subset "
  optESMF@SrcRegional         = True     ; source data is regional
  optESMF@DstRegional         = True     ; destination grid is regional
  optESMF@SrcGridType         = "curvilinear"   ; WRF is a curvilinear grid
  optESMF@DstGridType         = "curvilinear"   ; POP is a curvilinear grid

; regrid the height and create weight file
hgt_pop = ESMF_regrid(hgt_wrf,optESMF)

outfile = addfile("./regrid-test.nc","c")
; regrid data and write to new file
outfile ->Z_sfc = hgt_pop

print("Weights generated successfully")
; it has now generated the weight file we will need for other variables (need to test this!)

end

