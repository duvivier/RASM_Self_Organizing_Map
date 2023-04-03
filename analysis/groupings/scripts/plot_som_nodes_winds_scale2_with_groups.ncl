; Plot SOM nodes created by som_pak.
;
; Matt Higgins, 25 Jun 2008
; Matt Higgins, 11 Feb 2011
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
infile = "winds0.01_rlen2500000_r4.cod"
nx_node = 7
ny_node = 5
nnode = nx_node * ny_node
indir = "/data3/duvivier/SOM/training/som_75/"+nx_node+"x_"+ny_node+"y/"

print("Loading data...")
f1 = addfile("/data3/duvivier/SOM/DATA/wrf10/200511/wrf-2005-11-01_00.green10.cf.nc","r")
lat2d = f1->lat
lon2d = f1->lon
lat1D = ndtooned(lat2d)
lon1D = ndtooned(lon2d)
dims = dimsizes(lat2d)
n_sn = dims(0)
n_we = dims(1)
n_tot = n_sn * n_we


topo_2d = f1->Z_sfc
topo_2d@_FillValue = -999.
topo = ndtooned(topo_2d)
topo@_FillValue = -999.

; narrow down the values where I want winds 
; whole domain
 topo_1 = where(topo.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.70. .and. lon1D.gt.-50. .and. lon1D.lt.-20., 1, 0)

; remove box out to sea
 topo_2 = where(topo.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.64. .and. lon1D.gt.-25. .and. lon1D.lt.-20., 0, 1)

; combine topo arrays
 topo_fin = topo_1*topo_2
 topo = where(topo_fin .gt.0, topo, topo@_FillValue)

nsomcol = num(.not.ismissing(topo))
topoind = ind(.not.ismissing(topo))

som_header = readAsciiHead(indir+infile,1)
delim = " "
nsomcol2 = stringtoint(str_get_field(som_header,1,delim))
if (nsomcol.ne.nsomcol2/2) then
  print("Columns in SOM file do not match valid values in topography file!")
  exit
end if

som_nomissing = readAsciiTable(indir+infile, nsomcol2, "float", 1) ; 1 = skip header
somdims = dimsizes(som_nomissing)
if (nnode.ne.somdims(0)) then
  print("Input .cod file has incorrect number of nodes!")
  exit
end if

u_som_nomissing = som_nomissing(:,0:nsomcol2/2-1)
v_som_nomissing = som_nomissing(:,nsomcol2/2:nsomcol2-1)

; create array for entire domain, but only put data below 500 m into array
u_som = new((/nnode, n_tot/), "float")
v_som = new((/nnode, n_tot/), "float")
do n = 0, nnode - 1
  u_som(n,topoind) = u_som_nomissing(n,:)
  v_som(n,topoind) = v_som_nomissing(n,:)
end do


outstring = flt2string(nx_node*1.0)+"x_"+flt2string(ny_node*1.0)+"y_"
outfile = "./"+outstring+infile+"_groups"

; ready to plot!
colormap = "wind_color_table_SOM"
wks = gsn_open_wks("ps",outfile)
;gsn_define_colormap(wks,"wind_color_table_SOM")
gsn_merge_colormaps(wks,colormap,(/"purple","blue","lightblue","green","yellow","orange","red","pink"/))

; Graphics options:
resources                         = True

resources@gsnFrame                = False
resources@gsnDraw                 = False
resources@gsnAddCyclic            = False
resources@gsnMaximize             = True 


resources@lbLabelBarOn            = False
resources@gsnScalarContour        = True
resources@gsnSpreadColors         = True
resources@gsnSpreadColorStart     = 2 
resources@gsnSpreadColorEnd       = 35  

resources@mpProjection            = "Stereographic" 
resources@mpCenterLonF            = -35.
resources@mpCenterLatF            = 80.
resources@mpLimitMode             = "LatLon"
resources@mpMinLatF               = 56.
resources@mpMaxLatF               = 71.
resources@mpMinLonF               = -54.
resources@mpMaxLonF               = -20.
;resources@mpLimitMode             = "Points"
;resources@mpLeftPointLatF         = -78.
;resources@mpLeftPointLonF         = 160.
;resources@mpRightPointLatF        = -78.
;resources@mpRightPointLonF        = -145.
;resources@mpTopPointLatF          = -77.
;resources@mpTopPointLonF          = 180.
;resources@mpLimitMode             = "Corners"
;resources@mpLeftCornerLatF        = lat2d(0,0)
;resources@mpLeftCornerLonF        = lon2d(0,0)
;resources@mpRightCornerLatF       = lat2d(n_sn-1,n_we-1)
;resources@mpRightCornerLonF       = lon2d(n_sn-1,n_we-1)
;;resources@mpBottomPointLatF       = -87.
;;resources@mpBottomPointLonF       = 180.
;;resources@mpDataBaseVersion       = "HighRes"
resources@mpGeophysicalLineColor  = "black"
resources@mpGeophysicalLineThicknessF = 0.75
resources@mpOutlineOn              = True
resources@mpFillOn                 = False
resources@mpOutlineBoundarySets    = "AllBoundaries"

resources@tiMainFontHeightF       = 0.03   
 
resources@cnFillOn                = True
resources@cnLinesOn               = False
resources@cnInfoLabelOn           = False  
resources@cnMissingValFillColor   = "gray85"
resources@cnMissingValFillPattern = 0 
resources@cnMissingValPerimOn     = True
resources@cnMissingValPerimColor  = "black"
resources@cnLevelSelectionMode    = "ManualLevels"    ; set manual contour
resources@cnMinLevelValF          = 0.0             ; set min contour level specified above
resources@cnMaxLevelValF          = 20.             ; set max contour level specified above
resources@cnLevelSpacingF         = 1.             ; set contour spacing specified above
;resources@cnLevelSelectionMode = "ExplicitLevels"
;resources@cnLevels = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18/)

resources@vcGlyphStyle = "LineArrow"
resources@vcRefMagnitudeF = 1.0
resources@vcRefLengthF = 0.01
resources@vcMonoLineArrowColor = True
resources@vcLineArrowColor = "black"
resources@vcMinDistanceF = 0.07
resources@vcRefAnnoOn = False

; set resources for near-gale force (>13m/s)overlay
  res_gale                            = True               ; reset options
  res_gale@gsnLeftString              = ""
  res_gale@gsnRightString             = ""
  res_gale@gsnFrame                   = False             ; Do not draw plot 
  res_gale@gsnDraw                    = False             ; Do not advance fr
  res_gale@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_gale@cnFillOn                   = False             ; turn on filled contours
  res_gale@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_gale@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_gale@cnMaxLevelValF             = 13.0              ; set max contour level specified above
  res_gale@cnLevelSpacingF            = 13.0              ; set contour spacing specified above
  res_gale@cnLinesOn                  = True              ; contour lines specified above
  res_gale@cnLineLabelsOn             = True             ; line labels on specified above
  res_gale@cnLineColor                = "black"
  res_gale@cnLineThicknessF           = 2.0
  res_gale@tiXAxisOn                  = False
  res_gale@tiYAxisOn                  = False

; set resources for gentle (<5m/s)overlay
  res_gentle                            = True               ; reset options
  res_gentle@gsnLeftString              = ""
  res_gentle@gsnRightString             = ""
  res_gentle@gsnFrame                   = False             ; Do not draw plot 
  res_gentle@gsnDraw                    = False             ; Do not advance fr
  res_gentle@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_gentle@cnFillOn                   = False             ; turn on filled contours
  res_gentle@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_gentle@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_gentle@cnMaxLevelValF             = 6.0              ; set max contour level specified above
  res_gentle@cnLevelSpacingF            = 6.0              ; set contour spacing specified above
  res_gentle@cnLinesOn                  = True              ; contour lines specified above
  res_gentle@cnLineLabelsOn             = True             ; line labels on specified above
  res_gentle@cnLineColor                = "black" ;"gray85"
  res_gentle@cnLineThicknessF           = 2.0
  res_gentle@tiXAxisOn                  = False
  res_gentle@tiYAxisOn                  = False
  res_gentle@cnLineDashPattern          = 15

; Actual data section:

plot = new(nnode, graphic)
xpos = 0
ypos = 0

do n = 0, nnode-1

; code for adding group colored perimeters
  resources@mpPerimOn = True
  resources@mpPerimLineThicknessF = 4.0

if (n.eq.0.or.n.eq.1.or.n.eq.7)then
  resources@mpPerimLineColor = "orange"
end if
if (n.eq.2.or.n.eq.8.or.n.eq.9.or.n.eq.16.or.n.eq.17) then
  resources@mpPerimLineColor = "green"
end if
if (n.eq.3.or.n.eq.4.or.n.eq.10.or.n.eq.11.or.n.eq.18.or.n.eq.19) then
  resources@mpPerimLineColor = "pink"
end if
if (n.eq.5.or.n.eq.6.or.n.eq.12.or.n.eq.13.or.n.eq.20)
  resources@mpPerimLineColor = "red"
end if
if (n.eq.14.or.n.eq.21.or.n.eq.28.or.n.eq.29)
  resources@mpPerimLineColor = "blue"
end if
if (n.eq.15.or.n.eq.22.or.n.eq.23.or.n.eq.30)
  resources@mpPerimLineColor = "lightblue"
end if
if (n.eq.24.or.n.eq.25.or.n.eq.31.or.n.eq.32)
  resources@mpPerimLineColor = "yellow"
end if
if (n.eq.26.or.n.eq.27.or.n.eq.33.or.n.eq.34)
  resources@mpPerimLineColor = "purple"
end if

  print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  u_som2d   = onedtond(u_som(n,:),(/n_sn,n_we/))
  u_som2d@lat2d = lat2d
  u_som2d@lon2d = lon2d
  v_som2d   = onedtond(v_som(n,:),(/n_sn,n_we/))
  v_som2d@lat2d = lat2d
  v_som2d@lon2d = lon2d

  som2d = (/sqrt((u_som2d*u_som2d)+(v_som2d*v_som2d))/)
  som2d@lat2d = lat2d
  som2d@lon2d = lon2d

  resources@gsnRightString = "("+xpos+","+ypos+")"  ; (this changes)
  resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
  resources@gsnLeftString = round(min(som2d),3)+"/" \
        + round(max(som2d),3)+" ms-1"
  resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  
  cplot = gsn_csm_vector_scalar_map(wks,u_som2d,v_som2d,som2d,resources)
  cplot2 = gsn_csm_contour(wks,som2d,res_gale)
  overlay(cplot,cplot2)
  cplot3 = gsn_csm_contour(wks,som2d,res_gentle)
  overlay(cplot,cplot3)
  plot(n) = cplot


; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if

end do

print("Paneling...")

res_pan                       = True ; panel resources
res_pan@txString              = "7x 5y Master SOM: with groups"
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = "ms-1"
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelAutoStride     = "true"
res_pan@lbLabelFontHeightF    = 0.007
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = .007 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)

; convert to png
  convert_cmd = "convert -density 300 "+outfile+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+outfile+".png"

  system(convert_cmd)


end

