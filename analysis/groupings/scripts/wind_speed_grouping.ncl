;***************************************
; PROGRAM DESCRIPTION: This script plots node avgs of wind
; INPUT DATA: SOM cod file and matching WRF date files
; OUTPUT DATA: Panel plots of node avgs for specified variable
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
  varcode = "U10_field"
  datatitle1a = "wrf10_200511_200703_6h"
  datatitle1b = "wrf50_200511_200703_6h"
  datatitle1c = "era_i_200511_200703_6h"
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
plot1  = False ;True ; plot 1 - Frequency and frequency differences of all nodes (only needed once)
plot2  = True ; plot 2 - winter average for all nodes of avg (datatitle{1,1b,1c})
plot3  = True ; plot 3 - winter average for all nodes of datatitle1
plot4  = True ; plot 4 - winter average for all nodes of datatitle1b
plot5  = True ; plot 5 - winter average for all nodes of datatitle1c
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating why averages differ for: "+varcode)

; get tag to let us know if it needs interpolation
title1a_ch  = stringtocharacter(datatitle1a)
title1a_sub = title1a_ch(0:4)
tag_1a = chartostring(title1a_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag_1b = chartostring(title1b_sub)
title1c_ch  = stringtocharacter(datatitle1c)
title1c_sub = title1c_ch(0:4)
tag_1c = chartostring(title1c_sub)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate frequencies and change in frequencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load input files
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")

if (tag_1a .eq. "wrf10")then
  datatitle_1a = "wrf10_200511_200703"
  datefile_1a = "/data3/duvivier/SOM/training/dates/"+datatitle_1a+"_dates.txt"
  visfile_1a  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1a+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "wrf50")then
  datatitle_1b = "wrf50_199701_200712"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if
if (tag_1c .eq. "era_i")then
  datatitle_1c = "era_i_199701_200712"
  datefile_1c = "/data3/duvivier/SOM/training/dates/"+datatitle_1c+"_dates.txt"
  visfile_1c  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1c+"_"+master_vals+".vis"
end if

;;;;;;;;;;
; Load information for two files
;;;;;;;;;;
; file1 - wrf10
  dates_1a = ndtooned(readAsciiTable(datefile_1a,1,"string",0)) ; ignores no rows
  ndates_1a = dimsizes(dates_1a)
  dateschar_1a = stringtochar(dates_1a)
  sdateym_1a = chartostring(dateschar_1a(:,0:5))
  sdatehrs_1a = chartostring(dateschar_1a(:,8:9))
  vis_1a = new((/ndates_1a,3/),integer)
  vis_1a = readAsciiTable(visfile_1a,3,"integer",1) ; ignores first row
; file1b - wrf50
  dates_1b = ndtooned(readAsciiTable(datefile_1b,1,"string",0)) ; ignores no rows
  ndates_1b = dimsizes(dates_1b)
  dateschar_1b = stringtochar(dates_1b)
  sdateym_1b = chartostring(dateschar_1b(:,0:5))
  sdatehrs_1b = chartostring(dateschar_1b(:,8:9))
  vis_1b = new((/ndates_1b,3/),integer)
  vis_1b = readAsciiTable(visfile_1b,3,"integer",1) ; ignores first row
; file1c - era_i
  dates_1c = ndtooned(readAsciiTable(datefile_1c,1,"string",0)) ; ignores no rows
  ndates_1c = dimsizes(dates_1c)
  dateschar_1c = stringtochar(dates_1c)
  sdateym_1c = chartostring(dateschar_1c(:,0:5))
  sdatehrs_1c = chartostring(dateschar_1c(:,8:9))
  vis_1c = new((/ndates_1c,3/),integer)
  vis_1c = readAsciiTable(visfile_1c,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)

;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (tag_1a .eq. "wrf10")then     ; wrf 10km - just narrow down hours
  dateind_1a = ind(sdatehrs_1a.eq.hrs_6(0).or.sdatehrs_1a.eq.hrs_6(1).or.sdatehrs_1a.eq.hrs_6(2).or.sdatehrs_1a.eq.hrs_6(3))
  visall_1a = vis_1a(dateind_1a,:) ; get only every 6 hours
  ndates_1a = dimsizes(visall_1a(:,0))
end if
if (tag_1b .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_1b = ind(sdateym_1b.eq.ym_sub(0).or.sdateym_1b.eq.ym_sub(1).or.sdateym_1b.eq.ym_sub(2).or.sdateym_1b.eq.ym_sub(3).or.sdateym_1b.eq.ym_sub(4).or.sdateym_1b.eq.ym_sub(5).or.sdateym_1b.eq.ym_sub(6).or.sdateym_1b.eq.ym_sub(7).or.sdateym_1b.eq.ym_sub(8).or.sdateym_1b.eq.ym_sub(9))
  visall_1b_tmp = vis_1b(dateind_1b,:)
  sdatehrs_tmp = sdatehrs_1b(dateind_1b)
  ;sdateym_tmp = sdateym_1b(dateind_1b)
  delete(dateind_1b)
  dateind_1b = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1b = visall_1b_tmp(dateind_1b,:)
  ndates_1b = dimsizes(visall_1b(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1b_tmp)
end if
if (tag_1c .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_1c = ind(sdateym_1c.eq.ym_sub(0).or.sdateym_1c.eq.ym_sub(1).or.sdateym_1c.eq.ym_sub(2).or.sdateym_1c.eq.ym_sub(3).or.sdateym_1c.eq.ym_sub(4).or.sdateym_1c.eq.ym_sub(5).or.sdateym_1c.eq.ym_sub(6).or.sdateym_1c.eq.ym_sub(7).or.sdateym_1c.eq.ym_sub(8).or.sdateym_1c.eq.ym_sub(9))
  visall_1c = vis_1c(dateind_1c,:)
  ndates_1c = dimsizes(visall_1c(:,0))
end if
;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1a   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1a     = new((/nnode/),"float") 
  nodecount_1a    = new((/nnode/),"integer") 
; variable_1b
  nodefreq_1b   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1b     = new((/nnode/),"float") 
  nodecount_1b    = new((/nnode/),"integer")
; variable_1c
  nodefreq_1c   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1c     = new((/nnode/),"float") 
  nodecount_1c    = new((/nnode/),"integer") 

; set default check values
  check1a = 0
  check1b = 0
  check1c = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1a = ind(visall_1a(:,0).eq.x.and.(visall_1a(:,1).eq.y))
  dateindices_1b = ind(visall_1b(:,0).eq.x.and.(visall_1b(:,1).eq.y))
  dateindices_1c = ind(visall_1c(:,0).eq.x.and.(visall_1c(:,1).eq.y))
        
  ; Calculate frequencies
  ; variable 1
  if (all(ismissing(dateindices_1a))) then
    node_ndates_1a = 0
    nodefreq_1a(n) = 0
    nodecount_1a(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1a))) then
    node_ndates_1a = dimsizes(dateindices_1a)
    nodefreq_1a(x,y) = (int2flt(node_ndates_1a)/int2flt(ndates_1a))*100.
    freq_nodes_1a(n) = (int2flt(node_ndates_1a)/int2flt(ndates_1a))*100.
    nodecount_1a(n) = node_ndates_1a
  end if
  check1a = check1a + node_ndates_1a  ; make sure all dates are counted
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
  ; variable 1c
  if (all(ismissing(dateindices_1c))) then
    node_ndates_1c = 0
    nodefreq_1c(n) = 0
    nodecount_1c(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1c))) then
    node_ndates_1c = dimsizes(dateindices_1c)
    nodefreq_1c(x,y) = (int2flt(node_ndates_1c)/int2flt(ndates_1c))*100.
    freq_nodes_1c(n) = (int2flt(node_ndates_1c)/int2flt(ndates_1c))*100.
    nodecount_1c(n) = node_ndates_1c
  end if
  check1c = check1c + node_ndates_1c  ; make sure all dates are counted
   n = n + 1
   delete(dateindices_1a)
   delete(dateindices_1b)
   delete(dateindices_1c)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1a.ne.ndates_1a) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1a+"   Tot indices: "+check1a)
end if
if (check1b.ne.ndates_1b) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1b+"   Tot indices: "+check1b)
end if
if (check1c.ne.ndates_1c) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1c+"   Tot indices: "+check1c)
end if

print("completed frequency calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate node differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."U10_field") then
  vartitle1 = "Average Wind Field at 10m"
  invar1 = "u_10m_tr_avg"
  invar_v = "u_10m_tr_var"
  invar2 = "v_10m_tr_avg"
  invar_v2 = "v_10m_tr_var"
  vartype = "2d"
  cmaptype = "wind"
  find_field = True
  zoom2 = True
end if
if (varcode.eq."U10_speed") then
  vartitle1 = "Average Wind Speed at 10m"
  invar1 = "ws_10m_avg"
  invar_v = "ws_10m_var"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if
if (varcode.eq."SH") then
  vartitle1 = "Average Sensible Heat Flux at surface"
  invar1 = "hfss_avg"
  invar_v = "hfss_var"
  vartype = "2d"
  cmaptype = "shflux"
  zoom2 = True
end if
if (varcode.eq."LH") then
  vartitle1 = "Average Latent Heat Flux at surface"
  invar1 = "hfls_avg"
  invar_v = "hfls_var"
  vartype = "2d"
  cmaptype = "lhflux"
  zoom2 = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 18.
    clev1               = 1.
    stride1             = 2                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride2             = 2                 ; label stride for diff plot
    cmin3               = 0.
    cmax3               = 22.
    clev3               = 1.
    stride3             = 2                 ; label stride
    cmin4               = -20.
    cmax4               = 20.
    clev4               = 2.
    stride4             = 1                 ; label stride for diff plot
    cmin5               = -1.5
    cmax5               = 1.5
    clev5               = 0.1
    stride5             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 132               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 35                ; end at color
    spreadstart4        = 37                ; start at color
    spreadend4          = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1               =  -200.
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -300.
    cmax3               = 300.
    clev3               = 20.
    stride3             = 2                 ; label stride
    cmin4               = -150.
    cmax4               = 150.
    clev4               = 10.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -10.
    cmax5               =  10.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux") then
    cmin1               =  -200.
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -150.
    cmax2               =  150.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -300.
    cmax3               = 300.
    clev3               = 20.
    stride3             = 2                 ; label stride
    cmin4               = -150.
    cmax4               = 150.
    clev4               = 10.
    stride4             = 2                 ; label stride for diff plot
    cmin5               = -15.
    cmax5               =  15.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/node_avgs/"

;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname0 = "node_0x_0y_"+datatitle1a
  f0 = addfile(dir1 + fname0 + ".nc","r")
  lat2d_1a = f0->lat
  lon2d_1a = f0->lon
  z_sfc_1a = f0->Z_sfc
  obs_1a = f0->number_dates
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d_1a)     ; get lat/lon dimensions
  n_sn_1a = dims(0)              ; get south/north points
  n_we_1a = dims(1)              ; get west/east points
  n_tot_1a = n_sn_1a*n_we_1a              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF50 domain
  fname0b = "node_0x_0y_"+datatitle1b
  f0b = addfile(dir1 + fname0b + ".nc","r")
  lat2d_1b = f0b->lat
  lon2d_1b = f0b->lon
  z_sfc_1b = f0b->Z_sfc
  obs_1b = f0b->number_dates
  delete(fname0b)
  delete(f0b)

  dims = dimsizes(lat2d_1b)     ; get lat/lon dimensions
  n_sn_1b = dims(0)              ; get south/north points
  n_we_1b = dims(1)              ; get west/east points
  n_tot_1b = n_sn_1b*n_we_1b              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  ; create all-node array for node average variable
  var1a = new((/nnode,n_sn_1a,n_we_1a/),"float")
  var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  var1c = new((/nnode,n_sn_1b,n_we_1b/),"float")
  fill = var1a@_FillValue

  ; create all-node array for node average variable
  if (isvar("find_field").and. (find_field))then
    var2a = new((/nnode,n_sn_1a,n_we_1a/),"float")
    var2b = new((/nnode,n_sn_1b,n_we_1b/),"float")
    var2c = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  fname1a = "node_"+x+"x_"+y+"y_"+datatitle1a
  f1a = addfile(dir1 + fname1a + ".nc","r")
  var1a(n,:,:) = f1a->$invar1$(south_north|:,west_east|:)

  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1b
  f1b = addfile(dir1 + fname1b + ".nc","r")
  var1b(n,:,:) = f1b->$invar1$(south_north|:,west_east|:)

  fname1c = "node_"+x+"x_"+y+"y_"+datatitle1c
  f1c = addfile(dir1 + fname1c + ".nc","r")
  var1c(n,:,:) = f1c->$invar1$(south_north|:,west_east|:)

  ; for fields
  if (isvar("find_field").and.(find_field)) then
    var2a(n,:,:) = f1a->$invar2$(south_north|:,west_east|:)
    var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)
    var2c(n,:,:) = f1c->$invar2$(south_north|:,west_east|:)
  end if

  ; mask terrain - focus on ocean
  var1a(n,:,:) = where(z_sfc_1a .lt. 50., var1a(n,:,:), var1a@_FillValue)
  var1b(n,:,:) = where(z_sfc_1b .lt. 50., var1b(n,:,:), var1b@_FillValue)
  var1c(n,:,:) = where(z_sfc_1b .lt. 50., var1c(n,:,:), var1c@_FillValue)
  
  ; mask lat/lons - focus on S. Greenland region
  var1a(n,:,:) = where(lat2d_1a .gt. 55. .and. lat2d_1a .lt. 71. .and. lon2d_1a .lt. -19. .and. lon2d_1a .gt. -55., var1a(n,:,:), var1a@_FillValue)
  var1b(n,:,:) = where(lat2d_1b .gt. 55. .and. lat2d_1b .lt. 71. .and. lon2d_1b .lt. -19. .and. lon2d_1b .gt. -55., var1b(n,:,:), var1b@_FillValue)
  var1c(n,:,:) = where(lat2d_1b .gt. 55. .and. lat2d_1b .lt. 71. .and. lon2d_1b .lt. -19. .and. lon2d_1b .gt. -55., var1c(n,:,:), var1c@_FillValue)

  if (isvar("find_field").and.(find_field)) then
    var2a(n,:,:) = where(z_sfc_1a .lt. 50., var2a(n,:,:), var2a@_FillValue)
    var2b(n,:,:) = where(z_sfc_1b .lt. 50., var2b(n,:,:), var2b@_FillValue)
    var2c(n,:,:) = where(z_sfc_1b .lt. 50., var2c(n,:,:), var2c@_FillValue)

    var2a(n,:,:) = where(lat2d_1a .gt. 55. .and. lat2d_1a .lt. 71. .and. lon2d_1a .lt. -19. .and. lon2d_1a .gt. -55., var2a(n,:,:), var2a@_FillValue)
    var2b(n,:,:) = where(lat2d_1b .gt. 55. .and. lat2d_1b .lt. 71. .and. lon2d_1b .lt. -19. .and. lon2d_1b .gt. -55., var2b(n,:,:), var2b@_FillValue)
    var2c(n,:,:) = where(lat2d_1b .gt. 55. .and. lat2d_1b .lt. 71. .and. lon2d_1b .lt. -19. .and. lon2d_1b .gt. -55., var2c(n,:,:), var2c@_FillValue)
  end if

  ; delete vars to use in next loop
  delete(fname1a)
  delete(f1a)
  delete(fname1b)
  delete(f1b)
  delete(fname1c)
  delete(f1c)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1a .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/nnode,n_sn_1a,n_we_1a/),"float") 
  var1b_tmp_1d  = new((/n_tot_1a/),"float")
  var1c_new = new((/nnode,n_sn_1a,n_we_1a/),"float") 
  var1c_tmp_1d  = new((/n_tot_1a/),"float")
  if (isvar("find_field").and.(find_field))then
    var2b_new = new((/nnode,n_sn_1a,n_we_1a/),"float") 
    var2b_tmp_1d  = new((/n_tot_1a/),"float")
    var2c_new = new((/nnode,n_sn_1a,n_we_1a/),"float") 
    var2c_tmp_1d  = new((/n_tot_1a/),"float")
  end if

  do n = 0, nnode - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    var1c_1d = ndtooned(var1c(n,:,:))
     if (isvar("find_field").and.(find_field))then
       var2b_1d = ndtooned(var2b(n,:,:))
       var2c_1d = ndtooned(var2c(n,:,:))
     end if
    do i = 0, n_tot_1a - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        var1c_tmp_1d(i) = sum(var1c_1d(indices)*weight/sum(weight))
        if (isvar("find_field").and.(find_field))then
          var2b_tmp_1d(i) = sum(var2b_1d(indices)*weight/sum(weight))
          var2c_tmp_1d(i) = sum(var2c_1d(indices)*weight/sum(weight))
        end if
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1a,n_we_1a/))
    var1c_new(n,:,:) = onedtond(var1c_tmp_1d,(/n_sn_1a,n_we_1a/))
    if (isvar("find_field").and.(find_field))then
      var2b_new(n,:,:) = onedtond(var2b_tmp_1d,(/n_sn_1a,n_we_1a/))
      var2c_new(n,:,:) = onedtond(var2c_tmp_1d,(/n_sn_1a,n_we_1a/))
    end if

   ; counter
    print("created node avg "+n+" of "+nnode)
  end do

  delete(var1b)
  var1b = var1b_new
  delete(var1b_new)
  copy_VarMeta(var1a, var1b)
  copy_VarCoords(var1a,var1b)
  var1b@_FillValue = fill
  if (isvar("find_field") .and. (find_field))then
    delete(var2b)
    var2b = var2b_new
    delete(var2b_new)
    copy_VarMeta(var2a, var2b)
    copy_VarCoords(var2a,var2b)
    var2b@_FillValue = fill
  end if
  delete(var1c)
  var1c = var1c_new
  delete(var1c_new)
  copy_VarMeta(var1a, var1c)
  copy_VarCoords(var1a,var1c)
  var1c@_FillValue = fill
  if (isvar("find_field") .and. (find_field))then
    delete(var2c)
    var2c = var2c_new
    delete(var2c_new)
    copy_VarMeta(var2a, var2c)
    copy_VarCoords(var2a,var2c)
    var2c@_FillValue = fill
  end if

end if

;;;;;;;;;;
; Find Average
;;;;;;;;;;
  var1 = (var1a+var1b+var1c)/3.0
  var1@units = "m s-1"
  var1@long_name = "10m wind speed"
  var1@standard_name = "Wind speed"

;;;;;;;;;;
; Find field calculations
;;;;;;;;;;
if (isvar("find_field").and.(find_field)) then
  ; find wind field speed post interpolation
  U_1a = var1a
  V_1a = var2a
  U_1b = var1b
  V_1b = var2b
  U_1c = var1c
  V_1c = var2c
  ; get avg. vectors
  U = (U_1a + U_1b + U_1c)/3.0
  V = (V_1a + V_1b + V_1c)/3.0

  ; get speeds from field vectors
  var1  = sqrt(U^2+V^2)
  var1a = sqrt(U_1a^2+V_1a^2)
  var1b = sqrt(U_1b^2+V_1b^2)
  var1c = sqrt(U_1c^2+V_1c^2)
  var1@long_name = "Net 10m Wind Field"
  var1@standard_name = "Wind Field"
  delete(var2a)
  delete(var2b)
  delete(var2c)
end if

; assign lat/lon info
var1@lat2d = lat2d_1a
var1@lon2d = lon2d_1a
var1a@lat2d = lat2d_1a
var1a@lon2d = lon2d_1a
var1b@lat2d = lat2d_1a
var1b@lon2d = lon2d_1a
var1c@lat2d = lat2d_1a
var1c@lon2d = lon2d_1a

; assign vector lat/lon info
if (isvar("find_field").and.(find_field)) then
  U@lat2d = lat2d_1a
  U@lon2d = lon2d_1a
  copy_VarMeta(U,U_1a)
  copy_VarMeta(U,U_1b)
  copy_VarMeta(U,U_1c)
  copy_VarMeta(U,V)
  copy_VarMeta(U,V_1a)
  copy_VarMeta(U,V_1b)
  copy_VarMeta(U,V_1c)  
end if

print("completed node calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - Frequency and frequency differences of all nodes (only needed once)
; plot 2 - winter average for all nodes of avg for datatitle{1a,1b,1c}
; plot 3 - winter average for all nodes of datatitle1a
; plot 4 - winter average for all nodes of datatitle1b
; plot 5 - winter average for all nodes of datatitle1c
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Frequency differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
if (varcode .eq. "U10_speed")then  ; only plot this once for all varcodes
  print("Plot 1 - frequency differences")
  fout1 = "frequency_"+datatitle1+"-"+datatitle1b
  title_1 = tag_1b
  title_2 = tag_1+"-"+tag_1b
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 "+tag_1+" and "+tag_1b

  wks1 = gsn_open_wks("ps",fout1)
  gsn_define_colormap(wks1,"gsdtol")
  gsn_reverse_colormap(wks1)
  colors = gsn_retrieve_colormap(wks1) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks1,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq_1     = nodefreq_1(:,::-1)
  nodefreq_1b     = nodefreq_1b(:,::-1)
  ; reverse the statistical information as well
  test_stat = test_stat(:,::-1)
  freq_diff = freq_diff(:,::-1)

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
  res_txt@txFontHeightF = 0.0125 ;0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"
; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Get grey scales(same used for all data sets)
    maxnodefreq = max(nodefreq_1b)
    minnodefreq = 0.
    if (maxnodefreq.ne.0) then
      slope = (32. - 2.) / (maxnodefreq - minnodefreq)  ; use 32 because there are 32 colors
    else
      slope = 0
    end if
    ; variable 1
    gray_index = slope * nodefreq_1b(x,y) + 2.
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = "white" ;gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks1, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks1, plot, xp, yp, res_poly)
    ; Frequency text:
    res_txt1 = res_txt
    res_txt1@txBackgroundFillColor = gray_index ;"white" "black"
    text_1 = title_1+":~C~ "+sprintf("%5.2f",nodefreq_1b(x,y))+"%"
    dum3(n) = gsn_add_text(wks1, plot, text_1, xp(0)+.5, yp(0)+.75, res_txt1)
    delete(text_1)

    res_txt2 = res_txt
    res_txt2@txFontColor = "black"
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
    dum4(n) = gsn_add_text(wks1, plot, text_2, xp(0)+.5, yp(0)+.25, res_txt2)   
    delete(text_2)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks1)
  print("converting plot 1 to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title_1)
delete(title_2)
delete(title)
delete(additional_colors)
delete(plot)

end if
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages for nodes (avg of all data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
print("Plot 2 - winter node averages for all data")
fout2   = varcode+"_avg_all_data_200511_200703_6h_node_avg"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic
  res@gsnMaximize                 = True              ; Make it as big as possible
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -30.             ; set the center lat/lon
  res@mpCenterLatF                = 63.               
  res@mpGridAndLimbOn             = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                ; Change dash pattern
  res@mpFillOn                    = True             ; Enables map fill
  res@mpGeophysicalLineColor      = "black"          ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
  if (isvar("zoom2").and.(zoom2))then
    res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 70.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -20.0            ; set the maximum longitude 
  end if

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart3      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend3        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin3             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  res@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

; set resources for sea gentle overlay
  res_gentle                            = True               ; reset options
  res_gentle@gsnLeftString              = ""
  res_gentle@gsnRightString             = ""
  res_gentle@gsnFrame                   = False             ; Do not draw plot 
  res_gentle@gsnDraw                    = False             ; Do not advance fr
  res_gentle@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_gentle@cnFillOn                   = False             ; turn on filled contours
  res_gentle@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_gentle@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_gentle@cnMaxLevelValF             = 6.0              ; set max contour level specified above
  res_gentle@cnLevelSpacingF            = 6.0              ; set contour spacing specified above
  res_gentle@cnLinesOn                  = True              ; contour lines specified above
  res_gentle@cnLineLabelsOn             = False             ; line labels on specified above
  res_gentle@cnLineThicknessF           = 1.5
  res_gentle@tiXAxisOn                  = False
  res_gentle@tiYAxisOn                  = False
  res_gentle@cnLineColor                = "black"
  res_gentle@cnLineDashPattern          = 15

; set resources for sea near-gale overlay
  res_gale                            = True               ; reset options
  res_gale@gsnLeftString              = ""
  res_gale@gsnRightString             = ""
  res_gale@gsnFrame                   = False             ; Do not draw plot 
  res_gale@gsnDraw                    = False             ; Do not advance fr
  res_gale@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_gale@cnFillOn                   = False             ; turn on filled contours
  res_gale@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_gale@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_gale@cnMaxLevelValF             = 13.0              ; set max contour level specified above
  res_gale@cnLevelSpacingF            = 13.0              ; set contour spacing specified above
  res_gale@cnLinesOn                  = True              ; contour lines specified above
  res_gale@cnLineLabelsOn             = False             ; line labels on specified above
  res_gale@cnLineThicknessF           = 1.5
  res_gale@tiXAxisOn                  = False
  res_gale@tiYAxisOn                  = False
  res_gale@cnLineColor                = "black"

; set resources for sea storm overlay
  res_storm                            = True               ; reset options
  res_storm@gsnLeftString              = ""
  res_storm@gsnRightString             = ""
  res_storm@gsnFrame                   = False             ; Do not draw plot 
  res_storm@gsnDraw                    = False             ; Do not advance fr
  res_storm@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_storm@cnFillOn                   = False             ; turn on filled contours
  res_storm@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_storm@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_storm@cnMaxLevelValF             = 21.0              ; set max contour level specified above
  res_storm@cnLevelSpacingF            = 21.0              ; set contour spacing specified above
  res_storm@cnLinesOn                  = True              ; contour lines specified above
  res_storm@cnLineLabelsOn             = False             ; line labels on specified above
  res_storm@cnLineThicknessF           = 1.5
  res_storm@tiXAxisOn                  = False
  res_storm@tiYAxisOn                  = False
  res_storm@cnLineColor                = "black"
  res_storm@cnLineDashPattern          = 6

; set vector resources if it's a wind plot
  if (isvar("find_field").and.(find_field)) then
    vcres                         = res
    vcres@vcGlyphStyle            = "LineArrow"
    vcres@vcRefMagnitudeF         = 5.0      ; set vector reference magnitude
    vcres@vcRefLengthF            = 0.02     ; length of vector (larger = longer)
    vcres@vcMinDistanceF          = 0.05     ; vector spacing (smaller = more dense)
    vcres@vcMonoLineArrowColor    = True
    vcres@vcLineArrowColor        = "black"
    vcres@vcRefAnnoOn             = False
    vcres@gsnScalarContour        = True
  
    ;; vector legend placement
    ;vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
    ;vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
    ;vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
    ;vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
    ;vcres@vcRefAnnoString2           = "10 m/s"          ; label vector legend bottom string
    ;vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string
 end if
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1_2d = var1(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  if (isvar("find_field").and.(find_field))then
    U_2d = U(n,:,:)
    V_2d = V(n,:,:) 
    vcres@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
    vcres@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well     
    cplot  = gsn_csm_vector_scalar_map(wks2,U_2d,V_2d,var1_2d,vcres)
    plot(n) = cplot 
  else
    cplot  = gsn_csm_contour_map(wks2,var1_2d,res)
  end if
  ; overlay wind speed thresholds
  cplot2 = gsn_csm_contour(wks2,var1_2d,res_gentle)
  overlay(cplot,cplot2)
  cplot3 = gsn_csm_contour(wks2,var1_2d,res_gale)
  overlay(cplot,cplot3)
;  cplot4 = gsn_csm_contour(wks2,var1_2d,res_storm)
;  overlay(cplot,cplot4)

  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : avg all data 200511_200703_6h"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks2,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 2 to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"

  system(convert_cmd)

; keep most resources
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Winter averages for nodes (avg of all data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then  ; if plotting is turned on
print("Plot 3 - winter node averages for "+datatitle1a)
fout3   = varcode+"_"+datatitle1a+"_node_avg"

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(nnode, graphic)

; keep resources from previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1a_2d = var1a(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

;  if (isvar("find_field").and.(find_field))then
;    U_1a_2d = U_1a(n,:,:)
;    V_1a_2d = V_1a(n,:,:) 
;    vcres@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
;    vcres@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well     
;    cplot  = gsn_csm_vector_scalar_map(wks3,U_1a_2d,V_1a_2d,var1a_2d,vcres)
;    plot(n) = cplot 
;  else
    cplot  = gsn_csm_contour_map(wks3,var1a_2d,res)
;  end if
  ; overlay wind speed thresholds
  cplot2 = gsn_csm_contour(wks3,var1a_2d,res_gentle)
  overlay(cplot,cplot2)
  cplot3 = gsn_csm_contour(wks3,var1a_2d,res_gale)
  overlay(cplot,cplot3)
;  cplot4 = gsn_csm_contour(wks3,var1a_2d,res_storm)
;  overlay(cplot,cplot4)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : "+datatitle1a

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks3,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 3 to png")
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"

  system(convert_cmd)

; keep most resources
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Winter averages for nodes (avg of all data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
print("Plot 4 - winter node averages for "+datatitle1b)
fout4   = varcode+"_"+datatitle1b+"_node_avg"

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(nnode, graphic)

; keep resources from previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1b_2d = var1b(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

;  if (isvar("find_field").and.(find_field))then
;    U_1b_2d = U_1b(n,:,:)
;    V_1b_2d = V_1b(n,:,:) 
;    vcres@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
;    vcres@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well     
;    cplot  = gsn_csm_vector_scalar_map(wks4,U_1b_2d,V_1b_2d,var1b_2d,vcres)
;    plot(n) = cplot 
;  else
    cplot  = gsn_csm_contour_map(wks4,var1b_2d,res)
;  end if
  ; overlay wind speed thresholds
  cplot2 = gsn_csm_contour(wks4,var1b_2d,res_gentle)
  overlay(cplot,cplot2)
  cplot3 = gsn_csm_contour(wks4,var1b_2d,res_gale)
  overlay(cplot,cplot3)
;  cplot4 = gsn_csm_contour(wks4,var1b_2d,res_storm)
;  overlay(cplot,cplot4)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks4,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 4 to png")
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"

  system(convert_cmd)

; keep most resources
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - Winter averages for nodes (avg of all data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot5").and.(plot5))then  ; if plotting is turned on
print("Plot 5 - winter node averages for "+datatitle1c)
fout5   = varcode+"_"+datatitle1c+"_node_avg"

  wks5 = gsn_open_wks("ps" ,fout5)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks5,colormap,additional_colors)
  plot = new(nnode, graphic)

; keep resources from previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1c_2d = var1c(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks5,var1c_2d,res)
;  if (isvar("find_field").and.(find_field))then
;    U_1c_2d = U_1c(n,:,:)
;    V_1c_2d = V_1c(n,:,:) 
;    vcres@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
;    vcres@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well     
;    cplot  = gsn_csm_vector_scalar_map(wks5,U_1c_2d,V_1c_2d,var1c_2d,vcres)
;    plot(n) = cplot 
;  else
    cplot  = gsn_csm_contour_map(wks5,var1c_2d,res)
;  end if
  ; overlay wind speed thresholds
  cplot2 = gsn_csm_contour(wks5,var1c_2d,res_gentle)
  overlay(cplot,cplot2)
  cplot3 = gsn_csm_contour(wks5,var1c_2d,res_gale)
  overlay(cplot,cplot3)
;  cplot4 = gsn_csm_contour(wks5,var1c_2d,res_storm)
;  overlay(cplot,cplot4)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : "+datatitle1c

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks5,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 5 to png")
  convert_cmd = "convert -density 300 "+fout5+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout5+".png"

  system(convert_cmd)

; keep most resources
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
