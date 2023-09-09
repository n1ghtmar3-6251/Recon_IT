ip_addresses=()
concatenated_ports=()
while IFS= read -r line; do
    IFS=':' read -r ip ports <<< "$line"
    port_array=($ports)
    concatenated_port=$(IFS=','; echo "${port_array[*]}")
    ip_addresses+=("$ip")
    concatenated_ports+=("$concatenated_port")
done < Recon/ports.txt
for ((i=0; i<${#ip_addresses[@]}; i++)); do
    echo "IP Address: ${ip_addresses[i]}" | tee -a Recon/nmap.txt
    nmap -sC -sV ${ip_addresses[i]} -p${concatenated_ports[i]} | tee -a Recon/nmap.txt
done



ip_addresses=(); concatenated_ports=(); while IFS= read -r line; do IFS=':' read -r ip ports <<< "$line"; port_array=($ports); concatenated_port=$(IFS=','; echo "${port_array[*]}"); ip_addresses+=("$ip"); concatenated_ports+=("$concatenated_port"); done < Recon/$domain/ports.txt; for ((i=0; i<${#ip_addresses[@]}; i++)); do echo "IP Address: ${ip_addresses[i]}" | tee -a Recon/$domain/nmap.txt; nmap -sC -sV ${ip_addresses[i]} -p${concatenated_ports[i]} | tee -a Recon/$domain/nmap.txt; done