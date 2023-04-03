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
infile = "slp_a0.04_rlen1000000_r4.cod"
nx_node = 9
ny_node = 7
nnode = nx_node * ny_node
indir = "./"+nx_node+"x_"+ny_node+"y/"

print("Loading data...")
f1 = addfile("geo_em.d01.100km.nc", "r")
lat2d = f1->XLAT_M(0,:,:)
lon2d = f1->XLONG_M(0,:,:)
dims = dimsizes(lat2d)
n_sn = dims(0)
n_we = dims(1)
n_tot = n_sn * n_we

f2 = "interpolated_100km_topo.txt"
topo = asciiread(f2, -1, "float")
if (dimsizes(topo).ne.n_tot) then
  print("Topography file does not match input lat/lon!")
  exit
end if
topo@_FillValue = -999.
nsomcol = num(.not.ismissing(topo))
topoind = ind(.not.ismissing(topo))

som_header = readAsciiHead(indir+infile,1)
delim = " "
nsomcol2 = stringtoint(str_get_field(som_header,1,delim))
if (nsomcol.ne.nsomcol2) then
  print("Columns in SOM file do not match valid values in topography file!")
  exit
end if

som_nomissing = readAsciiTable(indir+infile, nsomcol, "float", 1) ; 1 = skip header
somdims = dimsizes(som_nomissing)
if (nnode.ne.somdims(0)) then
  print("Input .cod file has incorrect number of nodes!")
  exit
end if

; create array for entire domain, but only put data below 500 m into array
som = new((/nnode, n_tot/), "float")
do n = 0, nnode - 1
  som(n,topoind) = som_nomissing(n,:)
end do


outstring = flt2string(nx_node*1.0)+"x_"+flt2string(ny_node*1.0)+"y_"
outfile = outstring+infile

; ready to plot!
wks = gsn_open_wks("ps",outfile)
;wks = gsn_open_wks("x11",outfile)
gsn_define_colormap(wks,"BlWhRe")
additional_colors = (/"gray85","forestgreen", "purple"/)
gsn_merge_colormaps(wks,"blWhRe",additional_colors)

; Graphics options:
resources                         = True

resources@cnFillOn                = True
resources@cnLinesOn               = False
resources@cnInfoLabelOn           = False   

resources@tiMainFontHeightF       = 0.03    

resources@cnMissingValFillColor   = "gray85"
resources@cnMissingValFillPattern = 0 

resources@lbLabelBarOn            = False

resources@gsnFrame                = False
resources@gsnDraw                 = False
resources@gsnAddCyclic            = False
resources@gsnMaximize             = True 
resources@gsnSpreadColors         = True 
resources@gsnSpreadColorEnd       = 102  

resources@mpProjection            = "Stereographic" 
resources@mpLimitMode             = "Corners"
resources@mpLeftCornerLatF        = lat2d(0,0)
resources@mpLeftCornerLonF        = lon2d(0,0)
resources@mpRightCornerLatF       = lat2d(n_sn-1,n_we-1)
resources@mpRightCornerLonF       = lon2d(n_sn-1,n_we-1)
resources@mpCenterLonF            = f1@STAND_LON
resources@mpCenterLatF            = 90.    ; think this is a bug!
;resources@mpDataBaseVersion       = "HighRes"
resources@mpGeophysicalLineColor  = "forestgreen"
resources@mpGeophysicalLineThicknessF = 0.75
;resources@mpGridAndLimbOn         = True
;resources@mpGridLatSpacingF       = 5.
;resources@mpGridLineDashPattern   = 2.
symMinMaxPlt(som,91,True,resources)

res_over                          = True
res_over@cnLinesOn                = True
res_over@cnLineColor              = "gray85"
res_over@cnLineLabelsOn           = True
res_over@cnInfoLabelOn            = False   
res_over@cnLevelSelectionMode     = "ManualLevels"
res_over@cnMaxLevelValF           = floor(resources@cnMaxLevelValF)
res_over@cnMinLevelValF           = ceil(resources@cnMinLevelValF)
res_over@cnLevelSpacingF          = 2.
res_over@cnFillOn                 = False
res_over@gsnDraw                  = False
res_over@gsnFrame                 = False


; Actual data section:
plot = new(nnode, graphic)
xpos = 0
ypos = 0

do n = 0, nnode-1
  print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  som2d   = onedtond(som(n,:),(/n_sn,n_we/))
  som2d@lat2d = lat2d
  som2d@lon2d = lon2d

  resources@gsnRightString = "("+xpos+","+ypos+")"  ; (this changes)
  resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
  resources@gsnLeftString = round(min(som2d),3)+"/" \
        + round(max(som2d),3)+" hPa"
  resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  
  plot(n) = gsn_csm_contour_map(wks,som2d,resources)
  overlay_plot = gsn_csm_contour(wks,som2d,res_over)
  overlay(plot(n),overlay_plot)

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if

end do

print("Paneling...")

res_pan                       = True ; panel resources
res_pan@txString              = infile
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString      = "hPa"
res_pan@lbTitlePosition    = "right"
res_pan@lbLabelAutoStride  = "true"
res_pan@lbLabelFontHeightF = 0.007
res_pan@lbTitleJust        = "CenterLeft"
res_pan@lbTitleFontHeightF = .007 
res_pan@lbTitleDirection   = "Across"

gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)


end

