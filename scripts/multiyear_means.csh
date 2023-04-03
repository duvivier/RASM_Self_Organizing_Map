#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates multiyear
# monthly averages of wrf, cice, or era data.
# It must be copied into the DATA/tag/ directory prior to use.
# CREATOR: Alice DuVivier - Dec. 2014
#################################################
# USER INPUT
set tag = 'cice' # 'cice', 'wrf', and 'era' are the options here

# START OF AUTOMATED SCRIPT
# Set main data directories
set maindir = '/vardar/data5/duvivier/SOM-RASM/DATA/'
set tagdir = $maindir$tag
set tmpdir = $tagdir'/tmp-'$tag'/'
mkdir -p $tmpdir
# Make directories 
set outdir = $tagdir'/multiyear_means_panarctic/' 
mkdir -p $outdir
echo $outdir
# Set output prefix
if ($tag == 'wrf')then
    set prefix = 'r27SOM.wrf'
endif
if ($tag == 'cice')then
    set prefix = 'r27SOM.cice'
endif
if ($tag == 'era')then
    set prefix = 'r27SOM.era'
endif

##############
# Choose Files for individual year monthly avgs
##############
echo 'Starting selection process:'
set months = ('01' '02' '03' '11' '12')

##############
# Make multiyear avgs
##############
cd $outdir
set m = 1 
while ($m <= 5)  # set for months
    set mm = $months[$m]
    echo 'Processing multiyear average for month' $mm
    set fout = $prefix'.1990-2010-'$mm'.nc'
    echo $fout
    if ($tag == 'wrf')then
       ln -sf $tagdir'/monthly_means_panarctic/wrf-'????'-'$mm* $tmpdir
    endif
    if ($tag == 'cice')then
       ln -sf $tagdir'/monthly_means_panarctic/cice-'????'-'$mm* $tmpdir
    endif
    if ($tag == 'era')then
       ln -sf $tagdir'/monthly_means_panarctic/'????$mm* $tmpdir
    endif
    cd $tmpdir
    ncra *.nc $fout
    echo 'Moving ' $fout
    if -e $fout mv $fout $outdir
    rm *.nc
    cd $tagdir
@ m++
end

rmdir $tmpdir
