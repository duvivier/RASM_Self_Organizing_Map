#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates seaasonal averages of RACM files
# INPUT DATA: 
# OUTPUT DATA: 
# CREATOR: Alice DuVivier - April 2012
#################################################
echo 'Starting selection process:'

##############
# Choose Files
##############
set years = ('1990' '1991' '1992' '1993' '1994' '1995' '1996' '1997' '1998' '1999' '2000' '2001' '2002' '2003' '2004' '2005' '2006' '2007' '2008' '2009' '2010')
set months = ('01' '02' '03' '04' '11' '12')

##############
# start loops
set y = 1
while($y <= 21)  # set for the number of years you need to process
    set yy = $years[$y]

set m = 4
while ($m <= 4)  # set for months you want to process
    set mm = $months[$m]

set yearmonth = $yy$mm
echo 'Moving files for' $yearmonth

#WRF
   mv ./r27SOM.wrf.ha.$yy-$mm* ./$yearmonth
#POP
#   mv ./r27SOM.pop.h.$yy-$mm* ./$yearmonth

@ m++
end
@ y++
end
