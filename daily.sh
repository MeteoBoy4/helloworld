#!/usr/bin/bash
#Program:
#	Daily averaging from 4 times a daily

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

filelist=$(ls *.nc)

for file in $filelist
do 
	ncra -O --mro -F -d time,1,,4,4 $file daily_$file
	echo -e $file" Done!"
done

exit 0
