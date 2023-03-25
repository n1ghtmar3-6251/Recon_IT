#!/bin/bash

host=$1

resolvers(){
    rm -rf Recon/resolvers.txt
    dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o Recon/resolvers.txt &>/dev/null
}

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

bruteforce(){
    for domain in $(cat $host);
    do
        puredns bruteforce /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-110000.txt $domain --resolvers Recon/resolvers.txt --rate-limit 20 -q | tee -a Recon/$domain/sources/pure.txt;
    done
    cat Recon/$domain/sources/*.txt | sort -u | tee -a Recon/$domain/sources/final.txt
    mv Recon/$domain/sources/final.txt Recon/$domain/
}

alive1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/final.txt | httpx -o Recon/$domain/aliv1.txt
        cat Recon/$domain/final.txt | httprobe -p http:81 -p http:3000 -p https:3000 -p http:3001 -p https:3001 -p http:8000 -p http:8080 -p https:8443 -p https:10000 -p http:9000 -p https:9443 -c 50 | tee -a Recon/$domain/aliv2.txt
    done
}

sorting1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/aliv*.txt | sort -u | tee -a Recon/$domain/aliv.txt
        rm -rf Recon/$domain/aliv1.txt
        rm -rf Recon/$domain/aliv2.txt
    done
}

urls(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/aliv.txt | waybackurls | tee -a Recon/$domain/urls1.txt
        cat Recon/$domain/aliv.txt | gau | tee -a Recon/$domain/urls2.txt
        cat Recon/$domain/urls*.txt | sort -u | tee -a Recon/$domain/urls.txt
        rm -rf Recon/$domain/urls1.txt
        rm -rf Recon/$domain/urls2.txt
    done
}

resolvers
domain_enum
bruteforce
alive1
sorting1
urls
