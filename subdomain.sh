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
        rm Recon/$domain/sources/subfinder.txt
        rm Recon/$domain/sources/passive.txt
        rm Recon/$domain/sources/findomain.txt
        rm Recon/$domain/sources/domain.txt
    done
}

bruteforce(){
    for domain in $(cat $host);
    do
        puredns bruteforce sub_wordlistaa.txt $domain --resolvers Recon/resolvers.txt --rate-limit 50 --wildcard-tests 5 --write-wildcards Recon/$domain/sources/wildcards1.txt -q | tee -a Recon/$domain/sources/pure1.txt
        sleep 300
        puredns bruteforce sub_wordlistab.txt $domain --resolvers Recon/resolvers.txt --rate-limit 50 --wildcard-tests 5 --write-wildcards Recon/$domain/sources/wildcards2.txt -q | tee -a Recon/$domain/sources/pure2.txt
        sleep 300
        puredns bruteforce sub_wordlistac.txt $domain --resolvers Recon/resolvers.txt --rate-limit 50 --wildcard-tests 5 --write-wildcards Recon/$domain/sources/wildcards3.txt -q | tee -a Recon/$domain/sources/pure3.txt
        cat Recon/$domain/sources/*.txt | sort -u | tee -a Recon/$domain/sources/final1.txt
        rm Recon/$domain/sources/all.txt
        rm Recon/$domain/sources/pure1.txt
        rm Recon/$domain/sources/pure2.txt
        rm Recon/$domain/sources/pure3.txt
    done
}

permute(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/sources/final1.txt | dnsgen -w permute_wordlist.txt - | tee -a Recon/$domain/sources/permute.txt
        cat Recon/$domain/sources/*.txt | sort -u| tee -a Recon/$domain/final.txt
        rm Recon/$domain/sources/permute.txt
    done
}

portscan(){
    for domain in $(cat $host);
    do
        naabu -list Recon/$domain/final.txt -p 1-65535 -silent | tee -a Recon/$domain/ports.txt
    done
}

alive1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/ports.txt | httpx -o Recon/$domain/aliv1.txt
        cat Recon/$domain/ports.txt | httprobe -c 100 | tee -a Recon/$domain/aliv2.txt
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

nuclei_all(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/aliv.txt | nuclei -t ~/nuclei-templates/ -rl 100 --silent | tee -a Recon/$domain/nuclei1.txt
        cat Recon/$domain/aliv.txt | nuclei -t nuclei_templates/ -rl 100 --silent | tee -a Recon/$domain/nuclei2.txt
        cat Recon/$domain/nuclei*.txt | sort -u | tee -a Recon/$domain/nuclei.txt
        rm Recon/$domain/nuclei1.txt
        rm Recon/$domain/nuclei2.txt
    done
}

resolvers
domain_enum
bruteforce
permute
portscan
alive1
sorting1
nuclei_all