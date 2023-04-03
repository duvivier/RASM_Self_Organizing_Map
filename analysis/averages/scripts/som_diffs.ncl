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
;  type = "group"
;  varcode = "BUOY"
;  nx = "7"
;  ny = "5"
;  mon = "DJF"   
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
if (varcode.eq."BUOY")then
  vartitle = "Surface Buoyancy flux"
  invar = "Buoy_flux"
  cmaptype = "flux_b"
  vartype = "2d"
  tag = "pop"
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
suffix = "_month-"+mon+"_199011_201003."+tag
suffix_ice = "_month-"+mon+"_199011_201003.pop"
suffix_xx = "_month-xx_199011_201003."+tag

; Load in lat/lon info for WRF or POP
if (tag .eq. "wrf")then
  geo = addfile(dir+geofile+suffix+".sfc.nc","r")
  lat2d = geo->lat
  lon2d = geo->lon
  z_sfc = geo->Z_sfc
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
invarv = invar+"_var"

; create all-node array for node average variable
var0     = new((/npan,n_sn,n_we/),"float")
var1     = new((/npan,n_sn,n_we/),"float")
var0_v   = new((/npan,n_sn,n_we/),"float")
var1_v   = new((/npan,n_sn,n_we/),"float")
ndates0  = new((/npan/),"integer")
ndates1  = new((/npan/),"integer")
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

; Group loading
if (type .eq. "group") then
  n = 0
  do n = 0, npan - 1
    g1 = n+1
    print("Loading group "+g1)
    prefix = "group_"+g1
    f0 = addfile(dir+prefix+suffix_xx+".sfc.nc","r")
    f1 = addfile(dir+prefix+suffix+".sfc.nc","r")
    f2 = addfile(dir+prefix+suffix_ice+".sfc.nc","r")
    var0(n,:,:)  = f0->$invar1$(:,:)
    var0_v(n,:,:) = f0->$invarv$(:,:)
    var1(n,:,:) = f1->$invar1$(:,:)
    var1_v(n,:,:) = f0->$invarv$(:,:)
    ndates0(n)   = f0->number_dates
    ndates1(n)   = f1->number_dates
    seaice(n,:,:) = f2->$insea$(:,:)
    delete([/prefix,f1,f2,f0,g1/])
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
      f0 = addfile(dir+prefix+suffix_xx+".sfc.nc","r")
      f1 = addfile(dir+prefix+suffix+".sfc.nc","r")
      f2 = addfile(dir+prefix+suffix_ice+".sfc.nc","r")
      var0(n,:,:)  = f0->$invar1$(:,:)
      var0_v(n,:,:) = f0->$invarv$(:,:)
      var1(n,:,:) = f1->$invar1$(:,:)
      var1_v(n,:,:) = f0->$invarv$(:,:)
      ndates0(n)   = f0->number_dates
      ndates1(n)   = f1->number_dates
      seaice(n,:,:) = f2->$insea$(:,:)
      delete([/prefix,f1,f2,f0/])
      n = n+1
    end do
  end do
  delete(n)
end if

; Change units as necessary
if (varcode.eq."BUOY")then
  var0 = var0*10.0^8
  var0@units = "E-8~C~m2 s-3"  
  var1 = var1*10.0^8
  var1@units = "E-8~C~m2 s-3"
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
    var0(n,:,:) = where(z_sfc .lt. 25.0, var0(n,:,:), var0@_FillValue)
    var1(n,:,:) = where(z_sfc .lt. 25.0, var1(n,:,:), var1@_FillValue)
  end if
  if (tag .eq. "pop") then
    var0(n,:,:) = where(seaice(n,:,:) .lt. 0.15, var0(n,:,:), var0@_FillValue)
    var1(n,:,:) = where(seaice(n,:,:) .lt. 0.15, var1(n,:,:), var1@_FillValue)
  end if
end do
delete(n)

; calculate difference
diff = var1 - var0   ; mon - NDJFM averages
; Calculate statistical significance
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically different.
prob = new((/npan,n_sn,n_we/),"float")
if (type .eq. "group") then
  n = 0
  do n = 0, npan - 1
    g1 = n+1
    prob(n,:,:) = 100.*(1.-ttest(var1(n,:,:),var1_v(n,:,:),ndates1(n),var0(n,:,:),var0_v(n,:,:),ndates0(n),False,False))
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
      prob(n,:,:) = 100.*(1.-ttest(var1(n,:,:),var1_v(n,:,:),ndates1(n),var0(n,:,:),var0_v(n,:,:),ndates0(n),False,False))
      n = n+1
    end do
  end do
  delete(n)
end if

; assign lat/lon info
var0@lat2d = lat2d
var0@lon2d = lon2d
var1@lat2d = lat2d
var1@lon2d = lon2d
diff@lat2d = lat2d
diff@lon2d = lon2d
prob@lat2d = lat2d
prob@lon2d = lon2d
seaice@lat2d = lat_p
seaice@lon2d = lon_p

print(varcode+" var min: "+min(var1)+"  max: "+max(var1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
print("Processing all plots for "+varcode)
; set outdir and fout names
outdir = "./"
fout_0   = varcode+"_"+type+"_avg_NDJFM_199011_201003."+tag
fout_1   = varcode+"_"+type+"_avg"+suffix
fout_d   = varcode+"_"+type+"_diff_month-"+mon+"_and_NDJFM_199011_201003."+tag
;;;;;;;;;;
; Contour intervals
;;;;;;;;;;
; NEXT
if (cmaptype.eq."wind") then
  cmin               = 0.0
  cmax               = 18.0
  clev               = 1.0
  stride             = 1  
  cmind              = -4.0
  cmaxd              = 4.0
  clevd              = 0.5
  strided            = 2                  
  plotlines          = False              
  spreadstart        = 2                  
  spreadend          = 18  
  spreadstartd       = 20
  spreadendd         = 115               
  colormap           = "SOM_wind_table_mod"
end if
if (cmaptype .eq."flux_b")then
  cmin               = -10.0
  cmax               = 10.0
  clev               = 1.0
  stride             = 2.0
  cmind              = -2.0
  cmaxd              = 2.0
  clevd              = 0.25
  strided             = 2.0
  plotlines          = False
  spreadstart        = 2 ;127
  spreadend          = 250
  spreadstartd       = 2 ;127
  spreadendd         = 250
  colormap           = "BlueYellowRed_mod"
end if

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

; set resources for normal plots
res_1                            = res
res_1@gsnSpreadColorStart        = spreadstart      ; start at color specified for each variable above
res_1@gsnSpreadColorEnd          = spreadend        ; end at color specified above
res_1@cnMinLevelValF             = cmin             ; set min contour level specified above
res_1@cnMaxLevelValF             = cmax             ; set max contour level specified above
res_1@cnLevelSpacingF            = clev             ; set contour spacing specified above

; set resources for difference plots
res_d                            = res
res_d@gsnSpreadColorStart        = spreadstartd      ; start at color specified for each variable above
res_d@gsnSpreadColorEnd          = spreadendd        ; end at color specified above
res_d@cnMinLevelValF             = cmind             ; set min contour level specified above
res_d@cnMaxLevelValF             = cmaxd             ; set max contour level specified above
res_d@cnLevelSpacingF            = clevd             ; set contour spacing specified above

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

; set resources for 95% statistical significance overlay
res_95                            = True               ; reset options
res_95@gsnLeftString              = ""
res_95@gsnRightString             = ""
res_95@gsnFrame                   = False             ; Do not draw plot 
res_95@gsnDraw                    = False             ; Do not advance fr
res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
res_95@lbLabelBarOn               = False             ; Turn off label bar
res_95@cnFillOn                   = True              ; turn on filled contours
res_95@cnMonoFillColor            = True
res_95@cnMonoFillPattern          = False
res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res_95@cnMinLevelValF             = 0.0              ; set min contour level specified above
res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
res_95@cnLevelSpacingF            = 95.0              ; set contour spacing specified above
res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling where significant and above threshold

; resources for final panel plots
res_pan                            = True
res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
res_pan@gsnMaximize                = True	      ; fill the page
res_pan@gsnPanelLabelBar           = True
res_pan@lbTitleString              = var1@units

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 0 - Winter mean of all winter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; only plot once- with DJF comparison
if (mon .eq. "DJF")then
  wks = gsn_open_wks("ps" ,fout_0)
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
      var0_2d = var0(n,:,:)
      seaice_2d = seaice(n,:,:)

    ; Method 1 (works with differing or same grids for U/V and var0)
      cplot = gsn_csm_contour_map(wks,var0_2d,res_1)
      iplot = gsn_csm_contour(wks,seaice_2d,res_ice)
      overlay(cplot,iplot)
      dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)

      plot(n) = cplot
      delete([/var0_2d,seaice_2d/])
    ; Update xpos and ypos for next time through:
      xpos = xpos + 1
      if (xpos.eq.nx_node) then
        xpos = 0
        ypos = ypos + 1
      end if
    end do
  ; Panel the group plots
    res_pan@txString                 = "1990-2010 winter "+type+ " average "+vartitle+" for NDJFM"
    res_pan@lbLabelStride              = stride
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
    cplot = gsn_csm_contour_map(wks,var0(0,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(0,:,:),res_ice)
    overlay(cplot,iplot)
    dum(0) = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
    plot(0) = cplot
    
  ; group 2 
    cplot = gsn_csm_contour_map(wks,var0(1,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(1,:,:),res_ice)
    overlay(cplot,iplot)
    dum(1) = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
    plot(1) = cplot

  ; group 3 
    cplot = gsn_csm_contour_map(wks,var0(2,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(2,:,:),res_ice)
    overlay(cplot,iplot)
    dum(2) = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
    plot(2) = cplot

  ; group 4 
    cplot = gsn_csm_contour_map(wks,var0(3,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(3,:,:),res_ice)
    overlay(cplot,iplot)
    dum(3) = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
    plot(3) = cplot

  ; group 5 
    cplot = gsn_csm_contour_map(wks,var0(4,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(4,:,:),res_ice)
    overlay(cplot,iplot)
    dum(4) = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
    plot(4) = cplot

  ; group 6 
    cplot = gsn_csm_contour_map(wks,var0(5,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(5,:,:),res_ice)
    overlay(cplot,iplot)
    dum(5) = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
    plot(5) = cplot

  ; group 7 
    cplot = gsn_csm_contour_map(wks,var0(6,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(6,:,:),res_ice)
    overlay(cplot,iplot)
    dum(6) = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
    plot(6) = cplot

  ; group 8 
    cplot = gsn_csm_contour_map(wks,var0(7,:,:),res_1)
    iplot = gsn_csm_contour(wks,seaice(7,:,:),res_ice)
    overlay(cplot,iplot)
    dum(7) = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
    plot(7) = cplot

  ; Panel the group plots
    res_pan@txString                   = "1990-2010 winter "+type+ " average "+vartitle+" for NDJFM"
    res_pan@lbLabelStride              = stride
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
  "-rotate -90 -trim -border 10 "+fout_0+".ps "+fout_0+".png")
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Winter mean of subset 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks = gsn_open_wks("ps" ,fout_1)
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

    ; Method 1 (works with differing or same grids for U/V and var1)
    cplot = gsn_csm_contour_map(wks,var1_2d,res_1)
    iplot = gsn_csm_contour(wks,seaice_2d,res_ice)
    overlay(cplot,iplot)
    dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)

    plot(n) = cplot
    delete([/var1_2d,seaice_2d/])
    ; Update xpos and ypos for next time through:
    xpos = xpos + 1
    if (xpos.eq.nx_node) then
      xpos = 0
      ypos = ypos + 1
    end if
  end do
  ; Panel the group plots
  res_pan@txString                 = "1990-2010 winter "+type+ " average "+vartitle+" for month "+mon+" subset"         ; main title
  res_pan@lbLabelStride              = stride
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
  cplot = gsn_csm_contour_map(wks,var1(0,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(0,:,:),res_ice)
  overlay(cplot,iplot)
  dum(0) = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
  plot(0) = cplot

  ; group 2 
  cplot = gsn_csm_contour_map(wks,var1(1,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(1,:,:),res_ice)
  overlay(cplot,iplot)
  dum(1) = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
  plot(1) = cplot

  ; group 3 
  cplot = gsn_csm_contour_map(wks,var1(2,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(2,:,:),res_ice)
  overlay(cplot,iplot)
  dum(2) = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
  plot(2) = cplot

  ; group 4 
  cplot = gsn_csm_contour_map(wks,var1(3,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(3,:,:),res_ice)
  overlay(cplot,iplot)
  dum(3) = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
  plot(3) = cplot

  ; group 5 
  cplot = gsn_csm_contour_map(wks,var1(4,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(4,:,:),res_ice)
  overlay(cplot,iplot)
  dum(4) = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
  plot(4) = cplot

  ; group 6 
  cplot = gsn_csm_contour_map(wks,var1(5,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(5,:,:),res_ice)
  overlay(cplot,iplot)
  dum(5) = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
  plot(5) = cplot

  ; group 7 
  cplot = gsn_csm_contour_map(wks,var1(6,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(6,:,:),res_ice)
  overlay(cplot,iplot)
  dum(6) = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
  plot(6) = cplot

  ; group 8 
  cplot = gsn_csm_contour_map(wks,var1(7,:,:),res_1)
  iplot = gsn_csm_contour(wks,seaice(7,:,:),res_ice)
  overlay(cplot,iplot)
  dum(7) = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
  plot(7) = cplot

  ; Panel the group plots
  res_pan@txString                   = "1990-2010 winter "+type+ " average "+vartitle+" for month "+mon+" subset"         ; main title
  res_pan@lbLabelStride              = stride
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
         "-rotate -90 -trim -border 10 "+fout_1+".ps "+fout_1+".png")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Difference in node average
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks = gsn_open_wks("ps" ,fout_d)
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
    diff_2d = diff(n,:,:)
    prob_2d = prob(n,:,:)

    ; Method 1 (works with differing or same grids for U/V and diff)
    cplot = gsn_csm_contour_map(wks,diff_2d,res_d)
    iplot = gsn_csm_contour(wks,prob_2d,res_95)
    overlay(cplot,iplot)
    dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)

    plot(n) = cplot
    delete([/diff_2d,prob_2d/])
    ; Update xpos and ypos for next time through:
    xpos = xpos + 1
    if (xpos.eq.nx_node) then
      xpos = 0
      ypos = ypos + 1
    end if
  end do
  ; Panel the group plots
  res_pan@txString                 = "1990-2010 winter difference "+vartitle+" ("+mon+" - NDJFM)"         ; main title
  res_pan@lbLabelStride              = stride
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
  cplot = gsn_csm_contour_map(wks,diff(0,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(0,:,:),res_95)
  overlay(cplot,iplot)
  dum(0) = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
  plot(0) = cplot

  ; group 2 
  cplot = gsn_csm_contour_map(wks,diff(1,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(1,:,:),res_95)
  overlay(cplot,iplot)
  dum(1) = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
  plot(1) = cplot

  ; group 3 
  cplot = gsn_csm_contour_map(wks,diff(2,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(2,:,:),res_95)
  overlay(cplot,iplot)
  dum(2) = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
  plot(2) = cplot

  ; group 4 
  cplot = gsn_csm_contour_map(wks,diff(3,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(3,:,:),res_95)
  overlay(cplot,iplot)
  dum(3) = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
  plot(3) = cplot

  ; group 5 
  cplot = gsn_csm_contour_map(wks,diff(4,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(4,:,:),res_95)
  overlay(cplot,iplot)
  dum(4) = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
  plot(4) = cplot

  ; group 6 
  cplot = gsn_csm_contour_map(wks,diff(5,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(5,:,:),res_95)
  overlay(cplot,iplot)
  dum(5) = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
  plot(5) = cplot

  ; group 7 
  cplot = gsn_csm_contour_map(wks,diff(6,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(6,:,:),res_95)
  overlay(cplot,iplot)
  dum(6) = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
  plot(6) = cplot

  ; group 8 
  cplot = gsn_csm_contour_map(wks,diff(7,:,:),res_d)
  iplot = gsn_csm_contour(wks,prob(7,:,:),res_95)
  overlay(cplot,iplot)
  dum(7) = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
  plot(7) = cplot

  ; Panel the group plots
  res_pan@txString                   = "1990-2010 winter difference "+vartitle+" ("+mon+" - NDJFM)"         ; main title
  res_pan@lbLabelStride              = strided
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
         "-rotate -90 -trim -border 10 "+fout_d+".ps "+fout_d+".png")


print("Completed all plots for "+varcode+". Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
