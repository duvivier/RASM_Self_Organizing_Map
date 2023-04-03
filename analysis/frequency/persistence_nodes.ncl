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
print("Running SOM frequency plot - monthly and persistence - nodes")
;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loop through month options for plotting
m = 0
do m = 0, times - 1
  fout  = nx_input+"x_"+ny_input+"y-event_duration_month-"+months(m)+"_wrf50_199011_201003"
  print("Plotting the som frequencies")
  ; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  plot  = new(nnode, graphic)
  txt   = new(nnode,graphic)  

  ; get subset of data
  nodecount_sub = nodecount(m,:,:,:)
  ; Reverse rows(for plotting purposes)
  ;nodecount_sub = nodecount_sub(:,::-1,:)
  maxval_all = max(nodecount) + 1
  maxval_sub = max(nodecount(0:4,:,:,:))+1

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
  res_bar@tmXBLabels                     = (/"0","1","2","3","4","5","6","7","8","9","10"/)
  res_bar@tmXBValues                     = (/0.,1.,2.,3.,4.,5.,6.,7.,8.,9.,10./)
  res_bar@tmXBLabelFontHeightF           = 0.025
  res_bar@tiYAxisFontHeightF             = 0.025
  res_bar@tiYAxisString                  = "# events"
  res_bar@tiXAxisString                  = "# days duration"
  res_bar@tiXAxisFontHeightF             = 0.025
  res_bar@trYMinF                        = 0.0
  if (months(m) .eq. "xx")then
    res_bar@trYMaxF                      = maxval_all
    yloc                                 = maxval_all - 40.0
  else
    res_bar@trYMaxF                      = maxval_sub
    yloc                                 = maxval_sub - 10.0    
  end if

; Text resources for percent long events:
  res_txt = True
  res_txt@txFontHeightF = 0.05
  res_txt@txFont = 22
  res_txt@txFontColor = "black"
  res_txt@txBackgroundFillColor = "white"

  n = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1  
      ; plot bar graph of events
      plot(n) = gsn_csm_xy(wks,xaxis,nodecount_sub(:,x,y),res_bar)
      ; add text to plot with percent events .ge. 3 days 
      ; percent events eq 1 day
      pct1 = ((int2flt(sum(nodecount_sub(1,x,y))))/(int2flt(sum(nodecount_sub(:,x,y)))))*100.
      ; percent events eq 2 days
      pct2 = ((int2flt(sum(nodecount_sub(2,x,y))))/(int2flt(sum(nodecount_sub(:,x,y)))))*100.
      ; percent events ge than 3 days
      pct3 = ((int2flt(sum(nodecount_sub(3:10,x,y))))/(int2flt(sum(nodecount_sub(:,x,y)))))*100.
      ;evt = int2flt(sum(nodecount_sub(3:10,x,y)))
      ;text_pct = sprintf("%5.1f",pct)+"%~C~of events~C~.ge. 3 days~C~"+sprintf("%5.0f",evt)+" events"
      text_pct = "1day: "+sprintf("%5.1f",pct1)+"%~C~2day: "+sprintf("%5.1f",pct2)+"%~C~3+day: "+sprintf("%5.1f",pct3)+"%"
      txt(n) = gsn_add_text(wks,plot(n),text_pct,7.5,yloc,res_txt)
      delete([/text_pct,pct1,pct2,pct3/])
      n = n + 1
    end do 
  end do
  print("Creating final panel plot.")
  res_pan                       = True 
  res_pan@txString              = "Event duration for month: "+months(m)
  res_pan@txFontHeightF         = 0.015 
  res_pan@gsnPaperOrientation   = "landscape" 
  res_pan@gsnMaximize           = True 
  gsn_panel(wks,(/plot/),(/ny_node, nx_node/),res_pan)

; Finally - make plot
  print("converting plot to png")
  delete(wks)
  system("convert -trim -border 10 -depth 8 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

  delete([/yloc,txt,plot,fout,nodecount_sub/])
end do

;;;;;;;;;;;;;;;;;;;;;; END script
end
