#! /bin/csh -f

#######
#  WRF geo_em processing
########

foreach file_wrf (`ls geo*.nc`)
    set main_wrf = `echo {$file_wrf} | cut -c 1-11`
    set output_wrf = {$main_wrf}'.green.nc'

    echo "File processing: "$output_wrf
    ncks -d south_north,60,125 -d south_north_stag,60,126 -d west_east,170,237 -d west_east_stag,170,237 $file_wrf $output_wrf
end


