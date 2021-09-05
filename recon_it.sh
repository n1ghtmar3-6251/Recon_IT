#!/bin/bash

host=$1
resolvers(){
    rm -rf resolvers.txt
    dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o resolvers.txt &>/dev/null
}
resolvers
domain_enum(){
for domain in $(cat $host);
do
    mkdir -p Recon Recon/$domain Recon/$domain/sources
    subfinder -d $domain -o Recon/$domain/sources/subfinder.txt
    assetfinder -subs-only $domain | tee Recon/$domain/sources/domain.txt
    amass enum -passive -d $domain -o  Recon/$domain/sources/passive.txt
    cat Recon/$domain/sources/*.txt | tee -a Recon/$domain/sources/tmp.txt
    cat Recon/$domain/sources/tmp.txt | sort -u >> Recon/$domain/sources/all.txt
    rm Recon/$domain/sources/tmp.txt
done
}
domain_enum
bruteforce(){
	for i in $(cat Recon/$domain/sources/all.txt); do puredns bruteforce all.txt $i --resolvers resolvers.txt -q | tee -a Recon/$domain/sources/pure.txt;done
	cat Recon/$domain/sources/*.txt | sort -u | tee -a Recon/$domain/sources/final.txt
}
bruteforce
