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
;  p = 0  ; 2005-2007 era_i vs. wrf50 6hrly
;  p = 1  ; 2005-2007 era_i vs. wrf10 6hrly
;  p = 2  ; 2005-2007 wrf50 vs. wrf10 3hrly
  p = 3  ; 2005-2007 wrf50 6hrly vs. wrf50 3hrly
;  p = 4  ; 1997-2007 era_i vs. wrf50 6hrly
;  p = 5  ; 1997-2007 wrf50 6h vs. wrf50 3hr
;  p = 6  ; wrf50 1997-2007 vs. wrf50 2005-2007 3hrly
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; era interim
  datatitle_1 = "era_i_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_1)
  dum1 = dum(0:4)
  tag_1 = chartostring(dum1)
  delete(dum)
  delete(dum1)
; wrf50
  datatitle_2 = "wrf50_199701_200712"
  datefile_2 = "/data3/duvivier/SOM/training/dates/"+datatitle_2+"_dates.txt"
  visfile_2  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_2+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_2)
  dum1 = dum(0:4)
  tag_2 = chartostring(dum1)
  delete(dum)
  delete(dum1)
; wrf10
  datatitle_3 = "wrf10_200511_200703"
  datefile_3 = "/data3/duvivier/SOM/training/dates/"+datatitle_3+"_dates.txt"
  visfile_3  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_3+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_3)
  dum1 = dum(0:4)
  tag_3 = chartostring(dum1)
  delete(dum)
  delete(dum1)

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")
; era interim
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row
; wrf 50km
  dates_2 = ndtooned(readAsciiTable(datefile_2,1,"string",0)) ; ignores no rows
  ndates_2 = dimsizes(dates_2)
  dateschar_2 = stringtochar(dates_2)
  sdateym_2 = chartostring(dateschar_2(:,0:5))
  sdatehrs_2 = chartostring(dateschar_2(:,8:9))
  vis_2 = new((/ndates_2,3/),integer)
  vis_2 = readAsciiTable(visfile_2,3,"integer",1) ; ignores first row
; wrf 10km
  dates_3 = ndtooned(readAsciiTable(datefile_3,1,"string",0)) ; ignores no rows
  ndates_3 = dimsizes(dates_3)
  dateschar_3 = stringtochar(dates_3)
  sdateym_3 = chartostring(dateschar_3(:,0:5))
  sdatehrs_3 = chartostring(dateschar_3(:,8:9))
  vis_3 = new((/ndates_3,3/),integer)
  vis_3 = readAsciiTable(visfile_3,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)
;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (p .eq. 0)
  print("2005-2007 era_i vs. wrf50 6hrly")
  ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 50km - narrow down years/months/hours
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2_tmp = vis_2(dateind_2,:)
  sdatehrs_tmp = sdatehrs_2(dateind_2)
  delete(dateind_2)
  dateind_2 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_2 = visall_2_tmp(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  delete(sdatehrs_tmp)
  delete(visall_2_tmp)

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_erai_wrf50"
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 erai and wrf50 (6hr)"
  title_1 = tag_1
  title_2 = tag_2+"-"+tag_1
end if

if (p .eq. 1)
  print("2005-2007 era_i vs. wrf10 6hrly")
  ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 10km - just narrow down hours
  dateind_2 = ind(sdatehrs_3.eq.hrs_6(0).or.sdatehrs_3.eq.hrs_6(1).or.sdatehrs_3.eq.hrs_6(2).or.sdatehrs_3.eq.hrs_6(3))
  visall_2 = vis_3(dateind_2,:) ; get only every 6 hours
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_erai_wrf10"
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 erai and wrf10 (6hr)"
  title_1 = tag_1
  title_2 = tag_3+"-"+tag_1
end if

if (p .eq. 2)
  print("2005-2007 wrf50 vs. wrf10 3hrly")
  ; wrf50 - narrow down months/years only
  dateind_1 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_1 = vis_2(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 10km - all data
  visall_2 = vis_3
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_wrf50_6h_3h"
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 wrf50 and wrf10 (3hr)"
  title_1 = tag_2
  title_2 = tag_3+"-"+tag_2
end if

if (p .eq. 3)
  print("2005-2007 wrf50 6hrly vs. wrf50 3hrly")
  ; wrf50 - narrow down months/years *and* hours to 6hourly 
  dateind_1 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_1_tmp = vis_2(dateind_1,:)
  sdatehrs_tmp = sdatehrs_2(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1_tmp)

  ; wrf 50km - narrow down months/years only
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_wrf50_6h_wrf50_3h"
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 wrf50 (6hr) and wrf10 (3hr)"
  title_1 = tag_2+"(6h)"
  title_2 = "(3h)-(6h)"
end if

if (p .eq. 4)
  print("1997-2007 era_i vs. wrf50 6hrly")
  ; era interim - just need to narrow down years/months
  visall_1 = vis_1
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 50km - narrow down hours to only 6hrs
  dateind_2 = ind(sdatehrs_2.eq.hrs_6(0).or.sdatehrs_2.eq.hrs_6(1).or.sdatehrs_2.eq.hrs_6(2).or.sdatehrs_2.eq.hrs_6(3))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_1997-2007_erai_wrf50"
  title = nx_input+"x"+ny_input+" pattern frequency: 1997-2007 erai and wrf50 (6hr)"
  title_1 = tag_1
  title_2 = tag_2+"-"+tag_1
end if

if (p .eq. 5)
  print("1997-2007 wrf50 6h vs. wrf50 3hr")
  ; wrf 50km - narrow down hours to only 6hrs
  dateind_1 = ind(sdatehrs_2.eq.hrs_6(0).or.sdatehrs_2.eq.hrs_6(1).or.sdatehrs_2.eq.hrs_6(2).or.sdatehrs_2.eq.hrs_6(3))
  visall_1 = vis_2(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 50km - all hours
  visall_2 = vis_3
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_1997-2007_wrf50_6h_3h"
  title = nx_input+"x"+ny_input+" pattern frequency: 1997-2007 wrf50(6h) and wrf50(3h)"
  title_1 = tag_2+"(6h)"
  title_2 = "(3h)-(6h)"
end if

if (p .eq. 6)
  print("wrf50 1997-2007 vs. wrf50 2005-2007 3hrly")
  ; wrf50-all dates
  visall_1 = vis_2
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 50km - narrow down years/months
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_1997-2007_2005-2007_wrf50_3h"
  title = nx_input+"x"+ny_input+" pattern frequency: wrf50 (3h) 1997-2007 and 2005-2007"
  title_1 = tag_2+"(97-07)"
  title_2 = "(05-07)-(97-07)"
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1     = new((/nx_node,ny_node/),"float") 
  nodecount_1    = new((/nx_node,ny_node/),"integer") 
; variable_2
  nodefreq_2     = new((/nx_node,ny_node/),"float") 
  nodecount_2    = new((/nx_node,ny_node/),"integer") 

; set default check values
  check1 = 0
  check2 = 0
  xpos = 0
  ypos = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  dateindices_2 = ind(visall_2(:,0).eq.x.and.(visall_2(:,1).eq.y))
        
  ; This is the data for this node:
  ; variable 1
  if (all(ismissing(dateindices_1))) then
    node_ndates_1 = 0
    nodefreq_1(x,y) = 0
    nodecount_1(x,y) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    node_ndates_1 = dimsizes(dateindices_1)
    nodefreq_1(x,y) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    nodecount_1(x,y) = node_ndates_1
  end if
  check1 = check1 + node_ndates_1  ; make sure all dates are counted
  ; variable 2
  if (all(ismissing(dateindices_2))) then
    node_ndates_2 = 0
    nodefreq_2(x,y) = 0
    nodecount_2(x,y) = 0
  end if
  if (.not.all(ismissing(dateindices_2))) then
    node_ndates_2 = dimsizes(dateindices_2)
    nodefreq_2(x,y) = (int2flt(node_ndates_2)/int2flt(ndates_2))*100.
    nodecount_2(x,y) = node_ndates_2
  end if
  check2 = check2 + node_ndates_2  ; make sure all dates are counted

; Update xpos and ypos for next time through:
   xpos = xpos + 1
   if (xpos.eq.nx_node) then
     xpos = 0
     ypos = ypos + 1
   end if
   n = n + 1
   delete(dateindices_1)
   delete(dateindices_2)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if
if (check2.ne.ndates_2) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_2+"   Tot indices: "+check2)
end if

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat = new((/nx_node,ny_node/),double)
test_stat = 0.
freq_diff = nodefreq_2 - nodefreq_1 ; get difference in frequencies
test_stat_num = freq_diff/100.
nf1 = nodefreq_1/100.  ; convert from % to just ratio
nf2 = nodefreq_2/100.
test_stat_den = sqrt((nf2*(1-nf2)/ndates_2) + (nf1*(1-nf1)/ndates_1))
test_stat_den = where(test_stat_den.eq.0,test_stat_den@_FillValue,test_stat_den) ; set 0 to missing to avoid divide by zero error
test_stat = test_stat_num/test_stat_den
test_stat = where(ismissing(test_stat),0,test_stat)

; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 95% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  colors = gsn_retrieve_colormap(wks) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq_1     = nodefreq_1(:,::-1)
  nodecount_1    = nodecount_1(:,::-1)
  maxnodefreq_1 = max(nodefreq_1)
  print("Max node frequency for "+tag_1+": "+max(nodefreq_1))
  nodefreq_2     = nodefreq_2(:,::-1)
  nodecount_2    = nodecount_2(:,::-1)
  maxnodefreq_2 = max(nodefreq_2)
  print("Max node frequency for "+tag_2+": "+max(nodefreq_2))
  max_all = new((/2/),"float")
  ; get the highest frequency to set box shades by
  max_all(0) = maxnodefreq_1
  max_all(1) = maxnodefreq_2
  maxnodefreq = max(max_all)
  minnodefreq = 0.
  ; reverse the statistical information as well
  test_stat = test_stat(:,::-1)
  freq_diff = freq_diff(:,::-1)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)
  dum5  = new((/nnode/),graphic)
  dum6  = new((/nnode/),graphic)

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

  plot = gsn_blank_plot(wks,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.01 ;0.0075
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"
; loop through each node to plot
  n = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      xp = xx + x
      yp = yy + y
          
      ; Get grey scales(same used for all data sets)
      if (maxnodefreq.ne.0) then
        slope = (32. - 2.) / (maxnodefreq - minnodefreq)  ; use 32 because there are 32 colors
      else
        slope = 0
      end if
      ; variable 1
      gray_index_1 = slope * nodefreq_1(x,y) + 2.
      if(gray_index_1.eq.2.) then
        gray_index_1 = 0. ; to get actual white because our color table is flaky
      end if
      ; variable 2 --> gray scale if needed...
      gray_index_2 = slope * nodefreq_2(x,y) + 2.
      if(gray_index_2.eq.2.) then
        gray_index_2 = 0. ; to get actual white because our color table is flaky
      end if
      
      ; Color squares
      res_poly@gsFillColor = "white" ;gray_index ; should auto round
      dum1(n) = gsn_add_polygon(wks, plot, xp, yp, res_poly)
      dum2(n) = gsn_add_polyline(wks, plot, xp, yp, res_poly)

      ; Frequency text:
      res_txt1 = res_txt
      res_txt1@txBackgroundFillColor = gray_index_1 ;"white" "black"
      text_1 = title_1+":~C~ "+sprintf("%5.2f",nodefreq_1(x,y))+"%"
      dum3(n) = gsn_add_text(wks, plot, text_1, xp(0)+.5, yp(0)+.75, res_txt1)
      delete(text_1)

      res_txt2 = res_txt
      res_txt2@txFontColor = "black"
      ;; information if NOT statistical significance plotted
      ; res_txt2@txBackgroundFillColor = gray_index_2
      ; text_2 = title_2+":~C~ "+sprintf("%5.2f",nodefreq_2(x,y))+"%"
      ;; get background colors for statistical significance
        res_txt2@txBackgroundFillColor = "white"
      if(test_stat(x,y).ge.1.645).and.(test_stat(x,y).lt.1.96) then
        res_txt2@txBackgroundFillColor = "pink"
        res_txt2@txFontColor = "white"
      end if
      if(test_stat(x,y).ge.1.96) then
        res_txt2@txBackgroundFillColor = "red"
        res_txt2@txFontColor = "white"
      end if
      if(test_stat(x,y).le.-1.645).and.(test_stat(x,y).gt.-1.96) then
        res_txt2@txBackgroundFillColor = "lightblue"
        res_txt2@txFontColor = "white"
      end if
      if(test_stat(x,y).le.-1.96) then
        res_txt2@txBackgroundFillColor = "blue"
        res_txt2@txFontColor = "white"
      end if
      text_2 = title_2+":~C~ "+sprintf("%5.2f",freq_diff(x,y))+"%"
      dum4(n) = gsn_add_text(wks, plot, text_2, xp(0)+.5, yp(0)+.35, res_txt2)   
      delete(text_2)
          
      ; Count:
      text_1 = nodecount_1(x,y)+""
;          dum6(n) = gsn_add_text(wks, plot, text_1, xp(0)+.5, yp(0)+.35, res_txt)
      delete(text_1)

      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
; Finally - make plot
draw(plot)
frame(wks)

convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"
system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
