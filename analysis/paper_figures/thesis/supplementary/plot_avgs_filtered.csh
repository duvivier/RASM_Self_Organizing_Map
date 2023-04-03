#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
set type = 'node' # or 'group'
set mon = 'NDJFM' # or 'DJF'
set per = '1p'

##############
# Choose Variables
##############
set varcode  = ('WSC' 'T_anom' 'Q_anom' 'BUOY_T' 'BUOY_H' \
		'BUOY_SW' 'BUOY_LW' 'BUOY_SH' 'BUOY_LH' \
		'BUOY_PREC' 'BUOY_EVAP')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/averages_ndays/'
if ($type == "node")then
  set nx = '4'
  set ny = '3'
endif

##############
# start variable loop
##############
set q = 1
while ($q <= 11)  # max 11 

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
       /vardar/data5/duvivier/SOM-RASM/analysis/paper_figures/thesis/supplementary/som_node_avgs_filtered.ncl
@ q ++
end

