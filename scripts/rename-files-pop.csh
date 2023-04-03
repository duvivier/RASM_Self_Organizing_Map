#!/bin/tcsh -f

#
# Script to rename a bunch of files in a directory
#
###########################################################################


echo 'Loading files'

set dir_in = './'
set dir_out = './'

foreach wrfout_file(`ls -1 r27*.nc`)
    
    #echo "Day:"$wrfout_file
    set year = `echo $wrfout_file | cut -c16-19`
    set month = `echo $wrfout_file | cut -c21-22`
    set day = `echo $wrfout_file | cut -c24-25`
    set outfile = 'r27SOM.pop.h.'$year'-'$month'-'$day'.green.nc'

    echo $outfile

   cp $wrfout_file $outfile

end

echo "Complete!"





