#!/usr/bin/bash
#Program:
# 	Do time averaging on every month and concatenate them together
# Histroy:
# 	2015/9/17 MeteoBoy4 First release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

for mm in {1..12}
do
	mon=$(printf "%02d" ${mm})
	ncra -O -F -d time,${mon},,12 ERA_isshf_85-14.nc ERA_isshf_85-14_${mon}.nc
done

ncrcat -O ERA_isshf_85-14_??.nc ERA_isshf_85-14_climon.nc 
