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
  yy = chartostring(dateschar(:,0:3))
  mm = chartostring(dateschar(:,5:6))
  dd = chartostring(dateschar(:,8:9))
  vis = new((/ndates,3/),integer)
  vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

; set output information
  fout  = "monthly_frequency_"+data

;;;;;;;;;;
; Calculate frequencies for each month for each group
;;;;;;;;;;
months = (/"11","12","01","02","03"/)
times = dimsizes(months)
; Make array to plot against
xaxis = ispan(0,times-1,1)

; Calculate group counts and frequencies
nx_group = 4
ny_group = 2
ngroup = nx_group*ny_group  ; 8 groups total
groupfreq     = new((/ngroup/),"float") 
groupfreq_all = new((/times,ngroup/),"float") 
groupcount    = new((/ngroup/),"integer")
groupcount_all= new((/times,ngroup/),"integer")

; set default check values
  check = 0
; loop through each group
do g = 0,ngroup - 1
   do m = 0, times - 1
  ; For each group, set the node values to load in
  ; group1: Nodes("0,0" "1,0" "2,0" "0,1" "1,1" "2,1" "1,2" "2,2")
  if (g .eq. 0) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.0.and.vis(:,1).eq.0).or.(vis(:,0).eq.1.and.vis(:,1).eq.0).or.(vis(:,0).eq.2.and.vis(:,1).eq.0).or.(vis(:,0).eq.0.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.1).or.(vis(:,0).eq.2.and.vis(:,1).eq.1).or.(vis(:,0).eq.1.and.vis(:,1).eq.2).or.(vis(:,0).eq.2.and.vis(:,1).eq.2)))
  end if
  ; group2: Nodes("3,0" "4,0" "3,1" "4,1" "3,2")
  if (g .eq. 1) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.3.and.vis(:,1).eq.0).or.(vis(:,0).eq.4.and.vis(:,1).eq.0).or.(vis(:,0).eq.3.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.1).or.(vis(:,0).eq.3.and.vis(:,1).eq.2)))
  end if
  ; group3: Nodes("5,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.5.and.vis(:,1).eq.1).or.(vis(:,0).eq.4.and.vis(:,1).eq.2).or.(vis(:,0).eq.5.and.vis(:,1).eq.2)))
  end if
  ; group4: Nodes("5,0" "6,0" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.5.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.0).or.(vis(:,0).eq.6.and.vis(:,1).eq.1).or.(vis(:,0).eq.6.and.vis(:,1).eq.2)))
  end if
  ; group5: Nodes("0,2" "0,3" "1,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.0.and.vis(:,1).eq.2).or.(vis(:,0).eq.0.and.vis(:,1).eq.3).or.(vis(:,0).eq.1.and.vis(:,1).eq.3).or.(vis(:,0).eq.0.and.vis(:,1).eq.4).or.(vis(:,0).eq.1.and.vis(:,1).eq.4)))
  end if
  ; group6: Nodes("2,3" "3,3" "2,4")
  if (g .eq. 5) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.2.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.3).or.(vis(:,0).eq.2.and.vis(:,1).eq.4)))
  end if
  ; group7: Nodes("4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.4.and.vis(:,1).eq.3).or.(vis(:,0).eq.3.and.vis(:,1).eq.4).or.(vis(:,0).eq.4.and.vis(:,1).eq.4)))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices = ind((mm.eq.months(m)).and.((vis(:,0).eq.5.and.vis(:,1).eq.3).or.(vis(:,0).eq.6.and.vis(:,1).eq.3).or.(vis(:,0).eq.5.and.vis(:,1).eq.4).or.(vis(:,0).eq.6.and.vis(:,1).eq.4)))
  end if

  ; This is the data for this node:
  if (all(ismissing(dateindices))) then
     group_ndates = 0
     groupfreq_all(m,g) = 0
     groupcount(m,g) = 0
  end if
  if (.not.all(ismissing(dateindices))) then
     group_ndates = dimsizes(dateindices)
     groupfreq_all(m,g) = (int2flt(group_ndates)/int2flt(ndates))*100.
     groupcount_all(m,g) = group_ndates
  end if
  check = check + group_ndates
  delete(dateindices)
  end do
  ; Get total node frequencies and #mappings
  groupfreq(g) = sum(groupfreq_all(:,g))
  groupcount(g) = sum(groupcount_all(:,g))
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
groupfreq_plot  = new((/times,nx_group, ny_group/),"float")

; assign data to new arrays
groupfreq_plot(:,:,0)  = groupfreq_all(:, 0:nx_group-1)
groupfreq_plot(:,:,1)  = groupfreq_all(:, nx_group:ngroup-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  plot  = new(ngroup, graphic)

; Reverse rows(for plotting purposes)
;  groupfreq_plot = groupfreq_plot(:,::-1,:)
  maxval = max(groupfreq_plot) + 0.25

; Bar plot resources
  res_bar                                = True
  res_bar@gsnMaximize                    = True
  res_bar@gsnDraw                        = False
  res_bar@gsnFrame                       = False
  res_bar@gsnXYBarChart                  = True
  res_bar@gsnYRefLine                    = 0.
  res_bar@gsnAboveYRefLineColor          = "black"
  res_bar@gsnXYBarChartBarWidth          = 0.4
  res_bar@tmXTOn                         = False
  res_bar@tmXBMode                       = "Explicit"
  res_bar@tmXBLabels                     = (/"11","12","01","02","03"/)
  res_bar@tmXBValues                     = (/0.,1.,2.,3.,4./)
  res_bar@tmXBLabelFontHeightF           = 0.025
  res_bar@tiYAxisFontHeightF             = 0.025
  res_bar@tiYAxisString                  = "Frequency"
  res_bar@trYMinF                        = 0.0
  res_bar@trYMaxF                        = maxval

n = 0
do y = 0, ny_group - 1
  do x = 0, nx_group - 1  
    plot(n) = gsn_csm_xy(wks,xaxis,groupfreq_plot(:,x,y),res_bar)
    n = n + 1
  end do 
end do

print("Creating final panel plot.")
res_pan                       = True 
res_pan@txString              = "Monthly node frequency: "+data
res_pan@txFontHeightF         = 0.015 
res_pan@gsnPaperOrientation   = "landscape" 
res_pan@gsnMaximize           = True 
gsn_panel(wks,(/plot/),(/ny_group, nx_group/),res_pan)

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+  \
       "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
