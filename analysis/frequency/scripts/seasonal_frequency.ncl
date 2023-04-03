; This NCL script plots the frequency of each node for a given season.
;
; 9 Oct 2008 - Matt Higgins
; 5 Mar 2011 - Matt Higgins
;
; Edits: Melissa A. Nigro
; August 2011
; Alice DuVivier
; June 2013

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; ******************************************************
  datatitle1 = "wrf10_wrf50_erai" ;"wrf10_wrf50_erai" "wrf10_200511_200703" "wrf50_199701_200712" "era_i_199701_200712"
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
  avgperiod = (/"hr6","ALL"/)
  hrs_6 = (/"00","06","12","18"/)
  p = 0
; ******************************************************
; Figure out correct input and output files based on above information.
  outfile    = "/data3/duvivier/SOM/analysis/"+nx_input+"x_"+ny_input+"y_"+datatitle1+"_"+master_vals+"_freq"
fout = outfile+"_"+avgperiod(p)
  datefile1 = "/data3/duvivier/SOM/training/dates/"+datatitle1+"_dates.txt"
  visfile1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle1+"_"+master_vals+".vis"

  plottitle1 = datatitle1
  print(plottitle1+"")

  print("Loading dates.")
  dates1 = ndtooned(readAsciiTable(datefile1,1,"string",0)) ; ignores no rows
  ndates1 = dimsizes(dates1)
  dateschar1 = stringtochar(dates1)
  sdateyears1 = chartostring(dateschar1(:,0:3))
  sdatemonths1 = chartostring(dateschar1(:,4:5))
  sdatehours1 = chartostring(dateschar1(:,8:9))

  ; Bring in visual file that places each date at a given node
  print("Loading SOM visual data.")
  vis1 = new((/ndates1,3/),integer)
  vis1 = readAsciiTable(visfile1,3,"integer",1) ; ignores first row

  print(avgperiod(p))
  if (avgperiod(p).eq."hr6") then
      dateind1 = ind(sdatehours1.eq.hrs_6(0).or.sdatehours1.eq.hrs_6(1).or.sdatehours1.eq.hrs_6(2).or.sdatehours1.eq.hrs_6(3))
      visall1 = vis1(dateind1,:) ; get only every 6 hours
      ndates = dimsizes(visall1(:,0))
  end if
  if (avgperiod(p).eq."ALL") then
    visall1 = vis1
    ndates = dimsizes(visall1(:,0))
  end if

; Calculate node counts and frequencies
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

  nodefreq1     = new((/nx_node,ny_node/),"float") 
  nodecount1    = new((/nx_node,ny_node/),"integer") 

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
  dateindices1 = ind(visall1(:,0).eq.x.and.(visall1(:,1).eq.y))
        
; This is the data for this node:
   if (all(ismissing(dateindices1))) then
    node_ndates = 0
    nodefreq1(x,y) = 0
    nodecount1(x,y) = 0
   end if
   if (.not.all(ismissing(dateindices1))) then
    node_ndates = dimsizes(dateindices1)
    nodefreq1(x,y) = (int2flt(node_ndates)/int2flt(ndates))*100.
    nodecount1(x,y) = node_ndates
   end if

; Check to make sure all dates are accounted.
   check1 = check1 + node_ndates

; Update xpos and ypos for next time through:
   xpos = xpos + 1
   if (xpos.eq.nx_node) then
     xpos = 0
     ypos = ypos + 1
   end if
   n = n + 1
   delete(dateindices1)

 end do
end do

if (check1.ne.ndates) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates+"   Tot indices: "+check1)
; exit
end if

;; Create the frequency plot
  wks2 = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks2,"gsdtol")
  gsn_reverse_colormap(wks2)
  colors = gsn_retrieve_colormap(wks2) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks2,colors,additional_colors)

; Reverse rows.  Need to do this for plotting purposes.
  nodefreq1     = nodefreq1(:,::-1)
  nodecount1    = nodecount1(:,::-1)

; Begin plotting:    
  plot2 = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)

  res_blank = True

  nodefreq = nodefreq1
  delete(nodefreq1)
  nodecount = nodecount1
  delete(nodecount1)
  ndates = ndates
  delete(ndates)
  res_blank@tiMainString = plottitle1+" SOM Pattern Frequency - "+avgperiod(p)
  maxnodefreq = max(nodefreq)
  print(maxnodefreq) 
  minnodefreq = 0.


; Resources for blank plot:
  res_blank@gsnMaximize   = True
  res_blank@trXMinF       = 0
  res_blank@trXMaxF       = nx_node
  res_blank@trYMinF       = 0
  res_blank@trYMaxF       = ny_node
  res_blank@vpWidthF      = 0.6                     ; this is default
  res_blank@vpHeightF     = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF = 0.015
  res_blank@tiMainPosition = "Left"
  res_blank@tiMainJust     = "centerleft"
  res_blank@tmEqualizeXYSizes = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode      = "Explicit"
  res_blank@tmXBLabels    = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues    = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode      = "Explicit"
  res_blank@tmYLLabels    = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues    = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF = res_blank@tiMainFontHeightF
  res_blank@gsnFrame      = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw       = False   ; do not draw yet (so we can panel)
  res_blank@tiXAxisString  = "SOM Pattern"
  res_blank@tiYAxisString  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF = 0.012
  res_blank@tiYAxisFontHeightF = 0.012

  plot2 = gsn_blank_plot(wks2,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True

  n = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      xp = xx + x
      yp = yy + y
          
; Colored squares:
      if(isvar("res_poly@gsFillColor")) 
        delete(res_poly@gsFillColor)
      end if
      if (maxnodefreq.ne.0) then
        slope = (32. - 2.) / (maxnodefreq - minnodefreq)
      else
        slope=0
      end if
;            print(slope)
      gray_index = slope * nodefreq(x,y) + 2.
      if(gray_index.eq.2.) then
        gray_index = 0. ; to get actual white because out color table is flaky
      end if
      res_poly@gsFillColor = gray_index ; should auto round
      dum1(n) = gsn_add_polygon(wks2, plot2, xp, yp, res_poly)
      dum2(n) = gsn_add_polyline(wks2, plot2, xp, yp, res_poly)
      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
; Finally, overlay text on top of everything else:
; Add in text:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.02
  res_txt@txFont = 22
  res_txt@txBackgroundFillColor = "white"

  n = 0
  do y = 0, ny_node - 1
    do x = 0, nx_node - 1
      xp = xx + x
      yp = yy + y
         
; Freq:
      text = sprintf("%5.2f",nodefreq(x,y))+"%"
;          dum3(n) = gsn_add_text(wks2, plot2, text, xp(0)+.5, yp(0)+.65, res_txt)
      dum3(n) = gsn_add_text(wks2, plot2, text, xp(0)+.5, yp(0)+.5, res_txt)
    
      delete(text)
          
; Count:
      text = nodecount(x,y)+""
;          dum4(n) = gsn_add_text(wks2, plot2, text, xp(0)+.5, yp(0)+.35, res_txt)
      delete(text)
      n = n + 1
    end do ; freq, and count for each node
  end do ; freq, and count for each node

draw(plot2)
frame(wks2)


  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
