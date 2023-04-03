#! /bin/tcsh -f

set infile = ../som_extract/wrf50_199011_201003_wind.dat
set master_som = master_som/wind-a0.04_rlen500000_r4-flip.cod
set outfile = master_som/wrf50_199011_201003_wind.vis

visual -din $infile -cin $master_som -dout $outfile
