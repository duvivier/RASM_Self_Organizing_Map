#! /bin/tcsh -f

# csh script to create and evaluate the output which results from varying
# the settings involved with the creation of a SOM map
# (From Matt Higgins, Mark Seefeldt and Joel Finnis)

# Number of nodes:
set nx_node = 6
set ny_node = 4

# Initial input data
set input_data = som_extract/wrf_data_200601_200712_wind.dat

# Name of map initialization
set init_data = {$nx_node}x_{$ny_node}y_wrf_wind.ini

# Directory to store files:
set map_dir = {$nx_node}x_{$ny_node}y
mkdir $map_dir

# set the option to include labels in the output file
set labels = 1

# set the arrays for the variables to be used with vsom

set alpha = ('0.005' '0.01' '0.02' '0.03' '0.04' '0.05')
set am = 6
# first run
set rlen = ('10000' '50000' '100000' '250000' '500000' '1000000' '2500000' '5000000' '10000000')
set lm = 9
set radius = ('1' '2' '3')
set rm = 3

# If qerror.log already exists, remove it
rm qerror.log
set echo on

# Perform the linear initialization
#lininit -xdim $nx_node -ydim $ny_node -din $input_data -cout $init_data  \
#        -neigh bubble -topol hexa

#if you want to skip the initialization, use these lines
#they create a "random" initialization
set entires = `cat $input_data | head -n 1`
echo "${entires} hexa ${nx_node} ${ny_node} bubble" > $init_data
echo "# random seed: 0" >> $init_data
set node_count = `echo "$nx_node $ny_node * p" | dc`
set node_count_plus_one = `echo "$node_count 1 + p" | dc`
cat $input_data | head -n $node_count_plus_one | tail -n $node_count >> $init_data

# Loop through the alpha values
set a = 1
while ($a <= $am)

  # Loop through the rlen values
  set l = 1
  while ($l <= $lm)

    # Loop through the radius values
    set r = 1
    while ($r <= $rm)

      # Set the value for the file_root
      set file_root = ${map_dir}/winds${alpha[$a]}_rlen${rlen[$l]}_r${radius[$r]}

      # Output header information to terminal
      echo $file_root
      echo alpha =  ${alpha[$a]}
      echo rlen = ${rlen[$l]}
      echo radius = ${radius[$r]}

      # Run the training program
      vsom -din $input_data -cin $init_data -cout ${file_root}.cod        \
           -alpha ${alpha[$a]} -rlen ${rlen[$l]} -radius ${radius[$r]}    \

      # Determine the qerror
      qerror -din $input_data -cin ${file_root}.cod > qerror.tmp

      # Take the 9th column of the qerror output (qerror value)
      awk < qerror.tmp '{ print $9}' >> qerror.tmp2

      # Create the sammon map
      sammon -cin ${file_root}.cod -cout ${file_root}.sam -rlen 10000 -ps 1

    # Continue through the loops

    @ r ++
    end

    #add a blank line to qerror every time n is incremented (rlen changes)
    echo " " >> qerror.tmp2
    if ( $labels == 1 ) then
      echo a=$alpha[$a], l=$rlen[$l] >> qerror.log
    endif

    # Paste entries surrounded by blank lines to a single line
    awk '{if(NF)x=x" "$0;else{print substr(x,2);x=""}}' qerror.tmp2 >>qerror.log

    # Rrase temporary file
    rm qerror.tmp2

  @ l ++
  end
  echo " " >> qerror.log

@ a ++
end

#--- Destroy the evidence ---#
rm qerror.tmp
