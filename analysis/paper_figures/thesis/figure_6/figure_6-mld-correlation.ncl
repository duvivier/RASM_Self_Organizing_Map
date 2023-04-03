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
  nx_input = "4"
  ny_input = "3"
  mon = "NDJFM"   ; DJF or NDJFM
; to skip around to sections search for "NEXT"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing mld change, frequency correlation maps for "+mon)
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

;;;;;;;;;;
; Arrays of years to go through (20 seasons)
;;;;;;;;;;
; year that starts winter season
ys = (/"1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009"/)
; year that ends winter season
ye = (/"1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010"/)

; total number of seasons to loop through
nseas = dimsizes(ys)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in frequency data and calculate frequency for each season
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT

print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
infile = dir+nx_input+"x_"+ny_input+"y_199011_201003_dates_persistence.txt"
data = asciiread(infile,-1,"string")
ndates = dimsizes(data)
nx = new((/ndates/),"string")    ; nx assignment
ny = new((/ndates/),"string")    ; ny assignment
ym = new((/ndates/),"string")    ; year start

; load everything as characters for now, will convert to string as necessary
t = 0
do t=0, ndates -1
  dum = stringtochar(data(t))
  nx(t) = chartostring(dum(0))
  ny(t) = chartostring(dum(2))
  ym(t) = chartostring(dum(4:10))
  delete(dum)
end do
delete(data)

;;;;;;;;;;
; Calculate frequency for each winter season
;;;;;;;;;;
nodefreq = new((/nseas,nnode/),"float")
n = 0
x = 0
y = 0
s = 0
; loop through each node
do s = 0, nseas -1
   ; get total days going into each winter season (should be same over all 20 years, but verify)
   check = 0
   if (mon .eq. "NDJFM")then
      total_dates = ind((ym.eq.ys(s)+"-11").or.(ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02").or.(ym.eq.ye(s)+"-03"))
   end if
   if (mon .eq. "DJF")then
      total_dates = ind((ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02"))
   end if
   if (.not.all(ismissing(total_dates))) then
     season_ndates = dimsizes(total_dates)
   else
     print("This winter season is not showing any days")
   end if
   ; reset value that is used in variable for # nodes
   n = 0
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y+" and winter season "+s)
   if (mon .eq. "NDJFM")then
      dateindices = ind(((ym.eq.ys(s)+"-11").or.(ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02").or.(ym.eq.ye(s)+"-03")).and.(nx.eq.x .and. ny.eq.y))
   end if
   if (mon .eq. "DJF")then
      dateindices = ind(((ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02")).and.(nx.eq.x .and. ny.eq.y))
   end if

  ; These are the dates for this particular node:
  ; This is the data for this node:
   if (all(ismissing(dateindices))) then
     node_ndates = 0
     nodefreq(s,n) = 0
   end if
   if (.not.all(ismissing(dateindices))) then
     node_ndates = dimsizes(dateindices)
     nodefreq(s,n) = (int2flt(node_ndates)/int2flt(season_ndates))*100.
   end if
   n = n+1
   check = check + node_ndates
   delete(dateindices)
  end do
end do
; check if every day in this season was accounted for
if (check.ne.season_ndates) then
   print("Error.  Number of dates is not equal to total number of indices.")
   print("Num. dates: "+season_ndates+"   Tot indices: "+check)
end if
delete([/total_dates,check/])
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in start and end file to calculate change in MLD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
; path where POP data resides
dir = "/vardar/data5/duvivier/SOM-RASM/"
path =  dir+"analysis/surface_files/pop_sfc_old/"
;path =  dir+"analysis/surface_files/pop_sfc_files/"

; get geography data
geo = addfile(path+"pop.1990-11-01.sfc.green.nc","r")
lat2d = geo->TLAT
lon2d = geo->TLONG
dims = dimsizes(lat2d)
dim_sn = dims(0)
dim_we = dims(1)
delete(dims)

; make array for change in MLD over each season
delta_mld = new((/dim_sn,dim_we,nseas/),"float")
; loop through seasons to load and calculate change in MLD
s = 0
do s = 0, nseas -1
   if (mon .eq. "NDJFM")then
     fstart = addfile(path+"pop."+ys(s)+"-11-01.sfc.green.nc","r")
     fend   = addfile(path+"pop."+ye(s)+"-03-31.sfc.green.nc","r")
   end if
   if (mon .eq. "DJF")then
     fstart = addfile(path+"pop."+ys(s)+"-12-01.sfc.green.nc","r")
     fend   = addfile(path+"pop."+ye(s)+"-02-28.sfc.green.nc","r")
   end if
   ; get spatial maps of starting and ending HMXL depths
   mld_st = fstart ->HMXL
   mld_ed = fend ->HMXL   
   ; calculate difference in MLD in meters
   delta_mld(:,:,s) = (mld_ed - mld_st)/100.0
   delete([/fstart,fend,mld_st,mld_ed/]) 
end do

; get overall 20 winter mean change in MLD over this season
mean_delta_mld = dim_avg_n_Wrap(delta_mld,2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Correlate change in MLD to frequency for each node
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
print("calculating correlation maps")
; make array for correlation maps
corr = new((/nnode,dim_sn,dim_we/),"float")
sig = new((/nnode,dim_sn,dim_we/),"float")

n = 0
do n = 0, nnode - 1
   corr(n,:,:) = escorc(nodefreq(:,n),delta_mld)
   sig(n,:,:) = 100.*(1-rtest(corr(n,:,:),nseas,0))
end do

; Load sea ice (1990-2010 Feb.28 or Mar.31 sea ice concentration)
if (mon .eq. "NDJFM")then
   ice = addfile(dir+"DATA/pop/daily_means_greenland/r27SOM.pop.1990-2010-03-31.green.nc","r")
end if
if (mon .eq. "DJF")then
   ice = addfile(dir+"DATA/pop/daily_means_greenland/r27SOM.pop.1990-2010-02-28.green.nc","r")
end if
seaice = ice->aice(0,:,:)

; Load node average wind vectors
geofile_wrf = dir+"DATA/wrf/geo_em.50km.green.nc"
wrf = addfile(geofile_wrf,"r")
lat2d_w = wrf->XLAT_M(0,:,0:66)
lon2d_w = wrf->XLONG_M(0,:,0:66)
z_sfc = wrf->HGT_M(0,:,0:66)
dims = dimsizes(lat2d_w)
dims_ne_w = dims(0)
dims_we_w = dims(1)
u = new((/nnode,dims_ne_w,dims_we_w/),"float")
v = new((/nnode,dims_ne_w,dims_we_w/),"float")
delete([/dims,dims_ne_w,dims_we_w,wrf/])
n = 0
x = 0
y = 0
; loop through each node
if (mon .eq. "NDJFM")then
   wrf_dir = dir+"analysis/averages/"+nx_input+"x_"+ny_input+"y_node_avgs/" 
end if
if (mon .eq. "DJF")then
   wrf_dir = dir+"analysis/averages_ndays/"+nx_input+"x_"+ny_input+"y_node_avgs/"
end if

do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y+" and winter season "+s)
    if (mon .eq. "NDJFM")then
       wrf = addfile(wrf_dir+"node_"+x+"x_"+y+"y_month-xx_199011_201003.wrf.sfc.nc","r")
    end if
    if (mon .eq. "DJF")then
       wrf = addfile(wrf_dir+"node_"+x+"x_"+y+"y_month-DJF_persist-1p_199011_201003.wrf.sfc.nc","r")
    end if
    u(n,:,:) = wrf->u_tr_avg
    v(n,:,:) = wrf->v_tr_avg
   n = n+1
  end do
end do

; Mask sea ice and terrain height 
mean_delta_mld = where(seaice .lt. 15.0, mean_delta_mld, mean_delta_mld@_FillValue)
n = 0
; loop through each file
do n = 0, nnode - 1
    corr(n,:,:) = where(seaice .lt. 15.0, corr(n,:,:), corr@_FillValue)
    sig(n,:,:) = where(seaice .lt. 15.0, sig(n,:,:), sig@_FillValue)
    u(n,:,:) = where(z_sfc .lt. 25.0, u(n,:,:), u@_FillValue)
    v(n,:,:) = where(z_sfc .lt. 25.0, v(n,:,:), v@_FillValue)
end do
delete(n)

; assign lat/lon
mean_delta_mld@lat2d = lat2d
mean_delta_mld@lon2d = lon2d
corr@lat2d = lat2d
corr@lon2d = lon2d
sig@lat2d = lat2d
sig@lon2d = lon2d
seaice@lat2d = lat2d
seaice@lon2d = lon2d
u@lat2d = lat2d_w
u@lon2d = lon2d_w
v@lat2d = lat2d_w
v@lon2d = lon2d_w

print("correlation min: "+min(corr)+"  max: "+max(corr))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NEXT
print("Processing node correlation maps")
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
res@trGridType                  = "TriangularMesh"

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
res@cnLinesOn                   = False             ; contour lines specified above
res@cnLineLabelsOn              = False       
res@cnMissingValFillColor       = "gray85"          ; missing value color
res@cnMissingValFillPattern     = 0                 ; fill in
res@cnMissingValPerimOn         = True
res@cnMissingValPerimColor      = "black"
res@tiMainFontHeightF           = 0.013
res@lbLabelBarOn                = False
res@cnInfoLabelOn               = False

; correlation contour resources
res1                            = res
res1@gsnSpreadColorStart        = 2                ; start at color specified for each variable above
res1@gsnSpreadColorEnd          = 250              ; end at color specified above
res1@cnMinLevelValF             = -0.8 ;-1.0             ; set min contour level specified above
res1@cnMaxLevelValF             = 0.8 ;1.0              ; set max contour level specified above
res1@cnLevelSpacingF            = 0.1             ; set contour spacing specified above

; MLD mean change contour resources
res2                            = res
res2@gsnSpreadColorStart        = 2                ; start at color specified for each variable above
res2@gsnSpreadColorEnd          = 250              ; end at color specified above
if (mon .eq. "DJF")then
   res2@cnMinLevelValF             = -750.             ; set min contour level specified above
   res2@cnMaxLevelValF             = 750.              ; set max contour level specified above
   res2@cnLevelSpacingF            = 75.             ; set contour spacing specified above
end if
if (mon .eq. "NDJFM")then
   res2@cnMinLevelValF             = -750.             ; set min contour level specified above
   res2@cnMaxLevelValF             = 750.              ; set max contour level specified above
   res2@cnLevelSpacingF            = 75.             ; set contour spacing specified above
end if

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

; set resources for 95% statistical significance overlay
; set statistical significance
siglvl = 0.05   ; 95% significance level using r-test
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
  res_95@cnMaxLevelValF             = 95.0              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.0              ; set contour spacing specified above
;  res_95@cnFillPatterns             = (/17, -1, 17/)    ; stipling where not significant
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling where significant and above threshold
  res_95@trGridType                  = "TriangularMesh"

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

; resources for final panel plot
res_pan                            = True
res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
res_pan@gsnMaximize                = True	      ; fill the page
res_pan@gsnPanelLabelBar           = True
;res_pan@lbTitleString              = corr@units
res_pan@lbLabelStride              = 2

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Correlation map 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fout1 = "./figure_6-mld-correlation"
wks = gsn_open_wks("ps" ,fout1)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,"BlueYellowRed_mod",additional_colors)
plot = new(nnode, graphic)
dum = new(nnode, graphic)

xpos = 0
ypos = 0
n = 0
do n = 0, nnode-1
  print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  corr_2d = corr(n,:,:)
  sig_2d = sig(n,:,:)
  U_2d = u(n,:,:)
  V_2d = v(n,:,:)
 
  ; Method 1 (works with differing or same grids for U/V and var1)
  cplot = gsn_csm_contour_map(wks,corr_2d,res1)
  iplot = gsn_csm_contour(wks,seaice,res_ice)
  splot = gsn_csm_contour(wks,sig_2d,res_95)
  vplot = gsn_csm_vector(wks,U_2d,V_2d,vcres)
  overlay(cplot,iplot)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t, lat_t, txres)
  plot(n) = cplot
  delete([/corr_2d,sig_2d,U_2d,V_2d/])
  ; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do
  ; Panel the group plots
  res_pan1                            = res_pan
  res_pan1@txString                   = "Correlation between pattern frequency and November to March change in mixed layer depth: 1990-2010"
  res_pan1@gsnPanelYWhiteSpacePercent = 2          ; Add white space b/w plots.
  res_pan1@gsnPanelXWhiteSpacePercent = 2          ; Add white space b/w plots.
  res_pan1@gsnPanelScalePlotIndex     = 1
  res_pan1@lbOrientation              = "Horizontal"
  res_pan1@lbTitlePosition            = "right"
  res_pan1@lbTitleDirection           = "Across"
  res_pan1@lbTitleJust                = "CenterLeft"
  res_pan1@lbTitleFontHeightF         = 0.015 ;0.0075
  res_pan1@lbLabelFontHeightF         = 0.0095
  res_pan1@pmLabelBarWidthF           = 0.975
  res_pan1@pmLabelBarHeightF          = 0.075
  res_pan1@txFontHeightF              = 0.015
  gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan1)      ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - 20 year winter mean mld change
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting mean MLD change for winter season")
fout2 = "./mld_mean_change_"+mon+"_"+nx_input+"x_"+ny_input+"y"
wks = gsn_open_wks("ps" ,fout2)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,"BlueYellowRed_mod",additional_colors)
plot2 = new(1, graphic)

cplot = gsn_csm_contour_map(wks,mean_delta_mld,res2)
iplot = gsn_csm_contour(wks,seaice,res_ice)
overlay(cplot,iplot)
plot2(0) = cplot

; Panel the group plots
res_pan2                           = res_pan
res_pan2@txString                  = "Seasonal "+mon+" change in mixed layer for 20 winter seasons (+ = deepening)"
res_pan2@gsnPanelYWhiteSpacePercent = 2         ; Add white space b/w plots.
res_pan2@gsnPanelXWhiteSpacePercent = 2         ; Add white space b/w plots.
res_pan2@gsnPanelScalePlotIndex     = 1
res_pan2@lbOrientation              = "Horizontal"
res_pan2@lbTitlePosition            = "right"
res_pan2@lbTitleDirection           = "Across"
res_pan2@lbTitleJust                = "CenterLeft"
res_pan2@lbTitleFontHeightF         = 0.0075
res_pan2@lbLabelFontHeightF         = 0.0095
res_pan2@pmLabelBarWidthF           = 0.975
res_pan2@pmLabelBarHeightF          = 0.075
res_pan2@txFontHeightF              = 0.015
gsn_panel(wks,plot2,(/1,1/),res_pan2)      ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout2+".ps "+fout2+".png")



print("Completed all correlation plots. Good job!")

;;;;;;;;;;;;;;;;;;;;;; END script
end
