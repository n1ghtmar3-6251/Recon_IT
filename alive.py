import requests
import argparse
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Create the argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--file", help="Input file containing the list of domains", required=True)
parser.add_argument("--output", help="Output file to save the results", required=True)
args = parser.parse_args()

# Read the input file and remove the domains that return 400 or 404
with open(args.file, "r") as f:
    domains = [line.strip() for line in f.readlines()]
    
clean_domains = []
for domain in domains:
    try:
        response = requests.get(domain, verify=False)
        if response.status_code not in [400, 404]:
            clean_domains.append(domain)
    except requests.exceptions.RequestException as e:
        print(f"Error occurred while accessing domain {domain}: {e}")
        continue

# Save the clean domains to the output file
with open(args.output, "w") as f:
    f.write("\n".join(clean_domains))