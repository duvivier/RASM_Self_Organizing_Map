#! /bin/csh -f

echo 'Time: ' `/bin/date -u +'%m/%d/%Y %T'`

#################################################
# Post processes WRF output and includes only
# eta level variables
#################################################
set dir_in = '/vardar/data5/duvivier/SOM-RASM/analysis/regrid_WRF_to_POP/wrf_orig_files/'
set dir_out = '/vardar/data5/duvivier/SOM-RASM/analysis/regrid_WRF_to_POP/wrf_interp_files/'

foreach wrf_file (`ls -1 $dir_in`)

    echo "Let's go for: "$wrf_file
    set yy = `echo $wrf_file | cut -c5-8`
    set mm = `echo $wrf_file | cut -c10-11`
    set dd = `echo $wrf_file | cut -c13-14`

    ncl 'yy="'{$yy}'"' \
        'mm="'{$mm}'"' \
        'dd="'{$dd}'"' \
        'dir_in="'{$dir_in}'"' \
        'dir_out="'{$dir_out}'"'  \
        /vardar/data5/duvivier/SOM-RASM/analysis/regrid_WRF_to_POP/regrid_WRF_to_POP-all.ncl

end

