#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates seaasonal averages of RACM files
# INPUT DATA: 
# OUTPUT DATA: 
# CREATOR: Alice DuVivier - April 2012
#################################################
echo 'Loading files to cat'

foreach som_file(`ls -1 WRF50_*`)   
    echo "YearMonth:"$som_file
    cat $som_file >> wrf50_199011_201003_dates.txt
end

echo "catted all files for SOM"
