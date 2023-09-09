#!/bin/bash

host=$1

domain_enum(){
    for domain in $(cat $host);
    do
        mkdir -p Recon/$domain Recon/$domain/sources
        subfinder -d $domain -o Recon/$domain/sources/subfinder.txt
        assetfinder -subs-only $domain | tee Recon/$domain/sources/domain.txt
        amass enum -passive -d $domain -o  Recon/$domain/sources/passive.txt
        findomain -t $domain -q | tee -a Recon/$domain/sources/findomain.txt
        cat Recon/$domain/sources/*.txt | tee -a Recon/$domain/sources/tmp.txt
        cat Recon/$domain/sources/tmp.txt | sort -u >> Recon/$domain/sources/all.txt
        rm Recon/$domain/sources/tmp.txt
        rm Recon/$domain/sources/subfinder.txt
        rm Recon/$domain/sources/passive.txt
        rm Recon/$domain/sources/findomain.txt
        rm Recon/$domain/sources/domain.txt
    done
}

portscan(){
    for domain in $(cat $host);
    do
        naabu -list Recon/$domain/sources/all.txt -p 1-65535 -silent | tee -a Recon/$domain/ports.txt
    done
}

alive1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/sources/all.txt | httpx -o Recon/$domain/aliv1.txt
        cat Recon/$domain/sources/all.txt | httprobe -p http:81 -p http:3000 -p https:3000 -p http:3001 -p https:3001 -p http:8000 -p http:8080 -p https:8443 -p https:10000 -p http:9000 -p https:9443 -c 100 | tee -a Recon/$domain/aliv2.txt
        cat Recon/$domain/ports.txt | httpx -o Recon/$domain/aliv3.txt
        cat Recon/$domain/ports.txt | httprobe -c 100 | tee -a Recon/$domain/aliv4.txt
    done
}

sorting1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/aliv*.txt | sort -u | tee -a Recon/$domain/aliv.txt
        rm -rf Recon/$domain/aliv1.txt
        rm -rf Recon/$domain/aliv2.txt
        rm -rf Recon/$domain/aliv3.txt
        rm -rf Recon/$domain/aliv4.txt
    done
}

0day(){
    cat Recon/$domain/aliv.txt | nuclei -t nuclei_templates/ --silent -o Recon/$domain/0day.txt
}

domain_enum
#portscan
alive1
sorting1
0day
