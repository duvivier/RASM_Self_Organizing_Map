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
indir = "/vardar/data5/duvivier/SOM-RASM/analysis/revisions/"
fin = "pop_NDJFM_avg_1990-2010.nc"
; set outdir and fout names
outdir = "./"
fout   = "T_sfc_avg"

; Load Data
f1 = addfile(indir+fin,"r")
temp = f1->SST_avg
ice = f1->ice_frac_avg
ice = ice*100.
lat2d = f1->TLAT
lon2d = f1->TLONG

temp@lat2d = lat2d
temp@lon2d = lon2d
ice@lat2d = lat2d
ice@lon2d = lon2d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
res@mpGeophysicalLineThicknessF = 2.5              ; Make continents thinner
res@trGridType                  = "TriangularMesh"

res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
res@mpMinLatF                   = 56.              ; set the minimum latitude 
res@mpMaxLatF                   = 70.              ; set the maximum latitude 
res@mpMinLonF                   = -62.0            ; set the minimum longitude 
res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

; Resources for contours
res@cnFillMode                  = "AreaFill"
res@cnFillOn                    = True              ; turn on filled contours
res@gsnSpreadColors             = True              ; use full colormap
res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
res@cnLinesOn                   = False             ; contour lines specified above
res@cnLineLabelsOn              = True
res@cnLineLabelInterval         = 1
res@cnMissingValFillColor       = "gray85"          ; missing value color
res@cnMissingValFillPattern     = 0                 ; fill in
res@cnMissingValPerimOn         = True
res@cnMissingValPerimColor      = "black"
res@tiMainFontHeightF           = 0.013
res@lbLabelBarOn                = False
res@cnInfoLabelOn               = False
res@gsnSpreadColorStart        = 2                ; start at color specified for each variable above
res@gsnSpreadColorEnd          = 65               ; end at color specified above
res@cnMinLevelValF             = -5.               ; set min contour level specified above
res@cnMaxLevelValF             = 10.            ; set max contour level specified above
res@cnLevelSpacingF            = 1.             ; set contour spacing specified above

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
res_ice@cnMaxLevelValF             = 15.0              ; set max contour level specified above
res_ice@cnLevelSpacingF            = 15.0              ; set contour spacing specified above
res_ice@cnLinesOn                  = True              ; contour lines specified above
res_ice@cnLineLabelsOn             = False             ; line labels on specified above
res_ice@cnLineColor                = "black"
res_ice@cnLineThicknessF           = 3.0
res_ice@tiXAxisOn                  = False
res_ice@tiYAxisOn                  = False
res_ice@trGridType                 = "TriangularMesh"

; resources for final panel plot
res_pan                            = True
res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
res_pan@gsnMaximize                = True	      ; fill the page
res_pan@gsnPanelLabelBar           = True
res_pan@lbTitleString              = "deg C"
res_pan@txString                  = "1990-2010 average winter (NDJFM) SST"
res_pan@gsnPanelYWhiteSpacePercent = 2         ; Add white space b/w plots.
res_pan@gsnPanelXWhiteSpacePercent = 2         ; Add white space b/w plots.
res_pan@gsnPanelScalePlotIndex     = 1
res_pan@lbOrientation              = "Horizontal"
res_pan@lbTitlePosition            = "right"
res_pan@lbTitleDirection           = "Across"
res_pan@lbTitleJust                = "CenterLeft"
res_pan@lbTitleFontHeightF         = 0.0075
res_pan@lbLabelFontHeightF         = 0.0095
res_pan@lbLabelStride              = 1
res_pan@pmLabelBarWidthF           = 0.975
res_pan@pmLabelBarHeightF          = 0.075
res_pan@txFontHeightF              = 0.015
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot winter average SST with ice contour
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting mean SST")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,"temp64_anoms.dave",additional_colors)
plot = new(1, graphic)

; average deepest mld
cplot0 = gsn_csm_contour_map(wks,temp,res)
iplot0 = gsn_csm_contour(wks,ice,res_ice)
overlay(cplot0,iplot0)
plot(0) = cplot0

; Panel the plot
gsn_panel(wks,plot,(/1,1/),res_pan)      ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")



print("Completed all correlation plots. Good job!")


print("Plots Completed")
;;;;;;;;;;;;;;;;;;;;;; END script
end
