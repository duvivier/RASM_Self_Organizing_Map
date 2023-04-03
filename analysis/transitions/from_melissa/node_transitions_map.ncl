; This NCL script outputs a text file.  The text file
; lists the number of transitions to neighboring nodes for a given node.
;
;
; Melissa A. Nigro
; March 2012
;
;
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; ******************************************************
  startyearmonth = 200810
  endyearmonth = 201009
  f1_type     = "wrf"
  f1_descrip  = "data"
  nx_input = "6"
  ny_input = "4"
  a_input = "0.005"
  l_input = "1000000"
  r_input = "2"
; ******************************************************

; Figure out correct input and output files based on above information.
  infile    = nx_input+"x_"+ny_input+"y/node_transitions/"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+".txt"

  outfile   = nx_input+"x_"+ny_input+"y/node_transitions/"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+"_map.txt"
  
  nx_node = 6
  ny_node = 4

 
; Read in node transitions
  node_tr = readAsciiTable(infile,5,"integer",0)

; Make output array

  node_tr_map = new((/nx_node*ny_node,10/),"integer")
  ; x y T RT R RB B LB L LT

m=0

do x1=0, nx_node-1
 do y1=0, ny_node-1

 node_tr_map(m,0)=x1
 node_tr_map(m,1)=y1
 
if (y1.eq.0) then
 ind_T = -999
else
 ind_T = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1.and.node_tr(:,3).eq.y1-1)
end if

if (y1.eq.0.or.x1.eq.5) then
 ind_RT = -999
else
 ind_RT = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1+1.and.node_tr(:,3).eq.y1-1)
end if

if (x1.eq.5) then
 ind_R = -999
else
 ind_R = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1+1.and.node_tr(:,3).eq.y1)
end if

if (y1.eq.3.or.x1.eq.5) then
 ind_RB = -999
else
 ind_RB = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1+1.and.node_tr(:,3).eq.y1+1)
end if

if (y1.eq.3) then
 ind_B = -999
else
 ind_B  = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1.and.node_tr(:,3).eq.y1+1)
end if

if (y1.eq.3.or.x1.eq.0) then
 ind_LB = -999
else
 ind_LB = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1-1.and.node_tr(:,3).eq.y1+1)
end if

if (x1.eq.0) then
 ind_L = -999
else
 ind_L = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1-1.and.node_tr(:,3).eq.y1)
end if

if (y1.eq.0.or.x1.eq.0) then
 ind_LT = -999
else
 ind_LT = ind(node_tr(:,0).eq.x1.and.node_tr(:,1).eq.y1.and.node_tr(:,2).eq.x1-1.and.node_tr(:,3).eq.y1-1)
end if

 ind_T@_FillValue  = -999
 ind_RT@_FillValue = -999
 ind_R@_FillValue  = -999
 ind_RB@_FillValue = -999
 ind_B@_FillValue  = -999
 ind_LB@_FillValue = -999
 ind_L@_FillValue  = -999
 ind_LT@_FillValue = -999

if (ismissing(ind_T)) then
 node_tr_map(m,2)= 0
else
 node_tr_map(m,2)=node_tr(ind_T,4)
end if
if (ismissing(ind_RT)) then
 node_tr_map(m,3) = 0
else
 node_tr_map(m,3)=node_tr(ind_RT,4)
end if
if (ismissing(ind_R)) then
 node_tr_map(m,4) = 0
else
 node_tr_map(m,4)=node_tr(ind_R,4)
end if
if (ismissing(ind_RB)) then
 node_tr_map(m,5) = 0
else
 node_tr_map(m,5)=node_tr(ind_RB,4)
end if
if (ismissing(ind_B)) then
 node_tr_map(m,6) = 0
else
 node_tr_map(m,6)=node_tr(ind_B,4)
end if
if (ismissing(ind_LB)) then
 node_tr_map(m,7) = 0
else
 node_tr_map(m,7)=node_tr(ind_LB,4)
end if
if (ismissing(ind_L)) then
 node_tr_map(m,8) = 0
else
 node_tr_map(m,8)=node_tr(ind_L,4)
end if
if (ismissing(ind_LT)) then
 node_tr_map(m,9) = 0
else
 node_tr_map(m,9)=node_tr(ind_LT,4)
end if


m=m+1

 end do
end do   


;; Write output file
format = 10+"I5"
options = True
options@fout = outfile


write_matrix(node_tr_map,format,options)



end