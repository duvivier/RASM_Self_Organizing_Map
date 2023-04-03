;***************************************
; PROGRAM DESCRIPTION: Calculate cross node correlations
; INPUT DATA: Master som data
; OUTPUT DATA: Plot of correlation of each node with other nodes
; CREATOR: Alice DuVivier - October 2013
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
  infile   = "wind-a0.03_rlen500000_r3-flip.cod"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Preliminary domain information
;;;;;;;;;;
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node * ny_node
indir = "/data5/duvivier/SOM-RASM/analysis/"+nx_node+"x_"+ny_node+"y_files/"

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

;;;;;;;;;;
; Load actual Master SOM data
;;;;;;;;;;
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
; calculate wind speed
  ws_som = sqrt(u_som^2 + v_som^2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Do statistical analysis - loop through all nodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
a = 0
do a = 0, nnode - 1
stat_node = a

;;;;;;;;;;;;;
; Correlate the node chosen with the other nodes
;;;;;;;;;;;;;
print("Calculating correlation between node "+stat_node+" and all other nodes")

; preallocate arrays
u_som_corr  = new((/nnode/), "float")
v_som_corr  = new((/nnode/), "float")
ws_som_corr = new((/nnode/), "float")

do n = 0, nnode-1
  u_som_corr(n)  = escorc(u_som(n,:),u_som(stat_node,:))
  v_som_corr(n)  = escorc(v_som(n,:),v_som(stat_node,:))
  ws_som_corr(n) = escorc(ws_som(n,:),ws_som(stat_node,:))
end do

;;;;;;;;;;;;;
; Calculate RMSE for the node chosen with the other nodes
;;;;;;;;;;;;;
print("Calculating RMSE between node "+stat_node+" and all other nodes")

; preallocate arrays
u_som_rmse  = new((/nnode/), "float")
v_som_rmse  = new((/nnode/), "float")
ws_som_rmse = new((/nnode/), "float")

npts = dimsizes(topoind)

do n = 0, nnode-1
  ; u component
  dum = sum((u_som(n,:)-u_som(stat_node,:))^2) ; sum of bias squared     
  u_som_rmse(n)  = sqrt(dum/npts)
  delete(dum)
  ; v component
  dum = sum((v_som(n,:)-v_som(stat_node,:))^2) ; sum of bias squared     
  v_som_rmse(n)  = sqrt(dum/npts)
  delete(dum)
  ; ws component
  dum = sum((ws_som(n,:)-ws_som(stat_node,:))^2) ; sum of bias squared     
  ws_som_rmse(n)  = sqrt(dum/npts)
  delete(dum)
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot results
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot 1 - correlation
; Plot 2 - RMSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Nodes of correlations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot 1 - node correlations")
  fout1 = "corr_node_"+stat_node
  title = "Node "+stat_node+" correlation with other nodes: Wind speed, U, V"

  wks1 = gsn_open_wks("ps",fout1)
  gsn_define_colormap(wks1,"gsdtol")
  gsn_reverse_colormap(wks1)
  ;colors = gsn_retrieve_colormap(wks1) ; load fixed map into "colors"
  ;additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  ;gsn_merge_colormaps(wks1,colors,additional_colors)

; Begin plotting:    
  plot  = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)
  dum5  = new((/nnode/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_node
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_node
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  res_blank@tiXAxisString                  = "SOM Pattern"
  res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks1,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "black"
  res_txt@txBackgroundFillColor = "white"

  ; make data into som size for plotting
  u_corr_2d  = onedtond(u_som_corr, (/ny_node,nx_node/))
  v_corr_2d  = onedtond(v_som_corr, (/ny_node,nx_node/))
  ws_corr_2d = onedtond(ws_som_corr, (/ny_node,nx_node/))
  ; reverse rows for plotting
  u_corr_2d  = u_corr_2d(::-1,:)
  v_corr_2d  = v_corr_2d(::-1,:)
  ws_corr_2d = ws_corr_2d(::-1,:)

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Get grey scales(same used for all data sets)
    maxcorr = 1.0  ; the node plotted will always have a correlation of 1
    mincorr = 0.0  ; no correlation
    if (maxcorr.ne.0) then
      slope = (32. - 2.) / (maxcorr - mincorr)  ; use 32 because there are 32 colors
    else
      slope = 0
    end if
    ; How to deal with negative correlations
    gray_index = slope * ws_corr_2d(y,x) + 2.
    if(gray_index.le.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks1, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks1, plot, xp, yp, res_poly)

      ; Correlation text:
      text_1 = "WS:"+sprintf("%5.2f",ws_corr_2d(y,x))
      dum3(n) = gsn_add_text(wks1, plot, text_1, xp(0)+.5, yp(0)+.8, res_txt)
      delete(text_1)

      text_2 = "U:"+sprintf("%5.2f",u_corr_2d(y,x))
      dum4(n) = gsn_add_text(wks1, plot, text_2, xp(0)+.5, yp(0)+.5, res_txt)   
      delete(text_2)
          
      text_3 = "V:"+sprintf("%5.2f",v_corr_2d(y,x))
      dum5(n) = gsn_add_text(wks1, plot, text_3, xp(0)+.5, yp(0)+.25, res_txt)   
      delete(text_3)

      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
  
; Finally - make plot
  draw(plot)
  frame(wks1)
  print("converting plot 1 to png")
  delete(wks1)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 "+fout1+".ps "+fout1+".png")

;delete(res_blank)
;delete(res_poly)
;delete(res_txt)
delete(slope)
delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(dum4)
delete(dum5)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Nodes of rmse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot 2 - node rmse")
  fout2 = "rmse_node_"+stat_node
  title = "Node "+stat_node+" rmse with other nodes: Wind speed, U, V"

  wks2 = gsn_open_wks("ps",fout2)
  gsn_define_colormap(wks2,"gsdtol")
;  gsn_reverse_colormap(wks1)

  delete(res_blank@tiMainString)
  res_blank@tiMainString                   = title
; Begin plotting:    
  plot  = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)
  dum5  = new((/nnode/),graphic)

  plot = gsn_blank_plot(wks2,res_blank)

  ; make data into som size for plotting
  u_rmse_2d  = onedtond(u_som_rmse, (/ny_node,nx_node/))
  v_rmse_2d  = onedtond(v_som_rmse, (/ny_node,nx_node/))
  ws_rmse_2d = onedtond(ws_som_rmse, (/ny_node,nx_node/))
  ; reverse rows for plotting
  u_rmse_2d  = u_rmse_2d(::-1,:)
  v_rmse_2d  = v_rmse_2d(::-1,:)
  ws_rmse_2d = ws_rmse_2d(::-1,:)

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Get grey scales(same used for all data sets)
    maxrmse = max(ws_rmse_2d)  ; maximum rmse
    minrmse = 0.0  ; the node plotted will always have a rmse of 0
    if (maxrmse.ne.0) then
      slope = (32. - 2.) / (maxrmse - minrmse)  ; use 32 because there are 32 colors
    else
      slope = 0
    end if
    ; How to deal with negative correlations
    gray_index = slope * ws_rmse_2d(y,x) + 2.
    if(gray_index.eq.2.) then
      gray_index = 1. ; to get actual black
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks2, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks2, plot, xp, yp, res_poly)

      ; RMSE text:
      text_1 = "WS:"+sprintf("%5.2f",ws_rmse_2d(y,x))
      dum3(n) = gsn_add_text(wks2, plot, text_1, xp(0)+.5, yp(0)+.8, res_txt)
      delete(text_1)

      text_2 = "U:"+sprintf("%5.2f",u_rmse_2d(y,x))
      dum4(n) = gsn_add_text(wks2, plot, text_2, xp(0)+.5, yp(0)+.5, res_txt)   
      delete(text_2)
          
      text_3 = "V:"+sprintf("%5.2f",v_rmse_2d(y,x))
      dum5(n) = gsn_add_text(wks2, plot, text_3, xp(0)+.5, yp(0)+.25, res_txt)   
      delete(text_3)

      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
  
; Finally - make plot
  draw(plot)
  frame(wks2)
  print("converting plot 2 to png")
  delete(wks2)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 "+fout2+".ps "+fout2+".png")

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(dum4)
delete(dum5)

print("Completed all plots for node "+stat_node)
delete(stat_node)
delete(u_som_corr)
delete(v_som_corr)
delete(ws_som_corr)
delete(u_som_rmse)
delete(v_som_rmse)
delete(ws_som_rmse)

end do

print("Statistics completed. Good job! ")
;;;;;;;;;;;;;;;;;;;;;; END script
end

