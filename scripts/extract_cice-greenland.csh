#! /bin/csh -f


set folder = 'ciceout'
cd $folder

 foreach file (`ls *cice*.nc`)

  set main = `echo {$file} | cut -c 1-37`
  set output = {$main}'-green.nc'

  echo "File processing: "$output

ncks -v hi,aice -d nlat,175,530 -d nlon,785,1215 $file $output

end




