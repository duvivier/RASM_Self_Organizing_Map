#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
# split up the visual file into all three data sets
set master_vals = winds0.01_rlen1000000_r4
set nx_input = 7
set ny_input = 5
set datatitle_1 = wrf10_200511_200703 
set datatitle_2 = wrf50_199701_200712
set datatitle_3 = era_i_199701_200712

##############
# Break visual file into separate files for each data type 
##############
# This is all fairly hard coded...
# visual output file name
set input_data = wrf10_wrf50_erai_$master_vals.vis
# set info for separate resolutions
# Note: we want to keep the header for each of these
# 10 km
set vis_10 = {$datatitle_1}_$master_vals.vis
set dates_10 = 2416          # has 2416 total lines
set dates_10_end = `echo "$dates_10 1 + p" | dc`
echo 'Creating file:'$vis_10
cat $input_data | head -n $dates_10_end >> $vis_10
# 50 km
set vis_50 = {$datatitle_2}_$master_vals.vis
set dates_50 = 13303         # has 13303 total lines
set dates_50_end = `echo "$dates_10_end $dates_50 + p" | dc`
echo 'Creating file:'$vis_50
cat $input_data | head -n 1 >> $vis_50
cat $input_data | head -n $dates_50_end | tail -n $dates_50 >> $vis_50
# era-i
set vis_era = {$datatitle_3}_$master_vals.vis
set dates_era = 6652         # has 6652 total lines
set dates_era_end = `echo "$dates_50_end $dates_50 + p" | dc`
echo 'Creating file:'$vis_era
cat $input_data | head -n 1 >> $vis_era
cat $input_data | head -n $dates_era_end | tail -n $dates_era >> $vis_era

##############
# Call NCL script to make node avg. netcdf files
##############
# We have 8 combinations of dates/hours that we need averages for
set pvals = ('0' '1' '2' '3' '4' '5' '6' '7')
#  p = 0  ; wrf10 2005-2007 3hrly
#  p = 1  ; wrf10 2005-2007 6hrly
#  p = 2  ; wrf50 2005-2007 3hrly
#  p = 3  ; wrf50 2005-2007 6hrly
#  p = 4  ; wrf50 1997-2007 3hrly
#  p = 5  ; wrf50 1997-2007 6hrly
#  p = 6  ; erai 2005-2007 6hrly
#  p = 7  ; erai 1997-2007 6hrly

# Set directory for output
 set outdir = '/data3/duvivier/SOM/training/som_'$nx_input$ny_input'/master/node_avgs/'
 mkdir -p $outdir

 # start loops through types of data combinations
set pp = 1
while ($pp <= 6)  # max val = 8

   echo 'Processing node averages for '$nx_input' and '$ny_input' and date combo:'$pvals[$pp]
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'master_vals        = "'$master_vals'"' \
       'p                  = "'$pvals[$pp]'"'\
      /data3/duvivier/SOM/training/make_node_avgs.ncl
      mv *.nc $outdir

@ pp ++
end


