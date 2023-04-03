;***************************************
; Script to go through 6-hourly core files and
; interpoLATe to the wrf grid
;
; Mimi Hughes
; 11 June 2012
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;***************************************
begin
 setfileoption("nc","Format","LargeFile")
 setfileoption("nc","SuppressClose",False)

 dirin     = "./"

 filiwrfmask="./timeinv.nc"
 a=addfile(filiwrfmask,"r")
 
 wrflat=a->XLAT
 wrflon=a->XLONG

 fili1="ncar_precip.1948-2009.23OCT2012.nc"
 fili2="ncar_rad.1948-2009.23OCT2012.nc"
 fili3="q_10.1948-2009.23OCT2012.nc"
 fili4="slp.1948-2009.23OCT2012.nc"
 fili5="t_10.1948-2009.23OCT2012.nc"
 fili6="u_10.1948-2009.23OCT2012.nc"
 fili7="v_10.1948-2009.23OCT2012.nc"

 fi1=addfile(fili1,"r")
 fi2=addfile(fili2,"r")
 fi3=addfile(fili3,"r")
 fi4=addfile(fili4,"r")
 fi5=addfile(fili5,"r")
 fi6=addfile(fili6,"r")
 fi7=addfile(fili7,"r")

 yeari=ispan(1948,2009,1)
 yearstr=yeari+""

 moni=ispan(1,12,1)
 monstr=moni+""
 do i=0,11
  if (moni(i) .le. 9) then
   monstr(i)="0"+monstr(i)
  end if
 end do

;read in the variables
; RAIN=fi1->RAIN
; SNOW=fi1->SNOW
; LWDN_MOD=fi2->LWDN_MOD
; SWDN_MOD=fi2->SWDN_MOD
 Q_10_MOD=fi3->Q_10_MOD
; SLP=fi4->SLP
; T_10_MOD=fi5->T_10_MOD
; U_10_MOD=fi6->U_10_MOD
; V_10_MOD=fi7->V_10_MOD

;create a monthly time variable
time= ispan(0,743,1)
time@units = "months since 1948-01"
utc = cd_calendar(time,0)
year = utc(:,0)
month = utc(:,1)

;read in all the TIMEs and double check they're identical
;NOTE -- fi1 is monthly and fi2 are daily, while the rest are 6 hourly.
 TIME=fi1->TIME
 TIME2=fi2->TIME
 TIME3=fi3->TIME
 TIME4=fi4->TIME
 TIME5=fi5->TIME
 TIME6=fi6->TIME
 TIME7=fi7->TIME
print("TIME dims " + dimsizes(TIME))
print("TIME2 dims " + dimsizes(TIME2))
print("TIME3 dims " + dimsizes(TIME3))
print("TIME4 dims " + dimsizes(TIME4))
print("TIME5 dims " + dimsizes(TIME5))
print("TIME6 dims " + dimsizes(TIME6))
print("TIME7 dims " + dimsizes(TIME7))
; read in all the LATs and double check they're identical
 LAT=fi1->LAT
 LON=fi1->LON
 LAT2=fi2->LAT
 LON2=fi2->LON
 LAT3=fi3->LAT
 LON3=fi3->LON
 LAT4=fi4->LAT
 LON4=fi4->LON
 LAT5=fi5->LAT
 LON5=fi5->LON
 LAT6=fi6->LAT
 LON6=fi6->LON
 LAT7=fi7->LAT
 LON7=fi7->LON

 diffLAT=LAT-LAT2
 diffLON=LON-LON2
; diffTIME=TIME-TIME2
; if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0) .or. (min(abs(diffTIME)).ne.0)) then
 if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0)) then
   print("something bad happened")
 end if
 diffLAT=LAT-LAT3
 diffLON=LON-LON3
; diffTIME=TIME-TIME3
; if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0) .or. (min(abs(diffTIME)).ne.0)) then
 if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0)) then
   print("something bad happened")
 end if
 diffLAT=LAT-LAT4
 diffLON=LON-LON4
 diffTIME=TIME3-TIME4
 if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0) .or. (min(abs(diffTIME)).ne.0)) then
   print("something bad happened")
 end if
 diffLAT=LAT-LAT5
 diffLON=LON-LON5
 diffTIME=TIME3-TIME5
 if ((min(abs(diffLAT)).ne.0) .or. (min(abs(diffLON)).ne.0) .or. (min(abs(diffTIME)).ne.0)) then
   print("something bad happened")
 end if

  Opt           = True

  Opt@SrcFileName      = "CORE_SCRIP.nc"         ; output file names
  if isfilepresent( Opt@SrcFileName ) then
     Opt@SkipSrcGrid = True
  else
     Opt@SkipSrcGrid = False
  end if
  Opt@DstFileName      = "WRF_ESMF.nc"
  if isfilepresent( Opt@DstFileName ) then
     Opt@SkipDstGrid = True
  end if

  ;Opt@WgtFileName      = "CORE_2_WRF_neareststod.nc"
  Opt@WgtFileName      = "CORE_2_WRF_patch.nc"
  if isfilepresent( Opt@WgtFileName ) then
     Opt@SkipWgtGen = True
  end if

  Opt@ForceOverwrite   = True
  Opt@SrcTitle   = Opt@SrcFileName

  ; Here is where you set your source/destination files
  Opt@DstGridType          = "curvilinear" ; here i set the destination grid type, but you can also set the source grid type
  ; Opt@SrcGridLat                   = LAT ;this is not necessary, since the vars from CERES have them associated as metadata
  ; Opt@SrcGridLon                   = LON
  Opt@DstGridLat                   = wrflat
  Opt@DstGridLon                   = wrflon
  Opt@SrcRegional          = False ; my source data is global so set this to false
  Opt@DstRegional          = True  ; my destination grid is regional so set this to true
  ;Opt@InterpMethod      = "neareststod"         ; you can change this, patch is slower but works well for things like snow (and probably winds)
  Opt@InterpMethod      = "patch"         ; you can change this, patch is slower but works well for things like snow (and probably winds)
  ;Opt@InterpMethod      = "bilinear"         ; you can change this, patch is slower but works well for things like snow (and probably winds)
;  RAIN_regrid = ESMF_regrid(RAIN,Opt)    ; Regrid swe
;  SNOW_regrid = ESMF_regrid(SNOW,Opt)    ; Regrid swe
;  LWDN_MOD_regrid = ESMF_regrid(LWDN_MOD,Opt)    ; Regrid swe
;  SWDN_MOD_regrid = ESMF_regrid(SWDN_MOD,Opt)    ; Regrid swe
  Q_10_MOD_regrid = ESMF_regrid(Q_10_MOD,Opt)    ; Regrid swe
;  SLP_regrid = ESMF_regrid(SLP,Opt)    ; Regrid swe
;  T_10_MOD_regrid = ESMF_regrid(T_10_MOD,Opt)    ; Regrid swe
;  U_10_MOD_regrid = ESMF_regrid(U_10_MOD,Opt)    ; Regrid swe
;  V_10_MOD_regrid = ESMF_regrid(V_10_MOD,Opt)    ; Regrid swe

  utc_date=cd_calendar(TIME,0)
  utc_date2=cd_calendar(TIME2,0)
  utc_date3=cd_calendar(TIME3,0)
  temp=dimsizes(utc_date)
  numofmon=temp(0)

 do mi=0,numofmon-1
; Write out in monthly files
  ;datestryr=""+utc_date(mi,0)
  datestryr=""+year(mi)
  ;datestrmo=""+utc_date(mi,1)
  datestrmo=""+month(mi)
  if (month(mi) .le. 9) then
   datestrmo="0"+datestrmo
  end if
;the above are monthly, but the following are daily and 6 hourly
;  datestryr2=""+utc_date2(mi,0)
;  datestrmo2=""+utc_date2(mi,1)
;  if (utc_date2(mi,1) .le. 9) then
;   datestrmo2="0"+datestrmo2
;  end if
;  datestryr3=""+utc_date3(mi,0)
;  datestrmo3=""+utc_date3(mi,1)
;  if (utc_date3(mi,1) .le. 9) then
;   datestrmo3="0"+datestrmo3
;  end if
  wherethismo2=ind((utc_date2(:,0).eq.year(mi)).and.(utc_date2(:,1).eq.month(mi)))
  wherethismo3=ind((utc_date3(:,0).eq.year(mi)).and.(utc_date3(:,1).eq.month(mi)))

  ;filo = "COREradvars" + datestryr + datestrmo + ".nc"
  filo = "COREQ" + datestryr + datestrmo + ".nc"
  ;filo = "CORESLP" + datestryr + datestrmo + ".nc"
  ;filo = "CORET" + datestryr + datestrmo + ".nc"
  ;filo = "COREwinds" + datestryr + datestrmo + ".nc"
  fo=addfile(filo,"c")

; note that I've fudged the time variable for the precip variables
; for some reason, since it's days since Jan 1 1948 near the end
; of the time series things get funky. 
  ;fo->RAIN=RAIN_regrid(mi,:,:)
  ;fo->SNOW=SNOW_regrid(mi,:,:)
  ;fo->LWDN_MOD=LWDN_MOD_regrid(wherethismo2,:,:)
  ;fo->SWDN_MOD=SWDN_MOD_regrid(wherethismo2,:,:)
  fo->Q_10_MOD=Q_10_MOD_regrid(wherethismo3,:,:)
  ;fo->SLP=SLP_regrid(wherethismo3,:,:)
  ;fo->T_10_MOD=T_10_MOD_regrid(wherethismo3,:,:)
  ;fo->U_10_MOD=U_10_MOD_regrid(wherethismo3,:,:)
  ;fo->V_10_MOD=V_10_MOD_regrid(wherethismo3,:,:)

  delete(datestryr)
  delete(datestrmo)
  delete(wherethismo2)
  delete(wherethismo3)

end do

end

