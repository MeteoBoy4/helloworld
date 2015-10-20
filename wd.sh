#!/usr/bin/bash
#Program:
#	Mount the WD Elements external disk by script
#Histroy:
#	2015/10/20 MeteoBoy4 First Release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

WDPATH=/run/media/MeteoBoy4/Elements

[ -e $WDPATH ]||sudo mkdir $WDPATH

sudo mount -t ntfs-3g /dev/sdb1 $WDPATH
