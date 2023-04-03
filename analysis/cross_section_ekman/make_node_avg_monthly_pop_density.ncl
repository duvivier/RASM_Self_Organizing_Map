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
fout_string = "199011_201003.pop.density"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations by month")
months = (/"11","12","01","02","03","xx","DJF"/)
times = dimsizes(months)

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

; create filenames array
files = new((/ndates/),string)
files = "/vardar/data5/duvivier/SOM-RASM/analysis/surface_files/pop_orig_files/r27SOM.pop.h."+yy+"-"+mm+"-"+dd+".green.nc"

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
; calculate Node averages for pop variables by month
;;;;;;;;;;
; loop through each month
mon = "xx"
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   print("node: "+x+","+y+" and month "+mon)
  ; These are the dates for this particular node:
   dateindices = ind((vis(:,0).eq.x.and.vis(:,1).eq.y))
   if (.not.all(ismissing(dateindices))) then
     files_sub = files(dateindices)

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
   fout_node = "node_"+x+"x_"+y+"y_month-"+mon+"_"+fout_string
   node_avg = addfile("./"+fout_node+".nc","c")

  ; fields that do not need to be averaged
   geo = addfile(files_sub(0),"r")
   TLAT = geo->TLAT
   TLONG = geo->TLONG
   TAREA = geo->TAREA
   PD = geo->PD
   dims = dimsizes(PD)
   dim_z  = dims(1)
   dim_sn = dims(2)
   dim_we = dims(3)

  ; write to new average file
   node_avg ->TLAT = TLAT
   print("latitude")
   node_avg ->TLONG = TLONG
   print("longitude") 
   node_avg ->TAREA = TAREA
   print("Terrain height")
   delete([/geo,TLAT,TLONG,TAREA,PD,dims/])

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data
  ; Go through each type of surface variable and calculate average and variance

  ;; Sea Ice
   ice_frac = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     ice_frac(f,:,:) = pop->aice
     delete(pop)
   end do
   ; get averages and variances
   ice_frac_avg = dim_avg_n_Wrap(ice_frac,0)
   ice_frac_var = dim_variance_n_Wrap(ice_frac,0)
   ice_frac_avg!0 = "nlat"
   ice_frac_avg!1 = "nlon"
   copy_VarCoords(ice_frac_avg, ice_frac_var)
   ; write to node average file
   node_avg ->ice_frac_avg = ice_frac_avg
   node_avg ->ice_frac_var = ice_frac_var
   print("Sea ice")
   delete([/ice_frac,ice_frac_avg,ice_frac_var/])

  ;; 3D density profile
   PD = new((/dim_files,dim_z,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     pop = addfile(files_sub(f),"r")
     PD(f,:,:,:) = pop->PD
     delete(pop)
   end do
   ; get averages and variances
   PD_avg = dim_avg_n_Wrap(PD,0)
   PD_var = dim_variance_n_Wrap(PD,0)
   ; write to node average file
   node_avg ->PD_avg = PD_avg
   node_avg ->PD_var = PD_var
   print("PD")
   delete([/PD,PD_avg,PD_var/])

  n = n + 1
  ;; delete variables to use again
  delete([/fout_node,node_avg,dim_files,node_files,dateindices,files_sub/])
else
  print("All files missing for node")
end if

end do
end do
;;;;;;;;;;;;;;;;;;;;;; END script
end
