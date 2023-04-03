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
nx_input = "4"
ny_input = "3"
fout_string = "199011_201003.wrf.sfc"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations")
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
; Break date and vis data into 20 years so we can calculate transitions properly 
;;;;;;;;;;
; NOTE: this is very hard coded for my data. Be careful with how this is done for other applications
; There are 3020 dates total (ndates) but only 151 dates per winter. Because we want to calculate
; transitions +/- 7 days from an event, each winter season, we need to make an array of each winter
; season and treat these separately
ndays = 151          ;# days per winter
nwinters = 20        ;# winters
vis_20seasons = new((/nwinters,ndays,2/),"integer")  ; days x #winters x nx/ny node assignment
;yy_20seasons = new((/nwinters,ndays/),"string")
;mm_20seasons = new((/nwinters,ndays/),"string")

; loop through winters
w = 0
do w = 0, nwinters -1
   st = (w*ndays)
   ed = ((w+1)*ndays)-1
   vis_20seasons(w,:,:) = vis(st:ed,0:1)
   ;yy_20seasons(w,:) = yy(st:ed)
   ;mm_20seasons(w,:) = mm(st:ed)
   delete([/st,ed/])
end do
delete(w)

;;;;;;;;;;
; Make array of +/- 1 week
;;;;;;;;;;
week = 7      ; Time to look before and after
vis_trans = new((/nwinters,ndays,(week*2+1),2/),"integer")

t = 0
d = 0
w = 0
do w = 0, nwinters -1
  do d = week, ndays-week-1       ; loop through all days +/- 1 week at ends 
    do t = -week, week     ; loop through days +/- and write to file
      vis_trans(w,d,t+7,:) = vis_20seasons(w,d+t,:)
    end do
  end do
end do
delete([/d,w,t/])

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

fill = new((/1/),"float")
n = 0
;;;;;;;;;
; calculate Node averages for wrf variables
;;;;;;;;;;
; loop through each node to calculate transitions
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   print("node: "+x+","+y)
   inds = ind(vis(:,0).eq.x.and.(vis(:,1).eq.y))
   year_sub = yy(inds)

return



  ; These are the dates for this particular node:
   dateindices = ind(vis(:,0).eq.x.and.(vis(:,1).eq.y))
   if (.not.all(ismissing(dateindices))) then
     files_sub = files(dateindices)
   else
     print("All files missing for node")
   end if

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
   fout_node = "node_"+x+"x_"+y+"y_"+fout_string
   node_avg = addfile("./"+fout_node+".nc","c")

  ; fields that do not need to be averaged
   geo = addfile(files_sub(0),"r")
   lat = geo->lat
   lon = geo->lon
   Z_sfc = geo->Z_sfc
   dims = dimsizes(Z_sfc)
   dim_sn = dims(0)
   dim_we = dims(1)

  ; write to new average file
   node_avg ->lat = lat
   print("latitude")
   node_avg ->lon = lon
   print("longitude") 
   node_avg ->Z_sfc = Z_sfc
   print("Terrain height")
   delete([/geo,lat,lon,Z_sfc,dims/])

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files

  n = n + 1

 end do
end do
;;;;;;;;;;;;;;;;;;;;;; END script
end
