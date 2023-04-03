;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  fname1 = "wrf50_1997_2007_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running net average/variance calculations")

;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf data
if (fname1 .eq. "wrf10_200511_200703_6h")then
  tag_1 = "wrf"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
if (fname1 .eq. "wrf50_200511_200703_6h")then
  tag_1 = "wrf"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
if (fname1 .eq. "era_i_200511_200703_6h") then
  tag_1 = "met_em"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
if (fname1 .eq. "wrf50_1997_2007_6h") then
  tag_1 = "met_em"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

;node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_avg_"+fname1
net_avg = addfile("./"+fout_avg+".nc","c")

;;;;;;;;;;
; Calculate averages for each data type
;;;;;;;;;;

  ; files that do not need to be averaged
  Z_sfc = node_files->Z_sfc
  lat = node_files->lat
  lon = node_files->lon

  ; write to new average file
  net_avg ->lat = lat
  print("latitude")
  net_avg ->lon = lon
  print("longitude")
  net_avg ->Z_sfc = Z_sfc
  print("Terrain height")
  if (tag_1 .eq. "wrf") then
    LandMask = node_files->LandMask
    net_avg ->LandMask = LandMask
    delete(LandMask)
  end if
  delete(lat)
  delete(lon)
  delete(Z_sfc)

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
  SeaIce = node_files->SeaIce
  SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
  SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
  net_avg ->SeaIce_avg = SeaIce_avg
  net_avg ->SeaIce_var = SeaIce_var
  print("Seaice")
  ; get dimensions for # times
  dims = dimsizes(SeaIce)
  times = dims(0)
  net_avg ->number_dates = times
  delete(SeaIce) 
  delete(SeaIce_avg)
  delete(SeaIce_var)
  delete(dims)
  ;; SLP
  slp = node_files->slp
  slp_avg = dim_avg_n_Wrap(slp,0)
  slp_var = dim_variance_n_Wrap(slp,0)
  net_avg ->slp_avg = slp_avg
  net_avg ->slp_var = slp_var
  print("SLP")
  delete(slp)
  delete(slp_avg)
  delete(slp_var)
  ;; SLP anomaly
  slp_anom = node_files->slp_anom
  slp_anom_avg = dim_avg_n_Wrap(slp_anom,0)
  slp_anom_var = dim_variance_n_Wrap(slp_anom,0)
  net_avg ->slp_anom_avg = slp_anom_avg
  net_avg ->slp_anom_var = slp_anom_var
  print("SLP_anomaly")
  delete(slp_anom)
  delete(slp_anom_avg)
  delete(slp_anom_var)
  ;; Surface pressure
  p_sfc = node_files->p_sfc
  p_sfc_avg = dim_avg_n_Wrap(p_sfc,0)
  p_sfc_var = dim_variance_n_Wrap(p_sfc,0)
  net_avg ->p_sfc_avg = p_sfc_avg
  net_avg ->p_sfc_var = p_sfc_var
  print("Surface pressure")
  delete(p_sfc)
  delete(p_sfc_avg)
  delete(p_sfc_var)
  ;; Surface temperature
  T_sfc = node_files->T_sfc
  T_sfc_avg = dim_avg_n_Wrap(T_sfc,0)
  T_sfc_var = dim_variance_n_Wrap(T_sfc,0)
  net_avg ->T_sfc_avg = T_sfc_avg
  net_avg ->T_sfc_var = T_sfc_var
  print("Surface temperature")
  delete(T_sfc)
  delete(T_sfc_avg)
  delete(T_sfc_var)
  ;; 2m temperature
  T_2m = node_files->T_2m
  T_2m_avg = dim_avg_n_Wrap(T_2m,0)
  T_2m_var = dim_variance_n_Wrap(T_2m,0)
  net_avg ->T_2m_avg = T_2m_avg
  net_avg ->T_2m_var = T_2m_var
  print("2m Temperature")
  delete(T_2m)
  delete(T_2m_avg)
  delete(T_2m_var)
  ;; eta0 temperature
  if (tag_1 .eq. "wrf") then
    T_eta0 = node_files->T_eta0
    T_eta0_avg = dim_avg_n_Wrap(T_eta0,0)
    T_eta0_var = dim_variance_n_Wrap(T_eta0,0)
    ; convert from double to float for later ease
    T_eta0_flt = dble2flt(T_eta0_avg)
    delete(T_eta0_avg)
    T_eta0_avg = T_eta0_flt
    delete(T_eta0_flt)
    T_eta0_flt = dble2flt(T_eta0_var)
    delete(T_eta0_var)
    T_eta0_var = T_eta0_flt
    delete(T_eta0_flt)
    ; write to file
    net_avg ->T_eta0_avg = T_eta0_avg
    net_avg ->T_eta0_var = T_eta0_var
    print("eta0 Temperature")
    delete(T_eta0)
    delete(T_eta0_avg)
    delete(T_eta0_var)
  end if
  ;; 2m mixing ratio
  q_2m = node_files->q_2m
  q_2m_avg = dim_avg_n_Wrap(q_2m,0)
  q_2m_var = dim_variance_n_Wrap(q_2m,0)
  net_avg ->q_2m_avg = q_2m_avg
  net_avg ->q_2m_var = q_2m_var
  print("2m mixing ratio")
  delete(q_2m)
  delete(q_2m_avg)
  delete(q_2m_var)
  ;; eta0 mixing ratio
  if (tag_1 .eq. "wrf") then
    q_eta0 = node_files->q_eta0
    q_eta0_avg = dim_avg_n_Wrap(q_eta0,0)
    q_eta0_var = dim_variance_n_Wrap(q_eta0,0)
    ; convert from double to float for later ease
    q_eta0_flt = dble2flt(q_eta0_avg)
    delete(q_eta0_avg)
    q_eta0_avg = q_eta0_flt
    delete(q_eta0_flt)
    q_eta0_flt = dble2flt(q_eta0_var)
    delete(q_eta0_var)
    q_eta0_var = q_eta0_flt
    delete(q_eta0_flt)
    ; write to file
    net_avg ->q_eta0_avg = q_eta0_avg
    net_avg ->q_eta0_var = q_eta0_var
    print("eta0 mixing ratio")
    delete(q_eta0)
    delete(q_eta0_avg)
    delete(q_eta0_var)
  end if
  ;; u10m
  u_10m_tr = node_files->u_10m_tr
  u_10m_tr_avg = dim_avg_n_Wrap(u_10m_tr,0)
  u_10m_tr_var = dim_variance_n_Wrap(u_10m_tr,0)
  net_avg ->u_10m_tr_avg = u_10m_tr_avg
  net_avg ->u_10m_tr_var = u_10m_tr_var
  print("10m U")
   ;delete(u_10m_tr)
  delete(u_10m_tr_avg)
  delete(u_10m_tr_var)
  ;; v10m
  v_10m_tr = node_files->v_10m_tr
  v_10m_tr_avg = dim_avg_n_Wrap(v_10m_tr,0)
  v_10m_tr_var = dim_variance_n_Wrap(v_10m_tr,0)
  net_avg ->v_10m_tr_avg = v_10m_tr_avg
  net_avg ->v_10m_tr_var = v_10m_tr_var
  print("10m V")
   ;delete(v_10m_tr)
  delete(v_10m_tr_avg)
  delete(v_10m_tr_var)
  ;; ws10m
  ws_10m = sqrt(u_10m_tr^2 + v_10m_tr^2)
  copy_VarMeta(u_10m_tr, ws_10m)
  ws_10m@standard_name = "magnitude_wind_speed"
  ws_10m@long_name = "wind speed"  
;  ws_10m = node_files->ws_10m
  delete(u_10m_tr)
  delete(v_10m_tr)
  ws_10m_avg = dim_avg_n_Wrap(ws_10m,0)
  ws_10m_var = dim_variance_n_Wrap(ws_10m,0)
  net_avg ->ws_10m_avg = ws_10m_avg
  net_avg ->ws_10m_var = ws_10m_var
  print("10m WS")
  delete(ws_10m)
  delete(ws_10m_avg)
  delete(ws_10m_var)
  ;; eta0 winds for wrf only
  if (tag_1 .eq. "wrf") then
    ;; u eta0
    u_tr_eta0 = node_files->u_tr_eta0
    u_tr_eta0_avg = dim_avg_n_Wrap(u_tr_eta0,0)
    u_tr_eta0_var = dim_variance_n_Wrap(u_tr_eta0,0)
    net_avg ->u_tr_eta0_avg = u_tr_eta0_avg
    net_avg ->u_tr_eta0_var = u_tr_eta0_var
    print("eta0 U")
     ;delete(u_tr_eta0)
    delete(u_tr_eta0_avg)
    delete(u_tr_eta0_var)
    ;; v eta0
    v_tr_eta0 = node_files->v_tr_eta0
    v_tr_eta0_avg = dim_avg_n_Wrap(v_tr_eta0,0)
    v_tr_eta0_var = dim_variance_n_Wrap(v_tr_eta0,0)
    net_avg ->v_tr_eta0_avg = v_tr_eta0_avg
    net_avg ->v_tr_eta0_var = v_tr_eta0_var
    print("eta0 V")
     ;delete(v_tr_eta0)
    delete(v_tr_eta0_avg)
    delete(v_tr_eta0_var)
    ;; ws eta0
    ws_eta0 = sqrt(u_tr_eta0^2+v_tr_eta0^2)
    copy_VarMeta(u_tr_eta0,ws_eta0)
    delete(u_tr_eta0)
    delete(v_tr_eta0)
    ws_eta0@standard_name = "magnitude_wind_speed"
    ws_eta0@long_name = "wind speed"
    ws_eta0_avg = dim_avg_n_Wrap(ws_eta0,0)
    ws_eta0_var = dim_variance_n_Wrap(ws_eta0,0)
    net_avg ->ws_eta0_avg = ws_eta0_avg
    net_avg ->ws_eta0_var = ws_eta0_var
    print("eta0 WS")
    delete(ws_eta0)
    delete(ws_eta0_avg)
    delete(ws_eta0_var)
  end if
  ;; Wind stress curl
  if (tag_1 .eq. "wrf") then
    wsc = node_files->wsc
    wsc_avg = dim_avg_n_Wrap(wsc,0)
    wsc_var = dim_variance_n_Wrap(wsc,0)
    net_avg ->wsc_avg = wsc_avg
    net_avg ->wsc_var = wsc_var
    print("Wind Stress Curl")
    delete(wsc)
    delete(wsc_avg)
    delete(wsc_var)
  end if
  if (tag_1 .eq. "met_em") then
    taux = node_files->taux
    taux_avg = dim_avg_n_Wrap(taux,0)
    taux_var = dim_variance_n_Wrap(taux,0)
    net_avg ->taux_avg = taux_avg
    net_avg ->taux_var = taux_var
    print("Eastward surface stress")
    delete(taux)
    delete(taux_avg)
    delete(taux_var)
    tauy = node_files->tauy
    tauy_avg = dim_avg_n_Wrap(tauy,0)
    tauy_var = dim_variance_n_Wrap(tauy,0)
    net_avg ->tauy_avg = tauy_avg
    net_avg ->tauy_var = tauy_var
    print("Northward surface stress")
    delete(tauy)
    delete(tauy_avg)
    delete(tauy_var)
  end if
  ;; Ustar
  u_star = node_files->u_star
  u_star_avg = dim_avg_n_Wrap(u_star,0)
  u_star_var = dim_variance_n_Wrap(u_star,0)
  net_avg ->u_star_avg = u_star_avg
  net_avg ->u_star_var = u_star_var
  print("Ustar")
  delete(u_star)
  delete(u_star_avg)
  delete(u_star_var)
  ;; Total Precipitation rate
  precip_tot = node_files->precip_tot
  precip_tot_avg = dim_avg_n_Wrap(precip_tot,0)
  precip_tot_var = dim_variance_n_Wrap(precip_tot,0)
  net_avg ->precip_tot_avg = precip_tot_avg
  net_avg ->precip_tot_var = precip_tot_var
  print("Total precip")
  delete(precip_tot)
  delete(precip_tot_avg)
  delete(precip_tot_var)
  ;; Frozen Precipitation rate
  if (tag_1 .eq. "wrf") then
    precip_froz = node_files->precip_froz
    precip_froz_avg = dim_avg_n_Wrap(precip_froz,0)
    precip_froz_var = dim_variance_n_Wrap(precip_froz,0)
    net_avg ->precip_froz_avg = precip_froz_avg
    net_avg ->precip_froz_var = precip_froz_var
    print("Frozen precip")
    delete(precip_froz)
    delete(precip_froz_avg)
    delete(precip_froz_var)
  end if
  ;; Shortwave down instantaneous
  if (tag_1 .eq. "wrf") then
    SW_d = node_files->SW_d
    SW_d_avg = dim_avg_n_Wrap(SW_d,0)
    SW_d_var = dim_variance_n_Wrap(SW_d,0)
    net_avg ->SW_d_avg = SW_d_avg
    net_avg ->SW_d_var = SW_d_var
    print("Instantaneous SW down")
    ;delete(SW_d)
    delete(SW_d_avg)
    delete(SW_d_var)
  ;; Shortwave up instantaneous
    SW_u = node_files->SW_u
    SW_u_avg = dim_avg_n_Wrap(SW_u,0)
    SW_u_var = dim_variance_n_Wrap(SW_u,0)
    net_avg ->SW_u_avg = SW_u_avg
    net_avg ->SW_u_var = SW_u_var
    print("Instantaneous SW up")
    ;delete(SW_u)
    delete(SW_u_avg)
    delete(SW_u_var)
  ;; Net shortwave instantaneous
    SW_inst_net = SW_u - SW_d
    copy_VarMeta(SW_u,SW_inst_net)
    delete(SW_u)
    delete(SW_d)
    SW_inst_net@standard_name = "net_shortwave"
    SW_inst_net@long_name = "Net inst shortwave radiation (+ UP)"
    SW_inst_net_avg = dim_avg_n_Wrap(SW_inst_net,0)
    SW_inst_net_var = dim_variance_n_Wrap(SW_inst_net,0)
    net_avg ->SW_inst_net_avg = SW_inst_net_avg
    net_avg ->SW_inst_net_var = SW_inst_net_var
    print("Instantaneous Net Shortwave")
    delete(SW_inst_net)
    delete(SW_inst_net_avg)
    delete(SW_inst_net_var)
  ;; Longwave down instantaneous
    LW_d = node_files->LW_d
    LW_d_avg = dim_avg_n_Wrap(LW_d,0)
    LW_d_var = dim_variance_n_Wrap(LW_d,0)
    net_avg ->LW_d_avg = LW_d_avg
    net_avg ->LW_d_var = LW_d_var
    print("Instantaneous LW down")
    ;delete(LW_d)
    delete(LW_d_avg)
    delete(LW_d_var)
  ;; Longwave up instantaneous
    LW_u = node_files->LW_u
    LW_u_avg = dim_avg_n_Wrap(LW_u,0)
    LW_u_var = dim_variance_n_Wrap(LW_u,0)
    net_avg ->LW_u_avg = LW_u_avg
    net_avg ->LW_u_var = LW_u_var
    print("Instantaneous LW up")
    ;delete(LW_u)
    delete(LW_u_avg)
    delete(LW_u_var)
  ;; Net longwave instantaneous
    LW_inst_net = LW_u - LW_d
    copy_VarMeta(LW_u,LW_inst_net)
    delete(LW_u)
    delete(LW_d)
    LW_inst_net@standard_name = "net_longwave"
    LW_inst_net@long_name = "Net inst longwave radiation (+ UP)"
    LW_inst_net_avg = dim_avg_n_Wrap(LW_inst_net,0)
    LW_inst_net_var = dim_variance_n_Wrap(LW_inst_net,0)
    net_avg ->LW_inst_net_avg = LW_inst_net_avg
    net_avg ->LW_inst_net_var = LW_inst_net_var
    print("Instantaneous Net Longwave")
    delete(LW_inst_net_avg)
    delete(LW_inst_net_var)
  ;; Net radiation instantaneous
      SW_d = node_files->SW_d
      SW_u = node_files->SW_u
      SW_inst_net = SW_u - SW_d
      delete(SW_u)
      delete(SW_d)
    Rad_inst_net = LW_inst_net + SW_inst_net
    copy_VarMeta(LW_inst_net,Rad_inst_net)
    delete(LW_inst_net)
    delete(SW_inst_net)
    Rad_inst_net@standard_name = "net_radiation"
    Rad_inst_net@long_name = "Net inst radiation (+ UP)"
    Rad_inst_net_avg = dim_avg_n_Wrap(Rad_inst_net,0)
    Rad_inst_net_var = dim_variance_n_Wrap(Rad_inst_net,0)
    net_avg ->Rad_inst_net_avg = Rad_inst_net_avg
    net_avg ->Rad_inst_net_var = Rad_inst_net_var
    print("Instantaneous Net radiation")
    delete(Rad_inst_net)
    delete(Rad_inst_net_avg)
    delete(Rad_inst_net_var)
  end if
  ;; Shortwave down deaccumulated
  rsds = node_files->rsds
  rsds_avg = dim_avg_n_Wrap(rsds,0)
  rsds_var = dim_variance_n_Wrap(rsds,0)
  net_avg ->rsds_avg = rsds_avg
  net_avg ->rsds_var = rsds_var
  print("Deaccumulated SW down")
   ;delete(rsds)
  delete(rsds_avg)
  delete(rsds_var)
  ;; Shortwave up deaccumulated
  if (tag_1 .eq. "wrf")then
    rsus = node_files->rsus
    rsus_avg = dim_avg_n_Wrap(rsus,0)
    rsus_var = dim_variance_n_Wrap(rsus,0)
    net_avg ->rsus_avg = rsus_avg
    net_avg ->rsus_var = rsus_var
    print("Deaccumulated SW up")
    ;delete(rsus)
    delete(rsus_avg)
    delete(rsus_var)
  end if
  if (tag_1 .eq. "met_em")then
    dum1 = node_files->rsds
    dum2 = node_files->SW_deac_net
    rsus = dum1 + dum2
    rsus_avg = dim_avg_n_Wrap(rsus,0)
    rsus_var = dim_variance_n_Wrap(rsus,0)
    net_avg ->rsus_avg = rsus_avg
    net_avg ->rsus_var = rsus_var
    print("Deaccumulated SW up")
    ;delete(rsus)
    delete(rsus_avg)
    delete(rsus_var)
    delete(dum1)
    delete(dum2)
  end if
  ;; Net shortwave deaccumulated
  if (tag_1 .eq. "wrf") then
    SW_deac_net = rsus - rsds
    copy_VarMeta(rsus,SW_deac_net)
    delete(rsus)
    delete(rsds)
    SW_deac_net@standard_name = "net_shortwave"
    SW_deac_net@long_name = "Net deac shortwave radiation (+ UP)"
    SW_deac_net_avg = dim_avg_n_Wrap(SW_deac_net,0)
    SW_deac_net_var = dim_variance_n_Wrap(SW_deac_net,0)
    net_avg ->SW_deac_net_avg = SW_deac_net_avg
    net_avg ->SW_deac_net_var = SW_deac_net_var
    print("Deaccumulated Net Shortwave")
    delete(SW_deac_net)
    delete(SW_deac_net_avg)
    delete(SW_deac_net_var)
  end if
  if (tag_1 .eq. "met_em")then
    SW_deac_net = node_files->SW_deac_net
    SW_deac_net_avg = dim_avg_n_Wrap(SW_deac_net,0)
    SW_deac_net_var = dim_variance_n_Wrap(SW_deac_net,0)
    net_avg ->SW_deac_net_avg = SW_deac_net_avg
    net_avg ->SW_deac_net_var = SW_deac_net_var
    print("Deaccumulated Net Shortwave")
    delete(SW_deac_net_avg)
    delete(SW_deac_net_var)
  end if
  ;; Longwave down deaccumulated
  rlds = node_files->rlds
  rlds_avg = dim_avg_n_Wrap(rlds,0)
  rlds_var = dim_variance_n_Wrap(rlds,0)
  net_avg ->rlds_avg = rlds_avg
  net_avg ->rlds_var = rlds_var
  print("Deaccumulated LW down")
   ;delete(rlds)
  delete(rlds_avg)
  delete(rlds_var)
  ;; Longwave up deaccumulated
  if (tag_1 .eq. "wrf") then
    rlus = node_files->rlus
    rlus_avg = dim_avg_n_Wrap(rlus,0)
    rlus_var = dim_variance_n_Wrap(rlus,0)
    net_avg ->rlus_avg = rlus_avg
    net_avg ->rlus_var = rlus_var
    print("Deaccumulated LW up")
    ;delete(rlus)
    delete(rlus_avg)
    delete(rlus_var)
  end if
  if (tag_1 .eq. "met_em") then
    dum1 = node_files->rlds
    dum2 = node_files->LW_deac_net
    rlus = dum1 + dum2
    rlus_avg = dim_avg_n_Wrap(rlds,0)
    rlus_var = dim_variance_n_Wrap(rlus,0)
    net_avg ->rlus_avg = rlus_avg
    net_avg ->rlus_var = rlus_var
    print("Deaccumulated LW up")
    ;delete(rlus)
    delete(rlus_avg)
    delete(rlus_var)
    delete(dum1)
    delete(dum2)
  end if
  ;; Net longwave deaccumulated
  if (tag_1 .eq. "wrf") then
    LW_deac_net = rlus - rlds
    copy_VarMeta(rlus,LW_deac_net)
    delete(rlus)
    delete(rlds)
    LW_deac_net@standard_name = "net_longwave"
    LW_deac_net@long_name = "Net deac longwave radiation (+ UP)"
    LW_deac_net_avg = dim_avg_n_Wrap(LW_deac_net,0)
    LW_deac_net_var = dim_variance_n_Wrap(LW_deac_net,0)
    net_avg ->LW_deac_net_avg = LW_deac_net_avg
    net_avg ->LW_deac_net_var = LW_deac_net_var
    print("Deaccumulated Net Longwave")
    delete(LW_deac_net_avg)
    delete(LW_deac_net_var)
  end if
  if (tag_1 .eq. "met_em")then
    LW_deac_net = node_files->LW_deac_net
    LW_deac_net_avg = dim_avg_n_Wrap(LW_deac_net,0)
    LW_deac_net_var = dim_variance_n_Wrap(LW_deac_net,0)
    net_avg ->LW_deac_net_avg = LW_deac_net_avg
    net_avg ->LW_deac_net_var = LW_deac_net_var
    print("Deaccumulated Net Longwave")
    delete(LW_deac_net_avg)
    delete(LW_deac_net_var)
  end if
  ;; Net radiation deaccumulated
  if (tag_1 .eq. "wrf") then
      rsds = node_files->rsds
      rsus = node_files->rsus
      SW_deac_net = rsus - rsds
      delete(rsus)
      delete(rsds)
    Rad_deac_net = LW_deac_net + SW_deac_net
    copy_VarMeta(LW_deac_net,Rad_deac_net)
    delete(LW_deac_net)
    delete(SW_deac_net)
    Rad_deac_net@standard_name = "net_radiation"
    Rad_deac_net@long_name = "Net deac radiation (+ UP)"
    Rad_deac_net_avg = dim_avg_n_Wrap(Rad_deac_net,0)
    Rad_deac_net_var = dim_variance_n_Wrap(Rad_deac_net,0)
    net_avg ->Rad_deac_net_avg = Rad_deac_net_avg
    net_avg ->Rad_deac_net_var = Rad_deac_net_var
    print("Deaccumulated Net radiation")
    delete(Rad_deac_net)
    delete(Rad_deac_net_avg)
    delete(Rad_deac_net_var)
  end if
  if (tag_1 .eq. "met_em") then
    Rad_deac_net = LW_deac_net + SW_deac_net
    copy_VarMeta(LW_deac_net,Rad_deac_net)
    delete(LW_deac_net)
    delete(SW_deac_net)
    Rad_deac_net@standard_name = "net_radiation"
    Rad_deac_net@long_name = "Net deac radiation (+ UP)"
    Rad_deac_net_avg = dim_avg_n_Wrap(Rad_deac_net,0)
    Rad_deac_net_var = dim_variance_n_Wrap(Rad_deac_net,0)
    net_avg ->Rad_deac_net_avg = Rad_deac_net_avg
    net_avg ->Rad_deac_net_var = Rad_deac_net_var
    print("Deaccumulated Net radiation")
    delete(Rad_deac_net)
    delete(Rad_deac_net_avg)
    delete(Rad_deac_net_var)    
  end if
  ;; Sensible Heat flux instantaneous
  if (tag_1 .eq. "wrf") then
    SHFlx = node_files->SHFlx
    SHFlx_avg = dim_avg_n_Wrap(SHFlx,0)
    SHFlx_var = dim_variance_n_Wrap(SHFlx,0)
    net_avg ->SHFlx_avg = SHFlx_avg
    net_avg ->SHFlx_var = SHFlx_var
    print("Instantaneous Sensible Heat Flux")
    ;delete(SHFlx)
    delete(SHFlx_avg)
    delete(SHFlx_var)
  ;; Latent Heat flux instantaneous
    LHFlx = node_files->LHFlx
    LHFlx_avg = dim_avg_n_Wrap(LHFlx,0)
    LHFlx_var = dim_variance_n_Wrap(LHFlx,0)
    net_avg ->LHFlx_avg = LHFlx_avg
    net_avg ->LHFlx_var = LHFlx_var
    print("Instantaneous Latent Heat Flux")
    ;delete(LHFlx)
    delete(LHFlx_avg)
    delete(LHFlx_var)
  ;; Net Turbulent flux instantaneous
    Turb_inst_net = LHFlx + SHFlx
    copy_VarMeta(LHFlx,Turb_inst_net)
    delete(LHFlx)
    delete(SHFlx)
    Turb_inst_net@standard_name = "net_turbulent_fluxes"
    Turb_inst_net@long_name = "Net inst turbulent fluxes (+ UP)"
    Turb_inst_net_avg = dim_avg_n_Wrap(Turb_inst_net,0)
    Turb_inst_net_var = dim_variance_n_Wrap(Turb_inst_net,0)
    net_avg ->Turb_inst_net_avg = Turb_inst_net_avg
    net_avg ->Turb_inst_net_var = Turb_inst_net_var
    print("Instantaneous Net Turbulent Flux") 
    delete(Turb_inst_net_avg)
    delete(Turb_inst_net_var)
  ;; Net Radiative and Turbulent fluxes instantaneous
      SW_d = node_files->SW_d
      SW_u = node_files->SW_u
      SW_inst_net = SW_u - SW_d
      delete(SW_u)
      delete(SW_d)
      LW_d = node_files->LW_d
      LW_u = node_files->LW_u
      LW_inst_net = LW_u - LW_d
      delete(LW_u)
      delete(LW_d)
      Rad_inst_net = LW_inst_net + SW_inst_net
      delete(LW_inst_net)
      delete(SW_inst_net)
    Flux_inst_net = Turb_inst_net + Rad_inst_net
    copy_VarMeta(Turb_inst_net, Flux_inst_net)
    delete(Turb_inst_net)
    delete(Rad_inst_net)
    Flux_inst_net@standard_name = "net_flux"
    Flux_inst_net@long_name = "Net inst radiative and turbulent fluxes (+ UP)"
    Flux_inst_net_avg = dim_avg_n_Wrap(Flux_inst_net,0)
    Flux_inst_net_var = dim_variance_n_Wrap(Flux_inst_net,0)
    net_avg ->Flux_inst_net_avg = Flux_inst_net_avg
    net_avg ->Flux_inst_net_var = Flux_inst_net_var
    print("Instantaneous Net Flux (turb and rad)")
    delete(Flux_inst_net)
    delete(Flux_inst_net_avg)
    delete(Flux_inst_net_var)
  end if
  ;; Sensible Heat flux deaccumulated
  hfss = node_files->hfss
  hfss_avg = dim_avg_n_Wrap(hfss,0)
  hfss_var = dim_variance_n_Wrap(hfss,0)
  net_avg ->hfss_avg = hfss_avg
  net_avg ->hfss_var = hfss_var
  print("Deaccumulated sensible heat flux")
   ;delete(hfss)
  delete(hfss_avg)
  delete(hfss_var)
  ;; Latent Heat flux deaccumulated
  hfls = node_files->hfls
  hfls_avg = dim_avg_n_Wrap(hfls,0)
  hfls_var = dim_variance_n_Wrap(hfls,0)
  net_avg ->hfls_avg = hfls_avg
  net_avg ->hfls_var = hfls_var
  print("Deaccumulated latent heat flux")
   ;delete(hfls)
  delete(hfls_avg)
  delete(hfls_var)
  ;; Net Turbulent flux deaccumulated
  Turb_deac_net = hfls + hfss
  copy_VarMeta(hfls,Turb_deac_net)
  delete(hfls)
  delete(hfss)
  Turb_deac_net@standard_name = "net_turbulent_fluxes"
  Turb_deac_net@long_name = "Net deac turbulent fluxes (+ UP)"
  Turb_deac_net_avg = dim_avg_n_Wrap(Turb_deac_net,0)
  Turb_deac_net_var = dim_variance_n_Wrap(Turb_deac_net,0)
  net_avg ->Turb_deac_net_avg = Turb_deac_net_avg
  net_avg ->Turb_deac_net_var = Turb_deac_net_var
  print("Deaccumulated Net Turbulent Flux") 
  delete(Turb_deac_net_avg)
  delete(Turb_deac_net_var)
  ;; Net Radiative and Turbulent fluxes deaccumulated
    rsds = node_files->rsds
    rsus = node_files->rsus
    SW_deac_net = rsus - rsds
    delete(rsus)
    delete(rsds)
    rlds = node_files->rlds
    rlus = node_files->rlus
    LW_deac_net = rlus - rlds
    delete(rlus)
    delete(rlds)
    Rad_deac_net = LW_deac_net + SW_deac_net
    delete(LW_deac_net)
    delete(SW_deac_net)
  Flux_deac_net = Turb_deac_net + Rad_deac_net
  copy_VarMeta(Turb_deac_net, Flux_deac_net)
  delete(Turb_deac_net)
  delete(Rad_deac_net)
  Flux_deac_net@standard_name = "net_flux"
  Flux_deac_net@long_name = "Net deac radiative and turbulent fluxes (+ UP)"
  Flux_deac_net_avg = dim_avg_n_Wrap(Flux_deac_net,0)
  Flux_deac_net_var = dim_variance_n_Wrap(Flux_deac_net,0)
  net_avg ->Flux_deac_net_avg = Flux_deac_net_avg
  net_avg ->Flux_deac_net_var = Flux_deac_net_var
  print("Deaccumulated Net Flux (turb and rad)")
  delete(Flux_deac_net)
  delete(Flux_deac_net_avg)
  delete(Flux_deac_net_var)

print("Finished averaging variables for "+fname1)


;;;;;;;;;;;;;;;;;;;;;; END script
end
