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
  ; Do we want the plot normalized by the #patterns/group?
  normal = True
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot - groups")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf50
  dir = "/data5/duvivier/SOM-RASM/analysis/7x_5y_files/"
  data = "wrf50_199011_201003"
; Dates from data and visual file that places each date at a given node
  datefile = dir+data+"_dates.txt"
  visfile = dir+data+"_wind.vis"
; Load actual data
  dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
  ndates = dimsizes(dates)
  dateschar = stringtochar(dates)
  sdateym = chartostring(dateschar(:,0:6))
  vis = new((/ndates,3/),integer)
  vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate group counts and frequencies
  nx_group = 4
  ny_group = 2
  ngroup = nx_group*ny_group  ; 8 groups total
  groupfreq     = new((/ngroup/),"float") 
  groupcount    = new((/ngroup/),"integer")

; get "normalized" group frequency by dividing by number of patterns per group
  groupfreq_norm = new((/ngroup/),"float")
  patterns = (/8.0, 5.0, 4.0, 3.0, 5.0, 3.0, 3.0, 4.0/)

; set default check values
  check = 0
; loop through each group
do g = 0,ngroup - 1
  ; For each group, set the node values to load in
  ; group1: Nodes("0,0" "1,0" "2,0" "0,1" "1,1" "2,1" "1,2" "2,2")
  if (g .eq. 0) then
    dateindices = ind((vis(:,0).eq.0.and.vis(:,1).eq.0).or.(vis(:,0).eq.1.and.vis(:,1).eq.0).or.(vis(:,0).eq.2.and.vis(:,1).eq.0).or.(vis(:,0).eq.0.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.1).or.(vis(:,0).eq.2.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.2).or.(vis(:,0).eq.2.and.vis(:,1).eq.2))
  end if
  ; group2: Nodes("3,0" "4,0" "3,1" "4,1" "3,2")
  if (g .eq. 1) then
    dateindices = ind((vis(:,0).eq.3.and.vis(:,1).eq.0).or.(vis(:,0).eq.4.and.vis(:,1).eq.0).or.(vis(:,0).eq.3.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.1).or.(vis(:,0).eq.3.and.vis(:,1).eq.2))
  end if
  ; group3: Nodes("5,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.2).or.(vis(:,0).eq.5.and.vis(:,1).eq.2))
  end if
  ; group4: Nodes("5,0" "6,0" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.1).or.(vis(:,0).eq.6.and.vis(:,1).eq.2))
  end if
  ; group5: Nodes("0,2" "0,3" "1,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices = ind((vis(:,0).eq.0.and.vis(:,1).eq.2).or.(vis(:,0).eq.0.and.vis(:,1).eq.3).or.(vis(:,0).eq.1.and.vis(:,1).eq.3).or.(vis(:,0).eq.0.and.vis(:,1).eq.4).or.(vis(:,0).eq.1.and.vis(:,1).eq.4))
  end if
  ; group6: Nodes("2,3" "3,3" "2,4")
  if (g .eq. 5) then
    dateindices = ind((vis(:,0).eq.2.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.3).or.(vis(:,0).eq.2.and.vis(:,1).eq.4))
  end if
  ; group7: Nodes("4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices = ind((vis(:,0).eq.4.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.4).or.(vis(:,0).eq.4.and.vis(:,1).eq.4))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices = ind((vis(:,0).eq.5.and.vis(:,1).eq.3).or.(vis(:,0).eq.6.and.vis(:,1).eq.3).or.(vis(:,0).eq.5.and.vis(:,1).eq.4).or.(vis(:,0).eq.6.and.vis(:,1).eq.4))
  end if
        
  ; This is the data for this group:
  if (all(ismissing(dateindices))) then
    group_ndates = 0
    groupfreq(g) = 0
    groupcount(g) = 0
  end if
  if (.not.all(ismissing(dateindices))) then
    group_ndates = dimsizes(dateindices)
    groupfreq(g) = (int2flt(group_ndates)/int2flt(ndates))*100.
    groupfreq_norm(g) = groupfreq(g)/patterns(g)
    groupcount(g) = group_ndates
  end if
  check = check + group_ndates
  delete(dateindices)
end do

; Check the dates and print error messages if calculation fails
if (check.ne.ndates) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates+"   Tot indices: "+check)
end if

;;;;;;;;;;
; Set array size for group plot
;;;;;;;;;;
; make new arrays
nodefreq  = new((/nx_group, ny_group/),"float")
nodefreq_norm = new((/nx_group, ny_group/),"float")

; assign data to new arrays
nodefreq(:,0)  = groupfreq(0:nx_group-1)
nodefreq(:,1)  = groupfreq(nx_group:ngroup-1)
nodefreq_norm(:,0) = groupfreq_norm(0:nx_group-1)
nodefreq_norm(:,1) = groupfreq_norm(nx_group:ngroup-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set output information
if(isvar("normal") .and. (normal))then
  fout = "frequency_normal_groups_"+data
  title = "Group frequency/#patterns: "+data
else
  fout = "frequency_groups_"+data
  title = "Group Frequency: "+data
end if
print("Plotting the som frequencies")
; Create the frequency plots
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  colors = gsn_retrieve_colormap(wks) ; load fixed map into "colors"
  additional_colors = (/"blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq     = nodefreq(:,::-1)
  nodefreq_norm = nodefreq_norm(:,::-1)
if(isvar("normal") .and. (normal))then
  maxnodefreq = max(nodefreq_norm)
  print("Max normalized group frequency for wrf50: "+max(nodefreq_norm))
else
  maxnodefreq = max(nodefreq)
  print("Max group frequency for wrf50: "+max(nodefreq))
end if
minnodefreq = 0.

; Get grey scales(same used for all data sets)
if (maxnodefreq.ne.0) then
  slope = (32. - 2.) / (maxnodefreq - minnodefreq)
else
  slope = 0
end if

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/ngroup/),graphic)
  dum2  = new((/ngroup/),graphic)
  dum3  = new((/ngroup/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_group
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_group
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_group / nx_group  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  ;res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_group-1, nx_group) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  ;res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_group-1, ny_group) + 0.5 ; position for tick labels
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
do y = 0, ny_group - 1
  do x = 0, nx_group - 1
    xp = xx + x
    yp = yy + y
   
    if(isvar("normal") .and. (normal))then
      gray_index = slope * nodefreq_norm(x,y) + 2.
    else
      gray_index = slope * nodefreq(x,y) + 2.
    end if
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
    if(isvar("normal") .and. (normal))then
      text = sprintf("%5.2f",nodefreq_norm(x,y))+"%"
    else
      text = sprintf("%5.2f",nodefreq(x,y))+"%"
    end if
    dum3(n) = gsn_add_text(wks, plot, text, xp(0)+.5, yp(0)+.5, res_txt)
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
