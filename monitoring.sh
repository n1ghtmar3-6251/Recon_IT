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
    done
}
domain_enum

sorting(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/sources/all.txt| tee -a monitoring/sub.txt
        rm -rf Recon/$domain
    done
}
