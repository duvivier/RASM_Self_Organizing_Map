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
; MANUAL INPUTS - for testing purposes
; ******************************************************
nx_input = "4"
ny_input = "3"
varcode = "Qgrad"
daylag = "1"
; options: "Tgrad" "Qgrad" and "1" "2" "3"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations by month")

;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
datefile = dir+"wrf50_199011_201003_dates.txt"
visfile  = dir+"wrf50_199011_201003_wind.vis"
dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
ndates = dimsizes(dates)
dateschar = stringtochar(dates)
yy = chartostring(dateschar(:,0:3))
mm = chartostring(dateschar(:,5:6))
dd = chartostring(dateschar(:,8:9))

vis = new((/ndates,3/),integer)
vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

; create filenames array
files = new((/ndates/),string)
files = "/vardar/data5/duvivier/SOM-RASM/analysis/regrid_WRF_to_POP/wrf_interp_files/wrf2pop."+yy+"-"+mm+"-"+dd+".sfc.green.nc"

files_pop = new((/ndates/),string)
files_pop = "/vardar/data5/duvivier/SOM-RASM/analysis/surface_files/pop_sfc_files/pop."+yy+"-"+mm+"-"+dd+".sfc.green.nc"

; Load 2D plotting information
geo = addfile(files(0),"r")
lat2d = geo->lat_pop
lon2d = geo->lon_pop
dims = dimsizes(lat2d)
n_sn = dims(0)
n_we = dims(1)

; Calculate node counts and frequencies for comparison of interest
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

; Note that all will be compared to change in MLD
  invar0 = "HMXL_lag"
if (daylag.eq."1")then
  level = 0
end if
if (daylag.eq."2")then
  level = 1
end if
if (daylag.eq."3")then
  level = 2
end if

; Information about variables we will correlate with change in MLD
if (varcode.eq."Tgrad")then
  vartitle = "Temperature gradient (sfc-eta0)"
  invar = "Tgrad"
end if
if (varcode.eq."Qgrad")then
  vartitle = "Moisture gradient (sfc-eta0)"
  invar = "Qgrad"
end if

; create new array to fill with correlation values
  corr = new((/nnode,n_sn,n_we/),"float")
  corr_sig = new((/nnode,n_sn,n_we/),"float")

fill = new((/1/),"float")
n = 0
;;;;;;;;;
; calculate Node correlations
;;;;;;;;;;
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   print("node: "+x+","+y)
  ; These are the dates for this particular node:
   dateindices = ind((vis(:,0).eq.x.and.vis(:,1).eq.y))
if (.not.all(ismissing(dateindices))) then
  files_sub = files(dateindices)
  files_pop_sub = files_pop(dateindices)

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; write the number of files going into the average for later statistical tests
   ndays = dim_files

  ; load the change in MLD over one day array
   ice  = new((/dim_files,n_sn,n_we/),"float")
   HMXL = new((/dim_files,n_sn,n_we/),"float")
   var  = new((/dim_files,n_sn,n_we/),"float")
  ; loop through files for this node
   f = 0
   do f = 0,dim_files - 1
     fwrf2pop = addfile(files_sub(f),"r")
     var(f,:,:)  = fwrf2pop->$invar$(:,:)
     fpop = addfile(files_pop_sub(f),"r")
     HMXL(f,:,:) = fpop->HMXL_lag(level,:,:)
     ice(f,:,:)  = fpop->ice_frac(:,:)
     delete([/fwrf2pop,fpop/])
   end do
   delete(f)  
  
  ; mask the variables based on sea ice concentration
   HMXL = where(ice .lt. 0.15, HMXL, HMXL@_FillValue)
   var  = where(ice .lt. 0.15, var, var@_FillValue)

  ; calculate cross correlation between change in MLD and variable of interest. Must do this at each point with full time series
   i = 0
   j = 0
   do i = 0,n_sn - 1
   do j = 0,n_we - 1
     corr(n,i,j) = escorc(HMXL(:,i,j),var(:,i,j))
     corr_sig (n,i,j) = 100.*(1-rtest(corr(n,i,j),ndays,0)) 
   end do
   end do
   delete([/i,j/])
  ;; delete variables to use again
  delete([/HMXL,var,ice,dim_files,node_files,dateindices,files_sub,files_pop_sub/])
else
  print("All files missing for node")
end if
  n = n + 1
end do
end do
delete(n)

; Load sea ice (1990-2010 Mar.31 sea ice concentration)
ice = addfile("/vardar/data5/duvivier/SOM-RASM/DATA/pop/daily_means_greenland/r27SOM.pop.1990-2010-03-31.green.nc","r")
seaice = ice->aice(0,:,:)

; Load node average wind vectors
geofile_wrf = "/vardar/data5/duvivier/SOM-RASM/DATA/wrf/geo_em.50km.green.nc"
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
wrf_dir = "/vardar/data5/duvivier/SOM-RASM/analysis/averages/"+nx_input+"x_"+ny_input+"y_node_avgs/" 

do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y)
   wrf = addfile(wrf_dir+"node_"+x+"x_"+y+"y_month-xx_199011_201003.wrf.sfc.nc","r")
   u(n,:,:) = wrf->u_tr_avg
   v(n,:,:) = wrf->v_tr_avg
   n = n+1
  end do
end do
delete(n)

; Mask sea ice and terrain height 
n = 0
; loop through each file
do n = 0, nnode - 1
    corr(n,:,:) = where(seaice .lt. 15.0, corr(n,:,:), corr@_FillValue)
    corr_sig(n,:,:) = where(seaice .lt. 15.0, corr_sig(n,:,:), corr_sig@_FillValue)
    u(n,:,:) = where(z_sfc .lt. 25.0, u(n,:,:), u@_FillValue)
    v(n,:,:) = where(z_sfc .lt. 25.0, v(n,:,:), v@_FillValue)
end do
delete(n)

; assign lat/lon
corr@lat2d = lat2d
corr@lon2d = lon2d
corr_sig@lat2d = lat2d
corr_sig@lon2d = lon2d
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
res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
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
res1@cnMinLevelValF             = -1.0             ; set min contour level specified above
res1@cnMaxLevelValF             = 1.0              ; set max contour level specified above
res1@cnLevelSpacingF            = 0.1             ; set contour spacing specified above

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
res_ice@cnLineThicknessF           = 2.0
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
; Create new file that corresponds to this node for averages/variances
fout1 = "./"+varcode+"_correlation_with_MLD_change_"+daylag+"day_after"
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
  sig_2d = corr_sig(n,:,:)
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
  res_pan1@txString                   = "Correlation between "+vartitle+" and change in mixed layer depth "+daylag+" day later"
  res_pan1@gsnPanelYWhiteSpacePercent = 2          ; Add white space b/w plots.
  res_pan1@gsnPanelXWhiteSpacePercent = 2          ; Add white space b/w plots.
  res_pan1@gsnPanelScalePlotIndex     = 1
  res_pan1@lbOrientation              = "Horizontal"
  res_pan1@lbTitlePosition            = "right"
  res_pan1@lbTitleDirection           = "Across"
  res_pan1@lbTitleJust                = "CenterLeft"
  res_pan1@lbTitleFontHeightF         = 0.0075
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

print("Completed correlation plots. Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
