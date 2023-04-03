#! /bin/csh -f


set folder = 'cplout'
cd $folder

 foreach file (`ls *cpl*.nc`)

  set main = `echo {$file} | cut -c 1-38`
  set output = {$main}'-green.nc'

  echo "File processing: "$output

ncks -v x2aavg_Faxx_lat,x2aavg_Faxx_sen,x2aavg_Faxx_taux,x2aavg_Faxx_tauy,a2xavg_Faxa_rainc,a2xavg_Faxa_rainl,a2xavg_Faxa_snowl,x2aavg_Sx_ifrac,doma_lat,doma_lon -d x2aavg_nx,170,237 -d x2aavg_ny,60,125 -d a2xavg_nx,170,237 -d a2xavg_ny,60,125 -d doma_nx,170,237 -d doma_ny,60,125 $file $output

end




