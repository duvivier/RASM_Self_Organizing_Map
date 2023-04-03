#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
set type = 'group' #'node' or 'group'
set months = ('DJF' '01' '02' '03' '11' '12')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output (2 tot)
set varcode  = ('WS' 'BUOY')

##############
# start data type loop
############## 
set m = 1
while ($m <= 6) # month loop (max: 6)
set mon = $months[$m]                                  
# Directory paths and creation
set maindir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/averages/'
if ($type == "group")then
  set nx = '7'
  set ny = '5'
  set outdir = $maindir$type'/diff-month-'$mon'/'
endif
if ($type == "node")then
  set nx = '4'
  set ny = '3'
  set outdir = $maindir$nx'x_'$ny'y_'$type'/diff-month-'$mon'/'
endif
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 2) # var loop (max:50)

##############
# Input into ncl
##############
        echo 'Processing ' $type' average for '$varcode[$q]
   ncl 'type               = "'$type'"'\
       'mon                = "'$mon'"' \
       'nx                 = "'$nx'"' \
       'ny                 = "'$ny'"' \
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/averages/som_diffs.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end
@ m ++
end
