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
  nx_input = "4"
  ny_input = "3"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot - nodes")

;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf50
  dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
  data = "wrf50_199011_201003"
; Dates from data and visual file that places each date at a given node
  datefile = dir+data+"_dates.txt"
  visfile = dir+data+"_wind.vis"
; Load actual data
  dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
  ndates = dimsizes(dates)
  dateschar = stringtochar(dates)
  yr = chartostring(dateschar(:,0:3))
  mm = chartostring(dateschar(:,5:6))
  dd = chartostring(dateschar(:,8:9))
  vis = new((/ndates,3/),integer)
  vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Calculate frequencies for each month for each node
;;;;;;;;;;

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node
  nodefreq     = new((/nx_node,ny_node/),"float")
  ndates_DJF = dimsizes(ind((mm.eq."12").or.(mm.eq."01").or.(mm.eq."02")))

; set default check values
  check = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y)
  ; These are the dates for this particular node:
   dateindices = ind(((mm.eq."12").or.(mm.eq."01").or.(mm.eq."02")).and.(vis(:,0).eq.x.and.(vis(:,1).eq.y)))
  ; This is the data for this node:
   if (all(ismissing(dateindices))) then
     node_ndates = 0
     nodefreq_all(x,y) = 0
   end if
   if (.not.all(ismissing(dateindices))) then
     node_ndates = dimsizes(dateindices)
     nodefreq(x,y) = (int2flt(node_ndates)/int2flt(ndates_DJF))*100.
   end if
   check = check + node_ndates
   n = n + 1
   delete(dateindices)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check.ne.ndates_DJF) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_DJF+"   Tot indices: "+check)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set output information
  fout  = "DJF_frequency_nodes_"+nx_input+"x_"+ny_input+"y_"+data
  title = "DJF Node Frequency: "+data
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  colors = gsn_retrieve_colormap(wks) ; load fixed map into "colors"
  additional_colors = (/"blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq     = nodefreq(:,::-1)
  maxnodefreq = max(nodefreq)
  print("Max node frequency for wrf50: "+max(nodefreq))
  minnodefreq = 0.

; Get grey scales(same used for all data sets)
  if (maxnodefreq.ne.0) then
    slope = (32. - 2.) / (maxnodefreq - minnodefreq)
  else
    slope = 0
  end if

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)

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
  ;res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  ;res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  ;res_blank@tiXAxisString                  = "SOM Pattern"
  ;res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.015
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"

; loop through each node to plot
  n = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      xp = xx + x
      yp = yy + y
          
      gray_index = slope * nodefreq(x,y) + 2.
      if(gray_index.eq.2.) then
        gray_index = 0. ; to get actual white because our color table is flaky
      end if
      ; Color squares
      res_poly@gsFillColor = gray_index ; "white" should auto round
      dum1(n) = gsn_add_polygon(wks, plot, xp, yp, res_poly)
      dum2(n) = gsn_add_polyline(wks, plot, xp, yp, res_poly)

      ; Frequency text:
      res_txt = res_txt
      res_txt@txBackgroundFillColor = gray_index ;"white" "black"
      text = sprintf("%5.2f",nodefreq(x,y))+"%"
      dum3(n) = gsn_add_text(wks, plot, text, xp(0)+.5, yp(0)+.75, res_txt)
      delete(text)

      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
; Finally - make plot
draw(plot)
frame(wks)
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+  \
       "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
