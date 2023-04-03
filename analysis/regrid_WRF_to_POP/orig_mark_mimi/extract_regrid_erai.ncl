;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; extract_regrid_erai.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script that creates netcdf files of data extracted from ERA-Interim.
; -The new netcdf files have the ERA-I data regridded to a new lat/lon domain
;  that is specified by the user in the settings below.
; -The user is able to select the variables to be included in the output file(s)
; -This program requires NCL 6.2.1+
;
;  COMMAND SYNTAX:
;  -
;
;  INPUT:  ERA-Interim files from NCAR-CISL Research Data Archive
;            http://rda.ucar.edu/datasets/ds627.0/
;            http://rda.ucar.edu/datasets/ds627.1/
;
;  Data citation:
;    European Centre for Medium-Range Weather Forecasts. 2009, updated monthly. 
;      ERA-Interim Project. Research Data Archive at the National Center for 
;      Atmospheric Research, Computational and Information Systems Laboratory. 
;      http://rda.ucar.edu/datasets/ds627.0. Accessed dd mmm yyyy.
;
;  CREATOR:  Mark Seefeldt - 2013-08
; 
;  RELEASE NOTES:
;    1.0 - 2013-08-14
;      -initial release
;    1.1 - 2013-08-15
;      -change from regridding using rgrid2rc_Wrap to using ESMF_regrid
;      -fixed the assigning dimensions and coordinates for regional regrid
;      -removed the capability to select a subset of variables or a region
;      -significant re-write including the removal of the sub-procedure
;    1.1.1 - 2013-08-30
;      -added a few more variables to the list of options to be extracted
;    1.1.2 - 2013-10-16
;      -fixed LW_u and SW_u to LW_net and SW_net per ERA documentation
;      -fixed SW_u_toa_acc and LW_u_toa_acc to SW_n_toa_acc and LW_n_toa_acc
;      -fixed SH and LH to be indicated as downward
;      -fixed w_p using omega_to_w (requires NCL 6.2.0) to be w instead of omega
;      -added comments attribute to SfcF variables for greater clarity
;   1.1.3 - 2014-03-25
;      -fixed a bug with the new(...) removing the third parameter
;   1.1.4 - 2014-05-21
;      -added the instantaneous and accumulated fields for surface stress
;   1.1.5 - 2014-11-24
;      -added the variables for snowfall (snowfall_t, snowfall_c, snowfall_g)
;      -added the ability to set the beginning and ending day
;      -added the option to pass through the beginning and ending year, month,
;       and day at the command line invoking the NCL program
;      -added the ability to write to NetCDF4classic (compressed NetCDF 3)
;   1.2 - 2015-03-18
;      -changes to correspond with improved methods used in CFSR version
;      -key change involving pressure var now has units of Pa instead of hPa
;   1.2.1 - 2015-04-30
;      -changed WgtFile to be written to the run directory not the output dir
;      -changed isfilepresent to fileexists for v6.2.1+
;      -fixed netCDF4 bug by including pressure@_FillValue
;
;  TODO:
;    
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start the main program
begin
  ; default general inputs for the beginning and ending year, month, and day
  if (.not.isvar("yr_beg")) then
    yr_b = 2012
  else
    ;  -the values input at the command prompt are strings, need to be int
    yr_b = stringtoint(yr_beg)
  end if
  if (.not.isvar("yr_end")) then
    yr_e = 2012
  else
    yr_e = stringtoint(yr_end)
  end if
  if (.not.isvar("mo_beg")) then
    mo_b = 1
  else
    mo_b = stringtoint(mo_beg)
  end if
  if (.not.isvar("mo_end")) then
    mo_e = 1
  else
    mo_e = stringtoint(mo_end)
  end if
  if (.not.isvar("dy_beg")) then
    dy_b = 1
  else
    dy_b = stringtoint(dy_beg)
  end if
  ; Note:  enter dy_e = 99 to go until the last day the month
  if (.not.isvar("dy_end")) then
    dy_e = 99
  else
    dy_e = stringtoint(dy_end)
  end if
  ; set the processing location for file/path defaults
  location = "yellowstone"
  ; based on the location, set the file and path values
  if (location .eq. "yellowstone") then
    ; path for ERA-I files 
    path_sfc1 = "/glade/p/rda/data/ds627.0/ei.oper.an.sfc/"
    path_sfc2 = "/glade/p/rda/data/ds627.0/ei.oper.fc.sfc/"
    path_pl = "/glade/p/rda/data/ds627.0/ei.oper.an.pl/"
    ; output files (path_out+yyyymm+"/"+prefix_out+yyyymmddhh+suffix_out)
    path_out = "/glade/scratch/seefeldm/era_i/rasm_50km/nc6hr/"
    prefix_out = ""
    suffix_out = ".rasm_50km.ERA_I.nc"
    ; set the path, filename, and title for the destination grid
    path_dst = "~/era_i/domain/pan_arctic/"
    file_dst = "geo_em.d01.nc"
    title_dst = "RASM - 50km domain"
  else
    ; path for ERA-I files 
    path_sfc1 = "/data3/seefeldm/era_i/ei.oper.an.sfc/"
    path_sfc2 = "/data3/seefeldm/era_i/ei.oper.fc.sfc/"
    path_pl = "/data3/seefeldm/era_i/ei.oper.an.pl/"
    ; output files (path_out+yyyymm+"/"+prefix_out+yyyymmddhh+suffix_out)
    path_out = "/data3/seefeldm/era_i/nc6hr/"
    prefix_out = ""
    suffix_out = ".rasm_50km.ERA_I.nc"
    ; set the path and filename for the destination grid
    path_dst = "/data/rasm/scripts/misc/gridding/"
    file_dst = "geo_em.d01.nc" 
    title_dst = "RASM - 50km domain" 
  end if
  ; set to use NetCDF4Classic (compressed NetCDF 3)
  fileNetCDF4Classic          = True      ;set NetCDF4Classic fileoption
  ; set the time units 
  TimeUnits = "hours since 1979-01-01 00:00:00"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the netcdf file global attributes
  fileAtt                = True
  fileAtt@creation_date  =  systemfunc("date")
  fileAtt@institution = "University of Colorado at Boulder - CIRES"
  fileAtt@created_by = "Mark Seefeldt - mark.seefeldt@colorado.edu"
  fileAtt@notes = "Created with NCL script:  extract_regrid_erai.ncl v1.2.1"
  ; fileAtt@Conventions    = "CF 1.6, Standard Name Table v19"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface analysis variables
  outSfcA                     = True
  outSfcA@SST                 = True      ;sea-surface temperature
  outSfcA@T_sfc               = True      ;temperature at the surface (skin)
  outSfcA@p_sfc               = True      ;pressure at the surface
  outSfcA@slp                 = True      ;sea-level pressure
  outSfcA@T_2m                = True      ;temperature at 2m
  outSfcA@Td_2m               = True      ;dewpoint temperature at 2m
  outSfcA@u_10m               = True      ;u wind at 10m
  outSfcA@v_10m               = True      ;v wind at 10m
  outSfcA@TCW                 = True      ;total column water
  outSfcA@TCWV                = True      ;total column water vapor
  outSfcA@cloud_t             = True      ;total cloud cover
  outSfcA@cloud_l             = False      ;low cloud cover
  outSfcA@cloud_m             = False      ;medium cloud cover
  outSfcA@cloud_h             = False      ;high cloud cover
  outSfcA@SeaIce              = True      ;sea-ice cover
  outSfcA@SnowHght            = False      ;snow depth  
  outSfcA@albedo              = False      ;albedo  
  outSfcA@sfc_rough           = True      ;surface roughness
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface forecast variables
  outSfcF                     = True
  ;  Note: the precipitation is 6-hourly accumulation ending at the valid time
  outSfcF@precip_t            = True      ;total precipitation
  outSfcF@precip_g            = False      ;stratiform precipitation
  outSfcF@precip_c            = False      ;convective precipitation
  outSfcF@snowfall_t          = True      ;total snowfall
  outSfcF@snowfall_g          = False      ;stratiform snowfall
  outSfcF@snowfall_c          = False      ;convective snowfall
  ;  Note: all fluxes are 6-hourly accumulated values
  ;        To find the average instantaneous flux over the 6-hour period, 
  ;        take the accumulated value and dived by 21600 s.
  outSfcF@SH_acc              = True      ;SH flux - downward - sfc - accum.
  outSfcF@LH_acc              = True      ;LH flux - downward - sfc - accum.
  outSfcF@SW_d_acc            = True      ;SW flux - downward - sfc - accum.
  outSfcF@LW_d_acc            = True      ;LW flux - downward - sfc - accum.
  outSfcF@SW_n_acc            = True      ;SW flux - net - sfc - accum.
  outSfcF@LW_n_acc            = True      ;LW flux - net - sfc - accum.
  outSfcF@SW_d_toa_acc        = True      ;SW flux - downward - TOA - accum.
  outSfcF@SW_n_toa_acc        = True      ;SW flux - net - TOA - accum.
  outSfcF@LW_n_toa_acc        = True      ;LW flux - net - TOA - accum.
  ; Note: wind stress is recorded as instantaneous and accumulated
  outSfcF@sfc_strs_x          = False     ;surface stress - west-east - inst.
  outSfcF@sfc_strs_y          = False     ;surface stress - south-north - inst.
  outSfcF@sfc_strs_x_acc      = True      ;surface stress - west-east - accum.
  outSfcF@sfc_strs_y_acc      = True      ;surface stress - south-north-accum.
  ; Note: pbl height is that value at that time (not definite)
  outSfcF@pblh                = True      ;boundary layer height
  ; Note: the min and max values are since the previous 00 UTC or 12 UTC
  outSfcF@T_2m_min            = True      ;temperature at 2 m - min.
  outSfcF@T_2m_max            = True      ;temperature at 2 m - max.
  outSfcF@ws_10m_gust         = True      ;wind gust at 10 m
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the values for pressure to be extracted/regridded
  pressure = (/92500.,85000.,70000.,50000.,30000./)
  ; three-dimensional pressure-level meteorology analysis variables
  outPresL                    = True
  outPresL@Z_p                = True      ;geopotential height - pressure
  outPresL@T_p                = True      ;temperature - pressure
  outPresL@q_p                = True      ;specific humidity - pressure
  outPresL@rh_p               = False      ;relative humidity - pressure
  outPresL@u_p                = True      ;u wind - pressure
  outPresL@v_p                = True      ;v wind - pressure
  outPresL@w_p                = True      ;w wind - pressure (from omega_p)
  outPresL@pv_p               = True      ;potential vorticity - pressure
  outPresL@rv_p               = True      ;relative vorticity - pressure
  outPresL@div_p              = False      ;divergence - pressure
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; create arrays corresponding to the available variables
  ;  -include three sets of arrays for each type
  ;  -the three sets provides the greatest flexibility for variable names
  ;   that are being read and for variables names being written
  ; two-dimensional surface analysis variables
  SfcA =     (/"SST","T_sfc","p_sfc","slp",  \
               "T_2m","Td_2m","u_10m","v_10m",  \
               "TCW","TCWV","cloud_t","cloud_l",  \
               "cloud_m","cloud_h","SeaIce","SnowHght",  \
               "albedo","sfc_rough"/)
  SfcA_dst = (/"SST","T_sfc","p_sfc","slp",  \
               "T_2m","Td_2m","u_10m","v_10m",  \
               "TCW","TCWV","cloud_t","cloud_l",  \
               "cloud_m","cloud_h","SeaIce","SnowHght",  \
               "albedo","sfc_rough"/)
  SfcA_src = (/"SSTK_GDS4_SFC","SKT_GDS4_SFC","SP_GDS4_SFC","MSL_GDS4_SFC",  \
               "2T_GDS4_SFC","2D_GDS4_SFC","10U_GDS4_SFC","10V_GDS4_SFC",  \
               "TCW_GDS4_SFC","TCWV_GDS4_SFC","TCC_GDS4_SFC","LCC_GDS4_SFC",  \
               "MCC_GDS4_SFC","HCC_GDS4_SFC","CI_GDS4_SFC","SD_GDS4_SFC",  \
               "AL_GDS4_SFC","SR_GDS4_SFC"/)
  nSfcA = dimsizes(SfcA)
  ; two-dimensional surface forecast variables
  SfcF =     (/"precip_t","precip_g","precip_c","snowfall_t",  \
               "snowfall_g","snowfall_c","SH_acc","LH_acc",  \
               "SW_d_acc","LW_d_acc","SW_n_acc","LW_n_acc",  \
               "SW_d_toa_acc","SW_n_toa_acc", "LW_n_toa_acc","sfc_strs_x",  \
               "sfc_strs_y","sfc_strs_x_acc","sfc_strs_y_acc","pblh",  \
               "T_2m_min","T_2m_max","ws_10m_gust"/)
  SfcF_dst = (/"precip_t","precip_g","precip_c","snowfall_t",  \
               "snowfall_g","snowfall_c","SH_acc","LH_acc",  \
               "SW_d_acc","LW_d_acc","SW_n_acc","LW_n_acc",  \
               "SW_d_toa_acc","SW_n_toa_acc", "LW_n_toa_acc","sfc_strs_x",  \
               "sfc_strs_y","sfc_strs_x_acc","sfc_strs_y_acc","pblh",  \
               "T_2m_min","T_2m_max","ws_10m_gust"/)
  SfcF_src = (/"TP_GDS4_SFC","LSP_GDS4_SFC","CP_GDS4_SFC","SF_GDS4_SFC",  \
               "LSF_GDS4_SFC","CSF_GDS4_SFC","SSHF_GDS4_SFC","SLHF_GDS4_SFC",  \ 
               "SSRD_GDS4_SFC","STRD_GDS4_SFC","SSR_GDS4_SFC","STR_GDS4_SFC",  \
               "TISR_GDS4_SFC","TSR_GDS4_SFC","TTR_GDS4_SFC","IEWS_GDS4_SFC",  \
               "INSS_GDS4_SFC","EWSS_GDS4_SFC","NSSS_GDS4_SFC","BLH_GDS4_SFC", \
               "MN2T_GDS4_SFC","MX2T_GDS4_SFC","10FG_GDS4_SFC"/)
  nSfcF = dimsizes(SfcF)
  ; attribute data for surface forecast variables
  SfcF_comment = (/"6-hour accumulation","6-hour accumulation",  \
              "6-hour accumulation","6-hour accumulation",  \
              "6-hour accumulation","6-hour accumulation",  \
              "6-hour accumulation, positive downward", \
              "6-hour accumulation, positive downward","6-hour accumulation", \
              "6-hour accumulation","6-hour accumulation", \
              "6-hour accumulation, positive downward","6-hour accumulation", \
              "6-hour accumulation","6-hour accumulation, positive downward", \
              "instantaneous","instantaneous", \
              "6-hour accumulation","6-hour accumulation", \
              "","since previous 00Z/12Z","since previous 00Z/12Z",  \
              "maximum 3-sec wind, since previous 00Z/12Z"/)
  ; three-dimensional upper-level (pressure levels) meteorology variables
  PresL =     (/"Z_p","T_p","q_p","rh_p",  \
                "u_p","v_p","w_p","pv_p",  \
                "rv_p","div_p"/)
  PresL_dst = (/"Z_p","T_p","q_p","rh_p",  \
                "u_p","v_p","w_p","pv_p",  \
                "rv_p","div_p"/)
  PresL_src = (/"Z_GDS4_ISBL","T_GDS4_ISBL","Q_GDS4_ISBL","R_GDS4_ISBL",  \
                "U_GDS4_ISBL","V_GDS4_ISBL","W_GDS4_ISBL","PV_GDS4_ISBL",  \
                "VO_GDS4_ISBL","D_GDS4_ISBL"/)
  nPresL = dimsizes(PresL)
  ;  -attribute data for pressure level variables
  PresL_l_n = (/"Geopotential Height","Temperature","Specific Humidity",  \
                "Relative Humidity","U wind component","V wind component",  \
                "W wind component","Potential Vorticity","Relative Vorticity", \
                "Divergence"/)
  PresL_s_n = (/"geopotential_height","air_temperature","specific_humidity",  \
                "relative_humidity","eastward_wind","northward_wind",  \
                "upward_wind","atmosphere_potential_vorticity",  \
                "atmosphere_relative_vorticity","divergence_of_wind"/)
  PresL_u = (/"m","K","kg kg**-1","%","m s**-1","m s**-1","m s**-1",  \
              "K m**2 kg**-1 s**-1","s**-1","s**-1"/)
  ; read in the lat/lon from the file with the destination domain
  f_dst = addfile(path_dst+file_dst, "r")
  lat_dst = f_dst->XLAT_M(0,:,:)
  lon_dst = f_dst->XLONG_M(0,:,:)
  ;  -delete some attributes
  delete_VarAtts(lat_dst,(/"FieldType","MemoryOrder","stagger","sr_x","sr_y"/))
  delete_VarAtts(lon_dst,(/"FieldType","MemoryOrder","stagger","sr_x","sr_y"/))
  ; -determine the dimensions of the destination grid
  DimLat = dimsizes(lat_dst)
  nS_N = DimLat(0)
  nW_E = DimLat(1)
  ; -edit some of the attributes
  lat_dst@long_name = "Latitude"
    lat_dst@standard_name = "latitude"
    lat_dst@units = "degrees_north"
    lat_dst!0 = "south_north"
    lat_dst!1 = "west_east"
  lon_dst@long_name = "Longitude"
    lon_dst@standard_name = "longitude"
    lon_dst@units = "degrees_east"
    lon_dst!0 = "south_north"
    lon_dst!1 = "west_east"
  ; set the file name for the weights
  WgtFile = prefix_out+"ESMF_weight"+suffix_out
  ; create the list of settings for ESMF_regrid -> non-source related
  optESMF                     = True
  optESMF@InterpMethod        = "bilinear"
  optESMF@WgtFileName         = WgtFile
  optESMF@DstGridLat          = lat_dst
  optESMF@DstGridLon          = lon_dst
  optESMF@DstRegional         = True     ;the destination grid is not periodic
  optESMF@DstInputFileName    = file_dst ;used only to define attribute
  optESMF@DstTitle            = title_dst
  optESMF@CopyVarAtts         = True
  optESMF@CopyVarCoords       = True
  optESMF@ForceOverwrite      = True
  optESMF@RemoveSrcFile       = True     ;remove file used to describe src grid
  optESMF@RemoveDstFile       = True     ;remove file used to describe dst grid
  optESMF@RemoveWgtFile       = False    ;need the weights file for regridding
  optESMF@Debug               = False
  ; loop through the years, months
  do y = yr_b, yr_e
    do m = mo_b, mo_e
      ; set the end day to the end day of the month, if dy_e = 99
      if (dy_e .eq. 99) then
        end_dy = days_in_month(y, m)
      else
        end_dy = dy_e
      end if
      ; loop through the days, hours
      do d = dy_b, end_dy
        do h = 0, 18, 6
          ; set the value and attributes for the time
          time = cd_inv_calendar(y, m, d, h, 0, 0, TimeUnits, 0)
            time@long_name = "Time"
            time@standard_name = "time"
            time@units = TimeUnits
            time@calendar = "standard"
            time@_FillValue = 1e20
            time!0 = "time"
            time&time = time
          ; create a values for yyyymm and yyyymmddhh
          yyyymm = cd_string(time, "%Y%N")
          yyyymmddhh = cd_string(time, "%Y%N%D%H")
          ; create a value for the time 12-hours previously (for the fcst file)
          ; -initial time of dateset, use same time since there is no previous
          if (y.eq.1979 .and. m.eq.1 .and. d.eq.1 .and. h.eq.0) then
            yyyymm_pr = yyyymm
            yyyymmddhh_pr = yyyymmddhh
          else
            ; determine the time 12 hours prior
            time_pr = time-12
            time_pr@units = TimeUnits
            ; set the yyyymmddhh_pr and yyyymm_pr strings
            yyyymm_pr = cd_string(time_pr, "%Y%N")
            yyyymmddhh_pr = cd_string(time_pr, "%Y%N%D%H")
          end if
          print("date/hour: "+yyyymmddhh+"    previous: "+yyyymmddhh_pr)
          ; open the ERA-I GRIB files from NCAR-CISL RDA
          f_sfc1 = addfile(path_sfc1+yyyymm+"/ei.oper.an.sfc.regn128sc."+  \
                           yyyymmddhh+".grb", "r")
          f_sfc2 = addfile(path_sfc2+yyyymm_pr+"/ei.oper.fc.sfc.regn128sc."+  \
                           yyyymmddhh_pr+".grb", "r")
          f_pl1 = addfile(path_pl+yyyymm+"/ei.oper.an.pl.regn128sc."+  \
                           yyyymmddhh+".grb", "r")
          f_pl2 = addfile(path_pl+yyyymm+"/ei.oper.an.pl.regn128uv."+  \
                           yyyymmddhh+".grb", "r")
          ; open the file to be written
          ;  -set the filename for the attributes
          fileAtt@title          = prefix_out+yyyymmddhh+suffix_out
          ;  -set the NetCDF4Classic option, if selected
          if (fileNetCDF4Classic) then
            setfileoption("nc","Format","NetCDF4Classic")
          end if
          ;  -set a value for the path and filename
          path_file_out = path_out+yyyymm+"/"+prefix_out+  \
                          yyyymmddhh+suffix_out
          ;  -check to see if the directory is present, if not, create it
          if .not. fileexists(path_out+yyyymm) then
            system ("mkdir "+path_out+yyyymm)
          end if
          ;  -check to see if file is present, if so, delete the previous file
          if fileexists(path_file_out) then
            system ("rm "+path_file_out)
          end if
          ;  -create the file
          f_out = addfile(path_file_out,"c")
          ;  -set the compression level, if NetCDF4Classic option is selected
          if (fileNetCDF4Classic) then
            setfileoption(f_out,"CompressionLevel", 1)
          end if
          ; create the global attributes
          fileattdef(f_out, fileAtt)
          ; set time to be the unlimited record variable
          filedimdef(f_out,"time",-1,True)
          ; read in the lat and lon from the different files
          ; Note: This section can be reduced to one lat/lon pair after a
          ;       full run of ERA-I has been retrieved verifying all is the same
          lat_sfc1 = f_sfc1->g4_lat_0
          lon_sfc1 = f_sfc1->g4_lon_1
          lat_sfc2 = f_sfc2->g4_lat_1
          lon_sfc2 = f_sfc2->g4_lon_2
          lat_pl1 = f_pl1->g4_lat_1
          lon_pl1 = f_pl1->g4_lon_2
          lat_pl2 = f_pl2->g4_lat_1
          lon_pl2 = f_pl2->g4_lon_2
          ; verify that the lat and lon values from the different files match
          if (.not. any(lat_sfc1 .eq. lat_sfc2)) then
            print ("ERROR:  The latitude of sfc2 does not match the latitude"  \
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if
          if (.not. any(lon_sfc1 .eq. lon_sfc2)) then
            print ("ERROR:  The longitude of sfc2 does not match the longitude"\
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if            
          if (.not. any(lat_sfc1 .eq. lat_pl1)) then
            print ("ERROR:  The latitude of pl1 does not match the latitude"  \
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if
          if (.not. any(lon_sfc1 .eq. lon_pl1)) then
            print ("ERROR:  The longitude of pl1 does not match the longitude"\
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if
          if (.not. any(lat_sfc1 .eq. lat_pl2)) then
            print ("ERROR:  The latitude of pl2 does not match the latitude"  \
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if
          if (.not. any(lon_sfc1 .eq. lon_pl2)) then
            print ("ERROR:  The longitude of pl2 does not match the longitude"\
                   +" of sfc1 in file: "+yyyymmddhh)
            exit
          end if
          ; set the values for the lat/lon of the source domain
          if (y.eq.yr_b .and. m.eq.mo_b .and. d.eq.dy_b .and. h.eq.0) then
            lat_src = lat_sfc1
            lon_src = lon_sfc1
          else  ; -verify all subsequent occurrences match the original
            if (.not. any(lat_sfc1 .eq. lat_src)) then
              print ("ERROR:  The latitude in files: "+yyyymmddhh+" does "+  \
                     "not match the initial latitude array.")
;              exit
            end if
            if (.not. any(lon_sfc1 .eq. lon_src)) then
              print ("ERROR:  The longitude in files: "+yyyymmddhh+" does "+  \
                     "not match the initial longitude array.")
;              exit
            end if
          end if
          ; find the values for Z_sfc and LandMask
          ;  -only necessary for the first file
          ;  -also creates the ESMF weights file for regridding of variables
          if (y.eq.yr_b .and. m.eq.mo_b .and. d.eq.dy_b .and. h.eq.0) then
            ; create the list of settings for ESMF_regrid -> source related
            optESMF@SrcGridLat          = lat_src
            optESMF@SrcGridLon          = lon_src
            optESMF@SrcInputFileName    = "ei.oper.an.sfc.regn128sc."+yyyymmddhh
            optESMF@SrcTitle            = "ERA-Interim"
            ; surface elevation
            Z_sfc_in = f_sfc1->Z_GDS4_SFC        ; read in the data
            Z_sfc_1 = Z_sfc_in / 9.81            ; calculate the height
            ;  -call ESMF_regrid with the generation of weights
            Z_sfc = ESMF_regrid(Z_sfc_1, optESMF)
            ;  -copy the attributes (atts were lost with calc)
            copy_VarAtts(Z_sfc_in, Z_sfc)
            ;  -delete some attributes
            delete_VarAtts(Z_sfc,(/"lat2d","lon2d","missing_value"/))
           ;  -fix/add some of the attributes/coordinates
            Z_sfc@long_name = "Terrain Height"
              Z_sfc@units = "m"
              Z_sfc@coordinates = "lon lat"
              Z_sfc!0 = "south_north"
              Z_sfc!1 = "west_east"
            ; land mask
            LandMask_in = f_sfc1->LSM_GDS4_SFC
            ;  -call ESMF_regrid_with_weights
            LandMask = ESMF_regrid_with_weights(LandMask_in, WgtFile, optESMF)
            ;  -delete some attributes
            delete_VarAtts(LandMask,(/"lat2d","lon2d","missing_value"/))
            ;  -fix/add some of the attributes/coordinates
            LandMask@coordinates = "lon lat"
              LandMask!0 = "south_north"
              LandMask!1 = "west_east"
          else
            Z_sfc_2 = f_sfc1->Z_GDS4_SFC
            ; verify that the new Z_sfc array is equal to the original
            if (.not. any(Z_sfc_in .eq. Z_sfc_2)) then
              print("ERROR:  The values for Z_sfc do not match the "+  \
                    "original field.")
;              exit
            end if
            delete(Z_sfc_2)
            LandMask_2 = f_sfc1->LSM_GDS4_SFC
            ; verify that the new LandMask array is equal to the original
            if (.not. any(LandMask_in .eq. LandMask_2)) then
              print("ERROR:  The values for LandMask do not match the "+  \
                    "original field.")
;              exit
            end if            
          end if          
          ; write the values for time, lat, lon, Z_sfc, LandMask
          f_out->time=time
          f_out->lat=lat_dst
          f_out->lon=lon_dst
          f_out->Z_sfc=Z_sfc
          f_out->LandMask=LandMask
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ; output the values from the surface analysis files
          if (outSfcA) then
            ; loop through all of the SfcA options
            do i = 0, nSfcA-1
              ; check to see if the variable is selected
              if (outSfcA@$SfcA(i)$) then
                ; read the variable from the ERA-I file
                x0 = f_sfc1->$SfcA_src(i)$
                ; check to see if there is a missing value
                if (any(x0 .eq. x0@_FillValue)) then
                  print("ERROR:  There is a missing value in the field: "+  \
                         SfcA(i))
                  exit
                end if
                ; regrid the data to the destination grid, using weights
                x1 = ESMF_regrid_with_weights(x0, WgtFile, optESMF)
                ; create set equal the new variable with time
                x2 = new((/1,nS_N,nW_E/),"float")
                x2(0,:,:) = x1
                ; delete some attributes
                delete_VarAtts(x2, (/"lat2d","lon2d","missing_value"/))
                ; add some attributes / coordinates
                x2@coordinates = "lon lat"
                x2!0 = "time"
                x2!1 = "south_north"
                x2!2 = "west_east"
                x2&time = time
                ; write the data to the file
                f_out->$SfcA_dst(i)$ = x2
                ; delete the variables that were used
                delete([/x0,x1,x2/])
              end if
            end do
          end if
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ; output the values from the surface forecast files
          if (outSfcF) then
            ; loop through all of the SfcF options
            do i = 0, nSfcF-1
              ; check to see if the variable is selected
              if (outSfcF@$SfcF(i)$) then
                ; read the variable from the ERA-I file
                x0 = f_sfc2->$SfcF_src(i)$
                ; need to create a field of missing values for the initial time
                if (y.eq.1979 .and. m.eq.1 .and. d.eq.1 .and. h.eq.0) then
                  ; need to create x1 and x2 to be deleted later
                  x1 = x0
                  x2 = x0
                  ; create the array
                  x3 = new((/1,nS_N,nW_E/),"float")
                  ; fill with missing values
                  x3(0,:,:) = x0@_FillValue
                  copy_VarAtts(x0, x3)
                ; all other dates/times            
                else
                  ; check to see if there is a missing value
                  if (any(x0 .eq. x0@_FillValue)) then
                    print("ERROR:  There is a missing value in the field: "+  \
                           SfcF(i))
                    exit
                  end if
                  ; non-accumulating values from the SfcF variables
                  if (SfcF(i).eq."sfc_strs_x" .or.  \
                      SfcF(i).eq."sfc_strs_y" .or.  \
                      SfcF(i).eq."pblh" .or.  \
                      SfcF(i).eq."T_2m_min" .or.  \
                      SfcF(i).eq."T_2m_max" .or.  \
                      SfcF(i).eq."ws_10m_gust") then
                    ; hr6 and hr18 = 1
                    if (h.eq.6 .or. h.eq.18) then
                      x1 = x0(1,:,:)
                    end if
                    ; hr0 and hr12 = 3 (from previous fcst)
                    if (h.eq.0 .or. h.eq.12) then
                      x1 = x0(3,:,:)      
                    end if
                  ; accumulating values from the SfcF variables
                  else
                    if (h.eq.6 .or. h.eq.18) then  ; no deaccum for hr6 and hr18
                      x1 = x0(1,:,:)
                    end if
                    if (h.eq.0 .or. h.eq.12) then  ; deaccum for hr0 and hr 12
                      x1 = x0(3,:,:)-x0(1,:,:)      
                      copy_VarAtts(x0, x1)      
                    end if
                  end if                
                  ; regrid the data to the destination grid, using weights
                  x2 = ESMF_regrid_with_weights(x1, WgtFile, optESMF)
                  ; create set equal the new variable with time
                  x3 = new((/1,nS_N,nW_E/),"float")
                  x3(0,:,:) = x2
                  ; delete some attributes
                  delete_VarAtts(x3, (/"lat2d","lon2d","missing_value"/))
                end if
                ; add some attributes / coordinates
                x3@comment = SfcF_comment(i)
                x3@coordinates = "lon lat"
                x3!0 = "time"
                x3!1 = "south_north"
                x3!2 = "west_east"
                x3&time = time
                ; write the data to the file
                f_out->$SfcF_dst(i)$ = x3
                ; delete the variables that were used
                delete([/x0,x1,x2,x3/])
              end if
            end do
          end if
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ; output the values from the pressure level analysis files
          ;  Note: There is something goofy that occurs with the pressure
          ;        variable's attributes when including the ERA-I variable's
          ;        attributes.  The easiest solution was to remove the ERA-I
          ;        attributes and fill in with new.
          if (outPresL) then
            ; retrieve the list of pressure levels
            pres_in = tofloat(f_pl1->lv_ISBL0)
            pres_in = pres_in * 100.   ; convert from hPa to Pa
            ; determine the number of pressure levels to be retrieved
            n_p = dimsizes(pressure)
            ; set the pressure attributes
            pressure@long_name = "Pressure Levels"
              pressure@standard_name = "air_pressure"
              pressure@units = "Pa"
              pressure@positive = "down"
              pressure@_FillValue = 1e+20
              pressure!0 = "pressure"
              pressure&pressure = pressure
            ; write out the pressure levels to the file
            f_out->pressure=pressure
            ; loop through all of the PresL options
            do i = 0, nPresL-1
              ; check to see if the variable is selected
              if (outPresL@$PresL(i)$) then
                ; read the variable from the ERA-I file
                ;  -the u_p and v_p are in a different file from the others
                if (PresL(i).eq."u_p" .or. PresL(i).eq."v_p") then
                  x0 = f_pl2->$PresL_src(i)$
                else
                  x0 = f_pl1->$PresL_src(i)$
                end if
                ;  -the geopotential height is calculated, all others are fine
                if (PresL(i).eq."Z_p") then
                  x1 = (/x0/)/9.81
                else
                  x1 = (/x0/)
                end if
                ; create a new array matching the user selected pressure levels
                ;  -determine the dimensions of the data
                s = dimsizes(x0)
                ;  -create new array
                x2 = new((/n_p,s(1),s(2)/), "float")
                ;  -fill in the array
              	do p = 0, n_p-1
                  x2(p,:,:) = x1(ind(pres_in .eq. pressure(p)),:,:)
                  ; check to see if there is a missing value
                  if (any(x2(p,:,:) .eq. x0@_FillValue)) then
                    print("ERROR:  There is a missing value in the field: "+  \
                           PresL(i)+" at pressure level: "+pressure(p))
                    exit
                  end if
                  ; convert ERA omega to w, if selected
                  if (PresL(i).eq."w_p") then
                    omega = x2(p,:,:)  ; set omega equal to ERA value
                    p_tmp = new((/s(1),s(2)/), "float")
                    p_tmp = pressure(p)
                    T_in = f_pl1->T_GDS4_ISBL
                    T_tmp = T_in(ind(pres_in .eq. pressure(p)),:,:)
                    w = omega_to_w(omega, p_tmp, T_tmp)
                    x2(p,:,:) = w
                    delete([/omega,p_tmp,T_in,T_tmp,w/])
                  end if
                end do
                ; regrid the data to the destination grid, using weights
                x3 = ESMF_regrid_with_weights(x2, WgtFile, optESMF)
                ; create set equal the new variable with time
                x4 = new((/1,n_p,nS_N,nW_E/),"float")
                x4(0,:,:,:) = x3
                ; delete some attributes
                delete_VarAtts(x4,(/"lat2d","lon2d","missing_value"/))
                ; add some attributes / coordinates
                x4@long_name = PresL_l_n(i)
                x4@standard_name = PresL_s_n(i)
                x4@units = PresL_u(i)
                x4@_FillValue = 1e+20
                x4@coordinates = "lon lat"
                x4!0 = "time"
                x4!1 = "pressure"
                x4!2 = "south_north"
                x4!3 = "west_east"
                x4&time = time
                x4&pressure = pressure
                ; write the data to the file
                f_out->$PresL_dst(i)$ = x4
                ; delete the variables that were used
                delete([/x0,x1,x2,x3,x4/])
              end if
            end do
          end if
          delete([/time/])
        end do
      end do
    end do  
  end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end the main program
end
