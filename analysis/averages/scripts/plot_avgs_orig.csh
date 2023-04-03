#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
set types = ('group' 'node')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output (84 tot)
# WRF vars are WS through Q_anom2 (18)
# POP vars are NetFlx through SST_28 (65)
set varcode  = ('WS' 'Tgrad' 'Qgrad' \
                'SLP' 'SLP_anom1' 'SLP_anom2' \
                'TSK' 'TSK_anom1' 'TSK_anom2' \
                'T' 'T_anom1' 'T_anom2' \
                'QS' 'QS_anom1' 'QS_anom2' \
                'Q' 'Q_anom1' 'Q_anom2' \
		'NetFlx' 'NetTrb' 'NetRad' \
		'NetLW' 'NetSW' 'LH' 'SH' \
		'BUOY' 'BUOY_T' 'BUOY_H' \
		'PREC' 'EVAP' 'EMP' 'WSC' \
                'HMXL' 'HMXL_anom1' 'HMXL_anom2' \
                'SST' 'SST_anom1' 'SST_anom2' \
                'SSS' 'SSS_anom1' 'SSS_anom2' \
                'SPD' 'SPD_anom1' 'SPD_anom2' \
		'CAPE_1' 'CAPE_2' 'CAPE_3' 'CAPE_4' \
		'STRAT_1' 'STRAT_2' 'STRAT_3' 'STRAT_4' \
		'HMXL_1' 'HMXL_2' 'HMXL_3' 'HMXL_5' \
		'HMXL_7' 'HMXL_14' 'HMXL_21' 'HMXL_28' \
		'SPD_1' 'SPD_2' 'SPD_3' 'SPD_5' \
		'SPD_7' 'SPD_14' 'SPD_21' 'SPD_28' \
		'SSS_1' 'SSS_2' 'SSS_3' 'SSS_5' \
		'SSS_7' 'SSS_14' 'SSS_21' 'SSS_28' \
		'SST_1' 'SST_2' 'SST_3' 'SST_5' \
		'SST_7' 'SST_14' 'SST_21' 'SST_28')

##############
# start data type loop
##############                                        
set t = 1
while ($t <= 2) # type loop (max: 2)

set type = $types[$t]

# Directory paths and creation
set maindir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/'
set outdir = $maindir$type'/'
mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 31
while ($q <= 31) # var loop (max:84)

##############
# Input into ncl
##############
        echo 'Processing ' $type' average for '$varcode[$q]
   ncl 'type               = "'$type'"'\
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/averages/som_avgs.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ t ++
end
