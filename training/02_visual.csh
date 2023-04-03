#! /bin/tcsh -f

set infile = som_extract/wrf_nudging_1989_2007_slp.dat2
set master_som = master/slp_a0.005_rlen1000000_r3.cod
set outfile = visual/wrf_nuding_1989_2007_slp.vis

visual -din $infile -cin $master_som -dout $outfile
