; Plots the frequency of node transitions
;
; Melissa Nigro Feb 2012
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

a_input=0.005
rlen_input=1000000
r_input=2
infile = "winds0.005_rlen1000000_r2.cod"
nx_node = 6
ny_node = 4
;a_input=0.04
;rlen_input=250000
;r_input=2
;infile = "winds0.04_rlen250000_r2.cod"
;nx_node = 5
;ny_node = 4
nnode = nx_node * ny_node
indir = "./"+nx_node+"x_"+ny_node+"y/"

outstring = flt2string(nx_node*1.0)+"x_"+flt2string(ny_node*1.0)+"y_transitions"
outfile = indir+"plots/transitions/"+outstring

;; read in transition data

transition_file="/data3/marichar/wrf_15km/raw/SOM_domain_test/SOM_training/"+nx_node+"x_"+ny_node+"y/node_transitions/"+nx_node+"x_"+ny_node+"y_"+a_input+"_rlen"+rlen_input+"_r"+r_input+".txt"
node_t=readAsciiTable(transition_file,5,"integer",0)
node_t_size = dimsizes(node_t)
tot_trans = sum(node_t(:,4))

print(tot_trans)

xxpos = 0
yypos = 0
nn = 0

map_to_self_freq = new((/nx_node,ny_node/),"float")
map_to_self_count = new((/nx_node,ny_node/),"integer")

do yy=0, ny_node-1
do xx=0, nx_node-1

nodefreq1 = new((/nx_node,ny_node/),"float")
nodecount1 = new((/nx_node,ny_node/),"integer")

xpos = 0
ypos = 0
n = 0

do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node"+x+","+y)

  ;; Get transition data
 
  node_tot_tran_ind = ind(node_t(:,0).eq.xx.and.node_t(:,1).eq.yy)
  node_tot_tran = sum(node_t(node_tot_tran_ind,4))  
  transition_ind = ind(node_t(:,0).eq.xx.and.node_t(:,1).eq.yy.and.node_t(:,2).eq.x.and.node_t(:,3).eq.y)
  if (all(ismissing(transition_ind))) then
  transition_num = 0
  nodefreq1(x,y) = 0
  nodecount1(x,y) = 0
  else
  transition_num=node_t(transition_ind,4)
  nodefreq1(x,y) = (int2flt(transition_num)/int2flt(node_tot_tran))*100.
  nodecount1(x,y) = transition_num
  end if

; Update xpos and ypos for next time through:
        xpos = xpos + 1
        if (xpos.eq.nx_node) then
          xpos = 0
          ypos = ypos + 1
        end if
        n = n + 1

delete(transition_ind)
delete(transition_num)

 end do
end do

print(xx)
print(yy)

map_to_self_freq(xx,yy) = nodefreq1(xx,yy)
map_to_self_count(xx,yy) = nodecount1(xx,yy)

print(map_to_self_freq)


;; Create the frequency plot

  wks2 = gsn_open_wks("ps",outfile+"_"+xx+"x_"+yy+"y")
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
;     ndates = ndates1
;     delete(ndates1)
     res_blank@tiMainString = "SOM Pattern Transition Frequency for Node "+xx+"x,"+yy+"y"
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
      xxx = (/0., 0., 1., 1., 0./)
      yyy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
      res_poly = True

      n = 0
      do yyyy = 0, ny_node - 1
        do xxxx = 0, nx_node - 1
          xp = xxx + xxxx
          yp = yyy + yyyy
          
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
            gray_index = slope * nodefreq(xxxx,yyyy) + 2.
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
      xxx = (/0., 0., 1., 1., 0./)
      yyy = (/0., 1., 1., 0., 0./)

; Text resources for count and freq:
      res_txt = True
      res_txt@txFontHeightF = 0.02
      res_txt@txFont = 22
      res_txt@txBackgroundFillColor = "white"

      n = 0
      do yyyyy = 0, ny_node - 1
        do xxxxx = 0, nx_node - 1
          xp = xxx + xxxxx
          yp = yyy + yyyyy
         
; Freq:
          text = sprintf("%5.2f",nodefreq(xxxxx,yyyyy))+"%"
          dum3(n) = gsn_add_text(wks2, plot2, text, xp(0)+.5, yp(0)+.65, res_txt)
          delete(text)
          
; Count:
          text = nodecount(xxxxx,yyyyy)+""
          dum4(n) = gsn_add_text(wks2, plot2, text, xp(0)+.5, yp(0)+.35, res_txt)
          delete(text)
          n = n + 1
        end do ; freq, and count for each node
      end do ; freq, and count for each node


draw(plot2)
frame(wks2)

; Update xpos and ypos for next time through:
        xxpos = xxpos + 1
        if (xxpos.eq.nx_node) then
          xxpos = 0
          yypos = yypos + 1
        end if
        nn = nn + 1

;print(nodefreq)
;print(nodefreq(xx,yy))
;print(xx)
;print(yy)

end do
end do

;print(map_to_self_freq)
;print(map_to_self_count) 

;; Create the map to self frequency plot

  wks3 = gsn_open_wks("ps",outfile+"map_to_self_freq")
  gsn_define_colormap(wks3,"gsdtol")
  gsn_reverse_colormap(wks3)
  colors = gsn_retrieve_colormap(wks3) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks3,colors,additional_colors)

; Reverse rows.  Need to do this for plotting purposes.
    map_to_self_freq     = map_to_self_freq(:,::-1)
    map_to_self_count    = map_to_self_count(:,::-1)

; Begin plotting:    
    plot3 = new(1, graphic)
    dum5  = new((/nnode/),graphic)
    dum6  = new((/nnode/),graphic)
    dum7  = new((/nnode/),graphic)
    dum8  = new((/nnode/),graphic)

    res_blank = True


     res_blank@tiMainString = "SOM Pattern Map to Self Frequency"
      maxnodefreq = max(map_to_self_freq)
print(maxnodefreq) 
      minnodefreq = 0.

      plot3 = gsn_blank_plot(wks3,res_blank)

; Add in squares:
      xm = (/0., 0., 1., 1., 0./)
      ym = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
      res_poly = True

      n = 0
      do ymm = 0, ny_node - 1
        do xmm = 0, nx_node - 1
          xp = xm + xmm
          yp = ym + ymm
          
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
            gray_index = slope * map_to_self_freq(xmm,ymm) + 2.
            if(gray_index.eq.2.) then
              gray_index = 0. ; to get actual white because out color table is flaky
            end if
            res_poly@gsFillColor = gray_index ; should auto round
            dum5(n) = gsn_add_polygon(wks3, plot3, xp, yp, res_poly)
            dum6(n) = gsn_add_polyline(wks3, plot3, xp, yp, res_poly)
          n = n + 1
        end do ; square for each node
      end do ; square for each node
  
; Finally, overlay text on top of everything else:
; Add in text:
      xm = (/0., 0., 1., 1., 0./)
      ym = (/0., 1., 1., 0., 0./)

; Text resources for count and freq:
      res_txt = True
      res_txt@txFontHeightF = 0.02
      res_txt@txFont = 22
      res_txt@txBackgroundFillColor = "white"

      n = 0
      do ymm = 0, ny_node - 1
        do xmm = 0, nx_node - 1
          xp = xm + xmm
          yp = ym + ymm
         
; Freq:
          text = sprintf("%5.2f",map_to_self_freq(xmm,ymm))+"%"
          dum7(n) = gsn_add_text(wks3, plot3, text, xp(0)+.5, yp(0)+.65, res_txt)
          delete(text)
          
; Count:
          text = map_to_self_count(xmm,ymm)+""
          dum8(n) = gsn_add_text(wks3, plot3, text, xp(0)+.5, yp(0)+.35, res_txt)
          delete(text)
          n = n + 1
        end do ; freq, and count for each node
      end do ; freq, and count for each node


draw(plot3)
frame(wks3)

end