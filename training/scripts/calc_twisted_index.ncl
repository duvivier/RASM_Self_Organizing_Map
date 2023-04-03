;----------------------------------------------------;
;                                                    ;
; PROGRAMMER:  Justin Glisan                         ;
; PROGRAM:     Twist.ncl                             ;
; PROGRAM                                            ;
; DESCRIPTION: Calculates Twist Index of Sammon Maps ;
; INPUT DATA: .sam files                             ;
; DATE: October 2013                                 ;
;                                                    ;
;----------------------------------------------------;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Set the file and path input info

	if (.not.isvar("path_in")) then
		path_in = "/vardar/data3/seefeldm/extremes/som/CW/Z850/9x7/qerror/sam/"
	end if
	if (.not.isvar("file_in")) then
		file_in = "Z850_a0.005_rlen1000000_r1.sam"
	end if

; What are the dimension of the Sammon Map?

  header = readAsciiHead(path_in+file_in, 1)
  dim_x = stringtoint(str_get_field(header,3," "))
  dim_y = stringtoint(str_get_field(header,4," "))

; Read in sammon file, which contain x and y coord. for node

 sammon = readAsciiTable(path_in+file_in,2,"float",1)

; Values for the Index output array and do loops

 dim_sammon = dim_x * dim_y
 dim_array  = dim_sammon - 1

 dim_i  = dim_sammon

; Create array for index distances

 res = new(dim_sammon,float)

; Loop across points, find Sammon distance and then the point closest to the anchor points

 do i=0,dim_array
   mindist = 9e9
   minindex = 999
   do j=0,dim_array
     if (i .ne. j) then 
        dist  = sqrt((sammon(i,0) - sammon(j, 0))^2 + (sammon(i,1) - sammon(j, 1))^2)
        if (dist .lt. mindist) then
            minindex = j
            mindist = dist
        end if
     end if
   end do

; Now create new array and x and y index using modulus. Compute distances in Index space

   x = i % dim_x
   y = i / dim_x
   x2 = minindex % dim_x
   y2 = minindex / dim_x

   coorddist = sqrt((x - x2)^2 + (y - y2)^2)
   res(i) = coorddist

 end do

 ;print(res)

; Here, the Index is calculated

 Index = sum(res) / dim_sammon
 print ("index: "+sprintf("%8.6f",Index))

end

