; Program:
; 	Draw streamline of 

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;------------Read the data in file
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim"
	dirbac="/run/media/MeteoBoy4/Data/MData/ERA-Interim/Surface_GeoP"
	ufile=addfile(dirvar+"/2013/Wind/daily/u850daily.nc","r")
	vfile=addfile(dirvar+"/2013/Wind/daily/v850daily.nc","r")
	ofile=addfile(dirbac+"/Surface_GeoP.nc","r")
	maskf=addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
	u=ufile->u
	v=vfile->v
	z=short2flt(ofile->z(0,:,:))
	lsdata=maskf->LSMASK
	pStrt=20130825
	daySkip=1
;	day=day_of_year(2013,05,01)
	
;------Set for orography and masking the ocean
	z=z/9.80665
	u=mask(u,z.gt.1500.,False)
	v=mask(v,z.gt.1500.,False)
	lsm=landsea_mask(lsdata,z&latitude,z&longitude)
	z=mask(z,lsm.eq.0,False)

;------------Create new date array for use on the plot
	date=cd_calendar(u&time,-2)
	yrfrac=yyyymmdd_to_yyyyfrac(date,0)

	iStrt=ind(date.eq.pStrt)

;-------Draw the streamline plot
	plot=new(8,"graphic")
	wks=gsn_open_wks("ps","streamline")

	restr=True
	restr@gsnDraw=False
	restr@gsnFrame=False

	restr@vfXCStartV=20.
	restr@vfXCEndV  =160.
	restr@vfYCStartV=-10.
	restr@vfYCEndV  =60.

	restr@mpMinLonF=20.
	restr@mpMaxLonF=160.
	restr@mpMinLatF=-10.
	restr@mpMaxLatF=60.

	restr@stMinArrowSpacingF=0.005
	restr@stMinLineSpacingF=0.005

	restr@gsnMaximize=True
	restr@gsnAddCyclic=False
	restr@gsnPaperOrientation="portrait"

	restr@gsnLeftString=""
	
	restr@mpFillOn=False
	restr@mpPerimOn=True
	
;	reswb=True

;	reswb@gsnDraw=False
;	reswb@gsnFrame=False
;
;	reswb@vfXCStartV=20.
;	reswb@vfXCEndV  =160.
;	reswb@vfYCStartV=-10.
;	reswb@vfYCEndV  =60.
;
;	reswb@vcRefMagnitudeF=16.
;	reswb@vcRefLengthF=0.03
;	reswb@vcGlyphStyle="WindBarb"
;	reswb@vcMinDistanceF=0.025
;	reswb@vcRefAnnoOn=False
;
;	reswb@gsnAddCyclic=False

;	plot2=gsn_csm_vector(wks,u(day-1,{-10:60},{20:160}),v(day-1,{-10:60},{20:160}),reswb)

;	overlay(plot,plot2)

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
	tpres@cnMonoLineDashPattern=True
	tpres@cnLineDashPattern=1	

	tpres@gsnMaximize=True
	tpres@gsnAddCyclic=False
	tpres@gsnPaperOrientation="portrait"
	
	tpres@tiMainFontHeightF=0.015

	do nt=0,7
		restr@gsnRightString=date(iStrt+daySkip*nt)
		plot(nt)=gsn_csm_streamline_map(wks,u(iStrt+daySkip*nt,{-10:60},{20:160}),v(iStrt+daySkip*nt,{-10:60},{20:160}),restr)
		orography=gsn_csm_contour(wks,z({-10:60},{20:160}),tpres)
		overlay(plot(nt),orography)
	end do

	resP=True
	resP@txString="Streamline on 850hpa"
	gsn_panel(wks,plot,(/4,2/),resP)


;	draw(plot)
;	frame(wks)

	delete(u)
	delete(v)
	delete(z)



end

