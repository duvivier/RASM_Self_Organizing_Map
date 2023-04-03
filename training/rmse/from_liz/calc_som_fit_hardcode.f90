!-----------------------------------------------------------!
!                                                           !
! PROGRAM: calc_SOM_fit                                     !
! PROGRAM DESCRIPTION: This program calculates how well     !
!  actual SLP fits to the SOM node pattern.                 !
! INPUT DATA: (1) Visual files                              !
!  (2) Input SLP data                                       !
!  (3) output SOM                                           !
! OUTPUT DATA: (1) Root mean square error                   !
!  (2) Mean square error                                    !
!  (3) Mean absolute error                                  !
!  (4) Bias                                                 !
!  (5) Correlations                                         !
!  For (1-4), there will be single spatial plots of these   !
!  values, and then averages of these spatial plots for     !
!  each node. For (1-5), I will calculate averages over the !
!  entire grid and have a single value for each day so can  !
!  create a time series of these values. I can also create  !
!  a xy plot for each SOM node.                             !
! DATE STARTED: May 21, 2013                                !
!                                                           !
!-----------------------------------------------------------!

program calc_som_fit
implicit none

!-----------------------!
! VARIABLE DECLARATIONS !
!-----------------------!

! Integers

integer :: a,z,i,j                   ! Counters
integer :: dumnum                    ! First line of input data
integer :: x,y                       ! SOM nodes
integer :: this_dy_cnt               ! For the arrays that hold the individual
                                     ! value for each day
integer, dimension(7,5) :: cnt ! How often each node occurs

! Reals

real :: slp ! In the visual file

! Below is the sum over the domain of bias, mean absolute error, and mean square
! error. Also have root mean square error
double precision :: bias_sum,mae_sum,mse_sum,rmse 

! Below is for the correlation calculation
double precision :: sumx,sumx2,sumy,sumy2,sumxy
double precision :: SSxx,SSyy,SSxy,corr

! Below are individual lines of the SOM output file, individual day's SLP used
! for training, bias, mean square error, mean absolute error
double precision, dimension(32168) :: som_node,input_day,bias,mse,mae

! Below are for the average of these variables for each node of the SOM
double precision, dimension(7,5) :: bias_arr,mae_arr,mse_arr,rmse_arr,corr_arr
double precision, dimension(7,5,1000) :: bias_ind_arr,mae_ind_arr,mse_ind_arr
!double precision, dimension(7,5,1000) :: rmse_ind_arr,corr_ind_arr

! Below are the SOM nodes in array format
double precision, dimension(32168,7,5) :: som_node_array 

! Characters

character(len=17) :: line2 ! First line of the visual file
character(len=20) :: line1 ! First line of the SOM output files

!---------------!
! START PROGRAM !
!---------------!

! Open SOM output, SOM intput data, and visual file for this SOM
open(10,file='SOM_input_data.txt',form='formatted',status='old')
open(11,file='SOM_output_data.txt',form='formatted',status='old')
open(12,file='visual.txt',form='formatted',status='old')

! Read in first lines of the SOM output data and the visual file
read(11,30) line1
read(12,31) line2

! Zero out counts and average of calculations on the SOM
do j=1,5
   do i=1,7
      cnt(i,j)=0   
      rmse_arr(i,j)=0.
      bias_arr(i,j)=0.
      corr_arr(i,j)=0.
      mse_arr(i,j)=0.
      mae_arr(i,j)=0.
   enddo
enddo

! Read in the SOM output data
do j = 1,5
   do i = 1,7
      read(11,*) som_node
      do y = 1,32168
         som_node_array(y,i,j) = som_node(y)
      enddo
   enddo
enddo
   
! Read in the first line of the SOM input data
read(10,30) dumnum

! Loop through all days
do z=1,22371

! Read a single day of the SOM input data and the visual data that is associated
! with that day
   read(10,*) input_day
   read(12,*) x,y,slp

! Add 1 to the x and y so they are 1 based rather than 0 based, add 1 to the
! count for how often each node occurs
   x=x+1
   y=y+1
   cnt(x,y)=cnt(x,y)+1
!   this_dy_cnt = cnt(x,y)

! Zero everything out for this day
   mse_sum=0.
   bias_sum=0.
   mae_sum=0.
   rmse=0.
   sumx=0.
   sumx2=0.
   sumy=0.
   sumy2=0.
   sumxy=0.
   corr=0.
   SSyy=0.
   SSxx=0.
   SSxy=0.

! Go through every point 
   do a = 1,32168
! Calculate the bias, mean squared error, mean absolute error
      bias(a) = input_day(a) - som_node_array(a,x,y)
      mae(a) = abs(input_day(a) - som_node_array(a,x,y))
      mse(a) = (input_day(a) - som_node_array(a,x,y))**2
! Sum mean squared error, bias, and mean absolute error
      mse_sum=mse_sum+mse(a)
      bias_sum=bias_sum+bias(a)
      mae_sum=mae_sum+mae(a)
! Sums for the correlation calculation
      sumx=sumx+input_day(a)
      sumx2=sumx2+(input_day(a)*input_day(a))
      sumy=sumy+som_node_array(a,x,y)
      sumy2=sumy2+(som_node_array(a,x,y)*som_node_array(a,x,y))
      sumxy=sumxy+(input_day(a)*som_node_array(a,x,y))
   enddo
! Average mean absolute and squared error and bias, and root mean square error
   mae_sum=mae_sum/float(32168)
   bias_sum=bias_sum/float(32168)
   mse_sum=mse_sum/float(32168)
   rmse=sqrt(mse_sum)

!   rmse_ind_arr(x,y,this_dy_cnt) = rmse
!   bias_ind_arr(x,y,this_dy_cnt) = bias
!   mse_ind_arr(x,y,this_dy_cnt) = mse
!   mae_ind_arr(x,y,this_dy_cnt) = mae

! Correlation calculation
   SSxx = sumx2 - ((sumx*sumx)/float(32168))
   SSyy = sumy2 - ((sumy*sumy)/float(32168))
   SSxy = sumxy - ((sumx*sumy)/float(32168))
   corr=SSxy/sqrt(SSxx*SSyy)

!   corr_ind_arr(x,y,this_dy_cnt) = corr

   rmse_arr(x,y)=rmse_arr(x,y)+rmse
   mse_arr(x,y)=mse_arr(x,y)+mse_sum
   mae_arr(x,y)=mae_arr(x,y)+mae_sum
   bias_arr(x,y)=bias_arr(x,y)+bias_sum
   corr_arr(x,y)=corr_arr(x,y)+corr 
enddo

do j=1,5
   do i=1,7
      rmse_arr(i,j)=rmse_arr(i,j)/float(cnt(i,j))
      bias_arr(i,j)=bias_arr(i,j)/float(cnt(i,j))
      corr_arr(i,j)=corr_arr(i,j)/float(cnt(i,j))
      mse_arr(i,j)=mse_arr(i,j)/float(cnt(i,j))
      mae_arr(i,j)=mae_arr(i,j)/float(cnt(i,j))
   enddo
enddo

open(15,file='rmse.txt',form='formatted',status='unknown')
open(16,file='bias.txt',form='formatted',status='unknown')
open(17,file='corr.txt',form='formatted',status='unknown')
open(18,file='mse.txt',form='formatted',status='unknown')
open(19,file='mae.txt',form='formatted',status='unknown')

do j=1,5
   write(15,32) (rmse_arr(i,j),i=1,7)
   write(16,33) (bias_arr(i,j),i=1,7)
   write(17,32) (corr_arr(i,j),i=1,7)
   write(18,34) (mse_arr(i,j),i=1,7)
   write(19,32) (mae_arr(i,j),i=1,7)
enddo

close(10)
close(11)
close(12)
close(13)
close(14)
close(15)
close(16)
close(17)
close(18)
close(19)

30 format(a20)
31 format(a17)
32 format(7(f5.2))
33 format(7(f10.6))
34 format(7(f6.2))

stop 'FINISHED!'
end
