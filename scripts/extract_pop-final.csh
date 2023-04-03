#! /bin/csh -f


set folder = 'pop-final'
cd $folder

 foreach file (`ls *pop*.nc`)

  set main = `echo {$file} | cut -c 1-34`
  set output = {$main}'.nc'

  echo "File processing: "$output

ncks -v dz,ANGLE,ANGLET,HT,TAREA,TLAT,TLONG,UAREA,ULAT,ULONG,SSH,TAUX,TAUY,MLD,WSC,NCNV,PD,PEC,PV,SALT,TEMP,UVEL,VVEL,Q -d z_t,0,10 $file $output

end




