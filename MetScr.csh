#!/bin/bash
module load apps/cdo
#read -p "Enter NetCDF File Path: " NCfile
#read -p "Enter variable list Path: " varList
#read -p "Enter Coordinates List Path: " lat_lon1
#read -p "Enter prefix String : " prefix
NCfile="ERAforcing_2003-2006.nc"
varList="varlist"
lat_lon1="l1"
prefix="MetForcing_"
awk '{print $1}' $lat_lon1 > lat
awk '{print $2}' $lat_lon1 > lon
paste -d' ' lat lon > lat_lon
while IFS=' '  read -r latF lonF
do
        str=""
	strrm=""
        echo -e "\e[1;31m Processing lon=$lonF lat=$latF \e[0m"
        eval $"cdo -outputtab,name,value -remapnn,lon=$lonF"$"_lat=$latF $NCfile > temp.log"
	cp temp.log ttemp.log
        while IFS=' ' read -r var
        do
                echo $var
                eval $"cat temp.log | grep -w $var > $var.log.bk"
		sed 's/|/ /' $var.log.bk | awk '{print $2}' > $var.log
	#	eval "cat temp.log | grep -w $var | sed 's/|/ /' $var.log.bk | awk '{print $2}' > $var.log"
	#	while IFS=' ' read -r name value
        #       do
        #        echo $value >> $var".log"
        #        awk 'BEGIN {v='$value'; if(v>-0.0001 && v<0.0001 && v!=0) {str="nan";printf "%10s\n", str} else {printf "%10.5f\n", v}}' >> $var".log"
        #        done < "$var.log.bk"
        str="$str $var.log"
	strrm="$str $var.log $var.log.bk"
        done < "$varList"
        echo $str
        paste -d " " $str > $prefix$latF"_"$lonF
        echo -e "\e[1;32m $prefix$latF $lonF FILE IS CREATED \e[0m"
        rm $strrm
done < lat_lon
echo -e "\e[1;33m FINISHED \e[0m"
