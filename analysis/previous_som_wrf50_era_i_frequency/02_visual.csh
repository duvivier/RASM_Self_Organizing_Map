#! /bin/tcsh -f

set infile = ./era_i_199701_200712_wind.dat
set outfile = era_i_199701_200712_wind.vis
#set infile = ./wrf50_199701_200712_wind.dat
#set outfile = wrf50_199701_200712_wind.vis

# for 4x3
set master_som = wind-a0.04_rlen100000_r2.cod
# for 7x5
#set master_som = wind-a0.03_rlen500000_r3-flip.cod

visual -din $infile -cin $master_som -dout $outfile
