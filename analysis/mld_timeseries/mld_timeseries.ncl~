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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting time series of MLD at LOCO points - 20 winters")

;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/4x_3y_files/"
datefile = dir+"wrf50_199011_201003_dates.txt"
dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
ndates = dimsizes(dates)
dateschar = stringtochar(dates)
yy = chartostring(dateschar(:,0:3))
mm = chartostring(dateschar(:,5:6))
dd = chartostring(dateschar(:,8:9))

; create filenames array for forcing variable
files = new((/ndates/),string)
files = "/vardar/data5/duvivier/SOM-RASM/analysis/surface_files/pop_sfc_files/pop."+yy+"-"+mm+"-"+dd+".sfc.green.nc"

; Load 2D plotting information
geo = addfile("/vardar/data5/duvivier/SOM-RASM/DATA/pop/pop_geo_green.nc","r")
lat2d = (geo->grid_center_lat)*(180.0/3.14159)
lon2d = (geo->grid_center_lon)*(180.0/3.14159)

; get locations of loco 2 and loco 3
lat_loco2 = 59.2
lon_loco2 = -39.5
lat_loco3 = 59.25
lon_loco3 = -36.417

ij = getind_latlon2d(lat2d, lon2d, lat_loco2, lon_loco2)
i_loco2 = ij(0,0)
j_loco2 = ij(0,1)
delete(ij)

ij = getind_latlon2d(lat2d, lon2d, lat_loco3, lon_loco3)
i_loco3 = ij(0,0)
j_loco3 = ij(0,1)
delete(ij)

; write an array with all days for all 20 years. 
ndates_total = 365 * 20
times = new((/ndates/),integer)
mld_loco2 = new((/ndates/),float)
mld_loco3 = new((/ndates/),float)

n = 0
;;;;;;;;;
; Load data at points for all days
;;;;;;;;;;
; loop through each node
do n = 0, ndates - 1
   times(n) = stringtoint(yy(n)+mm(n)+dd(n))
   f = addfile(files(n),"r")
   mld_loco2(n) = f->HMXL(i_loco2,j_loco2)
   mld_loco3(n) = f->HMXL(i_loco3,j_loco3)
   delete([/f/])
end do
print("Loaded MLD data at gridpoints nearest LOCO lat/lons")

; convert mld from cm to m
; note: 1m = 1dbar
mld_loco2 = mld_loco2/100.0
mld_loco2@units = "m"
mld_loco3 = mld_loco3/100.0
mld_loco3@units = "m"

; convert times to fractional years for plotting
times_frac = yyyymmdd_to_yyyyfrac(times,0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
; Set resources for normal plots
;;;;;;;;;;
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot

; set title resources
  res@tiMainOn                    = True              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.011              ; set size of font for main plot

; x axis options
  res@tmXTOn                      = False             ; delete top and right ticks
  res@trXMaxF                     = 2011              ; set upper x limit
  res@tmXBMode                    = "Manual"
  res@tmXBTickEndF                = 2011
  res@tmXBTickSpacingF            = 1
  res@tmXMajorGrid                = True
  res@tmXMajorGridThicknessF      = 1.0
  res@tmXMajorGridLineDashPattern = 1.0
  res@tmXMajorGridLineColor       = "grey"
  res@tmXBMinorOn                 = False
  res@tiXAxisFontHeightF          = 0.011            ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.011             ; set tick mark label size for x axis

; y axis options
  res@tmYROn                      = False
  res@trYReverse                  = True              ; reverse y axis
  res@tiYAxisFontHeightF          = 0.011             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.011             ; set tick mark label size for y axis
  res@vpHeightF                   = 0.3               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 1.5 ;0.9               
  
; data marker options
  res@xyMarkLineModes             = "Markers"
  res@xyMarkers                   = 1
  res@xyMarkerSizes               = 0.015
  res@xyMarkerColors              = "black"

print("Plotting MLD timeseries - all dates")
outdir = "./"
fout   = outdir+"mld_timeseries_LOCO_Irminger"
wks = gsn_open_wks("ps",fout) 
plot = new(2, graphic)

;;;;;;;;;;;;;
; Plot 1 - LOCO2
;;;;;;;;;;;;;
  opts                            = res    
  opts@trXMinF                    = 1990              ; set lower x limit
  opts@tmXBTickStartF             = 1990      
  opts@tiMainString               = "LOCO2: ("+lat_loco2+"N, "+ -lon_loco2+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco2@units+")"
  
  cplot0 = gsn_csm_xy(wks, times_frac, mld_loco2, opts) 
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 2 - LOCO3
;;;;;;;;;;;;;
  opts                            = res 
  opts@trXMinF                    = 1990              ; set lower x limit
  opts@tmXBTickStartF             = 1990               
  opts@tiMainString               = "LOCO3: ("+lat_loco3+"N, "+ -lon_loco3+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco3@units+")"
  
  cplot1 = gsn_csm_xy(wks, times_frac, mld_loco3, opts) 
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@txString                   = "RASM Daily Average Mixed Layer Depth Timeseries at Gridpoints Nearest LOCO: 1990-2010"
  pnlres@txFontHeightF              = 0.01
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,1/),pnlres)               ; create final panel plot

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
  frame(wks)
  delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")


; Subset of years
print("Plotting MLD timeseries - 2004-2010")
outdir = "./"
fout1   = outdir+"mld_timeseries_LOCO_Irminger_2004_2010"
wks1 = gsn_open_wks("ps",fout1) 
plot1 = new(2, graphic)

;;;;;;;;;;;;;
; Plot 1 - LOCO2
;;;;;;;;;;;;;
  opts                            = res    
  opts@trXMinF                    = 2004              ; set lower x limit
  opts@tmXBTickStartF             = 2004      
  opts@tiMainString               = "LOCO2: ("+lat_loco2+"N, "+ -lon_loco2+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco2@units+")"
  
  cplot0 = gsn_csm_xy(wks1, times_frac, mld_loco2, opts) 
  plot1(0) = cplot0                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 2 - LOCO3
;;;;;;;;;;;;;
  opts                            = res 
  opts@trXMinF                    = 2004              ; set lower x limit
  opts@tmXBTickStartF             = 2004               
  opts@tiMainString               = "LOCO3: ("+lat_loco3+"N, "+ -lon_loco3+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco3@units+")"
  
  cplot1 = gsn_csm_xy(wks1, times_frac, mld_loco3, opts) 
  plot1(1) = cplot1                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@txString                   = "RASM Daily Average Mixed Layer Depth Timeseries at Gridpoints Nearest LOCO: 2004-2010"
  pnlres@txFontHeightF              = 0.01
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks1,(/plot1/),(/2,1/),pnlres)               ; create final panel plot

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
  frame(wks1)
  delete(wks1)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")

print("Plots Completed")
;;;;;;;;;;;;;;;;;;;;;; END script
end
