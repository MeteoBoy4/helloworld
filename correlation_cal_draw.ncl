; Program:
 ;	This NCL script calculate the correlation between vectical integration of qflux and precipitation in Meiyu region
; History:
 ;;	2014/12/29 MeteoBoy4 First Release
; 	2015/1/28  MeteoBoy4 Minor Modification: Longer time arrge

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;----Read the data from ncfile and some other support data
	dirvar1="/run/media/MeteoBoy4/Data/MData/ERA-Interim"
	dirvar2="/run/media/MeteoBoy4/Data/MData/NOAA/PREC/L"
	dirbac="/run/media/MeteoBoy4/Data/MData/ERA-Interim/Surface_GeoP"
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	ofile=addfile(dirbac+"/Surface_GeoP.nc","r")
	file1=addfile(dirvar1+"/1985-2014_ALEV/Monthly/Calculation/vint_qflux_sepa_vector_summer.nc","r")
	file2=addfile(dirvar2+"/precip.mon.mean.1x1.nc","r")
	qv=file1->rov(:,:,:)
	qu=file1->rou(:,:,:)
	precip=file2->precip(444:803,:,:) ;time arranges from 1985:1~2014:12
	z=short2flt(ofile->z(0,:,:))
	lsdata=maskf->LSMASK
	dims=dimsizes(qv); Pay attention that file1's lon lat is 1,2,3 while in file2 it's 0.5,1.5,2.5, use file1's coordinate to draw
	ntime=dims(0)
	nlat=dims(1)
	nlon=dims(2)
	latitude=file1->latitude
	longitude=file1->longitude
	year=ntime
	system("rm -f qv_prec_summer.ps")
	system("rm -f qu_prec_summer.ps")

;------Set for orography and masking the ocean
	z=z/9.80665
	lsm=landsea_mask(lsdata,z&latitude,z&longitude)
	z=mask(z,lsm.eq.0,False)
			

;------Calculate the total sum of preciptation in Meiyu Region in summer
	sumrain=new((/year/),typeof(precip),precip@_FillValue)
	nmos=12
	do i=0,dimsizes(sumrain)-1
		sumrain(i)=sum((/precip((5+i*12),{28:34},{110:125})*30.,precip((6+i*12),{28:34},{110:125})*31.,precip((7+i*12),{28:34},{110:125})*31./))  ; total summer rain units:mm
	end do
	sumrain=sumrain/90.
	print(sumrain)
	
;------Calculate the correlation between precip and qflux in chosen month	
	ccrv=qv(0,:,:)
	ccrv=escorc(sumrain,qv(latitude|:,longitude|:,time|:))
	
	ccru=qu(0,:,:)
	ccru=escorc(sumrain,qu(latitude|:,longitude|:,time|:)) 
	
	Po=qu(0,:,:)
	P=qu(0,:,:)
	PoPo=qv(0,:,:)
	PP=qv(0,:,:)
	Po=rtest(ccru,30,0)
	P=where(Po.lt.0.1,1,0)
	PoPo=rtest(ccrv,30,0)
	PP=where(PoPo.lt.0.1,1,0)

;-------t distribtion test
;	t=ccrv
;	P=ccrv
;	t=ccrv*sqrt((year-2)/(1-ccrv*ccrv))
;	df=year-2
;	P=student_t(t,df)
;	print(P)

;------Draw the coorelation map
	wks=gsn_open_wks("ps","qv_prec_summer")
	wks2=gsn_open_wks("ps","qu_prec_summer")

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
;	cnres@mpDataBaseVersion="MediumRes"
;	cnres@mpDataSetName="Earth..4"
	cnres@mpFillOn=False

;	cnres@cnLevelSpacingF=0.25
	cnres@lbLabelBarOn=False
	cnres@cnInfoLabelOn=False

	cnres@cnLinesOn=False
	cnres@cnLineLabelsOn=True
	cnres@cnLineLabelPlacementMode="Computed"
	cnres@cnLineLabelDensityF=0.5
	cnres@cnLineLabelAngleF=0.
	cnres@cnLineLabelBackgroundColor=-1
	cnres@cnLineLabelFontHeightF=0.008
	cnres@cnLineLabelFormat="0@;*.1f"
;	cnres@cnFillOn=True
;	cnres@cnMonoFillColor=True
;	cnres@cnMonoFillPattern=True
;	cnres@cnFillColor="gray52"
;	cnres@cnLineThicknesses=0.005

	cnres@gsnLeftString=""
	cnres@gsnRightString=""

;	cnres@lbLabelBarOn=TrueA
	cnres@gsnContourZeroLineThicknessF=1.5
	cnres@gsnContourNegLineDashPattern=2
;	cnres@gsnContourZeroLineThicknessF=2.

;	cnres@cnLevelSelectionMode="ManualLevels"
;	cnres@cnMinLevelValF=0.5
;	cnres@cnMaxLevelValF=1.5
;	cnres@cnLevelSpacingF=0.3

;	cnres@cnLineLabelAngleF=0.
	
	ha=gsn_csm_contour_map(wks,PP({-10:60},{20:160}),cnres)
	haha=gsn_csm_contour_map(wks2,P({-10:60},{20:160}),cnres)
        cnres@cnLinesOn=True 
	cnres@cnLevelSpacingF=0.1
;	ha=gsn_csm_contour_map(wks,PP({-10:60},{20:160}),cnres)
	coco=gsn_csm_contour(wks,ccrv({-10:60},{20:160}),cnres)
	cnres@gsnLeftString=""
	cnres@gsnRightString=""
;	haha=gsn_csm_contour_map(wks2,P({-10:60},{20:160}),cnres)   
	co=gsn_csm_contour(wks2,ccru({-10:60},{20:160}),cnres)
	
	opt=True
	opt@gsnShadeFillType="color"
	opt@gsnShadeHigh="gray52"
	haha=gsn_contour_shade(haha,-999,0.8,opt)
	ha=gsn_contour_shade(ha,-999,0.8,opt)
	
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
	tpres@cnLineLabelsOn=False
	tpres@cnLevelSelectionMode="ExplicitLevels"
	tpres@cnLevels=(/1500./)
	tpres@cnLineThicknessF=2.0

	tpres@gsnMaximize=True
	tpres@gsnAddCyclic=False
	tpres@gsnPaperOrientation="portrait"

	map2=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
	map22=gsn_csm_contour(wks2,z({-10:60},{20:160}),tpres)
	overlay(ha,coco)
	overlay(ha,map2)
	overlay(haha,co)
	overlay(haha,map22)
	draw(ha)
	draw(haha)
	frame(wks)
	frame(wks2)

	delete(qv)
	delete(qu)
	delete(precip)
end 

