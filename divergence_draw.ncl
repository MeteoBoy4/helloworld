; Program:
;	Draw the vertical integration of qflux on time scale of monthly mean, coupled with qflux_vint_div_calc.ncl
;	The data is from vint_qflux_div.nc
; History:
;	2014/10/31 MeteoBoy4 First Realses: annually averaged, with TP isogopotential line

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;-----Read the data from ncfile and some other support data
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim/1985-2014_ALEV"
	dirbac="/run/media/MeteoBoy4/Data/MData/ERA-Interim/Surface_GeoP"
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	system("rm -f qflux_vint_div.eps")
	qfile=addfile(dirvar+"/vidmf/drought/drought_summerwhole_anomlies.nc","r")
	ofile=addfile(dirbac+"/Surface_GeoP.nc","r")
	div=qfile->vidmf(:,:,:)
	z=short2flt(ofile->z(0,:,:))
	lsdata=maskf->LSMASK
	dims=dimsizes(div)
	ntime=dims(0)
	nlat=dims(1)
	nlon=dims(2)
	lat=div&latitude
	lon=div&longitude

;------Set for orography and masking the ocean
	z=z/9.80665
	lsm=landsea_mask(lsdata,z&latitude,z&longitude)
	z=mask(z,lsm.eq.0,False)

;------Set up the map and plot
	wks=gsn_open_wks("ps","qflux_vint_div")
	
	gsn_define_colormap(wks,"temp_diff_18lev")

	cnres=True
	cnres@gsnDraw=False
	cnres@gsnFrame=False

	cnres@sfXCStartV=30.
	cnres@sfXCEndV  =160.
	cnres@sfYCStartV=-10.
	cnres@sfYCEndV  =60.

	cnres@mpMinLonF=30.
	cnres@mpMaxLonF=160.
	cnres@mpMinLatF=-10.
	cnres@mpMaxLatF=60.
	
	cnres@gsnMaximize=True
	cnres@gsnAddCyclic=False
	cnres@gsnPaperOrientation="portrait"
	cnres@mpDataBaseVersion="MediumRes"
	cnres@mpDataSetName="Earth..4"

	cnres@gsnLeftString=""
	cnres@gsnRightString="10~S~-5~N~kg m~S~-2~N~s~S~-1"
	
	cnres@cnLinesOn=False
	cnres@cnFillOn=True
	cnres@gsnSpreadColors=True

;	cnres@cnLevelSelectionMode="ExplicitLevels"
;	cnres@cnLevels=(/-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,2,4,6,8,10,12,14,16,18/)
	symMinMaxPlt(div(0,{-10:60},{30:160})*100000,30,False,cnres)

	map=gsn_csm_contour_map(wks,div(0,{-10:60},{30:160})*100000,cnres)
	
	tpres=True
	tpres@gsnDraw=False		;  Both plots should be set not to draw and frame
	tpres@gsnFrame=False
	tpres@gsnLeftString=""
	tpres@gsnRightString=""
	
	tpres@sfXCStartV=30.
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
	tpres@tiMainString="The Divergence of Vertical Integration of Vapor Transport on 1th month (climatology)"

	map2=gsn_csm_contour(wks,z({-10:60},{30:160}),tpres)
	overlay(map,map2)
	draw(map)
	frame(wks)

	nmos=ntime	; Of course, this is the same as previously defined
	do nmo=1,nmos-1
		month=nmo+1
		cnres@tiMainString="The Divergence of Vertical Integration of Vapor Transport on "+month+"th  month (climatology)"
		cnres@tiMainFontHeightF=0.015
		symMinMaxPlt(div(nmo,{-10:60},{30:160})*100000,30,False,cnres)

		map=gsn_csm_contour_map(wks,div(nmo,{-10:60},{30:160})*100000,cnres)
		map2=gsn_csm_contour(wks,z({-10:60},{30:160}),tpres)
		overlay(map,map2)

		draw(map)
		frame(wks)
	end do

	delete(z)
	delete(div)

end
