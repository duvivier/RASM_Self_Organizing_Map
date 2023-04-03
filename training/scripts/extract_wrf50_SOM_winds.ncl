; This program extracts u and v component of wind data from WRF output 
; files.  Input data should have previously been run through wrf->cf
; program or met->cf program.  Data is expected to be in combined
; monthly files.
;
; The entire dataset is then output as an SOM-readable ascii text file.
; A corresponding date file is also output at the same time.
; A seperate script can be used to add these files together.
; 
; Edits: Alice DuVivier
; alice.duvivier@colorado.edu
; September 2014

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

; Adjust these parameters as needed:
; **************************************************
;yearmonth = (/"199011"/)
file_type = "WRF50"
var = "wind"
; **************************************************
;setfileoption("nc","Format","LargeFile")

; set output names
 outdir = "som_extract/"
 outname = file_type+"_data_"+yearmonth+"_"+var+".dat"

 datedir = "dates/"
 fnamedates = file_type+"_"+yearmonth+"_dates.txt"

 coldir = "columns/"
 fcol = file_type+"_"+yearmonth+"_columns.txt"

; Grab file names of input files
 innames = systemfunc("ls /data5/duvivier/SOM-RASM/DATA/wrf/"+yearmonth+"/*.nc")

; Determine number of files to loop through and dimensions of output file
 dim_files = dimsizes(innames)
 wrf_files = addfiles(innames,"r")

; Get geography info from geo_em file
 geo = addfile("/data5/duvivier/SOM-RASM/DATA/wrf/geo_em.50km.green.nc","r")
 lat_file = geo->XLAT_M(0,:,0:66)
 lon_file = geo->XLONG_M(0,:,0:66)
 stand_lon = geo@STAND_LON
 Z_sfc_file = geo->HGT_M(0,:,0:66)

; Get lowest level winds from daily average files
 u_raw = addfiles_GetVar(wrf_files,innames,"U_M")
 v1 = addfiles_GetVar(wrf_files,innames,"V_M")
 v_raw = v1(:,:,0:67) ; get correct size
 delete(v1)
; Unstagger winds
 u = wrf_user_unstagger(u_raw, u_raw@stagger)
 v1 = wrf_user_unstagger(v_raw, v_raw@stagger)
 v = v1(:,:,0:66)
 delete(v1)
 dims = dimsizes(u)
 u_earth_files = new((/dims/),"double")
 v_earth_files = new((/dims/),"double")

; rotate wind vectors using same method as RASM
 tv = (lon_file - stand_lon)*(3.14159/180.)
 do n = 0, dim_files -1
   u_earth_files(n,:,:) = (u(n,:,:)*cos(tv))+(v(n,:,:)*sin(tv))
   v_earth_files(n,:,:) = (v(n,:,:)*cos(tv))-(u(n,:,:)*sin(tv))
 end do

; the windspeeds should be equal for both vector types. Sanity check...
 ;wspd1 = sqrt(u^2 + v^2)
 ;wspd2 = sqrt(u_earth_files^2 + v_earth_files^2)
 ;print(max(wspd1 - wspd2))
 ;print(min(wspd1 - wspd2))

;;;;;;;;;;
; select data for som
;;;;;;;;;;
 dates      = new((/dim_files/),string)

; Determine number of output grid points
 zsfc_2d = Z_sfc_file
 zsfc = ndtooned(zsfc_2d)
 lat1D = ndtooned(lat_file)
 lon1D = ndtooned(lon_file)
 zsfc@_FillValue = -999.

; make array to use for extraction
; smaller grid
; zsfc = where(zsfc.lt.25 .and. lat1D.gt.56. .and. lat1D.lt.65. .and. lon1D.gt.-51. .and. lon1D.lt.-30., zsfc, zsfc@_FillValue)

; whole domain
 zsfc_1 = where(zsfc.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.70. .and. lon1D.gt.-50. .and. lon1D.lt.-20., 1, 0)

; remove box out to sea
 zsfc_2 = where(zsfc.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.64. .and. lon1D.gt.-25. .and. lon1D.lt.-20., 0, 1)

; combine zsfc arrays
 zsfc_fin = zsfc_1*zsfc_2
 zsfc = where(zsfc_fin .gt.0, zsfc, zsfc@_FillValue)

; index values for locations where we'll get wind values
 zsfc_ind = ind(.not.ismissing(zsfc))
 dims1 = dimsizes(zsfc_ind)

;; make netcdf file to test winds
;n_sn = dims(1)
;n_we = dims(2)
;zsfc_sub = onedtond(zsfc,(/n_sn,n_we/))
;subset_test = addfile("./zsfc_subset.nc","c")
;subset_test ->zsfc_sub = zsfc_sub

 var_output = new((/dim_files,dims1*2/),double)  ; make array for wind output

 ; loop through the input files and pull the u and v components
 do d = 0, dim_files-1
   ; get u and v data and make it 1D
   u_var_2d = u_earth_files(d,:,:)
   v_var_2d = v_earth_files(d,:,:)
   u_var_1d = ndtooned(u_var_2d)
   v_var_1d = ndtooned(v_var_2d)
   ;printVarSummary(u_var_1d)
   ;printVarSummary(zsfc_ind)
   ; reduce to have only points specified from statements above
   ; 'gr' at the end specifies this is for the greenland region
   u_var_1d_gr = u_var_1d(zsfc_ind)
   v_var_1d_gr = v_var_1d(zsfc_ind)
   ; get date array
   dum1 = stringtochar(innames(d))
   dum2 = chartostring(dum1(55:64))
   dates(d) = dum2
   print(dum2)
   delete(dum1)
   delete(dum2)
   ; load in the wind arrays to the output variable:
   var_output(d,0:dims1-1) = u_var_1d_gr
   var_output(d,dims1:dims1*2-1) = v_var_1d_gr
   ; write #columns to file
   columns = dims1*2
 end do

; Now output the calculated variable and the date file:
format = dims1*2 + "f6.1"
options = True
options@fout = outdir + outname
print("Writing to " + options@fout)
write_matrix(var_output,format,options)

; write dates files
print("Writing to " + fnamedates)
asciiwrite(datedir+fnamedates,dates)

; write #columns
print("Writing to " + fcol)
asciiwrite(coldir+fcol,columns)


;;;;;;;;;;;;;;;;;;;;;;; END script
end
