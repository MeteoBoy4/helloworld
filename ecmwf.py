#! /home/meteoboy4/anaconda/bin/python
from ecmwfapi import ECMWFDataServer

#Make a list containing the desired year to download and parsing the filename later
year=["1985"]
for iyear in range(29):
    iyear=iyear+1
    year.append(str(int(year[0])+iyear))
print(year)

server=ECMWFDataServer()
for iyear in range(len(year)):
    server.retrieve({
    	'stream'	:	"oper",
    	'param'		:	"131.128",
    	'dataset'	:	"interim",
    	'step'		:	"0",
    	'grid'		:	"1.0/1.0",
    	'levelist'	:	"300",
    	'levtype'	:	"pl",
    	'time'		:	"00/06/12/18",
    	'date'		:	year[iyear]+"-01-01/to/"+year[iyear]+"-12-31",
    	'expver'	:	"1",
    	'type'		:	"an",
    	'class'		:	"ei",
    	'format'	:	"netcdf",
    	'target'	:	"/run/media/MeteoBoy4/Data/MData/ERA-Interim/1985-2014_ALEV/Daily4/U_wind_component/300hpa/"+year[iyear]+".nc"
    })
