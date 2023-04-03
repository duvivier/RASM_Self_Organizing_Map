;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; flip_som_nodes.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script that flips the SOM output along either the x, y, or both
;
;  COMMAND SYNTAX:
;  -ncl flip_som_map
;
;  NOTES:
;  
;
;  INPUT:  SOM output file
;
;  OUTPUT: SOM output file looking the same as the INPUT, except the lines
;          are re-ordered.
;
;
;  CREATOR:  Mark Seefeldt - 2014-07
; 
;  RELEASE NOTES:
;    1.0 - 2014-07-14
;      -initial release
;
;
;  TODO:
;    
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start the main program
begin
  ; set the default input/output paths and files
  if (.not.isvar("path_in")) then
    path_in = "/data5/duvivier/SOM-RASM/training/som_65/flip/"
  end if
  if (.not.isvar("file_cod_in")) then
    file_cod_in = "wind-a0.04_rlen250000_r2.cod"
  end if
  if (.not.isvar("file_sam_in")) then
    file_sam_in = "wind-a0.04_rlen250000_r2.sam"
  end if
  if (.not.isvar("path_out")) then
    path_out = "/data5/duvivier/SOM-RASM/training/som_65/flip/"
  end if
  if (.not.isvar("file_cod_out")) then
    file_cod_out = "wind-a0.04_rlen250000_r2-flip.cod"
  end if
  if (.not.isvar("file_sam_out")) then
    file_sam_out = "wind-a0.04_rlen250000_r2-flip.sam"
  end if
  ; -additional plotting settings
  flip_x   = False     ; flip in the x-dimension
  flip_y   = True      ; flip in the y-dimension
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; open and read the SOM file
  ; -read in the header into to retrieve number of columns for the cod file
  cod_header = readAsciiHead(path_in+file_cod_in,1)
  npts_som = stringtoint(str_get_field(cod_header,1," "))
  nx_node = stringtoint(str_get_field(cod_header,3," "))
  ny_node = stringtoint(str_get_field(cod_header,4," "))
  ; -read in the som data (skipping the header)
  cod_in = readAsciiTable(path_in+file_cod_in,npts_som,"float",1)
  ; open and read the sammon file
  ; -read in the header
  sam_header = readAsciiHead(path_in+file_sam_in,1)
  ; -read in the som data (skipping the header)
  sam_in = readAsciiTable(path_in+file_sam_in,2,"float",1)
  ; determine the number of nodes
  nnode = nx_node * ny_node
  ; create the data arrays
  cod = new((/nx_node,ny_node,npts_som/),float)
  cod_out = new ((/nnode,npts_som/),float)
  sam = new((/nx_node,ny_node,2/),float)
  sam_out = new ((/nnode,2/),float)
  ; loop through the nodes to create the SOM panels
  do j = 0, ny_node-1
    do i = 0, nx_node-1
      ; set the node number
      node = i + (j*nx_node)
      cod(i,j,:) = cod_in(node,:)
      sam(i,j,:) = sam_in(node,:)
    end do
  end do
  ; flip along the x-dimension, if selected
  if (flip_x) then
    cod = cod(::-1,:,:)
    sam = sam(::-1,:,:)
  end if
  ; flip along the y-dimension, if selected
  if (flip_y) then
    cod = cod(:,::-1,:)  
    sam = sam(:,::-1,:)  
  end if
  do j = 0, ny_node-1
    do i = 0, nx_node-1
      ; set the node number
      node = i + (j*nx_node)
      cod_out(node,:) = cod(i,j,:)
      sam_out(node,:) = sam(i,j,:)
    end do
  end do
  ; create the new SOM output file
  format_cod = npts_som+"f12.4"
  path_file_cod = path_out+file_cod_out
  format_sam = "2f12.4"
  path_file_sam = path_out+file_sam_out
  ; create the options variable and attribute for creating the output
  ; -SOM output
  opt         = True
  opt@fout    = path_file_cod
  opt@title   = cod_header
  ; -create the SOM output file
  write_matrix(cod_out, format_cod, opt)
  ; -sammon output
  opt@fout    = path_file_sam
  opt@title   = sam_header
  ; -create the sammon output file
  write_matrix(sam_out, format_sam, opt)
end
