; Plots node transitions with arrows between neighboring nodes.
;
; Melissa Nigro March 2012
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

a_input=0.005
rlen_input=1000000
r_input=2
infile = "winds0.01_rlen1000000_r2.cod"
nx_node = 6
ny_node = 4
nnode = nx_node * ny_node
indir = "./"+nx_node+"x_"+ny_node+"y/"

f1_type     = "wrf"
f1_descrip  = "data"
startyearmonth   = 200810
endyearmonth     = 201009
nx_input = "6"
ny_input = "4"
;a_input = "0.005"
l_input = "1000000"
;r_input = "2"

outstring = flt2string(nx_node*1.0)+"x_"+flt2string(ny_node*1.0)+"y_transitions"
outfile = indir+"plots/transitions/"+outstring+"_map_2"

;; read in transition data

transition_file="/data3/marichar/wrf_15km/raw/SOM_domain_test/SOM_training/"+nx_node+"x_"+ny_node+"y/node_transitions/"+nx_node+"x_"+ny_node+"y_"+a_input+"_rlen"+rlen_input+"_r"+r_input+"_map.txt"
node_t=readAsciiTable(transition_file,10,"integer",0)
node_t_size = dimsizes(node_t)

total_transition_file="/data3/marichar/wrf_15km/raw/SOM_domain_test/SOM_training/"+nx_node+"x_"+ny_node+"y/node_transitions/"+nx_node+"x_"+ny_node+"y_"+a_input+"_rlen"+rlen_input+"_r"+r_input+".txt"
t_node_t=readAsciiTable(total_transition_file,5,"integer",0)


; Get 10m wind data for plots

u_datafile1 = "som_extract_plotting/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_10m.dat"
v_datafile1 = "som_extract_plotting/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_10m.dat"

datefile1 = "./dates/"+startyearmonth+"_"+endyearmonth+"_dates.txt" 
visfile1  = nx_input+"x_"+ny_input+"y/visual/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+".vis" 
plottitle1 = outstring+" Transitions"

f1 = addfile("/data3/marichar/wrf_15km/inner/200810/2008100100-f012-cf-inner-SOM.nc", "r")
lat2d = f1->lat
lon2d = f1->lon
lat1d = ndtooned(lat2d)
lon1d = ndtooned(lon2d)
dims = dimsizes(lat2d)
n_sn = dims(0)        ; nx_grid
n_we = dims(1)        ; ny_grid
n_tot = n_sn * n_we   ; ncol

som_header = readAsciiHead(u_datafile1,1)

delim = " "
ncol = stringtoint(str_get_field(som_header,1,delim))
if (ncol.ne.n_tot) then
  print("data mixup!")
  exit
end if

print("Now is a good time for a cup of coffee.")

u_data1 = readAsciiTable(u_datafile1,ncol,"float",1)
v_data1 = readAsciiTable(v_datafile1,ncol,"float",1)
u_data1@_FillValue = -999999
v_data1@_FillValue = -999999

nsizes = dimsizes(u_data1)
ndates1 = nsizes(0)

topo_2d = f1->Z_sfc
topo_2d@_FillValue = -999999
topo = ndtooned(topo_2d)
topo@_FillValue = -999999

colormap = "wind_color_table_SOM"
unit = "ms-1"

; Bring in visual file that places each date at a given node
print("Loading SOM visual data.")
vis1 = new((/ndates1,3/),integer)
vis1 = readAsciiTable(visfile1,3,"integer",1)

print("Loading dates.")
dates1 = ndtooned(readAsciiTable(datefile1,1,"string",0))
dateschar1 = stringtochar(dates1)
sdatemonths1 = chartostring(dateschar1(:,4:5))

print("Done loading.  Setting graphics options.")

wks = gsn_open_wks("ps",outfile)

;gsn_define_colormap(wks,colormap)
gsn_merge_colormaps(wks,colormap,"Navy")

; Graphic options:
 resources                             = True
 resources@gsnMaximize                 = True
 resources@gsnFrame                    = False
 resources@gsnDraw                     = False
 resources@gsnAddCyclic                = False
 resources@mpProjection                = "Stereographic"
 resources@mpLimitMode             = "Points"
; resources@mpCenterLonF            = -180.
; resources@mpCenterLatF            = -85.
; resources@mpLeftPointLatF         = -78.
; resources@mpLeftPointLonF         = 160.
; resources@mpRightPointLatF        = -78.
; resources@mpRightPointLonF        = -145.
; resources@mpTopPointLatF          = -77.
; resources@mpTopPointLonF          = 180.
; resources@mpBottomPointLatF       = -87.
; resources@mpBottomPointLonF       = 180.
 resources@mpCenterLonF            = -180.
 resources@mpCenterLatF            = -83.
 resources@mpLeftPointLatF         = -75.5
 resources@mpLeftPointLonF         = 150.
 resources@mpRightPointLatF        = -75.5
 resources@mpRightPointLonF        = -140.
 resources@mpTopPointLatF          = -74.5
 resources@mpTopPointLonF          = 180.
 resources@mpBottomPointLatF       = -89.5
 resources@mpBottomPointLonF       = 180.
; resources@mpGeophysicalLineColor      = "black"
; resources@mpGeophysicalLineThicknessF = 0.75
 resources@mpOutlineOn                 = False
 resources@mpFillOn                    = False

 resources@cnFillOn                    = True
 resources@cnMissingValFillColor       = "gray"
 resources@cnLineLabelsOn              = False
 resources@cnInfoLabelOn               = False

 resources@tiMainFontHeightF           = 0.03
 resources@lbLabelBarOn                = False

 resources@gsnSpreadColors             = True
 resources@cnLinesOn                   = False
 resources@gsnSpreadColorEnd           = -3
 resources@cnLevelSelectionMode = "ExplicitLevels"
 resources@cnLevels = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18/)
 resources@gsnSpreadColorEnd          = -3
; resources@gsnScalarContour            = True
; resources@vcGlyphStyle = "LineArrow"
; resources@vcRefMagnitudeF = 1.0
; resources@vcRefLengthF = 0.01
; resources@vcMonoLineArrowColor = True
; resources@vcLineArrowColor = "black"
; resources@vcMinDistanceF = 0.05
; resources@vcRefAnnoOn = False
; resources@tfDoNDCOverlay = False

 nodestring       = new(n_tot,"string") ; this is used for a double check

 check1 = 0
 check2 = 0
 xpos = 0
 ypos = 0
 n = 0

 visall1 = vis1 ; get 'em all
 ndates1 = dimsizes(visall1(:,0))
 
 temp_plot = new(nnode, graphic)
 plot1  = new(nnode, graphic)
 dum_T  = new(nnode, graphic)
 dum_RT = new(nnode, graphic)
 dum_R  = new(nnode, graphic)
 dum_RB = new(nnode, graphic) 
 dum_B  = new(nnode, graphic)
 dum_LB = new(nnode, graphic)
 dum_L  = new(nnode, graphic)
 dum_LT = new(nnode, graphic)

 u_var_data1 = new(ncol,"float")
 v_var_data1 = new(ncol,"float")
 u_avg_data1 = new(ncol,"float")
 v_avg_data1 = new(ncol,"float")

 nptused1  = new(ncol, "integer")
    
 do y = 0, ny_node - 1
  do x = 0, nx_node - 1


print("node"+x+","+y)

; These are the dates for this particular node:

  dateindices1 = ind(visall1(:,0).eq.x.and.(visall1(:,1).eq.y))
        
; This is the data for this node:

  if (all(ismissing(dateindices1))) then
   u_node_data1   = new(n_tot, "float")
   v_node_data1   = new(n_tot, "float")
   node_ndates1 = 0
  end if
  if (.not.all(ismissing(dateindices1))) then
   u_node_data1 = u_data1(dateindices1,:)
   v_node_data1 = v_data1(dateindices1,:)
   node_ndates1 = dimsizes(dateindices1)
  end if

print("made arrays")

; Check to make sure all dates are accounted.
  check1 = check1 + node_ndates1


; Need to do some checks to make sure we actually have two dimensional data:
  rank1 = dimsizes(dimsizes(u_node_data1))
  if (rank1.eq.1) then
   u_node_data1_temp = conform_dims((/1,n_tot/),u_node_data1,1)
   v_node_data1_temp = conform_dims((/1,n_tot/),v_node_data1,1)
   delete(u_node_data1)
   delete(v_node_data1)
   u_node_data1 = u_node_data1_temp
   v_node_data1 = v_node_data1_temp
   delete(u_node_data1_temp)
   delete(v_node_data1_temp)
  end if

print("changed rank")

  u_node_data1!0 = "dates"
  u_node_data1!1 = "cords"
  u_node_data1@_FillValue = -999999
  v_node_data1!0 = "dates"
  v_node_data1!1 = "cords"     
  v_node_data1@_FillValue = -999999  


; calculate averages and variance
  if (node_ndates1.ne.0) then
   stat2(u_node_data1(cords|:,dates|:),u_avg_data1,u_var_data1,nptused1)
   stat2(v_node_data1(cords|:,dates|:),v_avg_data1,v_var_data1,nptused1)
  end if

print("got average")

  u_avg2d1 = onedtond(u_avg_data1,(/n_sn,n_we/))
  u_avg2d1@lat2d = lat2d
  u_avg2d1@lon2d = lon2d
  u_avg2d1@_FillValue = -999999
  v_avg2d1 = onedtond(v_avg_data1,(/n_sn,n_we/))
  v_avg2d1@lat2d = lat2d
  v_avg2d1@lon2d = lon2d
  v_avg2d1@_FillValue = -999999
  ws_avg2d1 = (/sqrt((u_avg2d1*u_avg2d1)+(v_avg2d1*v_avg2d1))/)
  ws_avg2d1@lat2d = lat2d
  ws_avg2d1@lon2d = lon2d
  ws_avg2d1@_FillValue = -999999

print("got magnitude")

 u_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),u_avg2d1@_FillValue,u_avg2d1)
 v_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),v_avg2d1@_FillValue,v_avg2d1)
 ws_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),ws_avg2d1@_FillValue,ws_avg2d1)

print("set missing values")
        
print("("+x+","+y+") "+f1_type+" "+f1_descrip+": min is "+min(ws_avg2d1)+" max is "+max(ws_avg2d1)+" with n = "+node_ndates1)

 resources@gsnRightString = "("+xpos+","+ypos+")"  ; (this changes)
 nodestring(n) = resources@gsnRightString ; for reference
 resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
 resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
; resources@gsnLeftString = round(min(ws_avg2d1),3)+"/" + round(max(ws_avg2d1),3)+" "+unit
; resources@gsnCenterString = "n = "+node_ndates1
 
; plot1(n) = gsn_csm_vector_scalar_map(wks,u_avg2d1,v_avg2d1,ws_avg2d1,resources)

 
; temp_plot(n) = gsn_csm_vector_scalar_map(wks,u_avg2d1,v_avg2d1,ws_avg2d1,resources)

 

print("made plot(n)")



 tr_ind = ind(node_t(:,0).eq.x.and.node_t(:,1).eq.y)
 T  = node_t(tr_ind,2)
 RT = node_t(tr_ind,3)
 R  = node_t(tr_ind,4)
 RB = node_t(tr_ind,5)
 B  = node_t(tr_ind,6)
 LB = node_t(tr_ind,7)
 L  = node_t(tr_ind,8)
 LT = node_t(tr_ind,9)


 total = T+RT+R+RB+B+LB+L+LT

print(total) 



; Total map to self

ind_self = ind(t_node_t(:,0).eq.x.and.t_node_t(:,1).eq.y.and.t_node_t(:,2).eq.x.and.t_node_t(:,3).eq.y)
self = t_node_t(ind_self,4)

; Total number of transitions
ind_trans = ind(t_node_t(:,0).eq.x.and.t_node_t(:,1).eq.y)
print(ind_trans)
trans_array = t_node_t(ind_trans,4)
trans=sum(trans_array)

; Total number of transition to non-adjacent
non_adj = trans-self-total

freq_adj = (int2flt(total)/int2flt(trans))*100
freq_non_adj = (int2flt(non_adj)/int2flt(trans))*100
freq_self = (int2flt(self)/int2flt(trans))*100

 resources@gsnLeftString = round(freq_adj,3)+"/" + round(freq_non_adj,3)+"/" + round(freq_self,3)+" %"

 temp_plot(n) = gsn_csm_contour_map(wks,ws_avg2d1,resources)

 T_freq  = (int2flt(T)/int2flt(trans))*100.
 RT_freq = (int2flt(RT)/int2flt(trans))*100.
 R_freq  = (int2flt(R)/int2flt(trans))*100.
 RB_freq = (int2flt(RB)/int2flt(trans))*100.
 B_freq  = (int2flt(B)/int2flt(trans))*100.
 LB_freq = (int2flt(LB)/int2flt(trans))*100.
 L_freq  = (int2flt(L)/int2flt(trans))*100.
 LT_freq = (int2flt(LT)/int2flt(trans))*100. 
 

 max_size = 0.8

 T_size  = max_size*(T_freq/100.)
 RT_size = max_size*(RT_freq/100.)
 R_size  = max_size*(R_freq/100.)
 RB_size = max_size*(RB_freq/100.)
 B_size  = max_size*(B_freq/100.)
 LB_size = max_size*(LB_freq/100.)
 L_size  = max_size*(L_freq/100.)
 LT_size = max_size*(LT_freq/100.)


 txres = True
 txres@txFontColor   = "Navy"
 txres@txFontThicknessF = 5.
 txConstantSpacingF  = 0.0000001

 txres@txFontHeightF = T_size
 txres@txAngleF      = 0.
 txres@txJust        = "TopCenter"
; dum_T(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",185.,-77.,txres)
 dum_T(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",182.,-74.5,txres)

 txres@txFontHeightF = RT_size
 txres@txAngleF      = 315.
 txres@txJust        = "CenterCenter"
; dum_RT(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",205.5,-77.,txres)
 dum_RT(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",209.4,-74.4,txres)

 txres@txFontHeightF = R_size
 txres@txAngleF      = 270.
 txres@txJust        = "CenterRight"
; dum_R(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",223.,-80.,txres)
 dum_R(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",233.,-78.6,txres)

 txres@txFontHeightF = RB_size
 txres@txAngleF = 225.
 txres@txJust   = "CenterCenter"
; txres@txPerimOn = True
; dum_RB(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",234.,-83.1,txres)
 dum_RB(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",256.1,-82.0,txres)

 txres@txFontHeightF = B_size
 txres@txAngleF      = 180.
 txres@txJust        = "BottomCenter" 
; dum_B(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",200.,-86.8,txres)
 dum_B(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",210.,-89.2,txres)

 txres@txFontHeightF = LB_size
 txres@txAngleF      = 135.
 txres@txJust        = "CenterCenter"
; dum_LB(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",145.,-85.,txres)
 dum_LB(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",110.5,-84.0,txres)

 txres@txFontHeightF = L_size
 txres@txAngleF      = 90.
 txres@txJust        = "CenterLeft"
; dum_L(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",151.2,-81.7,txres)
 dum_L(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",135.0,-80.4,txres)

 txres@txFontHeightF = LT_size
 txres@txAngleF      = 45.
 txres@txJust        = "CenterCenter"
; dum_LT(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",165.,-77.4,txres)
 dum_LT(n)=gsn_add_text(wks,temp_plot(n),"~F34~-",159.5,-75.6,txres)

;; Get stats to report freq of transition to adjacent nodes, freq of 
;; transitions to non-adjacent nodes, and freq of no transition (or
;; map to self)


 plot1(n) = temp_plot(n)

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
   xpos = 0
   ypos = ypos + 1
  end if
   n = n + 1

  delete(dateindices1)
  delete(u_node_data1)
  delete(v_node_data1)
  delete(ind_trans)
  delete(trans_array)

  end do
 end do

    print("Creating final plot.")

    res_pan                     = True   ; panel resources
    res_pan@txFontHeightF       = 0.015   ; title font height
    res_pan@gsnPaperOrientation = "landscape" ; landscape mode
    res_pan@gsnMaximize         = True   ; make it big
    res_pan@gsnPanelLabelBar    = True   ; common label bar
    res_pan@lbLabelFontHeightF  = 0.007  ; make label bar fonts smaller
    res_pan@lbTitleString      = unit
    res_pan@lbTitlePosition    = "right"
    res_pan@lbLabelAutoStride  = "true"
    res_pan@lbLabelFontHeightF = 0.007
    res_pan@lbTitleJust        = "CenterLeft"
    res_pan@lbTitleFontHeightF = .007 
    res_pan@lbTitleDirection   = "Across"
    

    res_pan@txString = plottitle1+"" 
    gsn_panel(wks,plot1,(/ny_node, nx_node/),res_pan)

    print("Done!  Nice job - the plot looks great.")
    
    if (check1.ne.ndates1) then
      print("Error.  Number of dates is not equal to total number of indices.")
      print("Num. dates: "+ndates1+"   Tot indices: "+check1)
;    exit
    end if


;    delete(visall1)
    if (isvar("dateind1")) then
      delete(dateind1)
    end if
  
end