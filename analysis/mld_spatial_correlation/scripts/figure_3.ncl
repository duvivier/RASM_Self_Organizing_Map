;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Modified by Alice DuVivier - August 2013
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
  datatitle1  = "wrf50_199701_200712_6h"
  datatitle1b = "era_i_199701_200712_6h"
  type = "1"  ;1 = "correct" fluxes, 2 = fluxes from nodeavg values
  varcode = "U10"
  ;; options: "era_i_200511_200703_6h"
  ;; "wrf10_200511_200703_6h" "wrf50_200511_200703_6h"
; ******************************************************
; NOTE: plots of wind do not have vector overlay. NCL memory has problems with the high
; resolution data in this volume and plotting vectors. For vector plots please use script
; that is less complex (node_avgs or winter_avg_diffs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set which plots to print out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
plot2  = True ; plot 2 - 6 panel of winter avgs, difference (w/stat sig), sum each term w/%contribution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating why averages differ for: "+varcode)

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag_1b = chartostring(title1b_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate frequencies and change in frequencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load input files
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")
if (tag_1 .eq. "wrf50")then
  datatitle_1 = "wrf50_199701_200712"
  plot_title1 = "WRF 50km"
  datefile_1 = "/vardar/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/vardar/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "era_i")then
  datatitle_1b = "era_i_199701_200712"
  plot_title1b = "ERA Interim"
  datefile_1b = "/vardar/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/vardar/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if

;;;;;;;;;;
; Load information for two files
;;;;;;;;;;
; file1 - wrf50
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row
; file1b - era_i
  dates_1b = ndtooned(readAsciiTable(datefile_1b,1,"string",0)) ; ignores no rows
  ndates_1b = dimsizes(dates_1b)
  dateschar_1b = stringtochar(dates_1b)
  sdateym_1b = chartostring(dateschar_1b(:,0:5))
  sdatehrs_1b = chartostring(dateschar_1b(:,8:9))
  vis_1b = new((/ndates_1b,3/),integer)
  vis_1b = readAsciiTable(visfile_1b,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)

;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (tag_1 .eq. "wrf50")then     ; wrf 10km - just narrow down hours
  dateind_1 = ind(sdatehrs_1.eq.hrs_6(0).or.sdatehrs_1.eq.hrs_6(1).or.sdatehrs_1.eq.hrs_6(2).or.sdatehrs_1.eq.hrs_6(3))
  visall_1 = vis_1(dateind_1,:) ; get only every 6 hours
  ndates_1 = dimsizes(visall_1(:,0))
end if
if (tag_1b .eq. "era_i")then    ; era interim - just need to narrow down years/months
  visall_1b = vis_1b
  ndates_1b = dimsizes(visall_1b(:,0))
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1     = new((/nnode/),"float") 
  nodecount_1    = new((/nnode/),"integer") 
; variable_1b
  nodefreq_1b   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1b     = new((/nnode/),"float") 
  nodecount_1b    = new((/nnode/),"integer") 

; set default check values
  check1 = 0
  check1b = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  dateindices_1b = ind(visall_1b(:,0).eq.x.and.(visall_1b(:,1).eq.y))
        
  ; Calculate frequencies
  ; variable 1
  if (all(ismissing(dateindices_1))) then
    node_ndates_1 = 0
    nodefreq_1(n) = 0
    nodecount_1(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    node_ndates_1 = dimsizes(dateindices_1)
    nodefreq_1(x,y) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    freq_nodes_1(n) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    nodecount_1(n) = node_ndates_1
  end if
  check1 = check1 + node_ndates_1  ; make sure all dates are counted
  ; variable 1b
  if (all(ismissing(dateindices_1b))) then
    node_ndates_1b = 0
    nodefreq_1b(n) = 0
    nodecount_1b(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1b))) then
    node_ndates_1b = dimsizes(dateindices_1b)
    nodefreq_1b(x,y) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    freq_nodes_1b(n) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    nodecount_1b(n) = node_ndates_1b
  end if
  check1b = check1b + node_ndates_1b  ; make sure all dates are counted

   n = n + 1
   delete(dateindices_1)
   delete(dateindices_1b)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if
if (check1b.ne.ndates_1b) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1b+"   Tot indices: "+check1b)
end if

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat = new((/nx_node,ny_node/),double)
test_stat = 0.
freq_diff = nodefreq_1 - nodefreq_1b ; get difference in frequencies
test_stat_num = freq_diff/100.
nf1 = nodefreq_1/100.  ; convert from % to just ratio
nf1b = nodefreq_1b/100.
test_stat_den = sqrt((nf1b*(1-nf1b)/ndates_1b) + (nf1*(1-nf1)/ndates_1))
test_stat_den = where(test_stat_den.eq.0,test_stat_den@_FillValue,test_stat_den) ; set 0 to missing to avoid divide by zero error
test_stat = test_stat_num/test_stat_den
test_stat = where(ismissing(test_stat),0,test_stat)

; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 95% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

print("completed frequency calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate node differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."U10")then
  vartitle1 = "Avg 10m Wind speed"
  invar1 = "wspd_10m_avg"
  invar_v = "wspd_10m_var"
  vartype = "2d"
  cmaptype = "wind"
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 15.
    clev1               = 1.
    stride1             = 1                 ; label stride
    cmin2               = -7.
    cmax2               = 7.
    clev2               = 0.5
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2 ;2                 ; start at color
    spreadend1          = 18 ;35                ; end at color
    spreadstart2        = 20 ;37                ; start at color
    spreadend2          = 115 ;132               ; end at color
    spreadstart3        = 20 ;37                ; start at color
    spreadend3          = 115 ;132               ; end at color
    colormap            = "SOM_wind_table_mod" ;"SOM_wind_table"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/vardar/data3/duvivier/SOM/analysis/flux_compare/node_avgs/"

;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname0 = "node_0x_0y_"+datatitle1
  if (type .eq. "1")then
    f0 = addfile(dir1 + "fluxes-sst/"+ fname0 + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f0 = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname0 + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  lat2d_1 = f0->lat
  lon2d_1 = f0->lon
  z_sfc_1 = f0->Z_sfc
  if(tag_1 .eq. "wrf10")then
    mask_50km = f0->mask_50km_terrain
  end if
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF10 domain
  fname0b = "node_0x_0y_"+datatitle1b
  if (type .eq. "1")then
    f0b = addfile(dir1 + "fluxes-sst/"+ fname0b + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f0b = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname0b + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  lat2d_1b = f0b->lat
  lon2d_1b = f0b->lon
  z_sfc_1b = f0b->Z_sfc
  delete(fname0b)
  delete(f0b)

  dims = dimsizes(lat2d_1b)     ; get lat/lon dimensions
  n_sn_1b = dims(0)              ; get south/north points
  n_we_1b = dims(1)              ; get west/east points
  n_tot_1b = n_sn_1b*n_we_1b              ; get total number of points in high res domain
  delete(dims)

  ; create all-node array for node average variable
  var1 = new((/nnode,n_sn_1,n_we_1/),"float")
  var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  if(type .eq. "1")then
    variance1 = new((/nnode,n_sn_1,n_we_1/),"float")
    variance1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if
  seaice_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_1b = new((/nnode,n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
  if (type .eq. "1")then
    f1 = addfile(dir1 + "fluxes-sst/"+ fname1 + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname1 + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  var1(n,:,:) = f1->$invar1$(south_north|:,west_east|:)
  seaice_1(n,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  if(type .eq. "1")then
    variance1(n,:,:) = f1->$invar_v$(south_north|:,west_east|:)
  end if

  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1b
  if (type .eq. "1")then
    f1b = addfile(dir1 + "fluxes-sst/"+ fname1b + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f1b = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname1b + "-fluxes_fromnodeavgs-sst.nc","r")
  end if

  var1b(n,:,:) = f1b->$invar1$(south_north|:,west_east|:)
  seaice_1b(n,:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)
  if(type .eq. "1")then
    variance1b(n,:,:) = f1b->$invar_v$(south_north|:,west_east|:)
  end if

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")

; change units for curltau variable and get rid of nans, etc.
if (varcode .eq. "curltau")then
  var1 = where(var1 .eq. "nan" .or. var1 .eq. "-nan" .or. var1 .eq. "inf" .or. var1 .eq. "-inf", fill, var1)
  var1b = where(var1b .eq. "nan" .or. var1b .eq. "-nan" .or. var1b .eq. "inf" .or. var1b .eq. "-inf", fill, var1b)
  var1 = var1*10.0E5
  var1b = var1b*10.0E5
  var1@units = "10E-5 N m-3"
  var1b@units = "10E-5 N m-3"
end if

print("Masking terrain - nodes")
n = 0
; loop through each node
do n = 0, nnode - 1
  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc_1 .lt. 10., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(z_sfc_1 .lt. 10., var1b(n,:,:), var1b@_FillValue)
  seaice_1(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1(n,:,:), seaice_1@_FillValue)
  seaice_1b(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1b(n,:,:), seaice_1b@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1b(n,:,:), var1b@_FillValue)
  seaice_1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1(n,:,:), seaice_1@_FillValue)
  seaice_1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1b(n,:,:), seaice_1b@_FillValue)

end do

;;;;;;;;;;
; Find difference and probability
;;;;;;;;;;
; find difference
diff = var1 - var1b
title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; Calculate statistical significance
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
if(type .eq. "1")then
  prob = new((/nnode,n_sn_1,n_we_1/),"float")
  n = 0
  do n = 0, nnode - 1
    prob(n,:,:) = 100.*(1. - ttest(var1(n,:,:),variance1(n,:,:),nodecount_1(n), var1b(n,:,:),variance1b(n,:,:),nodecount_1b(n), False, False))    
  end do
end if

; assign lat/lon info
var1@lat2d = lat2d_1
var1@lon2d = lon2d_1
var1b@lat2d = lat2d_1
var1b@lon2d = lon2d_1
diff@lat2d = lat2d_1
diff@lon2d = lon2d_1
seaice_1@lat2d = lat2d_1
seaice_1@lon2d = lon2d_1
seaice_1b@lat2d = lat2d_1
seaice_1b@lon2d = lon2d_1
if (type .eq. "1")then
  prob@lat2d = lat2d_1
  prob@lon2d = lon2d_1
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
print(vartitle1+" min: "+min(diff)+"  max: "+max(diff)) 

print("completed node calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate difference terms for analysis
; delta U = sigma (delta_freq*U + freq*delta_U + delta_freq*delta_U)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
var = var1b             ; era or wrf50 as control
freq = freq_nodes_1b/100.      ; era or wrf50 as control
delta_var = diff        ; var_1 - var_1b
delta_freq = (freq_nodes_1 - freq_nodes_1b)/100.     ; freq_1 - freq_1b

  ; Make arrays for each term for each node
  term1 = new((/nnode,n_sn_1,n_we_1/),"float")
  term1@_FillValue = fill
  term1_sum = new((/n_sn_1,n_we_1/),"float")
  term1_sum = 0.0
  term2 = new((/nnode,n_sn_1,n_we_1/),"float")
  term2@_FillValue = fill
  term2_sum = new((/n_sn_1,n_we_1/),"float")
  term2_sum = 0.0
  term3 = new((/nnode,n_sn_1,n_we_1/),"float")
  term3@_FillValue = fill
  term3_sum = new((/n_sn_1,n_we_1/),"float")
  term3_sum = 0.0
  winter_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_avg_1 = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1 = 0.0
  winter_avg_1b = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1b = 0.0
  seaice_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_avg_1 = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1 = 0.0
  seaice_avg_1b = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1b = 0.0

  ; Make arrays for each term for individual groups
  ;group1  = ("0" "1" "7")
  ;group2  = ("2" "8" "9" "16" "17")
  ;group3  = ("3" "4" "10" "11" "18" "19")
  ;group4  = ("5" "6" "12" "13" "20")
  ;group5  = ("14" "21" "28" "29")
  ;group6  = ("15" "22" "23" "30")
  ;group7  = ("24" "25" "31" "32")
  ;group8  = ("26" "27" "33" "34")

  term1_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group1 = 0.0
  term2_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group1 = 0.0
  term3_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group1 = 0.0
  term1_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group2 = 0.0
  term2_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group2 = 0.0
  term3_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group2 = 0.0
  term1_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group3 = 0.0
  term2_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group3 = 0.0
  term3_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group3 = 0.0
  term1_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group4 = 0.0
  term2_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group4 = 0.0
  term3_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group4 = 0.0
  term1_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group5 = 0.0
  term2_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group5 = 0.0
  term3_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group5 = 0.0
  term1_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group6 = 0.0
  term2_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group6 = 0.0
  term3_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group6 = 0.0
  term1_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group7 = 0.0
  term2_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group7 = 0.0
  term3_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group7 = 0.0
  term1_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group8 = 0.0
  term2_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group8 = 0.0
  term3_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group8 = 0.0

  do n = 0, nnode - 1
    ;Calculate each term for all nodes
    term1(n,:,:) = delta_freq(n)*var(n,:,:)
    term2(n,:,:) = freq(n)*delta_var(n,:,:)
    term3(n,:,:) = delta_freq(n)*delta_var(n,:,:)

    ; Do sums over various terms
    term1_sum(:,:) = term1_sum(:,:) + term1(n,:,:)
    term2_sum(:,:) = term2_sum(:,:) + term2(n,:,:)
    term3_sum(:,:) = term3_sum(:,:) + term3(n,:,:)

    ; Do sums over various terms for groups
    ;; group1 - northeastery flow
    if(n .eq. 0 .or. n .eq. 1 .or. n .eq. 7)then
      term1_sum_group1(:,:) = term1_sum_group1(:,:) + term1(n,:,:)
      term2_sum_group1(:,:) = term2_sum_group1(:,:) + term2(n,:,:)
      term3_sum_group1(:,:) = term3_sum_group1(:,:) + term3(n,:,:)
    end if
    ;; group2 - northeasterly flow in DSN
    if(n .eq. 2 .or. n .eq. 8 .or. n .eq. 9 .or. n .eq. 16 .or. n .eq. 17)then
      term1_sum_group2(:,:) = term1_sum_group2(:,:) + term1(n,:,:)
      term2_sum_group2(:,:) = term2_sum_group2(:,:) + term2(n,:,:)
      term3_sum_group2(:,:) = term3_sum_group2(:,:) + term3(n,:,:)
    end if
    ;; group3 - WTJ with barrier flow
    if(n .eq. 3 .or. n .eq. 4 .or. n .eq. 10 .or. n .eq. 11 .or. n .eq. 18 .or. n .eq. 19)then
      term1_sum_group3(:,:) = term1_sum_group3(:,:) + term1(n,:,:)
      term2_sum_group3(:,:) = term2_sum_group3(:,:) + term2(n,:,:)
      term3_sum_group3(:,:) = term3_sum_group3(:,:) + term3(n,:,:)
    end if
    ;; group4 - Strong WTJ with barrier flow
    if(n .eq. 5 .or. n .eq. 6 .or. n .eq. 12 .or. n .eq. 13 .or. n .eq. 20)then
      term1_sum_group4(:,:) = term1_sum_group4(:,:) + term1(n,:,:)
      term2_sum_group4(:,:) = term2_sum_group4(:,:) + term2(n,:,:)
      term3_sum_group4(:,:) = term3_sum_group4(:,:) + term3(n,:,:)
    end if
    ;; group5 - Strong ETJ
    if(n .eq. 14 .or. n .eq. 21 .or. n .eq. 28 .or. n .eq. 29)then
      term1_sum_group5(:,:) = term1_sum_group5(:,:) + term1(n,:,:)
      term2_sum_group5(:,:) = term2_sum_group5(:,:) + term2(n,:,:)
      term3_sum_group5(:,:) = term3_sum_group5(:,:) + term3(n,:,:)
    end if
    ;; group6 - ETJ
    if(n .eq. 15 .or. n .eq. 22 .or. n .eq. 23 .or. n .eq. 30)then
      term1_sum_group6(:,:) = term1_sum_group6(:,:) + term1(n,:,:)
      term2_sum_group6(:,:) = term2_sum_group6(:,:) + term2(n,:,:)
      term3_sum_group6(:,:) = term3_sum_group6(:,:) + term3(n,:,:)
    end if
    ;; group7 - southerly flow
    if(n .eq. 24 .or. n .eq. 25 .or. n .eq. 31 .or. n .eq. 32)then
      term1_sum_group7(:,:) = term1_sum_group7(:,:) + term1(n,:,:)
      term2_sum_group7(:,:) = term2_sum_group7(:,:) + term2(n,:,:)
      term3_sum_group7(:,:) = term3_sum_group7(:,:) + term3(n,:,:)
    end if
    ;; group8 - WTJ without barrier flow
    if(n .eq. 26 .or. n .eq. 27 .or. n .eq. 33 .or. n .eq. 34)then
      term1_sum_group8(:,:) = term1_sum_group8(:,:) + term1(n,:,:)
      term2_sum_group8(:,:) = term2_sum_group8(:,:) + term2(n,:,:)
      term3_sum_group8(:,:) = term3_sum_group8(:,:) + term3(n,:,:)
    end if

    ; Find winter net average
    winter_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * var1(n,:,:)
    winter_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * var1b(n,:,:)    
    winter_avg_1 = winter_avg_1(:,:) + winter_nodes_1(n,:,:)
    winter_avg_1b = winter_avg_1b(:,:) + winter_nodes_1b(n,:,:)

    ; Find seaice winter net average
    seaice_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * seaice_1(n,:,:)
    seaice_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * seaice_1b(n,:,:)    
    seaice_avg_1 = seaice_avg_1(:,:) + seaice_nodes_1(n,:,:)
    seaice_avg_1b = seaice_avg_1b(:,:) + seaice_nodes_1b(n,:,:)
  end do

  ; Find winter differences
  ; Winter net difference
  winter_diff = winter_avg_1 - winter_avg_1b
  winter_seaice_diff = seaice_avg_1 - seaice_avg_1b
  ; Do sums over various terms for why the difference exists
  nodes_sum_all = term1 + term2 + term3
  net_diff = term1_sum + term2_sum + term3_sum

  ; Find the "net" difference for each group
  net_group1 = term1_sum_group1 + term2_sum_group1 + term3_sum_group1
  net_group2 = term1_sum_group2 + term2_sum_group2 + term3_sum_group2
  net_group3 = term1_sum_group3 + term2_sum_group3 + term3_sum_group3
  net_group4 = term1_sum_group4 + term2_sum_group4 + term3_sum_group4   
  net_group5 = term1_sum_group5 + term2_sum_group5 + term3_sum_group5
  net_group6 = term1_sum_group6 + term2_sum_group6 + term3_sum_group6
  net_group7 = term1_sum_group7 + term2_sum_group7 + term3_sum_group7
  net_group8 = term1_sum_group8 + term2_sum_group8 + term3_sum_group8    

  ; assign lat/lon data for plotting
  var1@_FillValue = fill
  copy_VarMeta(var1,nodes_sum_all)
  copy_VarMeta(var1,term1)
  copy_VarMeta(var1,term2)
  copy_VarMeta(var1,term3)

  z_sfc_1@_FillValue = fill
  copy_VarMeta(z_sfc_1,net_diff)
  net_diff@lat2d = lat2d_1
  net_diff@lon2d = lon2d_1
  copy_VarMeta(net_diff,term1_sum)
  copy_VarMeta(net_diff,term2_sum)
  copy_VarMeta(net_diff,term3_sum)
  copy_VarMeta(net_diff,term1_sum_group1)
  copy_VarMeta(net_diff,term2_sum_group1)
  copy_VarMeta(net_diff,term3_sum_group1)
  copy_VarMeta(net_diff,net_group1)
  copy_VarMeta(net_diff,term1_sum_group2)
  copy_VarMeta(net_diff,term2_sum_group2)
  copy_VarMeta(net_diff,term3_sum_group2)
  copy_VarMeta(net_diff,net_group2)
  copy_VarMeta(net_diff,term1_sum_group3)
  copy_VarMeta(net_diff,term2_sum_group3)
  copy_VarMeta(net_diff,term3_sum_group3)
  copy_VarMeta(net_diff,net_group3)
  copy_VarMeta(net_diff,term1_sum_group4)
  copy_VarMeta(net_diff,term2_sum_group4)
  copy_VarMeta(net_diff,term3_sum_group4)
  copy_VarMeta(net_diff,net_group4)
  copy_VarMeta(net_diff,term1_sum_group5)
  copy_VarMeta(net_diff,term2_sum_group5)
  copy_VarMeta(net_diff,term3_sum_group5)
  copy_VarMeta(net_diff,net_group5)
  copy_VarMeta(net_diff,term1_sum_group6)
  copy_VarMeta(net_diff,term2_sum_group6)
  copy_VarMeta(net_diff,term3_sum_group6)
  copy_VarMeta(net_diff,net_group6)
  copy_VarMeta(net_diff,term1_sum_group7)
  copy_VarMeta(net_diff,term2_sum_group7)
  copy_VarMeta(net_diff,term3_sum_group7)
  copy_VarMeta(net_diff,net_group7)
  copy_VarMeta(net_diff,term1_sum_group8)
  copy_VarMeta(net_diff,term2_sum_group8)
  copy_VarMeta(net_diff,term3_sum_group8)
  copy_VarMeta(net_diff,net_group8)
  copy_VarMeta(net_diff,winter_avg_1)
  copy_VarMeta(net_diff,winter_avg_1b)
  copy_VarMeta(net_diff,winter_diff)
  copy_VarMeta(net_diff,winter_seaice_diff)
  copy_VarMeta(net_diff,seaice_avg_1)
  copy_VarMeta(net_diff,seaice_avg_1b)

  print("Completed calculations for assessing why differences exist")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  fname1 = "net_avg_"+datatitle1
  fname1b = "net_avg_"+datatitle1b
  if (type .eq. "1")then
    f1 = addfile(dir1+"fluxes-sst/"+fname1+"-fluxes-sst.nc","r")
    f1b = addfile(dir1+"fluxes-sst/"+fname1b+"-fluxes-sst.nc","r")
    obs_1 = f1->number_dates

    ; Get files with SLP info
    f2 = addfile("/vardar/data3/duvivier/SOM/analysis/flux_compare/"+tag_1+"_coare_fluxes/net_avg_"+tag_1+"_1997_2007.nc","r")
    f2b = addfile("/vardar/data3/duvivier/SOM/analysis/flux_compare/"+tag_1b+"_coare_fluxes/net_avg_"+tag_1b+"_1997_2007.nc","r")
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1+"fluxes_fromnodeavgs-sst/"+fname1+"-fluxes_fromnodeavgs-sst.nc","r")
    f1b = addfile(dir1+"fluxes_fromnodeavgs-sst/"+fname1b+"-fluxes_fromnodeavgs-sst.nc","r")
    obs_1 = 35.  ; from each node
  end if

  ; create all-node array for node average variable
  avg1 = new((/n_sn_1,n_we_1/),"float")
  avg1b = new((/n_sn_1b,n_we_1b/),"float")
  avg_variance1 = new((/n_sn_1,n_we_1/),"float")
  avg_variance1b = new((/n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  avg_seaice_1 = new((/n_sn_1,n_we_1/),"float")
  avg_seaice_1b = new((/n_sn_1b,n_we_1b/),"float")

  ; make slp var - overlay with means
  avg_slp_1 = new((/n_sn_1,n_we_1/),"float")
  avg_slp_1b = new((/n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  avg1(:,:) = f1->$invar1$(:,:) ;(south_north|:,west_east|:)
  avg_variance1(:,:) = f1->$invar_v$(:,:) ;(south_north|:,west_east|:)
  avg_seaice_1(:,:) = f1->SeaIce_avg(:,:) ;(south_north|:,west_east|:)
  avg_slp_1(:,:) = f2->slp(0,:,:)
  delete(f2)

  avg1b(:,:) = f1b->$invar1$(:,:) ;(south_north|:,west_east|:)
  avg_variance1b(:,:) = f1b->$invar_v$(:,:) ;(south_north|:,west_east|:)
  avg_seaice_1b(:,:) = f1b->SeaIce_avg(:,:) ;(south_north|:,west_east|:)
  avg_slp_1b(:,:) = f2b->slp(0,:,:)
  delete(f2b)

  if (varcode .eq. "curltau")then
    avg1 = where(avg1 .eq. "nan" .or. avg1 .eq. "-nan" .or. avg1 .eq. "inf" .or. avg1 .eq. "-inf", fill, avg1)
    avg1b = where(avg1b .eq. "nan" .or. avg1b .eq. "-nan" .or. avg1b .eq. "inf" .or. avg1b .eq. "-inf", fill, avg1b)
    avg1 = avg1*10.0E5
    avg1b = avg1b*10.0E5
    avg1@units = "10E-5 N m-3"
    avg1b@units = "10E-5 N m-3"
  end if

  ; delete vars to use in next loop
  delete(f1)
  delete(f1b)

print("Loaded variables from both files")
print("Masking terrain - net")
  ; mask terrain - focus on ocean
avg1(:,:) = where(z_sfc_1 .lt. 10., avg1(:,:), avg1@_FillValue)
avg1b(:,:) = where(z_sfc_1 .lt. 10., avg1b(:,:), avg1b@_FillValue)
avg_seaice_1(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
avg_seaice_1b(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)
avg_slp_1(:,:) = where(z_sfc_1 .lt. 10., avg_slp_1(:,:), avg_slp_1@_FillValue)
avg_slp_1b(:,:) = where(z_sfc_1 .lt. 10., avg_slp_1b(:,:), avg_slp_1b@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  avg1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1(:,:), avg1@_FillValue)
  avg1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1b(:,:), avg1b@_FillValue)
  avg_seaice_1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
  avg_seaice_1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)
  avg_slp_1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_slp_1(:,:), avg_slp_1@_FillValue)
  avg_slp_1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_slp_1b(:,:), avg_slp_1b@_FillValue)

;;;;;;;;;;
; Find difference
;;;;;;;;;;
avg_diff = avg1 - avg1b
title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; assign lat/lon info
avg1@lat2d = lat2d_1
avg1@lon2d = lon2d_1
avg1b@lat2d = lat2d_1
avg1b@lon2d = lon2d_1
avg_diff@lat2d = lat2d_1
avg_diff@lon2d = lon2d_1
avg_seaice_1@lat2d = lat2d_1
avg_seaice_1@lon2d = lon2d_1
avg_seaice_1b@lat2d = lat2d_1
avg_seaice_1b@lon2d = lon2d_1
avg_slp_1@lat2d = lat2d_1
avg_slp_1@lon2d = lon2d_1
avg_slp_1b@lat2d = lat2d_1
avg_slp_1b@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(avg_diff)+"  max: "+max(avg_diff)) 

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
avg_prob = 100.*(1. - ttest(avg1,avg_variance1,obs_1(0), avg1b,avg_variance1b,obs_1(0), False, False))

; make mask of points that are statistically significant at 95% level
; and fulfill cutoff of minimum differences
if (varcode .eq. "U10") then
  ; 1 m/s difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 0.95, 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .eq. "LH" .or. varcode .eq. "SH") then
  ; 10 W/m2 difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 10., 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .eq. "curltau")then
  ; 0.4X10E-5 N/m3 difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 0.4, 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .ne. "U10" .and. varcode .ne. "LH" .and. varcode .ne. "SH" .and. varcode .ne. "curltau")then
  ; all other variables
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_all = mask_95_prob
end if

; now get values for the mask so that we can actually plot it
; get numbers between 95 and 100 for the values this fits so we can contour properly
low =  95
high = 99.5
con = (high-low)/32766.0

dum1 = ndtooned(mask_all)
dum2 = ndtooned(var1)
dims = dimsizes(dum1)
dum3 = new((/dims/),"float")
do i = 0, dims - 1
  value = dum1(i)
  if(.not.ismissing(value))then
    dum3(i) = low+con*rand()
  end if
  if(ismissing(value) .and. .not.ismissing(dum2(i)))then
    dum3(i) = 50.0
  end if
  delete(value)
end do
prob_plot = onedtond(dum3,(/n_sn_1,n_we_1/))
delete(dum1)
delete(dum2)
delete(dum3)
delete(dims)

; assign lat/lon
avg_prob@lat2d = lat2d_1
avg_prob@lon2d = lon2d_1
prob_plot@lat2d = lat2d_1
prob_plot@lon2d = lon2d_1

print("completed calculations with net avg files")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate percent contributions to net avg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

avg_diff = where(avg_diff .eq. 0.0, avg_diff@_FillValue, avg_diff)

; get total points going into the averages
dum = ind(.not.ismissing(ndtooned(mask_all)))
pts_tot = dimsizes(dum)
delete(dum)

;;;;;;;;;;;;;;
; get percents for net terms
;;;;;;;;;;;;;;
; get % contribution for each point that is both within the 95% 
; confidence level *and* above the threshold of differences set earlier.
; Get the total percent contribution 

;;; term1 - net ;;;
term1_all = ((term1_sum*mask_all)/avg_diff)*100.
term1_pcnt = avg(term1_all)

;;; term2 - net ;;;
term2_all = ((term2_sum*mask_all)/avg_diff)*100.
term2_pcnt = avg(term2_all)

;;; term3 - net ;;;
term3_all = ((term3_sum*mask_all)/avg_diff)*100.
term3_pcnt = avg(term3_all)

;;; total pcnt ;;;
term_total_pcnt = term1_pcnt + term2_pcnt + term3_pcnt

;;;;;;;;;;;;;;
; get percents for groups
;;;;;;;;;;;;;;
;;; Group1 ;;;
group1_all = ((net_group1*mask_all)/avg_diff)*100.
group1_pcnt = avg(group1_all)

term1_group1_all = ((term1_sum_group1*mask_all)/term1_sum)*100.
term1_group1_pcnt = avg(term1_group1_all)

term2_group1_all = ((term2_sum_group1*mask_all)/term2_sum)*100.
term2_group1_pcnt = avg(term2_group1_all)

term3_group1_all = ((term3_sum_group1*mask_all)/term3_sum)*100.
term3_group1_pcnt = avg(term3_group1_all)

;;; Group2 ;;;
group2_all = ((net_group2*mask_all)/avg_diff)*100.
group2_pcnt = avg(group2_all)

term1_group2_all = ((term1_sum_group2*mask_all)/term1_sum)*100.
term1_group2_pcnt = avg(term1_group2_all)

term2_group2_all = ((term2_sum_group2*mask_all)/term2_sum)*100.
term2_group2_pcnt = avg(term2_group2_all)

term3_group2_all = ((term3_sum_group2*mask_all)/term3_sum)*100.
term3_group2_pcnt = avg(term3_group2_all)

;;; Group3 ;;;
group3_all = ((net_group3*mask_all)/avg_diff)*100.
group3_pcnt = avg(group3_all)

term1_group3_all = ((term1_sum_group3*mask_all)/term1_sum)*100.
term1_group3_pcnt = avg(term1_group3_all)

term2_group3_all = ((term2_sum_group3*mask_all)/term2_sum)*100.
term2_group3_pcnt = avg(term2_group3_all)

term3_group3_all = ((term3_sum_group3*mask_all)/term3_sum)*100.
term3_group3_pcnt = avg(term3_group3_all)

;;; Group4 ;;;
group4_all = ((net_group4*mask_all)/avg_diff)*100.
group4_pcnt = avg(group4_all)

term1_group4_all = ((term1_sum_group4*mask_all)/term1_sum)*100.
term1_group4_pcnt = avg(term1_group4_all)

term2_group4_all = ((term2_sum_group4*mask_all)/term2_sum)*100.
term2_group4_pcnt = avg(term2_group4_all)

term3_group4_all = ((term3_sum_group4*mask_all)/term3_sum)*100.
term3_group4_pcnt = avg(term3_group4_all)

;;; Group5 ;;;
group5_all = ((net_group5*mask_all)/avg_diff)*100.
group5_pcnt = avg(group5_all)

term1_group5_all = ((term1_sum_group5*mask_all)/term1_sum)*100.
term1_group5_pcnt = avg(term1_group5_all)

term2_group5_all = ((term2_sum_group5*mask_all)/term2_sum)*100.
term2_group5_pcnt = avg(term2_group5_all)

term3_group5_all = ((term3_sum_group5*mask_all)/term3_sum)*100.
term3_group5_pcnt = avg(term3_group5_all)

;;; Group6 ;;;
group6_all = ((net_group6*mask_all)/avg_diff)*100.
group6_pcnt = avg(group6_all)

term1_group6_all = ((term1_sum_group6*mask_all)/term1_sum)*100.
term1_group6_pcnt = avg(term1_group6_all)

term2_group6_all = ((term2_sum_group6*mask_all)/term2_sum)*100.
term2_group6_pcnt = avg(term2_group6_all)

term3_group6_all = ((term3_sum_group6*mask_all)/term3_sum)*100.
term3_group6_pcnt = avg(term3_group6_all)

;;; Group7 ;;;
group7_all = ((net_group7*mask_all)/avg_diff)*100.
group7_pcnt = avg(group7_all)

term1_group7_all = ((term1_sum_group7*mask_all)/term1_sum)*100.
term1_group7_pcnt = avg(term1_group7_all)

term2_group7_all = ((term2_sum_group7*mask_all)/term2_sum)*100.
term2_group7_pcnt = avg(term2_group7_all)

term3_group7_all = ((term3_sum_group7*mask_all)/term3_sum)*100.
term3_group7_pcnt = avg(term3_group7_all)

;;; Group8 ;;;
group8_all = ((net_group8*mask_all)/avg_diff)*100.
group8_pcnt = avg(group8_all)

term1_group8_all = ((term1_sum_group8*mask_all)/term1_sum)*100.
term1_group8_pcnt = avg(term1_group8_all)

term2_group8_all = ((term2_sum_group8*mask_all)/term2_sum)*100.
term2_group8_pcnt = avg(term2_group8_all)

term3_group8_all = ((term3_sum_group8*mask_all)/term3_sum)*100.
term3_group8_pcnt = avg(term3_group8_all)

;;;;;;;;;;;;;;
; get percents for nodes
;;;;;;;;;;;;;;
; Calculate percent contribution for each node (sum of all terms and terms individually)
; also get positive and negative contributions
nodes_all_pcnt = new((/nnode/),"float")
nodes_term1_pcnt = new((/nnode/),"float")
nodes_term2_pcnt = new((/nnode/),"float")
nodes_term3_pcnt = new((/nnode/),"float")

total_pcnt = 0.0
do n = 0, nnode - 1
  ; Get node contributions to net difference
   dum = ((nodes_sum_all(n,:,:)*mask_all)/avg_diff)*100.
   nodes_all_pcnt(n) = avg(dum)
   total_pcnt = total_pcnt + nodes_all_pcnt(n)
   
  ; each term individually
   ; term1 ;
   dum = ((term1(n,:,:)*mask_all)/term1_sum)*100.
   nodes_term1_pcnt(n) = avg(dum)

   ; term2 ;
   dum = ((term2(n,:,:)*mask_all)/term2_sum)*100.
   nodes_term2_pcnt(n) = avg(dum)
   
   ; term3 ;
   dum = ((term3(n,:,:)*mask_all)/term2_sum)*100.
   nodes_term3_pcnt(n) = avg(dum)
  
end do

print("Total nodes contribution = "+total_pcnt)
delete(total_pcnt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 2 - 3 panel of winter average values and difference and % contribution terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

  ; Set resources for plot
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""               ; Set this in loop
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic
  res@gsnMaximize                 = True              ; Make it as big as possible
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -35. ;-30.             ; set the center lat/lon
  res@mpCenterLatF                = 63.               
  res@mpGridAndLimbOn             = False            ; Turn on lat/lon grid
  ;res@mpGridLineDashPattern       = 2                ; Change dash pattern
  res@mpFillOn                    = True             ; Enables map fill
  res@mpGeophysicalLineColor      = "black"          ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
  res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 70.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

;;;;;;;;;;;;;
; Set resources for "normal" plots
;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@cnMissingValPerimOn        = True
  opts@cnMissingValPerimColor     = "black"
  opts@tiMainFontHeightF          = 0.015
  opts@lbLabelBarOn               = False
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

;;;;;;;;;;;;;
; Set resources for difference and term plots
;;;;;;;;;;;;
  optsd                            = res
  optsd@cnFillMode                 = cntype
  optsd@cnFillOn                   = True
  optsd@gsnSpreadColors            = True              ; use full colormap
  optsd@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  optsd@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  optsd@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  optsd@cnMinLevelValF             = cmin2             ; set min contour level specified above
  optsd@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  optsd@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  optsd@cnLinesOn                  = difflines         ; contour lines specified above
  optsd@cnLineLabelsOn             = difflines
  optsd@cnMissingValFillColor      = "gray85"          ; missing value color
  optsd@cnMissingValFillPattern    = 0                 ; fill in
  optsd@cnMissingValPerimOn        = True
  optsd@cnMissingValPerimColor     = "black"
  optsd@tiMainFontHeightF          = 0.015
  optsd@lbLabelBarOn               = False 
  optsd@lbLabelStride              = stride2
  optsd@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  optsd@pmLabelBarHeightF          = 0.075

;;;;;;;;;;;;;
; Set resources for seaice overlay
;;;;;;;;;;;;
  res_ice                            = True               ; reset options
  res_ice@gsnLeftString              = ""
  res_ice@gsnRightString             = ""
  res_ice@gsnFrame                   = False             ; Do not draw plot 
  res_ice@gsnDraw                    = False             ; Do not advance fr
  res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_ice@cnFillOn                   = False             ; turn on filled contours
  res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_ice@cnLinesOn                  = True              ; contour lines specified above
  res_ice@cnLineLabelsOn             = True             ; line labels on specified above
  res_ice@cnLineColor                = "black" ;"gray85"
  res_ice@cnLineThicknessF           = 3.0
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False

;;;;;;;;;;;;;
; Set resources for slp overlay
;;;;;;;;;;;;
  res_slp                            = True               ; reset options
  res_slp@gsnLeftString              = ""
  res_slp@gsnRightString             = ""
  res_slp@gsnFrame                   = False             ; Do not draw plot 
  res_slp@gsnDraw                    = False             ; Do not advance fr
  res_slp@cnInfoLabelOn              = True             ; Turn off info on contours at bottom
  res_slp@cnFillOn                   = False             ; turn on filled contours
  res_slp@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_slp@cnMinLevelValF             = 995.                ; set min contour level specified above
  res_slp@cnMaxLevelValF             = 1015.              ; set max contour level specified above
  res_slp@cnLevelSpacingF            = 1.0             ; set contour spacing specified above
  res_slp@cnLinesOn                  = True              ; contour lines specified above
  res_slp@cnLineLabelsOn             = True             ; line labels on specified above
  res_slp@cnLineColor                = "black" ;"gray85"
  res_slp@cnLineThicknessF           = 1.0
  res_slp@tiXAxisOn                  = False
  res_slp@tiYAxisOn                  = False

;;;;;;;;;;;;;
; Set resources for 95% significance overlay
;;;;;;;;;;;;
; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar
  res_95@cnFillOn                   = True              ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.0              ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.0              ; set contour spacing specified above
;  res_95@cnFillPatterns             = (/17, -1, 17/)    ; stipling where not significant
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling where significant and above threshold

; label lat/lon
  lat_t = 69.0
  lon_t = -40.5
  txres                             = True
  txres@txFontHeightF               = 0.05
  txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages and difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 3a - winter averages and difference")
fout   = "winds_figure_3a_slp"

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)
  plot = new(2, graphic)

;;;;;;;;;;;;;
; Make plot 0  - average field var1
;;;;;;;;;;;;;
  opts@tiMainString               = "a. ERA-I mean 10m wind speed"
  cplot0  = gsn_csm_contour_map(wks,winter_avg_1b,opts)
;  cplot0b = gsn_csm_contour(wks,seaice_avg_1b,res_ice)
  cplot0b = gsn_csm_contour(wks,avg_slp_1b,res_slp)
  overlay(cplot0,cplot0b)
  plot(0) = cplot0

;;;;;;;;;;;;;
; Make plot 1  - average field var1b
;;;;;;;;;;;;;    
  opts@tiMainString               = "b. WRF mean 10m wind speed"
  cplot1  = gsn_csm_contour_map(wks,winter_avg_1,opts)
;  cplot1b = gsn_csm_contour(wks,seaice_avg_1,res_ice)
  cplot1b = gsn_csm_contour(wks,avg_slp_1,res_slp)
  overlay(cplot1,cplot1b)
  plot(1) = cplot1

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  res_pan                            = True
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbTitleString              = "m s-1"
  res_pan@lbTitlePosition            = "Bottom"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.375

  gsn_panel(wks,(/plot/),(/1,2/),res_pan)               ; create final panel plot


; Finally - make plot
print("plot complete - converting figure 3a to png")
  delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")
  delete(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages and difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 3b - winter averages and difference")
fout1   = "winds_figure_3b"

  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(4, graphic)

;;;;;;;;;;;;;
; Make plot 0  - average field var1
;;;;;;;;;;;;;
  optsd@tiMainString               = "c. Mean Difference: WRF - ERA-I"
  cplot0  = gsn_csm_contour_map(wks1,winter_diff, optsd)
  cplot0a = gsn_csm_contour(wks1,seaice_avg_1b,res_ice)
  overlay(cplot0,cplot0a)
  cplot0b = gsn_csm_contour(wks1,avg_prob,res_95) ; all 95% confidence
  ; cplot0b = gsn_csm_contour(wks1,prob_plot, res_95)  ; 95% confidence and 1m/s threshold
  overlay(cplot0,cplot0b)
  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks1,cplot0,"100%", lon_t, lat_t, txres)
  plot(0) = cplot0

;;;;;;;;;;;;;
; Make plot 1  - Frequency term
;;;;;;;;;;;;;
  optsd@tiMainString               = "d. Total Frequency Term"
  cplot1  = gsn_csm_contour_map(wks1,term1_sum,optsd)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks1,cplot1,sprintf("%5.1f",term1_pcnt)+"%", lon_t, lat_t, txres)
  plot(1) = cplot1

;;;;;;;;;;;;;
; Make plot 2  - Intrapattern term
;;;;;;;;;;;;;
  optsd@tiMainString               = "e. Total Intrapattern Term"
  cplot2  = gsn_csm_contour_map(wks1,term2_sum,optsd)
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks1,cplot2,"85.0%",lon_t,lat_t,txres)
;  dum2 = gsn_add_text(wks1,cplot2,sprintf("%5.1f",term2_pcnt)+"%", lon_t, lat_t, txres)
  plot(2) = cplot2
 
;;;;;;;;;;;;;
; Make plot 3  - Combined term
;;;;;;;;;;;;;
  optsd@tiMainString               = "f. Total Combined Term"
  cplot3  = gsn_csm_contour_map(wks1,term3_sum,optsd)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks1,cplot3,sprintf("%5.1f",term3_pcnt)+"%", lon_t, lat_t, txres)
  plot(3) = cplot3

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  res_pan                            = True
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbTitleString              = "m s-1"
  res_pan@lbTitlePosition            = "Bottom"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbLabelStride              = stride2
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.75

  gsn_panel(wks1,(/plot/),(/2,2/),res_pan)               ; create final panel plot


; Finally - make plot
print("plot complete - converting figure 3b to png")
  delete(wks1)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")
  delete(plot)

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
