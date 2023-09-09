#!/usr/bin/env python3

import argparse
from shodan import Shodan

parser = argparse.ArgumentParser(description='Search for SSL certificates related to a domain using the Shodan API.')
parser.add_argument('--api', required=True, help='Shodan API key')
parser.add_argument('--domain', required=True, help='Domain to search for SSL certificates')
parser.add_argument('--output', required=True, help='Output file to save IP addresses')
args = parser.parse_args()

api_key = args.api
domain = args.domain
output_file = args.output

api = Shodan(api_key)

with open(output_file, 'w') as file:
    for banner in api.search_cursor('ssl:"{}"'.format(domain)):
        ip = banner['ip_str']
        if ':' not in ip:  # exclude IPv6 addresses
            file.write(ip + '\n')
            print(ip)