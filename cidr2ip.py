import argparse
import ipaddress

# Function to expand a CIDR range into a list of individual IPs
def expand_cidr(cidr):
    ip_list = []
    network = ipaddress.IPv4Network(cidr, strict=False)
    for ip in network:
        ip_list.append(str(ip))
    return ip_list

# Create an argument parser
parser = argparse.ArgumentParser(description="Expand CIDR notation IP ranges into individual IP addresses")

# Add command-line arguments for input and output files
parser.add_argument("--input", required=True, help="Input file containing CIDR notation IP ranges")
parser.add_argument("--output", required=True, help="Output file for expanded IP addresses")

# Parse command-line arguments
args = parser.parse_args()

# Read the CIDR ranges from the input file and expand them
input_file = args.input
output_file = args.output

with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    for line in infile:
        cidr = line.strip()
        ip_list = expand_cidr(cidr)
        outfile.write('\n'.join(ip_list) + '\n')