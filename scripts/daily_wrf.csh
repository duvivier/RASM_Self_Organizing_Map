#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates monthly averages of wrf or pop
# data used for the SOM training
# CREATOR: Alice DuVivier - Dec. 2014
#################################################
# USER INPUT
set tag = 'wrf' # 'pop' and 'wrf' are the options here
echo $tag
# START OF AUTOMATED SCRIPT
# Set main data directories
set maindir = '/vardar/data5/duvivier/SOM-RASM/DATA/'
set tagdir = $maindir$tag
set tmpdir = $maindir'/tmp-'$tag'/'
mkdir -p $tmpdir
set outdir = $tagdir'/daily_means_greenland/' 
mkdir -p $outdir
# Set output prefix
if ($tag == 'wrf')then
    set prefix = 'r27SOM.wrf'
endif
if ($tag == 'pop')then
    set prefix = 'r27SOM.pop'
endif

##############
# arrays of months and daiys
set months = ('01' '02' '03' '11' '12')
set days = ('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24' '25' '26' '27' '28' '29' '30' '31')

##############
# Make multiyear daily avgs
##############
cd $outdir
set m = 1 
while ($m <= 5)  # set for months (max = 5)
set d = 1
while ($d <= 31 ) # set for days (max = 31)
    set dd = $days[$d]
    set mm = $months[$m]
    echo 'Processing multiyear average for' $mm'-'$dd
    set fout = $prefix'.1990-2010-'$mm'-'$dd'.green.nc'
    ln -sf $tagdir'/'????$mm'/'$prefix*'-'$mm'-'$dd* $tmpdir
    cd $tmpdir
    ncra *.nc $fout
    echo 'Moving ' $fout
    if -e $fout mv $fout $outdir
    rm *.nc
    cd $maindir
@ d++
end
@ m++
end

rm -rf $tmpdir
