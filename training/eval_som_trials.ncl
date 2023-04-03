;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; eval_som_trials.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script that evaluates a collection of SOMs created with varied
;  settings.  The script ranks the SOMs based on lowest qerror, creates
;  a sammon map annotated with the qerror, twisted index, and rank.  The
;  sammon map is also named by rank for easy evaluation of the results.
;  Finally, a text file is also created with a ranked list.
;
; -This program requires NCL 6.1
;
;  COMMAND SYNTAX:
;  -ncl eval_som_trials.ncl
;  -The value for the SOM path can be set with the variable path_som.
;
;  NOTES:
;  -This program is to be used in conjunction with the csh script:
;     create_som_trials.csh
;
;  INPUT:  qerror.log, twist.log, filename.log, individual *.sam files
;
;
;  CREATOR:  Mark Seefeldt - 2014-06
; 
;  RELEASE NOTES:
;    1.0 - 2014-06-05
;      -initial release
;
;  TODO:
;    
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start the main program
begin
  ; set the processing location for file/path defaults
  if (.not.isvar("path_som")) then
    path_som = "/data1/seefeldm/amundsen_sea/som/slp_anom-std/7x5/qerror/"
  end if
  ; set additional flag/settings
  rank_by_twist   = False
  plot_sammon     = True
  ; Note: The settings for the creation of the sammon map are included
  ;       below in that section.  They are kept separate in order to keep
  ;       that section of the script the same as plot_som_sammon.ncl.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; read in the file contents for filename.log, qerror.log, and twist.log
  f_in = asciiread(path_som+"filename.log",  \
                   numAsciiRow(path_som+"filename.log"),"string")
  q_in = asciiread(path_som+"qerror.log",  \
                   numAsciiRow(path_som+"qerror.log"),"string")
  t_in = asciiread(path_som+"twist.log",  \
                   numAsciiRow(path_som+"twist.log"),"string")
  ; -determine the array sizes from f_in
  n_alpha = stringtoint(str_get_field(f_in(0),2," "))
  n_rlen = stringtoint(str_get_field(f_in(0),3," "))
  n_rad = stringtoint(str_get_field(f_in(0),4," "))
  ; -create the arrays for the settings
  alpha_in = str_split(f_in(1)," ")
  rlen_in = str_split(f_in(2)," ")
  rad_in = str_split(f_in(3)," ")
  alpha = stringtofloat(alpha_in(1:))
  rlen = stringtoint(rlen_in(1:))
  rad = stringtoint(rad_in(1:))
  ; -determine the dimensions of the SOM
  node_in = str_split(f_in(4)," ")
  nx = stringtoint(node_in(1))
  ny = stringtoint(node_in(2))
  ; -read the variable
  var_in = str_split(f_in(5)," ")
  var = var_in(1)
  ; -verify the dimensions match
  if (dimsizes(alpha) .ne. n_alpha) then
    print("There is a mismatch in the number of alpha values.")
    exit
  end if
  if (dimsizes(rlen) .ne. n_rlen) then
    print("There is a mismatch in the number of rlen values.")
    exit
  end if
  if (dimsizes(rad) .ne. n_rad) then
    print("There is a mismatch in the number of rad values.")
    exit
  end if
  ; create the three-dimensional arrays for the filename, qerror, and twist
  fname3D = new((/n_alpha,n_rlen,n_rad/),string)
  qerror3D = new((/n_alpha,n_rlen,n_rad/),float)
  twist3D = new((/n_alpha,n_rlen,n_rad/),float)
  ; set the initial line to be read
  f_ln = 7
  q_ln = 0
  t_ln = 0
  ; loop through the alpha settings
  do a = 0, n_alpha-1
    ; loop through the rlen settings
    do l = 0, n_rlen-1
      ; read the next line
      f_line = str_split(f_in(f_ln)," ")
      q_line = str_split(q_in(q_ln)," ")
      t_line = str_split(t_in(t_ln)," ")
      ; set the values to the arrays
      fname3D(a,l,0:) = f_line(0:)
      qerror3D(a,l,0:) = stringtofloat(q_line(0:))
      twist3D(a,l,0:) = stringtofloat(t_line(0:))
      ; increase the line counters
      f_ln = f_ln + 1
      q_ln = q_ln + 1
      t_ln = t_ln + 1
      ; delete the line variables
      delete([/f_line,q_line,t_line/])
    end do
    ; skip a line between alpha sections
    f_ln = f_ln + 1
    q_ln = q_ln + 1
    t_ln = t_ln + 1
  end do
  ; convert 3D variables to 1D
  fname1D = ndtooned(fname3D)
  qerror1D = ndtooned(qerror3D)
  twist1D = ndtooned(twist3D)
  ; sort the values based on qerror
  if (rank_by_twist) then
    isort = dim_pqsort(twist1D,1)
  else
    isort = dim_pqsort(qerror1D,1)
  end if
  fname = fname1D(isort)
  qerror = qerror1D(isort)
  twist = twist1D(isort)
  ; create a ranking for each line (including ties)
  n_trials = dimsizes(fname)
  rank = new(n_trials,integer)
  ; -set the initial value to 1
  rank(0) = 1
  ; -loop through the trials
  do n = 1, n_trials-1
    if qerror(n) .eq. qerror(n-1) then
      rank(n) = rank(n-1)
    else
      rank(n) = n+1
    end if
  end do
  ; write the ranked results to a text file
  out_list = [/rank,qerror,twist,fname/]
  write_table(path_som+"rank.log","w",out_list,"%3i %9.4f %6.4f %s")
  if (plot_sammon) then
    ; create a sammon map annotated with rank, qerror, and twist
    ; -general settings for all plots
    path_in = path_som+"sam/"
    path_out = path_som+"rank/"
    do t = 0, n_trials-1
      ; set the file input/output
      file_in = fname(t)
      file_out = sprinti("%0.3i",rank(t))+"-"+fname(t)
      path_file_out = path_out+file_out
      ; set the plot title
      plot_title = "rank: "+sprinti("%i",rank(t))+  \
                   "  qerror: "+sprintf("%9.4f",qerror(t))+  \
                   "  twist: "+sprintf("%6.4f",twist(t))+  \
                   "  file: "+fname(t)
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; the following lines are cut-and-past directly from plot_som_sammon.ncl
      ;; -they are taken from approximately line 60 to 197
      ;; -the lines are not indented to keep the same as plot_som_sammon.ncl
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set additional flag/settings
  plot_node_labels   = True
  plot_node_lines    = True
  plot_border        = False
  som_zero_based     = False
  fix_orientation    = True
  ; set any flags/parameters for creating the plot
  file_type          = "ps"    ; initial file output type
  convert_ps         = True    ; create a png file from the ps
  clean_ps           = True    ; delete the ps file after creating the png file
  rotate_png         = True    ; rotate the png file
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; read in the header information from the sammon file
  header = readAsciiHead(path_in+file_in+".sam", 1)
  ; -set the nx and ny
  nx = stringtoint(str_get_field(header,3," "))
  ny = stringtoint(str_get_field(header,4," "))
  ; -determine the number of nodes
  nnode = nx * ny
  ; read in the sammon coordinates
  sam = readAsciiTable(path_in+file_in+".sam",2,"float",1)
  ; create a string array with node labels
  node_labels = new(nnode,string)
  ; -create arrays for two dimensional sam position
  sam_x = new((/nx,ny/),float)
  sam_y = new((/nx,ny/),float)
  ; -set a counter
  n = 0
  ; -loop through the nodes
  do y = 0, ny-1
    do x = 0, nx-1
      ; -create the label, based on zero based or not
      if (som_zero_based) then
        ;node_labels(n) = "["+sprinti("%i",x)+","+sprinti("%i",y)+"]"
        node_labels(n) = sprinti("%i",x)+" "+sprinti("%i",y)
      else  
        ;node_labels(n) = "["+sprinti("%i",x+1)+","+sprinti("%i",y+1)+"]"
        node_labels(n) = sprinti("%i",x+1)+" "+sprinti("%i",y+1)
      end if
      ; -created a 2d sammon field
      sam_x(x,y) = sam(n,0)
      sam_y(x,y) = sam(n,1)
      ; -increase the counter
      n = n + 1
    end do
  end do
  ; create the sammon plot
  wks = gsn_open_wks(file_type,path_file_out)
  ; -set the plot resources   
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@gsnMaximize         = True
  res@gsnPaperOrientation = "landscape"
  res@xyMarkLineMode      = "Markers"
  res@xyMarker            = 1
  res@xyMarkerColor       = "black"
  ;res@xyMarkerSizeF       = 0.1
  res@tiMainString        = plot_title
  res@tiMainFontHeightF   = 0.010
  res@tmXBLabelsOn        = False
  res@tmXBOn              = False
  res@tmXTOn              = False
  res@tmYLLabelsOn        = False
  res@tmYLOn              = False
  res@tmYROn              = False
  ; -remove the border, if selected
  if .not.(plot_border) then
    res@tmXBBorderOn        = False
    res@tmXTBorderOn        = False
    res@tmYLBorderOn        = False
    res@tmYRBorderOn        = False
  end if
  ; -change the orientation, if selected and needed
  if (fix_orientation) then
    if (sam_x(0,0) .gt. sam_x(nx-1,0)) then
      res@trXReverse        = True
    end if
    if (sam_y(0,0) .lt. sam_y(0,ny-1)) then
      res@trYReverse        = True
    end if
  end if
  ; -plot the points
  plot = gsn_csm_xy(wks,sam(:,0),sam(:,1),res)
  ; -set the text resources for the labels
  tres                  = True
  tres@txFont           = "helvetica-bold"
  tres@txFontHeightF    = 0.01
  tres@txFontColor      = "black"
  ; -plot the node labels, if selected
  if (plot_node_labels) then  
    tid = new(nnode,graphic)
    do i = 0, nnode-1
      tid(i) = gsn_add_text(wks,plot,node_labels(i),sam(i,0),sam(i,1),tres)
    end do
  end if
  ; -set the text resources for the labels
  lres                  = True
  lres@gsLineThicknessF = 1.
  lres@gsLineColor     = "black"
  ; -plot the node lines, if selected
  if (plot_node_lines) then
    ; -determine the number of lines and create the graphic variables
    nlines = nx + ny
    lid = new(nlines,graphic)
    ; -initiate the counter
    n = 0
    ; -plot the horizontal lines
    do y = 0, ny-1
      lid(n) = gsn_add_polyline(wks,plot,sam_x(:,y),sam_y(:,y),lres)
      n = n + 1
    end do
    ; -plot the vertical lines
    do x = 0, nx-1
      lid(n) = gsn_add_polyline(wks,plot,sam_x(x,:),sam_y(x,:),lres)
      n = n + 1
    end do
  end if
  ; -draw the plot
  draw(plot)
  ; create a png from the ps file
  if (file_type .eq. "ps" .and. convert_ps) then
    ; -close the graphic
    delete(wks)
    ; -convert from the ps file
    if (rotate_png) then
      system("convert -trim -border 10 -bordercolor white -density 300 "+  \
             "-rotate -90 "+path_file_out+".ps "+path_file_out+".png")
    else
      system("convert -trim -border 10 -bordercolor white -density 300 "+  \
             path_file_out+".ps "+path_file_out+".png")      
    end if
    ; -remove the ps file, if selected
    if (clean_ps) then
      system("rm "+path_file_out+".ps")
    end if
  end if
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      delete([/res,lres,tres/])
    end do
  end if
end