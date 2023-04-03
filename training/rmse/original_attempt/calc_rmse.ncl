;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
  data_name = "wrf10_wrf50_erai"
  indir = "./"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
codfile = master_vals+".cod"   ; this is the master som values
visfile = data_name+"_"+master_vals+".vis"  ; gives node data maps to
datfile = data_name+"_wind.dat"           ; data

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
print("loading cod file")
som_header = readAsciiHead(indir+codfile,1)
delim = " "
nsomcol = stringtoint(str_get_field(som_header,1,delim))
cod_1 = readAsciiTable(indir+codfile, nsomcol, "float", 1) ; 1 = skip header
; get info on dimensions
dims = dimsizes(cod_1)
nnodes = dims(0)
nvect  = dims(1)
delete(dims)

print("loading vis file")
vis_1 = readAsciiTable(indir+visfile,3,"integer",1) ; ignores first row
dims = dimsizes(vis_1)
ndate = dims(0)



return

print("loading dat file")
dat_1 = readAsciiTable(indir+datfile,nvect,"double",1)
return


infile = "winds0.01_rlen2500000_r4.cod"
nx_node = 7
ny_node = 5
nnode = nx_node * ny_node
indir = "./"+nx_node+"x_"+ny_node+"y/"

print("Loading data...")
f1 = addfile("/data3/duvivier/SOM/DATA/WRF10/200511/wrf-2005-11-01_00.green10.cf.nc","r")
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
outfile = "./"+outstring+infile

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
resources@gsnSpreadColorEnd       = -2  

resources@mpProjection            = "Stereographic" 
resources@mpCenterLonF            = -35.
resources@mpCenterLatF            = 80.
resources@mpLimitMode             = "LatLon"
resources@mpMinLatF               = 54.
resources@mpMaxLatF               = 72.
resources@mpMinLonF               = -57.
resources@mpMaxLonF               = -18.
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
resources@cnMaxLevelValF          = 25.             ; set max contour level specified above
resources@cnLevelSpacingF         = 1.             ; set contour spacing specified above
;resources@cnLevelSelectionMode = "ExplicitLevels"
;resources@cnLevels = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18/)

resources@vcGlyphStyle = "LineArrow"
resources@vcRefMagnitudeF = 1.0
resources@vcRefLengthF = 0.01
resources@vcMonoLineArrowColor = True
resources@vcLineArrowColor = "black"
resources@vcMinDistanceF = 0.05
resources@vcRefAnnoOn = False


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

  resources@gsnRightString = "("+xpos+","+ypos+")"  ; (this changes)
  resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
  resources@gsnLeftString = round(min(som2d),3)+"/" \
        + round(max(som2d),3)+" ms-1"
  resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  
  plot(n) = gsn_csm_vector_scalar_map(wks,u_som2d,v_som2d,som2d,resources)


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

