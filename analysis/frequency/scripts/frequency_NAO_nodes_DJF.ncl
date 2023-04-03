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
; Load in NAO indices
;;;;;;;;;;
  NAOfile = "/vardar/data5/duvivier/SOM-RASM/analysis/frequency/NAO_indices_monthly.txt"
  NAO = readAsciiTable(NAOfile,2,"float",1)
  xlabel_dates = NAO(:,0)
  yrmons = flt2string(xlabel_dates)
  times = dimsizes(xlabel_dates)

;;;;;;;;;;
; set input file information
;;;;;;;;;;




dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
infile = dir+nx_input+"x_"+ny_input+"y_199011_201003_dates_persistence.txt"
data = asciiread(infile,-1,"string")
ndates = dimsizes(data)
nx = new((/ndates/),"string")    ; nx assignment
ny = new((/ndates/),"string")    ; ny assignment
ys = new((/ndates/),"string")    ; year start
ms = new((/ndates/),"string")    ; month start
ds = new((/ndates/),"string")    ; day start
ed = new((/ndates/),"string")    ; event duration (#days, 0 = not new event)
df = new((/ndates/),"string")    ; duration flag (how many days is this event part of?)

; load everything as characters for now, will convert to string as necessary
t = 0
do t=0, ndates -1
  dum = stringtochar(data(t))
  nx(t) = chartostring(dum(0))
  ny(t) = chartostring(dum(2))
  ys(t) = chartostring(dum(4:7))
  ms(t) = chartostring(dum(9:10))
  ds(t) = chartostring(dum(12:13))
  ed(t) = chartostring(dum(17))
  df(t) = chartostring(dum(30))
  delete(dum)
end do
delete(data)

; convert duration variables to integer
dum = stringtoint(ed)
delete(ed)
ed = dum
delete(dum)
; replace zeros (not new events) with missing so they're not counted
ed = where(ed .eq. 0, ed@_FillValue, ed)

;;;;;;;;;;
; Calculate averages data with filters (month and persistence)
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node
; get arrays of months/persistences to loop through
months = (/"11","12","01","02","03","xx","DJF"/)
times = dimsizes(months)

; make array to plot against
xaxis = ispan(0,10,1)
dur = dimsizes(xaxis)

; make array to fill
nodecount    = new((/times,dur,nx_node,ny_node/),"integer") 

; loop through month options for filtering
do m = 0, times - 1
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   do d = 0, dur - 1 
      print("node: "+x+","+y+" and month "+months(m)+" and duration "+xaxis(d))
      ; These are the dates for this particular node:
      if (months(m).eq."xx")then
         dateindices = ind((ed.eq.xaxis(d)).and.(nx.eq.x.and.ny.eq.y))
         else if (months(m).eq."DJF")then
            dateindices = ind(((ms.eq."12").or.(ms.eq."01").or.(ms.eq."02")).and.(ed.eq.xaxis(d)).and.(nx.eq.x.and.ny.eq.y))
         else
            dateindices = ind((ms.eq.months(m)).and.(ed.eq.xaxis(d)).and.(nx.eq.x.and.ny.eq.y))
         end if
      end if
      if (all(ismissing(dateindices))) then
     	 nodecount(m,d,x,y) = 0
      end if
      if (.not.all(ismissing(dateindices))) then
      	 node_ndates = dimsizes(dateindices)
     	 nodecount(m,d,x,y) = node_ndates
      end if
      delete(dateindices)
    end do
  end do
end do
end do

return

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
  yrmon = chartostring(dateschar(:,0:3))+chartostring(dateschar(:,5:6))
  vis = new((/ndates,3/),integer)
  vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node
  nodefreq     = new((/nx_node,ny_node/),"float")
  nodefreq_all = new((/nx_node,ny_node,times/),"float") 
  nodecount    = new((/nx_node,ny_node,times/),"integer") 
  nodecorr     = new((/nx_node,ny_node/),"float")
  nodecorr_sig = new((/nx_node,ny_node/),"float")

; set default check values
  check = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y)
   do ym = 0, times - 1
  ; These are the dates for this particular node:
   dateindices = ind((yrmon.eq.yrmons(ym)).and.(vis(:,0).eq.x.and.(vis(:,1).eq.y)))
  ; This is the data for this node:
   if (all(ismissing(dateindices))) then
     node_ndates = 0
     nodefreq_all(x,y,ym) = 0
     nodecount(x,y,ym) = 0
   end if
   if (.not.all(ismissing(dateindices))) then
     node_ndates = dimsizes(dateindices)
     nodefreq_all(x,y,ym) = (int2flt(node_ndates)/int2flt(ndates))*100.
     nodecount(x,y,ym) = node_ndates
   end if
   check = check + node_ndates
   n = n + 1
   delete(dateindices)
   end do
   ; Get total node frequencies
   nodefreq(x,y) = sum(nodefreq_all(x,y,:))
   ; Calculate correlation for node
   nodecorr(x,y) = escorc(NAO(:,1),nodefreq_all(x,y,:))
   nodecorr_sig(x,y) = rtest(nodecorr(x,y),times,0)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check.ne.ndates) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates+"   Tot indices: "+check)
end if

; set statistical significance level
siglvl = 0.05  ; 95% significance
;siglvl = 0.1   ; 90% significance
; if corr_sig .ge. siglvl then it's a significant correlation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set output information
  fout  = "NAO_frequency_nodes_"+nx_input+"x_"+ny_input+"y_"+data
  title = "Node Frequency and correlation to NAO: "+data
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
  nodecorr     = nodecorr(:,::-1)
  nodecorr_sig = nodecorr_sig(:,::-1)
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

    ; NAO correlation text
    ; red/dark blue are significantly correlated
    ; pink/light blue are not significantly correlated but show sign
    res_txt1 = res_txt
    res_txt1@txFontColor = "black"
    delete(res_txt1@txBackgroundFillColor)
    if(nodecorr(x,y) .gt. -0.004 .and. nodecorr(x,y) .lt. 0.004)then
      res_txt1@txBackgroundFillColor = "white"
    end if
    if(nodecorr(x,y) .gt. 0.004 .and. nodecorr_sig(x,y) .ge. siglvl) then
      res_txt1@txBackgroundFillColor = "red"
    end if
    if(nodecorr(x,y) .gt. 0.004 .and. nodecorr_sig(x,y) .lt. siglvl) then
      res_txt1@txBackgroundFillColor = "pink"
    end if
    if(nodecorr(x,y) .lt. -0.004 .and. nodecorr_sig(x,y) .ge. siglvl) then
      res_txt1@txBackgroundFillColor = "blue"
    end if
    if(nodecorr(x,y) .lt. -0.004 .and. nodecorr_sig(x,y) .lt. siglvl) then
      res_txt1@txBackgroundFillColor = "lightblue"
    end if
    text_1 = "NAO:~C~"+sprintf("%5.2f",nodecorr(x,y))
    dum4(n) = gsn_add_text(wks, plot, text_1, xp(0)+.5, yp(0)+.45, res_txt1)
    delete(text_1) 

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
