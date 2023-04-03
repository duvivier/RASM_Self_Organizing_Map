;***************************************
; PROGRAM DESCRIPTION: This script creates node averages of WRF data
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
nx_input = "7"
ny_input = "5"
fout_string = "199011_201003.wrf.sfc"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations")
outfile = nx_input+"x_"+ny_input+"y_199011_201003_dates_persistence.txt"

;;;;;;;;;;
; Load info for files
;;;;;;;;;;
print("Loading dates and SOM visual data")
dir = "/vardar/data5/duvivier/SOM-RASM/analysis/"+nx_input+"x_"+ny_input+"y_files/"
datefile = dir+"wrf50_199011_201003_dates.txt"
visfile  = dir+"wrf50_199011_201003_wind.vis"
dates = ndtooned(readAsciiTable(datefile,1,"string",0)) ; ignores no rows
ndates = dimsizes(dates)
dateschar = stringtochar(dates)
yy = chartostring(dateschar(:,0:3))
mm = chartostring(dateschar(:,5:6))
dd = chartostring(dateschar(:,8:9))

vis = new((/ndates,3/),integer)
vis = readAsciiTable(visfile,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Loop through each date
;;;;;;;;;;
; loop through each date and then check if nx = ny for day before

; make array to output as text file: all dates by 8 columns:
;nx,ny,group(if applicable),yyyy,mm,dd, new node event (0=no,1=yes), 
;if new event # days node persists, new group event, if new group event # days group persists
output = new((/ndates,10/),"string")


;;;;;;;;;;
; Calculate node event count and duration
;;;;;;;;;;
t = 0
do t = 0, ndates-1
  ; nx position
  output(t,0) = tostring(vis(t,0)) 
  ; ny position
  output(t,1) = tostring(vis(t,1))  
  ; year-month-day assignment
  output(t,2) = yy(t)+"-"+mm(t)+"-"+dd(t)

  ; Calculate if this is a new node event
  if(mm(t).eq. "11" .and. dd(t) .eq. "01")then
    ; start of a new winter season, so this is a new event
    output(t,3) = "1"
  else
    prev_nx = vis((t-1),0)
    prev_ny = vis((t-1),1)
    curr_nx = vis(t,0)
    curr_ny = vis(t,1)
    if( (prev_nx.eq.curr_nx) .and. (prev_ny.eq.curr_ny))then
      output(t,3) = "0"
    else
      output(t,3) = "1"
    end if
  end if
end do

; now loop through the "new event" designation to find duration of each "event"
t = 0
do t = 0, ndates-3
  ; write the "end date" of an event as "0000-00-00" to start
  ; write over later in loop for applicable events
  output(t,5) = "0000-00-00"
  if (output(t,3).eq."0")then
    ; if it's not a new event, then it has zero duration
    ; it will be counted as part of another event
    output(t,4) = "0"
  else
    if (output((t+1),3) .eq. "1")then
      output(t,4) = "1"   ; the next day is also a new event
      output(t,5) = yy(t)+"-"+mm(t)+"-"+dd(t) ; write day event ends     
    else
      ; loop through subsequent days until we reach new event marker
      c = 1   ; we already have one day, add subsequent days
      i = t+1   ; start with index of day we're examining
      do while (output(i,3) .ne. "1") ; new event marker, count # days
        i = i+1
        c = c+1
      end do
      output(t,4) = tostring(c)  ; write days persistence
      output(t,5) = yy(i-1)+"-"+mm(i-1)+"-"+dd(i-1) ; write day event ends
      delete([/i,c/])
    end if
  end if
end do

; now loop through the events and write length flag so these can be included in averaging
t = 0
do t = 0, ndates-3
  dum = stringtoint(output(t,4))
  if (dum .ne. 0) then
    output(t,6) = output(t,4)
  else
    i = t-1   ; reference previous time
    output(t,6) = output(i,6)  ; write that value
    delete([/i/])   
  end if
  delete([/dum/])
end do

;;;;;;;;;;
; Write output to file
;;;;;;;;;;

a = output(:,0)
b = output(:,1)
c = output(:,2)
d = output(:,3)
e = output(:,4)
f = output(:,5)
g = output(:,6)
alist = [/a,b,c,d,e,f,g/]

write_table(outfile,"w",alist,"%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s")

;;;;;;;;;;;;;;;;;;;;;; END script
end
