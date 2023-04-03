#! /bin/csh -f

# Set folder where files are linked
set folder = 'links_ocn'
cd $folder

#######
#  POP processing
########

foreach file_pop (`ls *pop*.nc`)
    set main_pop = `echo {$file_pop} | cut -c 1-25`
    set output_pop = {$main_pop}'.green.nc'

    echo "File processing: "$output_pop
#    ncks -d nlat,175,530 -d nlon,785,1215 -d z_t,0,10 $file_pop $output_pop
    ncks -d nlat,175,460 -d nlon,950,1200 -d z_t,0,30 $file_pop $output_pop
end

########
#  CICE processing
########

foreach file_cice (`ls *cice*.nc`)
    set main = `echo {$file_cice} | cut -c 1-8`
    set year = `echo {$file_cice} | cut -c 17-20`
    set month = `echo {$file_cice} | cut -c 22-23`
    set day = `echo {$file_cice} | cut -c 25-26`
    set output_cice = {$main}'.cice.h.'{$year}'-'{$month}'-'{$day}'.green.nc'
    set output_pop = {$main}'.pop.h.'{$year}'-'{$month}'-'{$day}'.green.nc'

    echo "File processing: "$output_cice
    ncks -v hi,aice -d nj,175,460 -d ni,950,1200 $file_cice $output_cice
    echo "Appending cice to: "$output_pop
    ncks --append ./$output_cice ./$output_pop
end

# Move processed files to common directory
set dir_out = './popout_greenland'
mkdir $dir_out
mv *pop*green.nc $dir_out

# Delete the files we don't need anymore
rm *cice*green.nc

# Move directory with post processed data
mv $dir_out ../

