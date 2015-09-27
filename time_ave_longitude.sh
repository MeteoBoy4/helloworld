#!/usr/bin/bash
#Program:
# 	Do time averaging on every month and concatenate them together
# Histroy:
# 	2015/9/17 MeteoBoy4 First release
#	2015/9/26 MeteoBoy4 Add the whole directory making, averaging, hovmuller ready, flooding and drought analysis
#			    into a single bash script

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo -e "Warning: If the netCDF file's name is two characters long, the program will give wrong answers!"

# Make the directory
[ -e $2 ]||mkdir $2
echo -e "Object Directory made!"

#Unpack the packed data and go into the right directory
ncpdq -O -P unpack $1 "$1".tmp
mv "$1".tmp $2
cd $2
mv "$1".tmp $1
echo -e "Data have been unpacked!"

#Do monthly averaging on seasonal cycle
for mm in {1..12}
do
	mon=$(printf "%02d" ${mm})
	ncra -O -F -d time,${mon},,12  $1 ${mon}.nc
done

ncrcat -O ??.nc climon.nc 
echo -e "Data have been averaged on seasonal cycle!"

#Make the data fit for hovmueller plot(time vs longitude)
ncwa -O -d latitude,10.,20. -a latitude climon.nc climon_aveocean.nc
ncwa -O -d latitude,27.5,37.5 -a latitude climon.nc climon_aveplateau.nc
echo -e "Hovmueller Ready!"

#Do the same things for flooding years
[ -e ./flood ]||mkdir ./flood
ncks -O -d time,'1996-01-01','1996-12-01' $1 ./flood/1996.nc
ncks -O -d time,'1998-01-01','1998-12-01' $1 ./flood/1998.nc
ncks -O -d time,'1999-01-01','1999-12-01' $1 ./flood/1999.nc
nces -O ./flood/1996.nc ./flood/1998.nc ./flood/1999.nc ./flood/flood.nc
ncbo -O ./flood/flood.nc climon.nc ./flood/flood_anomlies.nc
ncwa -O -d latitude,27.5,37.5 -a latitude ./flood/flood_anomlies.nc ./flood/flood_anomlies_aveplateau.nc
ncwa -O -d latitude,10.,20. -a latitude ./flood/flood_anomlies.nc ./flood/flood_anomlies_aveocean.nc
echo -e "Flooding years Ready!"

#Do the same things for drought years
[ -e ./drought ]||mkdir ./drought
ncks -O -d time,'1985-01-01','1985-12-01' $1 ./drought/1985.nc
ncks -O -d time,'1988-01-01','1988-12-01' $1 ./drought/1988.nc
ncks -O -d time,'1990-01-01','1990-12-01' $1 ./drought/1990.nc
ncks -O -d time,'2001-01-01','2001-12-01' $1 ./drought/2001.nc
ncks -O -d time,'2013-01-01','2013-12-01' $1 ./drought/2013.nc
nces -O ./drought/1985.nc ./drought/1988.nc ./drought/1990.nc ./drought/2001.nc ./drought/2013.nc ./drought/drought.nc
ncbo -O ./drought/drought.nc climon.nc ./drought/drought_anomlies.nc
ncwa -O -d latitude,27.5,37.5 -a latitude ./drought/drought_anomlies.nc ./drought/drought_anomlies_aveplateau.nc
ncwa -O -d latitude,10.,20. -a latitude ./drought/drought_anomlies.nc ./drought/drought_anomlies_aveocean.nc
echo -e "Drought years Ready!"

exit 0
