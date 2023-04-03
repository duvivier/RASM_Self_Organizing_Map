#! /bin/csh -f

# Set folder where files are linked
set folder = 'links_atm'
cd $folder

#######
#  WRF processing
########

foreach file_wrf (`ls *wrf*.nc`)
    set main_wrf = `echo {$file_wrf} | cut -c 1-26`
    set output_wrf = {$main_wrf}'.green.nc'

    echo "File processing: "$output_wrf
    ncks -d south_north,60,125 -d south_north_stag,60,126 -d west_east,170,237 -d west_east_stag,170,237 $file_wrf $output_wrf
end

# Move processed files to common directory
set dir_out = './wrfout_greenland'
mkdir $dir_out
mv *wrf*green.nc $dir_out

# Move directory with post processed data
mv $dir_out ../

