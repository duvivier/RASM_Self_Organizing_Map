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
  varcode = "HMXL_pcnt"
  nx = "4"
  ny = "3"
  mon = "NDJFM"   ; if passed as doing monthly average or not  
  per = "1p"
; to skip around to sections search for "NEXT"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all plots for "+varcode)
  nx_node = stringtoint(nx)
  ny_node = stringtoint(ny)
  nnode = nx_node*ny_node
;;;;;;;;;;
; Variable details
;;;;;;;;;;
if (varcode.eq."HMXL_pcnt")then
  vartitle = "mixed layer depth anomaly as percent of mean mixed layer depth"
  invar = "HMXL_pcnt"
  cmaptype = "mld_pcnt"
  vartype = "2d"
  tag = "pop"
end if

;;;;;;;;;;
; Contour intervals
;;;;;;;;;;
if (cmaptype.eq."mld_pcnt") then
  cmin               = -80.0
  cmax               = 80.0
  clev               = 10.0
  stride             = 2.0                  
  plotlines          = False              
  spreadstart        = 2                  
  spreadend          = 250              
  colormap           = "BlueYellowRed_mod"
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in data from average files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set data input directory and fin suffix
dir_main = "/vardar/data5/duvivier/SOM-RASM/"
dir_data = dir_main+"analysis/averages_ndays/"+nx+"x_"+ny+"y_node_avgs/"
; set geography data paths
geofile_w = dir_main+"DATA/wrf/geo_em.50km.green.nc"
geofile_p = dir_main+"DATA/pop/pop_geofile.nc"

; set suffix based on if this is monthly sub data or not
suffix = "_month-"+mon+"_persist-"+per+"_199011_201003."+tag
suffix_wind = "_month-"+mon+"_persist-"+per+"_199011_201003.wrf"
suffix_ice = "_month-"+mon+"_persist-"+per+"_199011_201003.pop"
; set outdir and fout names
outdir = "./"
fout   = outdir+"figure_6-node_avg_mld_pcnt"

; Load in lat/lon info for WRF or POP
if (tag .eq. "wrf")then
  geo = addfile(geofile_w,"r")
  lat2d = geo->XLAT_M(0,:,0:66)
  lon2d = geo->XLONG_M(0,:,0:66)
end if
if (tag .eq. "pop")then
  geo = addfile(geofile_p,"r")
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
var1     = new((/nnode,n_sn,n_we/),"float")
;ndates   = new((/nnode/),"integer")
fill = var1@_FillValue

; Load sea ice for masking
geo_p = addfile(geofile_p,"r")
lat_p = geo_p->TLAT
lon_p = geo_p->TLONG
dims = dimsizes(lat_p)
n_sn_p = dims(0)
n_we_p = dims(1)
seaice = new((/nnode,n_sn_p,n_we_p/),"float")
insea = "ice_frac_avg"
delete([/geo_p,dims,n_sn_p,n_we_p/]) 

; Load wind vectors for overlay
geo_w = addfile(geofile_w,"r")
lat_w = geo_w->XLAT_M(0,:,0:66)
lon_w = geo_w->XLONG_M(0,:,0:66)
z_sfc = geo_w->HGT_M(0,:,0:66)
dims = dimsizes(lat_w)
n_sn_w = dims(0)
n_we_w = dims(1)
u_vect   = new((/nnode,n_sn_w,n_we_w/),"float")
v_vect   = new((/nnode,n_sn_w,n_we_w/),"float")
invar_u_vec = "u_tr_avg"
invar_v_vec = "v_tr_avg"
delete([/geo_w,dims,n_sn_w,n_we_w/])

  n = 0
  y = 0
  x = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      print("Loading node "+x+"x "+y+"y")
      prefix = "node_"+x+"x_"+y+"y"
      f1 = addfile(dir_data+prefix+suffix+".sfc.nc","r")
      f2 = addfile(dir_data+prefix+suffix_ice+".sfc.nc","r")
      f3 = addfile(dir_data+prefix+suffix_wind+".sfc.nc","r")
      var1(n,:,:) = f1->$invar1$(:,:)
      ;ndates(n)   = f1->number_dates
      seaice(n,:,:) = f2->$insea$(:,:)
      u_vect(n,:,:) = f3->$invar_u_vec$(:,:)
      v_vect(n,:,:) = f3->$invar_v_vec$(:,:)
      delete([/prefix,f1,f2,f3/])
      n = n+1
    end do
  end do
  delete(n)
print("Loaded "+vartitle)


;;;;;;;;;;
; Mask terrain or sea ice
;;;;;;;;;;
; NEXT
print("Masking variable")
n = 0
; loop through each file
do n = 0, nnode - 1
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
res@mpGeophysicalLineThicknessF = 2.5              ; Make continents thinner
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
vcres@vcRefMagnitudeF            = 10.0
vcres@vcRefLengthF               = 0.05
vcres@vcMonoLineArrowColor       = True
vcres@vcLineArrowColor           = "black"
vcres@vcMinDistanceF             = 0.07
vcres@vcRefAnnoOn                = False
vcres@gsnLeftString              = ""
vcres@gsnRightString             = ""
vcres@vcRefAnnoFontHeightF       = 0.025
vcres@vcRefAnnoString1           = "10 m/s"
vcres@vcRefAnnoString2           = ""
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
res_ice@cnLineThicknessF           = 3.0
res_ice@tiXAxisOn                  = False
res_ice@tiYAxisOn                  = False
res_ice@trGridType                 = "TriangularMesh"

; resources for final panel plot
res_pan                            = True
res_pan@txString                   = "" ;"RASM pattern average mixed layer depth anomaly as percent of mean: 1990-2010 winter months (NDJFM)" 
res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
res_pan@gsnMaximize                = True	      ; fill the page
res_pan@gsnPanelLabelBar           = True
res_pan@lbTitleString              = var1@units
res_pan@lbLabelStride              = stride

; label lat/lon
lat_t1 = 69.0
lon_t1 = -40.5
lat_t2 = 67.0
lon_t2 = -41.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Winter mean 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(nnode, graphic)
dum1 = new(nnode, graphic)

  xpos = 0
  ypos = 0
  n = 0
  do n = 0, nnode-1
    print("Plotting graph "+n+" ("+xpos+","+ypos+")")
    var1_2d = var1(n,:,:)
    seaice_2d = seaice(n,:,:)
    U_2d = u_vect(n,:,:)
    V_2d = v_vect(n,:,:) 

    ; turn on vector reference for just single plot
    if (n .eq. nnode-1)then
       vcres@vcRefAnnoOn                = True
    end if

    ; Method 1 (works with differing or same grids for U/V and var1)
    cplot = gsn_csm_contour_map(wks,var1_2d,res)
    iplot = gsn_csm_contour(wks,seaice_2d,res_ice)
    vplot = gsn_csm_vector(wks,U_2d,V_2d,vcres)
    overlay(cplot,iplot)
    overlay(cplot,vplot)
    dum1(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t1, lat_t1, txres)
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
  res_pan@lbTitleFontHeightF         = 0.015 ;0.0075
  res_pan@lbLabelFontHeightF         = 0.0095
  res_pan@pmLabelBarWidthF           = 0.975
  res_pan@pmLabelBarHeightF          = 0.075
  res_pan@txFontHeightF              = 0.015
  gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)      ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")
print("Completed all plots for "+varcode+". Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
