; This NCL script outputs a text file.  The text file
; lists the number of transitions between two given nodes.
; i.e. (0,0) and (1,0) for a particular dataset
;
;
; Melissa A. Nigro
; October 2011
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
  outfile    = nx_input+"x_"+ny_input+"y/node_transitions/"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+".txt"

   datefile1 = "./dates/"+startyearmonth+"_"+endyearmonth+"_dates.txt" 
   visfile1  = nx_input+"x_"+ny_input+"y/visual/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+".vis" 


  nx_node = 6
  ny_node = 4

 
  ; Bring in visual file that places each date at a given node
  print("Loading SOM visual data.")
  vis1 = readAsciiTable(visfile1,3,"integer",1)

  print("Loading dates.")
  dates1         = ndtooned(readAsciiTable(datefile1,1,"string",0))
  dateschar1     = stringtochar(dates1)
  sdateyearmonth = chartostring(dateschar1(:,0:5))
  sdateday       = chartostring(dateschar1(:,6:7))
  sdatehour      = chartostring(dateschar1(:,8:9))

;; Make an array with each transition

node = new((/dimsizes(dates1)-1,4/),"integer")
node@_FillValue=-999999

do l=0, dimsizes(dates1)-2

 if(dates1(l).ne."2010061712") then  ;; 2010061800-2010061809 are missing
  node(l,0)=vis1(l,0)
  node(l,1)=vis1(l,1)
  node(l,2)=vis1(l+1,0)
  node(l,3)=vis1(l+1,1)
 else
  node(l,0)=-999999
  node(l,1)=-999999
  node(l,2)=-999999
  node(l,3)=-999999
 end if

end do

;; Count up number of transitions for each combination

output=new((/nx_node*nx_node*ny_node*ny_node,5/),"integer")

m=0

do x1=0, nx_node-1
 do y1=0, ny_node-1
  do x2=0, nx_node-1
   do y2=0, ny_node-1

    indices=ind(node(:,0).eq.x1.and.node(:,1).eq.y1.and.node(:,2).eq.x2.and.node(:,3).eq.y2)
    if(all(ismissing(indices)))then
     output(m,4)=0
    else
     output(m,4)=dimsizes(indices)
    end if
    output(m,0)=x1
    output(m,1)=y1
    output(m,2)=x2
    output(m,3)=y2

    print(m)
    m=m+1
    delete(indices)

   end do
  end do
 end do
end do   

;; Write output file
format = 5+"I5"
options = True
options@fout = outfile


write_matrix(output,format,options)


end