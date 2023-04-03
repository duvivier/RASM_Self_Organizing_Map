;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; plot_som_sammon.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script that creates a sammon plot from a som_pak sammon file.
;
; -This program requires NCL 6.1
;
;  COMMAND SYNTAX:
;  -ncl plot_som_sammon.ncl
;  -The following values can be set when starting the program:
;    path_in - path of sammon file
;    file_in - filename of sammon file (excluding the .sam extension)
;    path_out - path for output file
;
;  NOTES:
;  -
;
;  INPUT:  som_pak sammon file
;
;  OUTPUT:  png sammon file
;
;  CREATOR:  Mark Seefeldt - 2014-06
;   -based on plat_sammon.ncl from Elizabeth Cassano
;   -based on plot_sammon.pro (IDL) from Mark Seefeldt (based on Joel Finnis)
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
  if (.not.isvar("path_in")) then
    path_in = "/data5/duvivier/SOM-RASM/training/som_75/flip/"
  end if
  if (.not.isvar("path_out")) then
    path_out = "/data5/duvivier/SOM-RASM/training/som_75/flip/"
  end if    
  if (.not.isvar("file_in")) then  ; do not include the .sam extension
    file_in = "wind-a0.03_rlen500000_r3-flip"
  end if
  if (.not.isvar("file_out")) then
    file_out = file_in
  end if
  path_file_out = path_out+file_out
  if (.not.isvar("plot_title")) then
    plot_title = file_in
  end if
  ; set additional flag/settings
  plot_node_labels   = True
  plot_node_lines    = True
  plot_border        = False
  som_zero_based     = False
  fix_orientation    = True
  ; set any flags/parameters for creating the plot
  file_type          = "ps"    ; initial file output type
  convert_ps         = True    ; create a png file from the ps
  clean_ps           = False    ; delete the ps file after creating the png file
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

end
