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
        subfinder -d $domain -all -o Recon/$domain/sources/subfinder.txt
        assetfinder -subs-only $domain | tee Recon/$domain/sources/domain.txt
        amass enum -passive -d $domain | cut -d " " -f 1 | grep -i  $domain | sort -u|grep -v "The enumeration has finished"|tee -a Recon/$domain/sources/passive.txt
        findomain -t $domain -q | tee -a Recon/$domain/sources/findomain.txt
	github-subdomains -d $domain -t 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,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,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 -o Recon/$domain/sources/github.txt
        cat Recon/$domain/sources/*.txt | tee -a Recon/$domain/sources/tmp.txt
        cat Recon/$domain/sources/tmp.txt | sort -u >> Recon/$domain/sources/all.txt
        rm Recon/$domain/sources/tmp.txt
        rm Recon/$domain/sources/subfinder.txt
        rm Recon/$domain/sources/passive.txt
        rm Recon/$domain/sources/findomain.txt
        rm Recon/$domain/sources/domain.txt
	rm Recon/$domain/sources/github.txt
 	notify -data Recon/$domain/sources/all.txt -bulk -provider telegram
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

record(){
	for domain in $(cat $host);
	do
		for i in $(cat Recon/$domain/final.txt);do dig $i +noquestion +noauthority +noadditional +nostats | grep -wE "CNAME|A|AAAA" | tee -a Recon/$domain/records.txt;done
		cat Recon/$domain/records.txt | awk '{print $1}' | sed 's/\.$//'|sort -u| tee -a Recon/$domain/record_sub.txt
  		notify -data Recon/$domain/records.txt -bulk -provider telegram
	done
}

portscan(){
	for domain in $(cat $host);
	do
		rustscan -a Recon/$domain/record_sub.txt -r 1-65535 --ulimit 10000|tee -a Recon/$domain/rust.txt
  		cat Recon/$domain/rust.txt|grep Open|sed 's/Open //'|tee -a Recon/$domain/ports.txt
    		notify -data Recon/$domain/rust.txt -bulk -provider telegram
	done
}

alive1(){
    for domain in $(cat $host);
    do
        cat Recon/$domain/record_sub.txt | httpx -o Recon/$domain/aliv1.txt
        cat Recon/$domain/record_sub.txt | httprobe -p http:81 -p http:3000 -p https:3000 -p http:3001 -p https:3001 -p http:8000 -p http:8080 -p https:8443 -p https:10000 -p http:9000 -p https:9443 -c 100 | tee -a Recon/$domain/aliv2.txt
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
	notify -data Recon/$domain/aliv.txt -bulk -provider telegram
    done
}

dns_zone(){
	for domain in $(cat $host);
	do
		for i in $(cat Recon/$domain/final.txt);do dig $i +noquestion +noauthority +noadditional +nostats NS| grep -wE "NS" | tee -a Recon/$domain/ns_record.txt;done
		for i in $(cat Recon/$domain/final.txt); do dig $i +noquestion +noauthority +noadditional +nostats NS | awk '/NS/{print $NF}' | sed 's/\.$//' | sed 's/[^.]*\.//' | tee -a Recon/$domain/ns_domains.txt; done
		for i in $(cat Recon/$domain/ns_domains.txt);do curl -s -S -o /dev/null $i 2>&1 | grep -q 'Could not resolve host' && echo "Vulnerable : $i" | tee -a Recon/$domain/zone_takeover.txt;done
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
  		notify -data Recon/$domain/nuclei.txt -bulk -provider telegram
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
	notify -data Recon/$domain/urls.txt -bulk -provider telegram
    done
}

resolvers
domain_enum
bruteforce
permute
record
portscan
alive1
sorting1
#dns_zone
nuclei_all
urls
