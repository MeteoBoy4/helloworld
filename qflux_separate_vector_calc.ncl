; Program
;	This NCL script uses vertical integration of qflux to calcaluate its divergent and 
;	rotational wind components, and then writes them to netCDF file
; History:
;	i2015/1/29 MeteoBoy4 First Release

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;-------Open file to read	
	dir="/run/media/MeteoBoy4/Data/MData/ERA-Interim"
	system("rm -f "+dir+"/1985-2014_ALEV/Monthly/Calculation/Qflux_500hpa/vint_qflux_sepa_vector.nc")
	efile=addfile(dir+"/1985-2014_ALEV/Monthly/Calculation/Qflux_500hpa/qu.nc","r")
	nfile=addfile(dir+"/1985-2014_ALEV/Monthly/Calculation/Qflux_500hpa/qv.nc","r")
	qu=efile->qu(:,0,::-1,:)  ;Pay attentions to the dimensions !
	qv=nfile->qv(:,0,::-1,:)
	dims=dimsizes(qu)
	ntime=dims(0)
	nlat=dims(1)
	nlon=dims(2)
	latitude=qu&latitude
	longitude=qu&longitude
	time=qu&time
	printVarSummary(qu)
	print("Ready to calculate!")

;--------Calculate the divergent and rotational wind components
	div=uv2dvF_Wrap(qu,qv)
	print("Divergence Done!")
	uvd=dv2uvF_Wrap(div)
	print("Divergent Components Done!")

	uvr=uvd
	uvr(0,:,:,:)=qu-uvd(0,:,:,:)
	uvr(1,:,:,:)=qv-uvd(1,:,:,:) 
	print("Rotational Components Derived!")
	
	sfvp=uvd
	sfvp=uv2sfvpF(qu,qv)
	print("Functions Done!")

	delete(qu)
	delete(qv)

;-------Write the resulats into netCDF file
	system("free")
	fout=addfile(dir+"/1985-2014_ALEV/Monthly/Calculation/Qflux_500hpa/vint_qflux_sepa_vector.nc","c")
	fileAtt=True
	fileAtt@title="The divergent and rotational wind components of vertical integration of qflux on 500hpa"
	fileAtt@Conventions="None"
	fileAtt@creation_date=systemfunc("date")
	setfileoption(fout,"DefineMode",True)
	fileattdef(fout,fileAtt)
	dimNames=(/"time","latitude","longitude"/)
	dimSizes=(/ntime,nlat,nlon/)
	dimUnlim=(/False,False,False/)
	filedimdef(fout,dimNames,dimSizes,dimUnlim)
	filevardef(fout,"time",typeof(time),"time")
	filevardef(fout,"latitude",typeof(latitude),"latitude")
	filevardef(fout,"longitude",typeof(longitude),"longitude")
	filevardef(fout,"diu",typeof(uvd),getvardims(uvd(0,:,:,:)))
	filevardef(fout,"div",typeof(uvd),getvardims(uvd(1,:,:,:)))
	filevardef(fout,"rou",typeof(uvr),getvardims(uvr(0,:,:,:)))
	filevardef(fout,"rov",typeof(uvr),getvardims(uvr(1,:,:,:)))
	filevardef(fout,"sf",typeof(sfvp),getvardims(sfvp(0,:,:,:)))
	filevardef(fout,"vp",typeof(sfvp),getvardims(sfvp(1,:,:,:)))
	filevarattdef(fout,"time",time)
	filevarattdef(fout,"latitude",latitude)
	filevarattdef(fout,"longitude",longitude)
	filevarattdef(fout,"diu",uvd(0,:,:,:))
	filevarattdef(fout,"div",uvd(1,:,:,:))
	filevarattdef(fout,"rou",uvr(0,:,:,:))
	filevarattdef(fout,"rov",uvr(1,:,:,:))
	filevarattdef(fout,"sf",sfvp(0,:,:,:))
	filevarattdef(fout,"vp",sfvp(1,:,:,:))

	fout->time=(/time/)
	fout->latitude=(/latitude/)
	fout->longitude=(/longitude/)
	fout->diu=(/uvd(0,:,:,:)/)
	fout->div=(/uvd(1,:,:,:)/)
	fout->rou=(/uvr(0,:,:,:)/)
	fout->rov=(/uvr(1,:,:,:)/)
	fout->sf=(/sfvp(0,:,:,:)/)
	fout->vp=(/sfvp(1,:,:,:)/)
	print("Written to netCDF format!")

	delete(div)
	delete(uvd)
	delete(uvr)
	delete(sfvp)

end
