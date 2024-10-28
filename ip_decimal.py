#!/usr/bin/env python3

import argparse

def ip_to_decimal(ip_address):
    octets = ip_address.split('.')
    decimal = 0
    for i in range(4):
        decimal += int(octets[i]) * (256 ** (3 - i))
    return decimal

def main():
    parser = argparse.ArgumentParser(description="Convert IP address to decimal representation")
    parser.add_argument("--ip", help="IP address to convert", required=True)
    args = parser.parse_args()
    
    ip_address = args.ip
    decimal_representation = ip_to_decimal(ip_address)
    print("Decimal representation of", ip_address, "is : ", decimal_representation)

if __name__ == "__main__":
    main()