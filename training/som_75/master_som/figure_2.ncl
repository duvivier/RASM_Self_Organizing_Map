; Plot SOM nodes created by som_pak.
;
; Alice DuVivier - March 2014

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

infile = "6x_5y-wind-a0.04_rlen250000_r2-flip.cod"
nx_node = 6
ny_node = 5
nnode = nx_node * ny_node
indir = "/data5/duvivier/SOM-RASM/training/masters/"

print("Loading data...")
f1 = addfile("/data5/duvivier/SOM-RASM/DATA/wrf/geo_em.50km.green.nc","r")
lat2d = f1->XLAT_M(0,:,0:66)
lon2d = f1->XLONG_M(0,:,0:66)
lat1D = ndtooned(lat2d)
lon1D = ndtooned(lon2d)
dims = dimsizes(lat2d)
n_sn = dims(0)
n_we = dims(1)
n_tot = n_sn * n_we

topo_2d = f1->HGT_M(0,:,0:66)
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
outfile = "./"+outstring+"winds_master"

; ready to plot!
wks = gsn_open_wks("ps",outfile)
;gsn_define_colormap(wks,"WhiteYellowOrangeRed")
gsn_define_colormap(wks,"wind_color_table_SOM")

; Graphics options:
resources                         = True

resources@gsnFrame                = False
resources@gsnDraw                 = False
resources@gsnAddCyclic            = False
resources@gsnMaximize             = True 


resources@lbLabelBarOn            = False

resources@gsnSpreadColors         = True 
resources@gsnScalarContour        = True
resources@gsnSpreadColorStart     = 2
resources@gsnSpreadColorEnd       = 35  

resources@mpProjection            = "Stereographic" 
resources@mpCenterLonF            = -35.
resources@mpCenterLatF            = 63.
resources@mpLimitMode             = "LatLon"
resources@mpMinLatF               = 56.
resources@mpMaxLatF               = 70.
resources@mpMinLonF               = -52. ;-54.
resources@mpMaxLonF               = -23. ;-20. ;-15.
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

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.08
txres@txFontThicknessF            = 2.0

; Actual data section:

plot = new(nnode, graphic)
xpos = 0
ypos = 0

do n = 0, nnode-1
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

  cplot = gsn_csm_vector_scalar_map(wks,u_som2d,v_som2d,som2d,resources)
  cplot2 = gsn_csm_contour(wks,som2d,res_gale)
  overlay(cplot,cplot2)
  dum = new(1,graphic)
  dum = gsn_add_text(wks,cplot, "("+xpos+","+ypos+")", lon_t, lat_t, txres)
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
;res_pan@txString              = "Master SOM of near surface winds and pattern groups"
;res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnPanelYWhiteSpacePercent = 4        ; Add white space b/w plots.
res_pan@gsnPanelXWhiteSpacePercent = 4        ; Add white space b/w plots.
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = "m s-1"
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelAutoStride     = "true"
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.015 
res_pan@lbTitleDirection      = "Across"
res_pan@pmLabelBarWidthF      = 0.99 ;0.75
res_pan@pmLabelBarHeightF     = 0.09

gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)

; convert to png
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
       "-rotate -90 "+outfile+".ps "+outfile+".png")

end

