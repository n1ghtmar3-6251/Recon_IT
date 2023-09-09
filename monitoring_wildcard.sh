#!/bin/bash

hackerone(){
	bbscope h1 -t 7StodOBx0A+iQpEwTlKgrYo+PGUdRosftIsgG2GbN0g= -u n1ghtmar3_2421|grep "*."|tee -a monitoring/domains.txt
	domains=$(cat monitoring/domains.txt)
	domains=$(echo "$domains" | sed 's/http:\/\///')
	domains=$(echo "$domains" | sed 's/\/\*.*//')
	domains=$(echo "$domains" | tr ',' '\n')
	domains=$(echo "$domains" | tr '; ' '\n')
	domains=$(echo "$domains" | tr ' ' '\n')
	domains=$(echo "$domains" | sed 's/\*\.\|\[\*\]\.//g')
	echo "$domains"|sort -u|tee -a monitoring/wild_domains.txt
	rm -rf monitoring/domains.txt
}
hackerone

domain_enum(){
while read balsal;
do
    # echo $balsal
    mkdir -p Recon/$balsal Recon/$balsal/sources
    subfinder -d $balsal -o Recon/$balsal/sources/subfinder.txt
    assetfinder -subs-only $balsal | tee Recon/$balsal/sources/domain.txt
    amass enum -passive -d $balsal -o  Recon/$balsal/sources/passive.txt
    findomain -t $balsal -q | tee -a Recon/$balsal/sources/findomain.txt
    cat Recon/$balsal/sources/*.txt | tee -a Recon/$balsal/sources/tmp.txt
    cat Recon/$balsal/sources/tmp.txt | sort -u >> monitoring/all.txt
    rm Recon/$balsal/sources/tmp.txt
done < monitoring/wild_domains.txt
}
domain_enum

sorting(){
    while read balsal;
    do
        cat Recon/$balsal/sources/all.txt| tee -a monitoring/subs.txt
        rm -rf Recon/$balsal
    done < monitoring/wild_domains.txt
}
sorting