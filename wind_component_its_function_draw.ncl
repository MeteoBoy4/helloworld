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
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim/"
	dirbac="/run/media/MeteoBoy4/Data/MData/ERA-Interim/Surface_GeoP"
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	system("rm -f qflux_vint_rot.eps")
	qfile=addfile(dirvar+"/1985-2014_ALEV/Calculation/vint_qflux_sepa_vector_summerwhole.nc","r")
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
	wks=gsn_open_wks("ps","qflux_vint_rot")
	gsn_define_colormap(wks,"MPL_Blues")

	vcres=True
	vcres@gsnDraw=False
	vcres@gsnFrame=False

	vcres@vfXCStartV=20.
	vcres@vfXCEndV  =160.
	vcres@vfYCStartV=-10.
	vcres@vfYCEndV  =60.

	vcres@mpMinLonF=20.
	vcres@mpMaxLonF=160.
	vcres@mpMinLatF=-10.
	vcres@mpMaxLatF=60.
	vcres@mpLimitMode="LatLon"
	vcres@mpCenterLonF=180.

	vcres@gsnMaximize=True
	vcres@gsnAddCyclic=False
	vcres@gsnPaperOrientation="portrait"

;	vcres@mpDataBaseVersion="MediumRes"
;	vcres@mpDataSetName="Earth..4"
	
	vcres@vcGlyphStyle="LineArrow"
	vcres@vcLineArrowThicknessF=2.0
;	vcres@vcRefMagnitudeF=300.
	vcres@vcRefLengthF=0.045
	vcres@vcMinDistanceF=0.017
	vcres@vcVectorDrawOrder="PostDraw"
	
	vcres@gsnLeftString=""
	vcres@gsnRightString=""

	vcres@cnFillOn=True
	vcres@cnLinesOn=False
	vcres@cnLineLabelsOn=False
	vcres@gsnScalarContour=True

	vcres@mpFillOn=False
	vcres@mpPerimOn=True

	map=gsn_csm_vector_scalar_map(wks,qu(0,{-10:60},{20:160}),qv(0,{-10:60},{20:160}),wind(0,{-10:60},{20:160}),vcres)
;	mapa=gsn_csm_contour_map(wks,wind(0,:,:),False)
;	map=gsn_csm_vector_scalar_map(wks,quclm(0,:,:),qvclm(0,:,:),wind(0,:,:),vcres)

	cnres=True
	cnres@gsnDraw=False
	cnres@gsnFrame=False
	cnres@gsnLeftString=""
	cnres@gsnRightString=""

	cnres@sfXCStartV=20.
	cnres@sfXCEndV=160.
	cnres@sfYCStartV=-10.
	cnres@sfYCEndV=60.

	cnres@gsnMaximize=True
	cnres@gsnAddCyclic=False                                                                                                                    
	cnres@gsnPaperOrientation="portrait"   

	cnres@cnLineThicknessF=3.
	cnres@cnLineLabelsOn=False
	cnres@cnInfoLabelOn=False
;	cnres@gsnContourNegLineDashPattern=11

	map3=gsn_csm_contour(wks,sf(0,{-10:60},{20:160}),cnres)
;	map3=gsn_csm_contour(wks,sfclm(0,:,:),cnres) 
	
	tpres=True
	tpres@gsnDraw=False		;  Both plots should be set not to draw and frame
	tpres@gsnFrame=False
	tpres@gsnLeftString=""
	tpres@gsnRightString=""


	tpres@sfXCStartV=20.
	tpres@sfXCEndV=160.
	tpres@sfYCStartV=-10.
	tpres@sfYCEndV=60.

;	tpres@mpMinLonF=30.
;	tpres@mpMaxLonF=160.
;	tpres@mpMinLatF=-10.
;	tpres@mpMaxLatF=60.
;	tpres@mpLimitMode="LatLon"
;	tpres@mpCenterLonF=180.

	tpres@cnLineLabelsOn=False
	tpres@cnInfoLabelOn=False
	tpres@cnLevelSelectionMode="ExplicitLevels"
	tpres@cnLevels=(/1500./)
	tpres@cnLineThicknessF=2.0

	tpres@gsnMaximize=True
	tpres@gsnAddCyclic=False
	tpres@gsnPaperOrientation="portrait"
	
	tpres@tiMainFontHeightF=0.015
	tpres@tiMainString="Vertical Integration of Vapor Transport in summer(climatology)" 

	map2=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
;	map2=gsn_csm_contour(wks,z(:,:),tpres) 
	overlay(map,map3)
	overlay(map,map2)
	draw(map)
	frame(wks)

	nmos=ntime	; Of course, this is the same as previously defined
	do nmo=1,nmos-1
		month=nmo+1
		vcres@tiMainString="Vertical Integration of Vapor Transport on "+month+"th  month (climatology)"
		vcres@tiMainFontHeightF=0.015

		map=gsn_csm_vector_scalar_map(wks,qu(nmo,{-10:60},{20:160}),qv(nmo,{-10:60},{20:160}),wind(nmo,{-10:60},{20:160}),vcres)
		map2=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
;		map=gsn_csm_vector_scalar_map(wks,quclm(nmo,:,:),qvclm(nmo,:,:),wind(nmo,:,:),vcres)
		map3=gsn_csm_contour(wks,sf(nmo,{-10:60},{20:160}),cnres)
;		map3=gsn_csm_contour(wks,sfclm(nmo,:,:),cnres)
;		map2=gsn_csm_contour(wks,z(:,:),tpres)
		overlay(map,map3)
		overlay(map,map2)

		draw(map)
		frame(wks)
	end do

	delete(z)
	delete(qu)
	delete(qv)
	delete(sf)
	delete(wind)

end
