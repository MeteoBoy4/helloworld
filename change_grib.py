import pygrib
import glob
import numpy as N

def readfile(infile):
    grbs=pygrib.open(infile)
    grb=grbs.select(name='Temperature')[0]
    sst, lats, lons = grb.data(lat1=14,lat2=30,lon1=106,lon2=126)
    return sst
    grbs.close()
    
list_of_file=glob.glob("/Users/MeteoBoy4/Downloads/sst/rtg_sst_grb_0.5.*")
sst1=readfile(list_of_file[0])
sst=N.zeros((len(list_of_file),sst1.shape[0],sst1.shape[1]),dtype='d')
i=0
for files in list_of_file:
    sst[i,:,:]=readfile(files)
    i+=1
sst_ave_SCS=sst.mean(axis=0)

grbs=pygrib.open("/Users/MeteoBoy4/Downloads/sst/rtg_sst_grb_0.5.20140508")
grb=grbs.select(name='Temperature')[0]
#grb.__setitem__('values',sst_ave)
sst_ave=grb.values
sst_ave[120:152,210:250]=sst_ave_SCS
print sst_ave[120:152,210:250]-grb.values[120:152,210:250]
grb.values=sst_ave

msg=grb.tostring()
grbs.close()

grbout=open("/Users/MeteoBoy4/Downloads/sst/out.grb",'wb')
grbout.write(msg)
grbout.close()