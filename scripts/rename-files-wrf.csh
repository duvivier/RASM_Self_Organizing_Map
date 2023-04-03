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
    set year = `echo $wrfout_file | cut -c17-20`
    set month = `echo $wrfout_file | cut -c22-23`
    set day = `echo $wrfout_file | cut -c25-26`
    set outfile = 'r27SOM.wrf.ha.'$year'-'$month'-'$day'.green.nc'

    echo $outfile

   cp $wrfout_file $outfile

end

echo "Complete!"





