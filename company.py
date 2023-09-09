#!/usr/bin/env python3

import requests
import re
import os
import argparse

# Create an argument parser
parser = argparse.ArgumentParser(description="Web scraping script to retrieve CIDR notation IP ranges from bgp.he.net")

# Add command-line arguments
parser.add_argument("--company", required=True, help="Name of the company to search for on bgp.he.net")
parser.add_argument("--output", required=True, help="Output file to save the CIDR notation IP ranges")

args = parser.parse_args()

# URL for the search page with the --company argument
url2 = f"https://bgp.he.net/search?search%5Bsearch%5D={args.company}&commit=Search"

header1 = {
    "Accept-Encoding": "gzip, deflate",
    "Accept": "*/*",
    "Accept-Language": "en-US;q=0.9,en;q=0.8",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.5359.95 Safari/537.36",
    "Connection": "close",
    "Cache-Control": "max-age=0",
    "Referer": "https://bgp.he.net/search"
}

s = requests.Session()

req2 = s.get(url2, headers=header1)
res2 = req2.text
cidr = re.findall('<a href="/net/(.*)">', res2)

# Save the CIDR notation IP ranges to the output file
with open(args.output, 'w') as outfile:
    for i in range(len(cidr)):
        outfile.write(cidr[i] + '\n')

os.system(f'cat {args.output}|grep -v "::"|sort -u|tee -a {args.output}_final.txt')
os.system(f'rm -rf {args.output};mv {args.output}_final.txt {args.output}')
os.system(f'./recon_cidr.sh {args.output}')