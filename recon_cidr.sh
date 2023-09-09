#!/bin/bash

host=$1

cidr_to_ip(){
    mkdir -p Recon/cidr
    python3 cidr2ip.py --input $host --output Recon/cidr/ip.txt
}

portscan(){
    naabu -list Recon/cidr/ip.txt -p 1-65535 -silent | tee -a Recon/cidr/ports_tmp.txt
    cat Recon/cidr/ports_tmp.txt | sort -u | tee -a Recon/cidr/ports.txt
    rm -rf Recon/cidr/ports_tmp.txt
    ip_addresses=(); concatenated_ports=(); while IFS= read -r line; do IFS=':' read -r ip ports <<< "$line"; port_array=($ports); concatenated_port=$(IFS=','; echo "${port_array[*]}"); ip_addresses+=("$ip"); concatenated_ports+=("$concatenated_port"); done < Recon/cidr/ports.txt; for ((i=0; i<${#ip_addresses[@]}; i++)); do echo "IP Address: ${ip_addresses[i]}" | tee -a Recon/cidr/nmap.txt; nmap -sC -sV ${ip_addresses[i]} -p${concatenated_ports[i]}|grep -v "Starting Nmap"|grep -v "Host is"|grep -v "rDNS record"|grep -v "Nmap scan report for"|grep -v "Nmap done"|grep -v "Service detection performed." | tee -a Recon/cidr/nmap.txt; done
}

web(){
    cat Recon/cidr/ports.txt | httpx -o Recon/cidr/aliv1.txt
    cat Recon/cidr/ports.txt | httprobe -c 100 | tee -a Recon/cidr/aliv2.txt
}

sorting(){
    cat Recon/cidr/aliv*.txt | sort -u | tee -a Recon/cidr/aliv.txt
    rm -rf Recon/cidr/aliv1.txt
    rm -rf Recon/cidr/aliv2.txt
}

nuclei_all(){
    cat Recon/cidr/aliv.txt | nuclei -t ~/nuclei-templates/ -rl 100 --silent | tee -a Recon/cidr/nuclei1.txt
    cat Recon/cidr/aliv.txt | nuclei -t nuclei_templates/ -rl 100 --silent | tee -a Recon/cidr/nuclei2.txt
    cat Recon/cidr/nuclei*.txt | sort -u | tee -a Recon/cidr/nuclei.txt
    rm Recon/cidr/nuclei1.txt
    rm Recon/cidr/nuclei2.txt
}

cidr_to_ip
portscan
web
sorting
nuclei_all