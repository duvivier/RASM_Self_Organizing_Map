; This NCL script plots an average or anomaly for each node for
; a particular variable in a SOM.  It also plots the differences 
; in average or anomaly per node between two runs of interest.
;
; 9 Oct 2008 - Matt Higgins
; 5 Mar 2011 - Matt Higgins

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

; ******************************************************
  var         = "T_2m"  ; slp, Z500, Z300, T_2m, T500, or T300
  anom_tag    = "anom" ; anom or avg
  startyear   = 1989
  endyear     = 2007
  f1_type     = "met_em"
  f2_type     = "wrf"
  f1_descrip  = "era-interim"
  f2_descrip  = "no_nudging"
;  f2_descrip  = "nudging"
  pmax        = 5
; ******************************************************
; Figure out correct input and output files based on above information.
  outfile    = "som_plots/"+var+"_"+anom_tag+"_and_diff_"+f1_type+"_"+f1_descrip+"_v_"+f2_type+"_"+f2_descrip
  outdata    = "som_data/"+var+"_"+anom_tag+"_and_diff_"+f1_type+"_"+f1_descrip+"_v_"+f2_type+"_"+f2_descrip

  plottitle1 = ""
  plottitle2 = ""
  plottitle3 = ""
  var_title = var
  if (var.eq."slp") then
    var_title = "SLP"
  end if
  if (anom_tag.eq."anom") then
    anom_title = "Anomaly"
  end if
  if (anom_tag.eq."avg") then
    anom_title = "Average"
  end if
  if (f1_type.eq."met_em".and.f1_descrip.eq."era-interim") then
    datatitle1 = "ERA-Interim"
    datafile1  = "som_extract/"+f1_type+"_"+startyear+"_"+endyear+"_"+var+"_"+anom_tag+".dat"  
    datefile1  = "./dates/"+f1_type+"_"+startyear+"_"+endyear+"_dates.txt" 
    visfile1   = "./visual/"+f1_type+"_"+startyear+"_"+endyear+".vis" 
  end if
  if (f1_type.eq."wrf") then
    if (f1_descrip.eq."no_nudging") then
      datatitle1 = "WRF (no spectral nudging)"
    end if
    if (f1_descrip.eq."nudging") then
      datatitle1 = "WRF (with spectral nudging)"
    end if
    datafile1 = "som_extract/"+f1_type+"_"+f1_descrip+"_"+startyear+"_"+endyear+"_"+var+"_"+anom_tag+".dat"
    datefile1 = "./dates/"+f1_type+"_"+f1_descrip+"_"+startyear+"_"+endyear+"_dates.txt" 
    visfile2  = "./visual/"+f1_type+"_"+f1_descrip+"_"+startyear+"_"+endyear+".vis" 
  end if
  if (f2_type.eq."wrf") then
    if (f2_descrip.eq."no_nudging") then
      datatitle2 = "WRF (no spectral nudging)"
    end if
    if (f2_descrip.eq."nudging") then
      datatitle2 = "WRF (with spectral nudging)"
    end if
    datafile2 = "som_extract/"+f2_type+"_"+f2_descrip+"_"+startyear+"_"+endyear+"_"+var+"_"+anom_tag+".dat"
    datefile2 = "./dates/"+f2_type+"_"+f2_descrip+"_"+startyear+"_"+endyear+"_dates.txt" 
    visfile2  = "./visual/"+f2_type+"_"+f2_descrip+"_"+startyear+"_"+endyear+".vis" 
  end if
  plottitle1 = datatitle1+" "+var_title+" "+anom_title
  plottitle2 = datatitle2+" "+var_title+" "+anom_title
  plottitle3 = datatitle2+" - "+datatitle1+" "+var_title+" "+anom_title
  print(plottitle1+"")
  print(plottitle2+"")
  print(plottitle3+"")

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; for testing only
;  datafile1 = datafile1+"400"
;  datafile2 = datafile2+"400"
;  visfile1 = visfile1+"401"
;  visfile2 = visfile2+"401"
;  datefile1 = datefile1+"400"
;  datefile2 = datefile2+"400"
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  nx_node = 7
  ny_node = 5
  nnode = nx_node * ny_node
  print("Loading data...")
  f1 = addfile("geo_em.d01.100km.nc", "r")
  lat2d = f1->XLAT_M(0,:,:)
  lon2d = f1->XLONG_M(0,:,:)
  dims = dimsizes(lat2d)
  n_sn = dims(0)         ; nx_grid
  n_we = dims(1)         ; ny_grid
  n_tot = n_sn * n_we    ; ncol

  ncol  = numAsciiCol(datafile1)
  ncol2 = numAsciiCol(datafile2)
  if (ncol.ne.ncol2) then
    print("data mixup!")
    exit
  end if

  print("Now is a good time for a cup of coffee.")
  in1 = readAsciiTable(datafile1,ncol,"float",0)
  nsizes  = dimsizes(in1)
  ndates1 = nsizes(0)
  if (var.eq."slp")
    print("Adding back missing values.")
    f2 = "interpolated_100km_topo.txt"
    topo = asciiread(f2, -1, "float")
    if (dimsizes(topo).ne.n_tot) then
      print("Topography file does not match input lat/lon!")
      exit
    end if
    topo@_FillValue = -999.
    topoind = ind(.not.ismissing(topo))
    data1 = new((/ndates1,n_tot/),"float")
    data1(:,topoind) = in1
    delete(in1)
  end if
  if (var.ne."slp") then
    data1 = in1
    delete(in1)
  end if

  print("Perhaps a second?")
  in2 = readAsciiTable(datafile2,ncol,"float",0)
  nsizes  = dimsizes(in2)
  ndates2 = nsizes(0)

  if (var.eq."slp")
    print("Adding back missing values.")
    data2 = new((/ndates2,n_tot/),"float")
    data2(:,topoind) = in2
    delete(in2)
  end if
  if (var.ne."slp") then
    data2 = in2
    delete(in2)
  end if

  if (var.eq."T500".or.var.eq."T300") then
    data1 = data1 - 273.15
    data2 = data2 - 273.15
  end if

; set contour intervals
  if (var.eq."slp".and.anom_tag.eq."anom")  ; anomaly
    cmin1 = -28.
    cmax1 = 28.
    clev1 = 1.
    cmin2 = -28.
    cmax2 = 28.
    clev2 = 1.
    stride1             = 8                 ; label stride
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
    unit = "hPa"
  end if
 if (var.eq."slp".and.anom_tag.eq."avg")  ; anomaly
    cmin1 = 920.
    cmax1 = 1064.
    clev1 = 2.
    cmin2 = -28.
    cmax2 = 28.
    clev2 = 2.
    stride1             = 8                 ; label stride
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                 ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
    unit = "hPa"
  end if
  if (var.eq."Z500") then
    cmin1 = -500.
    cmax1 = 500.
    clev1 = 25.
    cmin2 = -300.
    cmax2 = 300.
    clev2 = 25.
    stride1             = 8                 ; label stride
    spreadstart1        = 67                 ; start at color
    spreadend1          = 118                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
    unit = "m"
  end if
  if (var.eq."Z300") then
    cmin1 = -800.
    cmax1 = 800.
    clev1 = 40.
    cmin2 = -400.
    cmax2 = 400.
    clev2 = 25.
    stride1             = 8                 ; label stride
    spreadstart1        = 67                 ; start at color
    spreadend1          = 118                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
    unit = "m"
  end if
  if (var.eq."T_2m".or.var.eq."T500".or.var.eq."T300") then
    if (anom_tag.eq."avg") then
      cmin1 = -88.
      cmax1 = 40.
      clev1 = 2.
      cmin2 = -20.
      cmax2 = 20.
      clev2 = 2.
      stride1             = 8                 ; label stride
      spreadstart1        = 2                 ; start at color
      spreadend1          = 65                ; end at color
      spreadstart2        = 67                ; start at color
      spreadend2          = 108 
      colormap            = "temp64_anoms.dave"
      unit = "C"
    end if
    if (anom_tag.eq."anom")
      cmin1 = -6.
      cmax1 = 6.
      clev1 = .2
      cmin2 = -3.
      cmax2 = 3.
      clev2 = .1
      stride1             = 8                 ; label stride
      spreadstart1        = 2                 ; start at color
      spreadend1          = 102                ; end at color
      spreadstart2        = 2                 ; start at color
      spreadend2          = 102               ; end at color
      colormap            = "BlWhRe"
      unit = "C"
    end if
  end if

  avgperiod = (/"All Year","DJF","MAM","JJA","SON","NDJF","Jan","Feb","Mar", \
  "Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  months = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)

  ; Bring in visual file that places each date at a given node
  print("Loading SOM visual data.")
  vis1 = new((/ndates1,3/),integer)
  vis1 = readAsciiTable(visfile1,3,"integer",1)
  vis2 = new((/ndates2,3/),integer)
  vis2 = readAsciiTable(visfile2,3,"integer",1)

  print("Loading dates.")
  dates1 = ndtooned(readAsciiTable(datefile1,1,"string",0))
  dateschar1 = stringtochar(dates1)
  sdatemonths1 = chartostring(dateschar1(:,4:5))
  dates2 = ndtooned(readAsciiTable(datefile2,1,"string",0))
  dateschar2 = stringtochar(dates2)
  sdatemonths2 = chartostring(dateschar2(:,4:5))

  print("Done loading.  Setting graphics options.")

  wks = gsn_open_wks("ps",outfile)
  additional_colors = (/"gray85","forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

; Graphics options:
  resources                             = True      ; plot mods desired
  resources@cnFillOn                    = True      ; color fill  
  resources@cnLinesOn                   = False      ; contour lines
  resources@cnLineColor                 = "gray85"  ; color of contour lines
  resources@cnLineLabelsOn              = False     ; no contour labels
  resources@gsnSpreadColors             = True      ; use total colormap
  resources@gsnSpreadColorStart         = spreadstart1       ; stop at color 102 for spread
  resources@gsnSpreadColorEnd           = spreadend1       ; stop at color 102 for spread
  resources@cnInfoLabelOn               = False     ; no contour info label
  resources@tiMainFontHeightF           = 0.03      ; node ledgend font
  resources@cnMissingValFillColor       = "gray85"  ; light gray fill for missing data
  resources@cnMissingValFillPattern     = 0        ; solid fill for missing data
  resources@lbLabelBarOn                = False     ; turn off label bar
  resources@gsnMaximize                 = True      ; max plot area
  resources@mpGeophysicalLineColor      = "forestgreen" ; color of continents
  resources@mpGeophysicalLineThicknessF = 0.75 ; make continents thinner
  resources@cnLevelSelectionMode        = "ManualLevels"
  resources@gsnFrame                = False   ; do not advance frame
  resources@gsnDraw                 = False   ; don't draw these individual plots

; Projection options:
  resources@gsnAddCyclic            = False              ; regional data
  resources@mpLimitMode             = "Corners"          ; choose range of map
  resources@mpLeftCornerLatF        = lat2d(0,0)
  resources@mpLeftCornerLonF        = lon2d(0,0)
  resources@mpRightCornerLatF       = lat2d(n_sn-1,n_we-1)
  resources@mpRightCornerLonF       = lon2d(n_sn-1,n_we-1)
  resources@mpProjection            = "Stereographic" 
  resources@mpCenterLonF            = f1@STAND_LON
  resources@mpCenterLatF            = 90. 

; to keep all data for NetCDF output at end of program
  avg1_allnodes    = new((/pmax,nnode,n_sn,n_we/),"float") 
  avg2_allnodes    = new((/pmax,nnode,n_sn,n_we/),"float") 
  avgdiff_allnodes = new((/pmax,nnode,n_sn,n_we/),"float") 
  nodestring       = new(nnode,"string") ; this is used for a double check

; Plot the first, second, and difference plots for our particular month or season.
  do p = 0, pmax-1 ; for each averaging period

    check1 = 0
    check2 = 0
    xpos = 0
    ypos = 0
    n = 0

    if (p.eq.0) then ; for all year
      visall1 = vis1 ; get 'em all
      ndates1 = dimsizes(visall1(:,0))
      visall2 = vis2 ; get 'em all
      ndates2 = dimsizes(visall2(:,0))
      pdata1  = data1
      pdata2  = data2
    end if
    if (p.eq.1) then ; DJF
      dateind1 = ind(sdatemonths1.eq.months(11).or. \
                     sdatemonths1.eq.months(0).or. \
                     sdatemonths1.eq.months(1))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(11).or. \
                     sdatemonths2.eq.months(0).or. \
                     sdatemonths2.eq.months(1))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if
    if (p.eq.2) then ; MAM
      dateind1 = ind(sdatemonths1.eq.months(2).or. \
                     sdatemonths1.eq.months(3).or. \
                     sdatemonths1.eq.months(4))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(2).or. \
                     sdatemonths2.eq.months(3).or. \
                     sdatemonths2.eq.months(4))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if
    if (p.eq.3) then ; JJA
      dateind1 = ind(sdatemonths1.eq.months(5).or. \
                     sdatemonths1.eq.months(6).or. \
                     sdatemonths1.eq.months(7))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(5).or. \
                     sdatemonths2.eq.months(6).or. \
                     sdatemonths2.eq.months(7))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if
    if (p.eq.4) then ; SON
      dateind1 = ind(sdatemonths1.eq.months(8).or. \
                     sdatemonths1.eq.months(9).or. \
                     sdatemonths1.eq.months(10))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(8).or. \
                     sdatemonths2.eq.months(9).or. \
                     sdatemonths2.eq.months(10))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if
    if (p.eq.5) then ; NDJF
      dateind1 = ind(sdatemonths1.eq.months(10).or. \
                     sdatemonths1.eq.months(11).or. \
                     sdatemonths1.eq.months(0).or. \
                     sdatemonths1.eq.months(1))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(10).or. \
                     sdatemonths2.eq.months(11).or. \
                     sdatemonths2.eq.months(0).or. \
                     sdatemonths2.eq.months(1))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if
    if (p.ge.6) then ; individual months
      dateind1 = ind(sdatemonths1.eq.months(p-6))
      visall1  = vis1(dateind1,:)
      ndates1  = dimsizes(visall1(:,0))
      pdata1   = data1(dateind1,:)
      dateind2 = ind(sdatemonths2.eq.months(p-6))
      visall2  = vis2(dateind2,:)
      ndates2  = dimsizes(visall2(:,0))
      pdata2   = data2(dateind1,:)
    end if

    plot1 = new(nnode, graphic)
    plot2 = new(nnode, graphic)
    plot3 = new(nnode, graphic)

    var_data1 = new(n_tot, "float")
    var_data2 = new(n_tot, "float")
    avg_data1 = new(n_tot, "float")
    avg_data2 = new(n_tot, "float")
    nptused1  = new(n_tot, "integer")
    nptused2  = new(n_tot, "integer")

    do y = 0, ny_node - 1
      do x = 0, nx_node - 1
; These are the dates for this particular node:

        dateindices1 = ind(visall1(:,0).eq.x.and.(visall1(:,1).eq.y))
        dateindices2 = ind(visall2(:,0).eq.x.and.(visall2(:,1).eq.y))
        
; This is the data for this node:
        if (all(ismissing(dateindices1))) then
          node_data1   = new(n_tot, "float")
          node_ndates1 = 0
        end if
        if (all(ismissing(dateindices2))) then
          node_data2   = new(n_tot, "float")
          node_ndates2 = 0
        end if
        if (.not.all(ismissing(dateindices1))) then
          node_data1 = pdata1(dateindices1,:)
          node_ndates1 = dimsizes(dateindices1)
        end if
        if (.not.all(ismissing(dateindices2))) then
          node_data2 = pdata2(dateindices2,:)
          node_ndates2 = dimsizes(dateindices2)
        end if

; Check to make sure all dates are accounted.
        check1 = check1 + node_ndates1
        check2 = check2 + node_ndates2

        print("check2 "+check2+" dates this x,y "+node_ndates2)

; Need to do some checks to make sure we actually have two dimensional data:
        rank1 = dimsizes(dimsizes(node_data1))
        rank2 = dimsizes(dimsizes(node_data2))
        if (rank1.eq.1) then
          node_data1_temp = conform_dims((/1,n_tot/),node_data1,1)
          delete(node_data1)
          node_data1 = node_data1_temp
          delete(node_data1_temp)
        end if
        if (rank2.eq.1) then
          node_data2_temp = conform_dims((/1,n_tot/),node_data2,1)
          delete(node_data2)
          node_data2 = node_data2_temp
          delete(node_data2_temp)
        end if

        node_data1!0 = "dates"
        node_data1!1 = "cords"
        node_data2!0 = "dates"
        node_data2!1 = "cords"
        
; calculate averages and variance
        if (node_ndates1.ne.0) then
          stat2(node_data1(cords|:,dates|:),avg_data1,var_data1,nptused1)
        end if
        if (node_ndates2.ne.0) then
          stat2(node_data2(cords|:,dates|:),avg_data2,var_data2,nptused2)
        end if

        avg2d1 = onedtond(avg_data1,(/n_sn,n_we/))
        avg2d2 = onedtond(avg_data2,(/n_sn,n_we/))
        avg2d1@lat2d = lat2d
        avg2d1@lon2d = lon2d
        avg2d2@lat2d = lat2d
        avg2d2@lon2d = lon2d
        
        print("("+x+","+y+") "+f1_type+" "+f1_descrip+": min is "+min(avg2d1)+" max is "+max(avg2d1)+" with n = "+node_ndates1)
        print("("+x+","+y+") "+f2_type+" "+f2_descrip+": min is "+min(avg2d2)+" max is "+max(avg2d2)+" with n = "+node_ndates2)
        
        avg2ddiff = avg2d2 - avg2d1
        copy_VarMeta(avg2d2,avg2ddiff)
        print("("+x+","+y+") diff: min is "+min(avg2ddiff)+" max is "+max(avg2ddiff))
        
        resources@gsnRightString = "("+xpos+","+ypos+")"  ; (this changes)
        nodestring(n) = resources@gsnRightString ; for reference
        resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
        resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

; Set min, max, and contour lines for plot1 and plot2
        resources@cnLevelSpacingF             = clev1
        resources@cnMaxLevelValF              = cmax1
        resources@cnMinLevelValF              = cmin1
        resources@cnLinesOn                   = False
        resources@gsnSpreadColorStart         = spreadstart1
        resources@gsnSpreadColorEnd           = spreadend1

        resources@gsnLeftString = round(min(avg2d1),3)+"/" + round(max(avg2d1),3)+" "+unit
        resources@gsnCenterString = "n = "+node_ndates1
        plot1(n) = gsn_csm_contour_map(wks,avg2d1,resources)

        resources@gsnLeftString = round(min(avg2d2),3)+"/" + round(max(avg2d2),3)+" "+unit
        resources@gsnCenterString = "n = "+node_ndates2
        plot2(n) = gsn_csm_contour_map(wks,avg2d2,resources)
        resources@gsnCenterString = ""

; Set min, max, and contour lines for diff
        resources@cnLevelSpacingF             = clev2
        resources@cnMaxLevelValF              = cmax2
        resources@cnMinLevelValF              = cmin2
        resources@cnLinesOn                   = False
        resources@gsnSpreadColorStart         = spreadstart2
        resources@gsnSpreadColorEnd           = spreadend2

        resources@gsnLeftString = round(min(avg2ddiff),3)+"/" + round(max(avg2ddiff),3)+" "+unit
        plot3(n) = gsn_csm_contour_map(wks,avg2ddiff,resources)

; Save our data for later output:
        avg1_allnodes(p,n,:,:)   = avg2d1(:,:)
        avg2_allnodes(p,n,:,:)   = avg2d2(:,:)
        avgdiff_allnodes(p,n,:,:) = avg2ddiff(:,:)

; Update xpos and ypos for next time through:
        xpos = xpos + 1
        if (xpos.eq.nx_node) then
          xpos = 0
          ypos = ypos + 1
        end if
        n = n + 1

        delete(dateindices1)
        delete(dateindices2)
        delete(node_data1)
        delete(node_data2)

        var_data1 = var_data1@_FillValue
        var_data2 = var_data2@_FillValue
        avg_data1 = avg_data1@_FillValue
        avg_data2 = avg_data2@_FillValue
        nptused1  = nptused1@_FillValue
        nptused2  = nptused2@_FillValue
      end do
    end do

    print("Creating final plot.")

    res_pan                     = True   ; panel resources
    res_pan@txFontHeightF       = 0.015   ; title font height
    res_pan@gsnPaperOrientation = "landscape" ; landscape mode
    res_pan@gsnMaximize         = True   ; make it big
    res_pan@gsnPanelLabelBar    = True   ; common label bar
    res_pan@lbLabelFontHeightF  = 0.007  ; make label bar fonts smaller
    res_pan@lbTitleString      = unit
    res_pan@lbTitlePosition    = "right"
    res_pan@lbLabelAutoStride  = "true"
    res_pan@lbLabelFontHeightF = 0.007
    res_pan@lbTitleJust        = "CenterLeft"
    res_pan@lbTitleFontHeightF = .007 
    res_pan@lbTitleDirection   = "Across"
    
;  getvalues plot1@contour
;  "cnLevels" : levels
;  end getvalues
;  res_pan@lbLabelStrings       = sprintf("%3.0f",levels)   ; Format the labels

    res_pan@txString = plottitle1+" "+avgperiod(p)
    gsn_panel(wks,plot1,(/ny_node, nx_node/),res_pan)

    res_pan@txString = plottitle2+" "+avgperiod(p)
    gsn_panel(wks,plot2,(/ny_node, nx_node/),res_pan)

;  delete(levels)
;  delete(res_pan@lbLabelStrings)

;  getvalues plot3@contour
;  "cnLevels" : levels
;  end getvalues
;  res_pan@lbLabelStrings       = sprintf("%3.0f",levels)   ; Format the labels

    res_pan@txString = plottitle3+" "+avgperiod(p)
    gsn_panel(wks,plot3,(/ny_node, nx_node/),res_pan)

    print("Done!  Nice job - the plot looks great.")
    
    if (check1.ne.ndates1) then
      print("Error.  Number of dates is not equal to total number of indices.")
      print("Num. dates: "+ndates1+"   Tot indices: "+check1)
;    exit
    end if
    if (check2.ne.ndates1) then
      print("Error.  Number of dates is not equal to total number of indices.")
      print("Num. dates: "+ndates2+"   Tot indices: "+check2)
;    exit
    end if

    delete(visall1)
    delete(visall2)
    if (isvar("dateind1")) then
      delete(dateind1)
    end if
    if (isvar("dateind2")) then
      delete(dateind2)
    end if
  
    delete(pdata1)
    delete(pdata2)

  end do ; p loop

  print("Outputing averaged data to NetCDF.")
  avg1_allnodes!0 = "avgperiod"
  avg1_allnodes!1 = "node"
  avg2_allnodes!0 = "avgperiod"
  avg2_allnodes!1 = "node"
  avgdiff_allnodes!0 = "avgperiod"
  avgdiff_allnodes!1 = "node"
  avg1_allnodes@long_name = f1_type+" "+f1_descrip
  avg2_allnodes@long_name = f2_type+" "+f2_descrip
  avgdiff_allnodes@long_name = f2_type+" "+f2_descrip+" - "+f1_type+" "+f1_descrip
  avg1_allnodes@units = unit
  avg2_allnodes@units = unit
  avgdiff_allnodes@units = unit

  fout = addfile(outdata+".nc","c")
  fileAtt = True
  fileAtt@creation_dates = systemfunc("date")
  fileAtt@author = "Matt Higgins"
  fileattdef(fout,fileAtt)

  nodelocation1 = stringtochar(nodestring) ; NetCDF only supports characters, not strings
  nodelocation = nodelocation1(:,1:3) ; get ride of 0x00 fill
  nodelocation@long_name = "characters of node location for reference"
  nodelocation!0 = "node"
  nodelocation!1 = "nothing"

  avgperiod1 = stringtochar(avgperiod(0:pmax-1))
  avgperiod1@long_name = "averaging period"
  avgperiod1!0 = "avg_period"
  avgperiod1!1 = "nothing"

  fout->nodelocation = nodelocation
  fout->avg1_allnodes = avg1_allnodes
  fout->avg2_allnodes = avg2_allnodes
  fout->avgdiff_allnodes = avgdiff_allnodes

end



