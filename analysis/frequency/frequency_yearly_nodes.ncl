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
print("Plotting yearly frequency of each node")
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

;;;;;;;;;;
; Arrays of years to go through (20 seasons)
;;;;;;;;;;
; year that starts winter season
ys = (/"1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009"/)
; year that ends winter season
ye = (/"1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010"/)

; total number of seasons to loop through
nseas = dimsizes(ys)
; Make array to plot against
xaxis = ispan(0,nseas-1,1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in frequency data and calculate frequency for each season
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
infile = dir+nx_input+"x_"+ny_input+"y_199011_201003_dates_persistence.txt"
data = asciiread(infile,-1,"string")
ndates = dimsizes(data)
nx = new((/ndates/),"string")    ; nx assignment
ny = new((/ndates/),"string")    ; ny assignment
ym = new((/ndates/),"string")    ; year start

; load everything as characters for now, will convert to string as necessary
t = 0
do t=0, ndates -1
  dum = stringtochar(data(t))
  nx(t) = chartostring(dum(0))
  ny(t) = chartostring(dum(2))
  ym(t) = chartostring(dum(4:10))
  delete(dum)
end do
delete(data)

;;;;;;;;;;
; Calculate frequency for each winter season
;;;;;;;;;;
nodefreq = new((/nseas,nx_node,ny_node/),"float")
nodefreq_2 = new((/nseas,nnode/),"float")
n = 0
x = 0
y = 0
s = 0
; loop through each node
do s = 0, nseas -1
   ; get total days going into each winter season (should be same over all 20 years, but verify)
   check = 0
   total_dates = ind((ym.eq.ys(s)+"-11").or.(ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02").or.(ym.eq.ye(s)+"-03"))
   if (.not.all(ismissing(total_dates))) then
     season_ndates = dimsizes(total_dates)
   else
     print("This winter season is not showing any days")
   end if
   ; reset value that is used in variable for # nodes
   n = 0
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y+" and winter season "+s)
   dateindices = ind(((ym.eq.ys(s)+"-11").or.(ym.eq.ys(s)+"-12").or.(ym.eq.ye(s)+"-01").or.(ym.eq.ye(s)+"-02").or.(ym.eq.ye(s)+"-03")).and.(nx.eq.x .and. ny.eq.y))

  ; These are the dates for this particular node:
  ; This is the data for this node:
   if (all(ismissing(dateindices))) then
     node_ndates = 0
     nodefreq(s,x,y) = 0
     nodefreq_2(s,n) = 0
   end if
   if (.not.all(ismissing(dateindices))) then
     node_ndates = dimsizes(dateindices)
     nodefreq(s,x,y) = (int2flt(node_ndates)/int2flt(season_ndates))*100.
     nodefreq_2(s,n) = (int2flt(node_ndates)/int2flt(season_ndates))*100.
   end if
   n = n+1
   check = check + node_ndates
   delete(dateindices)
  end do
end do
; check if every day in this season was accounted for
if (check.ne.season_ndates) then
   print("Error.  Number of dates is not equal to total number of indices.")
   print("Num. dates: "+season_ndates+"   Tot indices: "+check)
end if
delete([/total_dates,check/])
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set output information
  fout  = "Yearly_frequency_wrf50_199011_201003-"+nx_input+"x_"+ny_input+"y"

print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  plot  = new(nnode, graphic)

; Reverse rows(for plotting purposes)
  nodefreq     = nodefreq(:,::-1,:)
  maxval = max(nodefreq) + 0.25

; Bar plot resources
  res_bar                                = True
  res_bar@gsnMaximize                    = True
  res_bar@gsnDraw                        = False
  res_bar@gsnFrame                       = False 
  res_bar@gsnXYBarChart                  = True
  res_bar@gsnXYBarChartColors            = (/"black","black","red","black","red","black","black","black","red","red","black","black","blue","blue","black","black","black","red","red","black"/)
  ;res_bar@gsnYRefLine                    = 0.
  ;res_bar@gsnAboveYRefLineColor          = "black"
  res_bar@gsnXYBarChartBarWidth          = 0.4
  res_bar@tmXTOn                         = False
  res_bar@tmXBMode                       = "Explicit"
  res_bar@tmXBLabels                     = (/"'91","'93","'95","'97","'99","'01","'03","'05","'07","'09"/)
  res_bar@tmXBValues                     = (/0, 2, 4, 6, 8, 10, 12, 14, 16, 18/)
  res_bar@tmXBLabelFontHeightF           = 0.02 ;0.025
  res_bar@tiYAxisFontHeightF             = 0.025
  res_bar@tiYAxisString                  = "Frequency"
  res_bar@trYMinF                        = 0.0
  res_bar@trYMaxF                        = maxval


n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1  
    plot(n) = gsn_csm_xy(wks,xaxis,nodefreq(:,x,y),res_bar)
    n = n + 1
  end do 
end do

print("Creating final panel plot.")
res_pan                       = True 
res_pan@gsnMaximize           = True
res_pan@gsnFrame              = False
res_pan@txString              = "Yearly node frequency: wrf50_199011_201003"
res_pan@txFontHeightF         = 0.015 
res_pan@gsnPaperOrientation   = "landscape" 
gsn_panel(wks,(/plot/),(/ny_node, nx_node/),res_pan)

; Finally - make plot
print("converting plot to png")
frame(wks)
delete(wks)
system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+  \
       "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
