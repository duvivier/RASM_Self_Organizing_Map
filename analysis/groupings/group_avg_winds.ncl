;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Modified by Alice DuVivier - August 2013
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  datatitle  = "wrf50_199011_201003"
  varcode = "WS"
  dir1 = "/data5/duvivier/SOM-RASM/analysis/averages/group_avgs/"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN SCRIPT
print("Processing all graphs for "+varcode)
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
if (varcode.eq."WS")then
  vartitle = "Group average scalar wind speed: "+datatitle
  invar1 = "WS_avg"
  cmaptype = "wind"
  fout1   = "group_avg_scalar_wind_"+datatitle
end if
if (varcode.eq."UV")then
  vartitle = "Group average vector wind speed: "+datatitle
  invar1 = "U_earth_avg"
  invar2 = "V_earth_avg"
  cmaptype = "wind"
  fout1   = "group_avg_vector_wind_"+datatitle
end if

; Set the contour interval for each input variable   
if (cmaptype.eq."wind") then
  cmin1               = 0.
  cmax1               = 15.
  clev1               = 1.
  stride1             = 1                 ; label stride
  cmin2               = -7.
  cmax2               = 7.
  clev2               = 0.5
  stride2             = 2                 ; label stride for diff plot
  plotlines           = False              ; lines for reg plot
  difflines           = False              ; lines for diff plot
  cntype              = "AreaFill"
  spreadstart1        = 2                 ; start at color
  spreadend1          = 18                ; end at color
  colormap            = "SOM_wind_table_mod"
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in data from group averages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ngroup = 8   ; set number of groups
; Load in lat/lon to get information
fname0 = "group_1_"+datatitle
f0 = addfile(dir1+ fname0 + ".nc","r")
lat2d = f0->lat
lon2d = f0->lon
z_sfc = f0->Z_sfc
dims = dimsizes(lat2d)     ; get lat/lon dimensions
n_sn = dims(0)              ; get south/north points
n_we = dims(1)              ; get west/east points
n_tot = n_sn*n_we              
delete([/dims,f0,fname0/])

; create all-node array for node average variable
var1     = new((/ngroup,n_sn,n_we/),"double")
ndates   = new((/ngroup/),"integer")
fill = var1@_FillValue

if(varcode .eq. "UV")then
  U = new((/ngroup,n_sn,n_we/),"double")
  V = new((/ngroup,n_sn,n_we/),"double")
end if

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
; loop through each group
do g = 0, ngroup - 1
  g1 = g+1
  print("group: "+g1)
  ; file 1
  fname1 = "group_"+g1+"_"+datatitle
  f1 = addfile(dir1 + fname1 + ".nc","r")
  var1(g,:,:) = f1->$invar1$(south_north|:,west_east|:)
  if(varcode.eq."UV")then
    U(g,:,:) = var1(g,:,:)
    V(g,:,:) = f1->$invar2$(south_north|:,west_east|:)
    var1(g,:,:) = sqrt(U(g,:,:)^2 + V(g,:,:)^2)
  end if

  ndates(g) = f1->number_dates
  delete([/fname1,f1/])
  ; Mask areas not of interest
  print("Masking terain and lat/lon")
  ; mask terrain - focus on ocean
  var1(g,:,:) = where(z_sfc .lt. 50., var1(g,:,:), var1@_FillValue)
  ; mask lat/lons - focus on S. Greenland region
  var1(g,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var1(g,:,:), var1@_FillValue)
  if(varcode.eq."UV")then
    U(g,:,:) = where(z_sfc .lt. 50., U(g,:,:), U@_FillValue)
    U(g,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., U(g,:,:), U@_FillValue)
    V(g,:,:) = where(z_sfc .lt. 50., V(g,:,:), V@_FillValue)
    V(g,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., V(g,:,:), V@_FillValue)
  end if
end do

; assign lat/lon info
var1@lat2d = lat2d
var1@lon2d = lon2d
if(varcode.eq."UV")
  U@lat2d = lat2d
  U@lon2d = lon2d
  V@lat2d = lat2d
  V@lon2d = lon2d
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
print(vartitle+" var1 min: "+min(var1)+"  max: "+max(var1))
print("completed node calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing group average winds")
; set outdir and fout names
outdir = "./"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set resources for normal plots
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
res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
res@mpMinLatF                   = 56.              ; set the minimum latitude 
res@mpMaxLatF                   = 70.              ; set the maximum latitude 
res@mpMinLonF                   = -54.0            ; set the minimum longitude 
res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

res@cnFillMode                 = cntype
res@cnFillOn                   = True              ; turn on filled contours
res@gsnSpreadColors            = True              ; use full colormap
res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res@cnLinesOn                  = plotlines         ; contour lines specified above
res@cnLineLabelsOn             = plotlines         ; line labels on specified above
res@cnMissingValFillColor      = "gray85"          ; missing value color
res@cnMissingValFillPattern    = 0                 ; fill in
res@cnMissingValPerimOn        = True
res@cnMissingValPerimColor     = "black"
res@tiMainFontHeightF          = 0.013
res@lbLabelBarOn               = False
res@cnInfoLabelOn              = False
;res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;res@pmLabelBarHeightF          = 0.075             ; set height of labelbar

res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
res@cnMinLevelValF             = cmin1             ; set min contour level specified above
res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
;res@lbLabelStride              = stride1

; resources for vector plots if it's a wind plot
vcres                            = res
vcres@vcGlyphStyle               = "LineArrow"
vcres@vcRefMagnitudeF            = 1.0
vcres@vcRefLengthF               = 0.005
vcres@vcMonoLineArrowColor       = True
vcres@vcLineArrowColor           = "black"
vcres@vcMinDistanceF             = 0.07
vcres@vcRefAnnoOn                = False

vcres@gsnScalarContour           = True
vcres@cnInfoLabelOn              = False
vcres@mpOutlineOn                = True
vcres@mpOutlineBoundarySets      = "AllBoundaries" 

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Make plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot winter mean wind speed")
  wks = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)
  plot = new(8, graphic)

  if(varcode .eq. "UV")then
  ; Plots for vectors
  ; group 1 
    cplot  = gsn_csm_vector_scalar_map(wks,U(0,:,:),V(0,:,:),var1(0,:,:),vcres)
    dum0 = new(1,graphic)
    dum0 = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
    plot(0) = cplot
  ; group 2 
    cplot  = gsn_csm_vector_scalar_map(wks,U(1,:,:),V(1,:,:),var1(1,:,:),vcres) 
    dum1 = new(1,graphic)
    dum1 = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
    plot(1) = cplot
  ; group 3 
    cplot  = gsn_csm_vector_scalar_map(wks,U(2,:,:),V(2,:,:),var1(2,:,:),vcres)
    dum2 = new(1,graphic)
    dum2 = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
    plot(2) = cplot
  ; group 4 
    cplot  = gsn_csm_vector_scalar_map(wks,U(3,:,:),V(3,:,:),var1(3,:,:),vcres)
    dum3 = new(1,graphic)
    dum3 = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
    plot(3) = cplot
  ; group 5 
    cplot  = gsn_csm_vector_scalar_map(wks,U(4,:,:),V(4,:,:),var1(4,:,:),vcres)
    dum4 = new(1,graphic)
    dum4 = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
    plot(4) = cplot
  ; group 6 
    cplot  = gsn_csm_vector_scalar_map(wks,U(5,:,:),V(5,:,:),var1(5,:,:),vcres)
    dum5 = new(1,graphic)
    dum5 = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
    plot(5) = cplot
  ; group 7 
    cplot  = gsn_csm_vector_scalar_map(wks,U(6,:,:),V(6,:,:),var1(6,:,:),vcres)
    dum6 = new(1,graphic)
    dum6 = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
    plot(6) = cplot
  ; group 8 
    cplot  = gsn_csm_vector_scalar_map(wks,U(7,:,:),V(7,:,:),var1(7,:,:),vcres)
    dum7 = new(1,graphic)
    dum7 = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
    plot(7) = cplot
  else
  ; Plots for non-vector
  ; group 1 
    cplot  = gsn_csm_contour_map(wks,var1(0,:,:),res)
    dum0 = new(1,graphic)
    dum0 = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
    plot(0) = cplot
  ; group 2 
    cplot  = gsn_csm_contour_map(wks,var1(1,:,:),res)
    dum1 = new(1,graphic)
    dum1 = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
    plot(1) = cplot
  ; group 3 
    cplot  = gsn_csm_contour_map(wks,var1(2,:,:),res)
    dum2 = new(1,graphic)
    dum2 = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
    plot(2) = cplot
  ; group 4 
    cplot  = gsn_csm_contour_map(wks,var1(3,:,:),res)
    dum3 = new(1,graphic)
    dum3 = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
    plot(3) = cplot
  ; group 5 
    cplot  = gsn_csm_contour_map(wks,var1(4,:,:),res)
    dum4 = new(1,graphic)
    dum4 = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
    plot(4) = cplot
  ; group 6 
    cplot  = gsn_csm_contour_map(wks,var1(5,:,:),res)
    dum5 = new(1,graphic)
    dum5 = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
    plot(5) = cplot
  ; group 7 
    cplot  = gsn_csm_contour_map(wks,var1(6,:,:),res)
    dum6 = new(1,graphic)
    dum6 = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
    plot(6) = cplot
  ; group 8 
    cplot  = gsn_csm_contour_map(wks,var1(7,:,:),res)
    dum7 = new(1,graphic)
    dum7 = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
    plot(7) = cplot
  end if

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  res_pan                            = True
  res_pan@txString                   = vartitle
  res_pan@txFontHeightF              = 0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbTitleString              = "m s-1"
  res_pan@lbTitlePosition            = "Bottom"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.375

  gsn_panel(wks,(/plot/),(/2,4/),res_pan)


; Finally - make plot
  print("converting plot to png")
  delete(wks)
  system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+ \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
