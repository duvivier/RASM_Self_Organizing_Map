#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
set nx = '4'
set ny = '3'
set types = ('node' 'group')
set months = ('xx' '01' '02' '03' '11' '12')
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
set m = 2
while ($m <= 6) # month loop (max: 6)
set mon = $months[$m]                                  
set t = 1
while ($t <= 1) # type loop (max: 2)
set type = $types[$t]
# Directory paths and creation
set maindir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/averages/'
if ($type == "group")then
  set outdir = $maindir$type'/month-'$mon'/'
endif
if ($type == "node")then
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
       'nx                 = "'$nx'"' \
       'ny                 = "'$ny'"' \
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/averages/som_avgs.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end
@ t ++
end
@ m ++
end
