;***************************************
; PROGRAM DESCRIPTION: This script creates group averages of WRF data
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: NetCDF files of average WRF data
; CREATOR: Alice DuVivier - Sept. 2014
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
ngroup = 8  ; 8 groups total. They're specified below
nx_input = 7
ny_input = 5
fout_string = "199011_201003.wrf.sfc"
mon = "DJF"      ; options "DJF"
per = 3          ; look at events that are 3+ days (df.ge.per) NOT (df.eq.per)
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
infile = dir+nx_input+"x_"+ny_input+"y_group_199011_201003_dates_persistence.txt"
data = asciiread(infile,-1,"string")
ndates = dimsizes(data)
ng = new((/ndates/),"string")    ; ng assignment
ys = new((/ndates/),"string")    ; year start
ms = new((/ndates/),"string")    ; month start
ds = new((/ndates/),"string")    ; day start
ed = new((/ndates/),"string")    ; event duration (#days, 0 = not new event)
df = new((/ndates/),"string")    ; duration flag (how many days is this event part of?)

; load everything as characters for now, will convert to string as necessary
t = 0
do t=0, ndates -1
  dum = stringtochar(data(t))
  ng(t) = chartostring(dum(4))
  ys(t) = chartostring(dum(6:9))
  ms(t) = chartostring(dum(11:12))
  ds(t) = chartostring(dum(14:15))
  ed(t) = chartostring(dum(19))
  df(t) = chartostring(dum(32))
  delete(dum)
end do
delete(data)

; make array with the subsequent day's group (group plus 1 = gp1)
gp1 = new((/dimsizes(ng)-1,2/),"string")
l = 0
do l = 0, dimsizes(ng)-2
  gp1(l,0) = ng(l)
  gp1(l,1) = ng(l+1)
end do

;; Count up number of transitions for each combination
output = new((/ngroup,ngroup/),"integer")
grp_total = new((/ngroup/),"integer")
m=0
n=0
check = 0
do m=0, ngroup-1
  ; get total times this group will have information
  g1 = m+1
  indices = ind(gp1(:,0).eq.g1)
  if(all(ismissing(indices)))then
    grp_total(m) = 0
  else
    grp_total(m) = dimsizes(indices)
  end if
  delete([/g1,indices/])
  do n=0, ngroup-1
    g1 = m+1
    g2 = n+1
    ; get indicies where a group maps to each subsequent group
    indices=ind(gp1(:,0).eq.g1 .and. gp1(:,1).eq.g2)
    ; write to an array
    if(all(ismissing(indices)))then
     output(m,n)=0
    else
     output(m,n)=dimsizes(indices)
    end if
    check = check+dimsizes(indices)
    delete(indices)
 end do
end do

; convert the absolute number of transitions to frequency of time:
percent = new((/ngroup,ngroup/),"float")
m = 0
do m = 0, ngroup -1
  percent(m,:) = (int2flt(output(m,:))/int2flt(grp_total(m)))*100.
end do

;; Write output file
; Figure out correct input and output files based on above information.
outfile    = "./group_transitions_1day.txt"

format = "7f7.2"
options = True
options@fout = outfile
write_matrix(percent,format,options)

end