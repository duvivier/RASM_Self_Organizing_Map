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
set varcode = ('TAU' 'WSC' 'SH' 'LH' 'BUOY' 'Tgrad' 'Qgrad' 'TSK' 'T' 'T_anom' 'QS' 'Q' 'Q_anom')

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
set q = 2
while ($q <= 2) # var loop (max:13)

##############
# Input into ncl
##############
        echo 'Processing correlation for '$varcode[$q]
   ncl 'daylag             = "'$daylag'"'\
       'nx_input           = "'$nx'"' \
       'ny_input           = "'$ny'"' \
       'varcode            = "'$varcode[$q]'"' \
       /vardar/data5/duvivier/SOM-RASM/analysis/mld_forcing_correlation/mld_correlations.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end
@ t ++
end
