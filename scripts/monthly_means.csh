#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates monthly averages of wrf or pop
# data used for the SOM training
# CREATOR: Alice DuVivier - Dec. 2014
#################################################
# USER INPUT
set tag = 'wrf' # 'pop' and 'wrf' are the options here

# START OF AUTOMATED SCRIPT
# Set main data directories
set maindir = '/vardar/data5/duvivier/SOM-RASM/DATA/'
set tagdir = $maindir$tag
echo $tagdir
# Make directories 
set outdir = $tagdir'/monthly_avgs/' 
mkdir -p $outdir
# Set output prefix
if ($tag == 'wrf')then
    set prefix = 'r27SOM.wrf'
endif
if ($tag == 'pop')then
    set prefix = 'r27SOM.pop'
endif

##############
# Choose Files for individual year monthly avgs
##############
echo 'Starting selection process:'
set years = ('1990' '1991' '1992' '1993' '1994' '1995' '1996' '1997' '1998' '1999' '2000' '2001' '2002' '2003' '2004' '2005' '2006' '2007' '2008' '2009' '2010')
set months = ('01' '02' '03' '11' '12')

##############
# start loops
set y = 1
while($y <= 21)  # set for the number of years
    set yy = $years[$y]
set m = 1 
while ($m <= 5)  # set for months
    set mm = $months[$m]
    cd $tagdir
    set ym = $yy$mm
    echo 'Processing month average '$ym
    if -d $ym cd $ym
    set fout = $prefix'.'$yy'-'$mm'.green.nc'
    ncra $prefix*$yy'-'$mm* $fout
    if -e $fout mv $fout $outdir
@ m++
end
@ y++
end

##############
# Make multiyear avgs
##############
cd $outdir
set m = 1 
while ($m <= 5)  # set for months
    set mm = $months[$m]
    echo 'Processing multiyear average for month' $mm
    set fout = $prefix'.1990-2010-'$mm'.green.nc'
    ncra $prefix*$mm* $fout
@ m++
end
