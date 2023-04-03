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

; get array at each location for maximum depths
; use fractional years to determine yearly divisions. Use 0.5 (June) as division in year for greater and equal to
ys = (/1990.5, 1991.5, 1992.5, 1993.5, 1994.5, 1995.5, 1996.5, 1997.5, 1998.5, 1999.5, 2000.5, 2001.5, 2002.5, 2003.5, 2004.5, 2005.5, 2006.5, 2007.5, 2008.5, 2009.5/)
; year that ends winter season
ye = (/1991.5, 1992.5, 1993.5, 1994.5, 1995.5, 1996.5, 1997.5, 1998.5, 1999.5, 2000.5, 2001.5, 2002.5, 2003.5, 2004.5, 2005.5, 2006.5, 2007.5, 2008.5, 2009.5, 2010.5/)
nyrs = dimsizes(ys)

mld_loco2_max = new((/nyrs/),"float")
mld_loco3_max = new((/nyrs/),"float")

n = 0
do n = 0, nyrs-1
   inds = ind(times_frac.ge.ys(n) .and. times_frac.le.ye(n))
   mld_loco2_max(n) = max(mld_loco2(inds))
   mld_loco3_max(n) = max(mld_loco3(inds))
   delete(inds)
end do

; x and y positions to put text
xpos = (/1991.0, 1992.0, 1993.0, 1994.0, 1995.0, 1996.0, 1997.0, 1998.0, 1999.0, 2000.0, 2001.0, 2002.0, 2003.0, 2004.0, 2005.0, 2006.0, 2007.0, 2008.0, 2009.0, 2010.0/)
ypos = (/725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0, 725.0, 675.0/)

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
  res@trXMinF                     = 1990              ; set lower x limit
  res@tmXBTickStartF              = 1990   
  res@trXMaxF                     = 2011              ; set upper x limit
  res@tmXBTickEndF                = 2011
  res@tmXBMode                    = "Manual"
  res@tmXBPrecision               = 4

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
  res@tmYLMode                    = "Manual"
  res@tmYLTickStartF              = 0.0
  res@tmYLTickEndF                = 700.0
  res@trYMinF                     = 0.0
  res@trYMaxF                     = 750.0

; viewport size
  res@vpHeightF                   = 0.3               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 1.0 ;1.25 ;1.5 ;0.9               
  
; data marker options
  res@xyMarkLineModes             = "Markers"
  res@xyMarkers                   = 1
  res@xyMarkerSizes               = 0.015
  res@xyMarkerColors              = "black"

; text options
  txres                           = True
  txres@txFontHeightF             = 0.01

print("Plotting MLD timeseries - all dates")
outdir = "./"
fout   = outdir+"figure_5b_mld_timeseries_LOCO_Irminger"
wks = gsn_open_wks("ps",fout) 
plot = new(2, graphic)
dum = new(nyrs,graphic)

;;;;;;;;;;;;;
; Plot 1 - LOCO2
;;;;;;;;;;;;;
  opts                            = res       
  opts@tiMainString               = "RASM-POP gridpoint nearest LOCO 2: ("+lat_loco2+"N, "+ -lon_loco2+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco2@units+")"
  
  cplot0 = gsn_csm_xy(wks, times_frac, mld_loco2, opts)
  ; add text with deepest MLD that year
  n = 0
  do n = 0, nyrs-1
     txt = sprintf("%5.0f",mld_loco2_max(n))+" m"
     dum(n) = gsn_add_text(wks,cplot0,txt,xpos(n),ypos(n), txres)
     delete(txt)
  end do

  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 2 - LOCO3
;;;;;;;;;;;;;
  opts                            = res 
  opts@tiMainString               = "RASM-POP gridpoint nearest LOCO 3: ("+lat_loco3+"N, "+ -lon_loco3+"W)"
  opts@tiYAxisString              = "Mixed layer depth ("+mld_loco3@units+")"
  
  cplot1 = gsn_csm_xy(wks, times_frac, mld_loco3, opts) 
  ; add text with deepest MLD that year
  n = 0
  do n = 0, nyrs-1
     txt = sprintf("%5.0f",mld_loco3_max(n))+" m"
     dum(n) = gsn_add_text(wks,cplot1,txt,xpos(n),ypos(n), txres)
     delete(txt)
  end do
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@txString                   = "RASM Daily Average Mixed Layer Depth Timeseries"
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

print("Plots Completed")
;;;;;;;;;;;;;;;;;;;;;; END script
end
