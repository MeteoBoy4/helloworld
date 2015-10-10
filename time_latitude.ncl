;Program:
;	This NCL script draw latitude vs. time Hovmueller plot with nice time axis above
;Histroy:
;	2015/10/23 MeteoBoy4 First Release

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
;-----------------Read the data in file
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim/1985-2014_ALEV/Daily4/U_wind_component/300hpa"
	hfile=addfile(dirvar+"/time_lat/1985pentad.nc","r")
	uold=hfile->u
	time=uold&time
;----------------Reorder the variable for plotting latitude vs time plot
	u=uold(longitude|:,latitude|:,time|:)
		
	mylon=135

;------------------Draw the plot
	wks=gsn_open_wks("ps",tostring(mylon))

	res=True
	res@gsnDraw=False
	res@gsnFrame=False
	res@gsnLeftString=""
	res@gsnRightString=tostring(mylon)+"~S~o"

;----------------Adjust the size and position of the plot
	res@vpXF=0.12
	res@vpYF=0.8
	res@vpWidthF=0.8
	res@vpHeightF=0.4	
	res@gsnPaperOrientation="portrait"
	res@gsnMaximize=True

;----------------Setting the latitude axis label
	res@tmYLMode="Explicit"
	res@tmYLLabelFont=25
	res@tmYLLabelFontHeightF=0.01
	res@tmYLValues=ispan(0,70,10)
	res@tmYLLabels=(/"0","10N","20N","30N","40N","50N","60N","70N"/)


;----------------Put the axis at left and top of the plot, turn off others
	res@tmXUseBottom=False
	res@tmYROn=False
	res@tmXBOn=False
	res@tmXBLabelsOn=False
	res@tmXTOn=True
	res@tmXTLabelsOn=True
	res@tmXTLabelFontHeightF=0.010
	res@tiXAxisString=""

;------------------Contour effect(Negative, zero and angle, spacing)
	res@cnLevelSpacingF=15
	res@gsnContourZeroLineThicknessF=2.
	res@gsnContourNegLineDashPattern=2
	res@cnLineLabelAngleF=0.0

;-------------------Set for nice time axis 
	resTick=True
	resTick@ttmFormat="%d~C~%c"
	resTick@ttmAxis="XT"
	resTick@ttmMajorStride=6
	time_axis_labels(time,res,resTick)

	plot=gsn_csm_lat_time(wks,u({mylon},{0:70},:),res)

;----------------Shade (color) the contour greater than a given number
	opt=True
	opt@gsnShadeFillType="color"
	opt@gsnShadeHigh="gray"
	plot=gsn_contour_shade(plot,-999,30.,opt)
		
	draw(plot)
	frame(wks)



end
