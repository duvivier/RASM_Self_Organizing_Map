#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
set type = 'node' # or 'group'
set months = ('xx' 'DJF' '01' '02' '03' '11' '12')  # list of month subsets (xx = all)
set persist = ('1' '2' '3' '4')  # list of days minimum persistence

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output (50 tot)
# WRF vars are WS through Q_anom2 (13)
# POP vars are WSC through HMXL_28 (37)
set varcode  = ('WS' 'SLP' 'SLP_anom' \
                'Tgrad' 'TSK' 'TSK_anom' 'T' 'T_anom' \
                'Qgrad' 'QS' 'QS_anom' 'Q' 'Q_anom' \
		'WSC' 'NetFlx' 'NetTrb' 'NetRad' \
		'NetLW' 'NetSW' 'LH' 'SH' \
		'BUOY' 'BUOY_T' 'BUOY_H' \
		'BUOY_SW' 'BUOY_LW' 'BUOY_SH' 'BUOY_LH' \
		'BUOY_PREC' 'BUOY_EVAP' 'PREC' 'EVAP' 'EMP' \
                'HMXL' 'HMXL_anom' 'HMXL_pcnt' \
                'SST' 'SST_anom' 'SSS' 'SSS_anom' 'SPD' 'SPD_anom'\
		'HMXL_1' 'HMXL_2' 'HMXL_3' 'HMXL_5' \
		'HMXL_7' 'HMXL_14' 'HMXL_21' 'HMXL_28')

##############
# start data type loop
############## 
set p = 1
while ($p <= 4) # persistence loop (max:5)
set per = $persist[$p]
set m = 1
while ($m <= 7) # month loop (max: 7)
set mon = $months[$m]                                  

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/averages/'
if ($type == "group")then
  set nx = '7'
  set ny = '5'
  set outdir = $maindir$type'/month-'$mon'/'
endif
if ($type == "node")then
  set nx = '4'
  set ny = '3'
  set outdir = $maindir$nx'x_'$ny'y_'$type'/month-'$mon'/'
endif
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 50) # var loop (max:50)

##############
# Input into ncl
##############
        echo 'Processing ' $type' average for '$varcode[$q]
   ncl 'type               = "'$type'"'\
       'mon                = "'$mon'"' \
       'per                = "'$per'"' \
       'nx                 = "'$nx'"' \
       'ny                 = "'$ny'"' \
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/averages/som_avgs_filtered.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end
@ m ++
end
@ p ++ 
end
