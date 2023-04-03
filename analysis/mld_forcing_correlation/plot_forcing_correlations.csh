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
set lag = ('1' '2' '3')
set varcode = ('TAU' 'SH' 'LH' 'BUOY')

##############
# start data type loop
############## 
set t = 1
while ($t <= 3) # type loop (max: 3)
set daylag = $lag[$t]
# Directory paths and creation
set outdir = '/vardar/data5/duvivier/SOM-RASM/analysis/figures/mld_forcing_correlation/'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 4) # var loop (max:4)

##############
# Input into ncl
##############
        echo 'Processing correlation for '$varcode[$q]
   ncl 'daylag             = "'$daylag'"'\
       'nx_input           = "'$nx'"' \
       'ny_input           = "'$ny'"' \
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/mld_forcing_correlation/mld_forcing_correlations.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end
@ t ++
end
