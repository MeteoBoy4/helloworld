; Program:
; 	This NCL script draw the climatology of GMPT on monthly time scale
; History:
; 	2015/2/3 MeteoBoy4 First Release

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;------Read the data from ncfile and some other support data
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim"
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	system("rm -f GPT500_clm.ps")
;	system("rm -f "+dirvar+"/1985-2014_ALEV/Calculation/GPT_clm.nc")
	Gfile=addfile(dirvar+"/1985-2014_ALEV/Calculation/GPT/flood/flood_summer_anomlies.nc","r")
	ofile=addfile(dirvar+"/Surface_GeoP/Surface_GeoP.nc","r")
	Gtheta=Gfile->Gtheta
	z=short2flt(ofile->z(0,:,:))
	lsdata=maskf->LSMASK
	dims=dimsizes(Gtheta)
	ntime=dims(0)
	klev=dims(1)
	nlat=dims(2)
	nlon=dims(3)
	system("free")


;------Set for orography and masking the ocean
	z=z/9.80665
	lsm=landsea_mask(lsdata,z&latitude,z&longitude)
	z=mask(z,lsm.eq.0,False)

;------Set up the map
	wks=gsn_open_wks("ps","GPT500_clm")

	cnres=True
	cnres@gsnDraw=False
	cnres@gsnFrame=False

	cnres@sfXCStartV=20.
	cnres@sfXCEndV  =160.
	cnres@sfYCStartV=-10.
	cnres@sfYCEndV  =60.

	cnres@mpMinLonF=20.
	cnres@mpMaxLonF=160.
	cnres@mpMinLatF=-10.
	cnres@mpMaxLatF=60.

	cnres@gsnMaximize=True
	cnres@gsnAddCyclic=False
	cnres@gsnPaperOrientation="portrait"

	cnres@mpDataBaseVersion="MediumRes"
	cnres@mpDataSetName="Earth..4"

	cnres@cnFillOn=True
	cnres@cnLinesOn=True
	cnres@cnLineLabelsOn=True

	cnres@gsnLeftString=""
	cnres@gsnRightString="K"

	symMinMaxPlt(Gtheta(0,{500},{-10:60},{20:160}),20,True,cnres)

	map=gsn_csm_contour_map(wks,Gtheta(0,0,{-10:60},{20:160}),cnres)

	tpres=True
	tpres@gsnDraw=False		;  Both plots should be set not to draw and frame
	tpres@gsnFrame=False
	tpres@gsnLeftString=""
	tpres@gsnRightString=""

	tpres@sfXCStartV=20.
	tpres@sfXCEndV=160.
	tpres@sfYCStartV=-10.
	tpres@sfYCEndV=60.

	tpres@cnLineLabelsOn=False
	tpres@cnInfoLabelOn=False
	tpres@cnLevelSelectionMode="ExplicitLevels"
	tpres@cnLevels=(/1500./)
	tpres@cnLineThicknessF=2.0

	tpres@gsnMaximize=True
	tpres@gsnAddCyclic=False
	tpres@gsnPaperOrientation="portrait"
			
	tpres@tiMainFontHeightF=0.015
	tpres@tiMainString="Generalized Potential Temperature on 500hPa in 1 month (climatology)" 

	map2=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
	overlay(map,map2)
	draw(map)
	frame(wks)

	nmos=ntime
	do nmo=1,nmos-1
		month=nmo+1
		cnres@tiMainString="Generalized Potential Temperature on 500hPa in "+month+"th month (climatology)"
		cnres@tiMainFontHeightF=0.015
		symMinMaxPlt(Gtheta(nmo,{500},{-10:60},{20:160}),20,True,cnres)

		map=gsn_csm_contour_map(wks,Gtheta(nmo,{500},{-10:60},{20:160}),cnres)
		map2=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
		overlay(map,map2)

		draw(map)
		frame(wks)
	end do

	delete(Gtheta)

end
