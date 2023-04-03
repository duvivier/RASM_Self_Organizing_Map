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
  fout  = "Monthly_frequency_"+data+"-"+nx_input+"x_"+ny_input+"y"

;;;;;;;;;;
; Calculate frequencies for each month for each node
;;;;;;;;;;
months = (/"11","12","01","02","03"/)
times = dimsizes(months)
; Make array to plot against
xaxis = ispan(0,times-1,1)

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node
  nodefreq         = new((/nx_node,ny_node/),"float")
  nodefreq_all     = new((/times,nx_node,ny_node/),"float") 
  nodecount        = new((/nx_node,ny_node/),"integer") 
  nodecount_all    = new((/times,nx_node,ny_node/),"integer") 

; set default check values
  check = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   do m = 0, times - 1
      print("node: "+x+","+y+" and month "+months(m))
      ; These are the dates for this particular node:
      dateindices = ind((mm.eq.months(m)).and.(vis(:,0).eq.x.and.(vis(:,1).eq.y)))
      ; This is the data for this node:
      if (all(ismissing(dateindices))) then
      	 node_ndates = 0
     	 nodefreq_all(x,y,m) = 0
     	 nodecount(x,y,m) = 0
      end if
      if (.not.all(ismissing(dateindices))) then
      	 node_ndates = dimsizes(dateindices)
     	 nodefreq_all(m,x,y) = (int2flt(node_ndates)/int2flt(ndates))*100.
     	 nodecount_all(m,x,y) = node_ndates
      end if
      check = check + node_ndates
      delete(dateindices)
   end do
   ; Get total node frequencies and #mappings
   nodefreq(x,y) = sum(nodefreq_all(:,x,y))
   nodecount(x,y) = sum(nodecount_all(:,x,y))
 end do
end do
; Check the dates and print error messages if calculation fails
if (check.ne.ndates) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates+"   Tot indices: "+check)
end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  plot  = new(nnode, graphic)

; Reverse rows(for plotting purposes)
  nodefreq_all     = nodefreq_all(:,::-1,:)
  maxval = max(nodefreq_all) + 0.25

; Bar plot resources
  res_bar                                = True
  res_bar@gsnMaximize                    = True
  res_bar@gsnDraw                        = False
  res_bar@gsnFrame                       = True
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
do y = 0, ny_node - 1
  do x = 0, nx_node - 1  
    plot(n) = gsn_csm_xy(wks,xaxis,nodefreq_all(:,x,y),res_bar)
    n = n + 1
  end do 
end do

print("Creating final panel plot.")
res_pan                       = True 
res_pan@txString              = "Monthly node frequency: "+data
res_pan@txFontHeightF         = 0.015 
res_pan@gsnPaperOrientation   = "landscape" 
res_pan@gsnMaximize           = True 
gsn_panel(wks,(/plot/),(/ny_node, nx_node/),res_pan)

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+  \
       "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
