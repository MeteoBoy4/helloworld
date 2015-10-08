;Program:
;	This NCL script draw the time vs. longitude (Hovmueller) plot by climatology of 12 months in a year
;History:
;	2015/9/21 MeteoBoy4 First Release

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;-------------------Read the data in file
	dirvar="/run/media/MeteoBoy4/Data/MData/ERA-Interim/1985-2014_ALEV"
	hfile=addfile(dirvar+"/vite/flood/flood_anomlies_aveplateau.nc","r")
	ishf=hfile->vite

;--------------------Crete the plot
	wks=gsn_open_wks("ps","hov")
;	gsn_define_colormap(wks,"MPL_YlOrRd")
	
	res=True
	res@cnFillOn=True
	res@cnLineLabelsOn=False
	res@cnLinesOn=False
;	res@gsnDraw=False
;	res@gsnFrame=False
	res@tiMainString="27.5-37.5~S~o~N~N"
	res@trYReverse=True
;	res@cnLineLabelAngleF=0.0

;--------Define own tick marks lables
	res@tmYLMode="Explicit"
	res@tmYLLabelFont=25
	res@tmYLLabelFontHeightF=0.015
	res@tmYLValues=ishf&time
	res@tmYLLabels=(/"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"/)

;	res@cnLevelSelectionMode="ExplicitLevels"
;	res@cnLevels=(/-10,-8,-6,-4,-2,0,2,4,6,8,10/)
	symMinMaxPlt(ishf(:,{0:180}),20,False,res)

	plot=gsn_csm_hov(wks,ishf(:,{0:180}),res)
	
;--------Shade (color) the contour greater than a given number
;	opt=True
;	opt@gsnShadeFillType="color"
;	opt@gsnShadeHigh="black"
;	plot=gsn_contour_shade(plot,-999,40.,opt)
	
;	draw(plot)
;	frame(wks)

end
