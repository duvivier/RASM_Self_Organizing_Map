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
  nx_input = "3" ;"7"
  ny_input = "2" ;"5"
  master_vals = "winds0.03_rlen1000000_r1" ;"winds0.01_rlen1000000_r4"
;  p = 0  ; 2005-2007 era_i vs. wrf50 6hrly
;  p = 1  ; 2005-2007 era_i vs. wrf10 6hrly
;  p = 2  ; 2005-2007 wrf50 vs. wrf10 3hrly
;  p = 3  ; 2005-2007 wrf50 6hrly vs. wrf50 3hrly
  p = 4  ; 1997-2007 era_i vs. wrf50 6hrly
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
; Load in NAO indices
;;;;;;;;;;
NAOfile = "/data3/duvivier/SOM/analysis/NAO_indices_monthly.txt"
NAO = readAsciiTable(NAOfile,2,"float",1)
xlabel_dates = NAO(:,0)
times = dimsizes(xlabel_dates)
dates = ispan(0,times-1,1)
deltax = dates/10.

;;;;;;;;;;
; Get just dates we want for WRF/ERA data
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
  yrmon_1 = sdateym_1(dateind_1)

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
  yrmon_2 = sdateym_2(dateind_2)  

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_erai_wrf50"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 2005-2007 erai and wrf50 (6hr) by month"
  title_1 = tag_1
  title_2 = tag_2+"-"+tag_1
end if

if (p .eq. 1)
  print("2005-2007 era_i vs. wrf10 6hrly")
  ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1(dateind_1)

  ; wrf 10km - just narrow down hours
  dateind_2 = ind(sdatehrs_3.eq.hrs_6(0).or.sdatehrs_3.eq.hrs_6(1).or.sdatehrs_3.eq.hrs_6(2).or.sdatehrs_3.eq.hrs_6(3))
  visall_2 = vis_3(dateind_2,:) ; get only every 6 hours
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2(dateind_2)

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_erai_wrf10"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 2005-2007 erai and wrf10 (6hr) by month"
  title_1 = tag_1
  title_2 = tag_3+"-"+tag_1
end if

if (p .eq. 2)
  print("2005-2007 wrf50 vs. wrf10 3hrly")
  ; wrf50 - narrow down months/years only
  dateind_1 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_1 = vis_2(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1(dateind_1)

  ; wrf 10km - all data
  visall_2 = vis_3
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_wrf50_6h_3h"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 2005-2007 wrf50 and wrf10 (3hr) by month"
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
  yrmon_1 = sdateym_1(dateind_1)

  ; wrf 50km - narrow down months/years only
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2(dateind_2)

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_2005-2007_wrf50_6h_wrf50_3h"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 2005-2007 wrf50 (6hr) and wrf50 (3hr) by month"
  title_1 = tag_2+"(6h)"
  title_2 = "(3h)-(6h)"
end if

if (p .eq. 4)
  print("1997-2007 era_i vs. wrf50 6hrly")
  ; era interim - just need to narrow down years/months
  visall_1 = vis_1
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1

  ; wrf 50km - narrow down hours to only 6hrs
  dateind_2 = ind(sdatehrs_2.eq.hrs_6(0).or.sdatehrs_2.eq.hrs_6(1).or.sdatehrs_2.eq.hrs_6(2).or.sdatehrs_2.eq.hrs_6(3))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2(dateind_2)

  ; set output information
  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_NAO_freq"+"_1997-2007_erai_wrf50"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 1997-2007 erai and wrf50 (6hr) by month"
  title_1 = tag_1
  title_2 = tag_2
end if

if (p .eq. 5)
  print("1997-2007 wrf50 6h vs. wrf50 3hr")
  ; wrf 50km - narrow down hours to only 6hrs
  dateind_1 = ind(sdatehrs_2.eq.hrs_6(0).or.sdatehrs_2.eq.hrs_6(1).or.sdatehrs_2.eq.hrs_6(2).or.sdatehrs_2.eq.hrs_6(3))
  visall_1 = vis_2(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1(dateind_1)

  ; wrf 50km - all hours
  visall_2 = vis_3
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_1997-2007_wrf50_6h_3h"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: 1997-2007 wrf50(6h) and wrf50(3h) by month"
  title_1 = tag_2+"(6h)"
  title_2 = "(3h)-(6h)"
end if

if (p .eq. 6)
  print("wrf50 1997-2007 vs. wrf50 2005-2007 3hrly")
  ; wrf50-all dates
  visall_1 = vis_2
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1

  ; wrf 50km - narrow down years/months
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2(dateind_2)

  ; set output information
;  fout  = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+master_vals+"_freq"+"_1997-2007_2005-2007_wrf50_3h"
  title = nx_input+"x"+ny_input+" pattern frequency and NAO index: wrf50(3h) 1997-2007 and 2005-2007 by month"
  title_1 = tag_2+"(97-07)"
  title_2 = "(05-07)-(97-07)"
end if

;;;;;;;;;;
; Calculate frequencies for each yearmonth for each node
;;;;;;;;;;
; get arrays for months and years
yrmons = (/"199701","199702","199703","199711","199712","199801","199802","199803","199811","199812","199901","199902","199903","199911","199912","200001","200002","200003","200011","200012","200101","200102","200103","200111","200112","200201","200202","200203","200211","200212","200301","200302","200303","200311","200312","200401","200402","200403","200411","200412","200501","200502","200503","200511","200512","200601","200602","200603","200611","200612","200701","200702","200703","200711","200712"/)

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1     = new((/nx_node,ny_node,times/),"float") 
  nodecount_1    = new((/nx_node,ny_node,times/),"integer") 
; variable_2
  nodefreq_2     = new((/nx_node,ny_node,times/),"float") 
  nodecount_2    = new((/nx_node,ny_node,times/),"integer") 
; correlations
  corr = new((/nx_node,ny_node,2/),"float")
  corr_sig = new((/nx_node,ny_node,2/),"float")

; set default check values
  check1 = 0
  check2 = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  ; loop through year/months
   do ym = 0, times - 1   ; yearmonth loop
     print("node: "+x+","+y+" and yearmonth "+yrmons(ym))
     ; These are the dates for this particular node:
     dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y.and.yrmon_1.eq.yrmons(ym)))
     dateindices_2 = ind(visall_2(:,0).eq.x.and.(visall_2(:,1).eq.y.and.yrmon_2.eq.yrmons(ym)))

     ; This is the data for this node:
     ; variable 1
     if (all(ismissing(dateindices_1))) then
       node_ndates_1 = 0
       nodefreq_1(x,y,ym) = 0
       nodecount_1(x,y,ym) = 0
     end if
     if (.not.all(ismissing(dateindices_1))) then
       node_ndates_1 = dimsizes(dateindices_1)
       nodefreq_1(x,y,ym) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
       nodecount_1(x,y,ym) = node_ndates_1
     end if
     check1 = check1 + node_ndates_1  ; make sure all dates are counted
     ; variable 2
     if (all(ismissing(dateindices_2))) then
       node_ndates_2 = 0
       nodefreq_2(x,y,ym) = 0
       nodecount_2(x,y,ym) = 0
     end if
     if (.not.all(ismissing(dateindices_2))) then
       node_ndates_2 = dimsizes(dateindices_2)
       nodefreq_2(x,y,ym) = (int2flt(node_ndates_2)/int2flt(ndates_2))*100.
       nodecount_2(x,y,ym) = node_ndates_2
     end if
     check2 = check2 + node_ndates_2  ; make sure all dates are counted
     n = n + 1
     delete(dateindices_1)
     delete(dateindices_2)
   end do

   ; Calculate correlation
   corr(x,y,0) = escorc(NAO(:,1),nodefreq_1(x,y,:))
   corr_sig(x,y,0) = rtest(corr(x,y,0),times,0)
   corr(x,y,1) = escorc(NAO(:,1),nodefreq_2(x,y,:))
   corr_sig(x,y,1) = rtest(corr(x,y,1),times,0)
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

; Reverse rows(for plotting purposes)
  nodefreq_1     = nodefreq_1(:,::-1,:)
  nodefreq_2     = nodefreq_2(:,::-1,:)
  corr           = corr(:,::-1,:)
  corr_sig       = corr_sig(:,::-1,:)

; set significance level
  siglvl = 0.05  ; 95% significance

; Begin plotting:    
  plot  = new(nnode, graphic)
  ploto = new(nnode,graphic)

  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)

; Resources for both xy and bar plots:
  res                      = True
  res@gsnMaximize                    = True
  res@gsnDraw                        = False
  res@gsnFrame                       = False

; Bar plot resources
  res_bar                                = res
  res_bar@gsnXYBarChart                  = True
  res_bar@tmXTOn                         = False
  res_bar@tmXBMode                       = "Explicit"
  res_bar@tmXBLabels                     = (/"1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007"/)
  res_bar@tmXBValues                     = (/0,5,10,15,20,25,30,35,40,45,50/)
  res_bar@tmXBLabelFontHeightF           = 0.01
  res_bar@tiYAxisFontHeightF             = 0.025
  res_bar@tiYAxisString                  = "NAO index"
  res_bar@trYMinF                        = -2.0
  res_bar@trYMaxF                        = 2.0
  res_bar@gsnYRefLine                    = 0.0
  res_bar@gsnXYBarChartBarWidth          = 0.4
  res_bar@gsnAboveYRefLineColor          = "pink"
  res_bar@gsnBelowYRefLineColor          = "lightblue"
  res_bar@xyLineColors = (/"pink","lightblue"/)

; XY plot resources
  res_xy                                 = res
  res_xy@tmXBOn                          = False
  res_xy@tmXTOn                          = False
  res_xy@tiYAxisFontHeightF              = 0.025
  res_xy@tiYAxisString                   = "Frequency (%)"
  res_xy@tiYAxisAngleF                   = 270.
  res_xy@trYMinF                         = 0.0
  res_xy@trYMaxF                         = 2.0;0.6
  res_xy@xyLineThicknesses               = (/1.0,1.0/)
  res_xy@xyLineColors                    = (/"black","black"/)
  res_xy@xyDashPatterns                  = (/2,0/)

  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1  
      xp = xx + x
      yp = yy + y

    nodefreq_plot  = new((/2,times/),"float")
    nodefreq_plot(0,:) = nodefreq_1(x,y,:)
    nodefreq_plot(1,:) = nodefreq_2(x,y,:)
    plot(n) = gsn_csm_xy2(wks,dates,NAO(:,1),nodefreq_plot,res_bar,res_xy)
    delete(nodefreq_plot)

    ; Correlation text
    res_txt  = True
    res_txt@txFontHeightF  = 0.02
;    res_txt@txTextJustification = "CenterRight"
    res_txt@txBackgroundFillColor = "white"
    res_txt@txFontColor = "black"
    
    res_txt1 = res_txt
    res_txt2 = res_txt

    ; first correlation and significance
    if(corr_sig(x,y,0).ge.siglvl)then
      res_txt1@txFontColor = "white"
      res_txt1@txBackgroundFillColor = "black"
    end if  
    ; second correlation and significance
    if(corr_sig(x,y,1).ge.siglvl)then
      res_txt2@txFontColor = "white"
      res_txt2@txBackgroundFillColor = "black"
    end if

    text_1 = title_1+"(solid):"+sprintf("%5.2f",corr(x,y,0))
    text_2 = title_2+"(dash):"+sprintf("%5.2f",corr(x,y,1))
    dum1(n) = gsn_add_text(wks,plot(n),text_1,14.0,1.9,res_txt1)
    dum2(n) = gsn_add_text(wks,plot(n),text_2,42.0,1.9,res_txt2)

;    dum1(n) = gsn_add_text(wks,plot(n),text_1,28.0,1.9,res_txt1)
;    dum2(n) = gsn_add_text(wks,plot(n),text_2,28.0,1.6,res_txt2)
    delete(res_txt1)
    delete(res_txt2)
          
    n = n + 1
  end do ; square for each node
end do ; square for each node

print("Creating final panel plot.")
res_pan                       = True ; panel resources
res_pan@txString              = title
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
;res_pan@gsnYWhiteSpacePercent = 5.
;res_pan@gsnXWhiteSpacePercent = 5.
;res_pan@tiXAxisString         = "SOM Pattern"  - have to add text and number separately
;res_pan@tiYAxisString         = "SOM Pattern"

gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)
print("Done!  Nice job - the plot looks great.")

convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"
system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
