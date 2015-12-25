; Program:
;	Draw the vertical integration of qflux's divergent wind component and velecity potential on time scale of monthly mean
;	The data is from vint_qflux_sepa_vector.nc
; History:
;	2014/10/30 MeteoBoy4 First Realease: annually averaged, with TP isogeopotential line
;       2015/1/28  MeteoBoy4 Minor Modification: with 1500-m isogeopotential line only, new directory with longer time range

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;------Read the data from ncfile and some other support data
	lonW=20.0
	lonE=160.0
	latS=-10.0
	latN=60.0
	pltType="ps"
	pltName="qflux_vint_rot_paper"
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim/"
	dirbac="/run/media/MeteoBoy4/Data/MData/ERA-Interim/Surface_GeoP"
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	system("rm -f "+pltName+"."+pltType)
	qfile=addfile(dirvar+"/1985-2014_ALEV/Monthly/Calculation/April_July_climate.nc","r")
	ofile=addfile(dirbac+"/Surface_GeoP.nc","r")
	qu=qfile->rou(:,:,:)
	qv=qfile->rov(:,:,:)
	sf=qfile->sf(:,:,:)
	z=short2flt(ofile->z(0,:,:))
	lsdata=maskf->LSMASK
	dims=dimsizes(qu)
	ntime=dims(0)
	nlat=dims(1)
	nlon=dims(2)
	lat=qu&latitude
	lon=qu&longitude
;	print(lat)
	wind=qu
	wind=sqrt(qu*qu+qv*qv)

;------Set for orography and masking the ocean
	z=z/9.80665
	lsm=landsea_mask(lsdata,z&latitude,z&longitude)
	z=mask(z,lsm.eq.0,False)

;------Set up the map
	plot = new(2,"graphic")
	wks=gsn_open_wks(pltType,pltName)
	gsn_define_colormap(wks,"MPL_Blues")

	vcres=True
	vcres@gsnDraw=False
	vcres@gsnFrame=False

	vcres@vfXCStartV=lonW
	vcres@vfXCEndV  =lonE
	vcres@vfYCStartV=latS
	vcres@vfYCEndV  =latN

	vcres@mpMinLonF=lonW
	vcres@mpMaxLonF=lonE
	vcres@mpMinLatF=latS
	vcres@mpMaxLatF=latN
	vcres@mpLimitMode="LatLon"
	vcres@mpCenterLonF=180.

;	vcres@gsnMaximize=True
	vcres@gsnAddCyclic=False
	vcres@gsnPaperOrientation="portrait"

;	vcres@mpDataBaseVersion="MediumRes"
;	vcres@mpDataSetName="Earth..4"
	
	vcres@vcGlyphStyle="LineArrow"
	vcres@vcLineArrowThicknessF=1.2
	vcres@vcRefMagnitudeF=300.
	vcres@vcRefLengthF=0.045
	vcres@vcMinDistanceF=0.017
	vcres@vcVectorDrawOrder="PostDraw"
	vcres@vcRefAnnoOn=False   ;For common sigle reference annotation
	
	vcres@gsnLeftString=""
	vcres@gsnRightString=""

	vcres@cnFillOn=True
	vcres@cnLinesOn=False
	vcres@cnLineLabelsOn=False
	vcres@gsnScalarContour=True
	vcres@lbLabelBarOn=False

	vcres@cnLevelSelectionMode="ManualLevels"
	vcres@cnMinLevelValF=0.0
	vcres@cnMaxLevelValF=600.0
	vcres@cnLevelSpacingF=40.0

	vcres@mpFillOn=False
	vcres@mpPerimOn=True

	plot(0)=gsn_csm_vector_scalar_map(wks,qu(0,{latS:latN},{lonW:lonE}),qv(0,{latS:latN},{lonW:lonE}),wind(0,{latS:latN},{lonW:lonE}),vcres)
;	mapa=gsn_csm_contour_map(wks,wind(0,:,:),False)
;	map=gsn_csm_vector_scalar_map(wks,quclm(0,:,:),qvclm(0,:,:),wind(0,:,:),vcres)

	cnres=True
	cnres@gsnDraw=False
	cnres@gsnFrame=False
	cnres@gsnLeftString=""
	cnres@gsnRightString=""

	cnres@sfXCStartV=lonW
	cnres@sfXCEndV=lonE
	cnres@sfYCStartV=latS
	cnres@sfYCEndV=latN

	cnres@gsnMaximize=True
	cnres@gsnAddCyclic=False 
	cnres@gsnPaperOrientation="portrait"

	cnres@cnLineThicknessF=3.
	cnres@cnLineLabelsOn=False
	cnres@cnInfoLabelOn=False

	map3=gsn_csm_contour(wks,sf(0,{latS:latN},{lonW:lonE}),cnres)

	tpres=True
	tpres@gsnDraw=False		;  Both plots should be set not to draw and frame
	tpres@gsnFrame=False
	tpres@gsnLeftString=""
	tpres@gsnRightString=""


	tpres@sfXCStartV=lonW
	tpres@sfXCEndV=lonE
	tpres@sfYCStartV=latS
	tpres@sfYCEndV=latN

;	tpres@mpMinLonF=30.
;	tpres@mpMaxLonF=lonE
;	tpres@mpMinLatF=latS.
;	tpres@mpMaxLatF=latN.
;	tpres@mpLimitMode="LatLon"
;	tpres@mpCenterLonF=180.

	tpres@cnLineLabelsOn=False
	tpres@cnInfoLabelOn=False
	tpres@cnLevelSelectionMode="ExplicitLevels"
	tpres@cnLevels=(/1500./)
	tpres@cnLineThicknessF=2.0

;	tpres@gsnMaximize=True
	tpres@gsnAddCyclic=False
	tpres@gsnPaperOrientation="portrait"
	
	tpres@tiMainFontHeightF=0.015
	tpres@tiMainString=""

	map2=gsn_csm_contour(wks,z({latS:latN},{lonW:lonE}),tpres)
;	map2=gsn_csm_contour(wks,z(:,:),tpres) 
	overlay(plot(0),map3)
	overlay(plot(0),map2)
	
	vcres@vcRefAnnoOrthogonalPosF=-1.2
;	vcres@vcRefAnnoSide="Left"
	vcres@vcRefAnnoOn=True
	plot(1)=gsn_csm_vector_scalar_map(wks,qu(1,{latS:latN},{lonW:lonE}),qv(1,{latS:latN},{lonW:lonE}),wind(1,{latS:latN},{lonW:lonE}),vcres)
	map3=gsn_csm_contour(wks,sf(1,{latS:latN},{lonW:lonE}),cnres)
	map2=gsn_csm_contour(wks,z({latS:latN},{lonW:lonE}),tpres)
	overlay(plot(1),map3)
	overlay(plot(1),map2)
	
	resP=True
	resP@gsnPanelLabelBar=True
	resP@gsnMaximize=True
	resP@gsnPaperOrientation="portrait"
	resP@gsnPanelFigureStrings=(/"(a)","(b)"/)
	resP@amJust="TopLeft"
	resP@gsnPanelFigureStringsPerimOn=False
	resP@gsnPanelFigureStringsBackgroundFillColor=10
	gsn_panel(wks,plot,(/1,2/),resP)

	delete(z)
	delete(qu)
	delete(qv)
	delete(sf)
	delete(wind)

end
