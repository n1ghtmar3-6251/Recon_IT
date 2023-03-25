#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --input)
      INPUT_FILE="$2"
      shift
      shift
      ;;
    --output)
      OUTPUT_FILE="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

# Check if input file is specified
if [[ -z "$INPUT_FILE" ]]; then
  echo "Please specify an input file using the --input option"
  exit 1
fi

# Check if output file is specified
if [[ -z "$OUTPUT_FILE" ]]; then
  echo "Please specify an output file using the --output option"
  exit 1
fi

# Read subdomains from file
while read subdomain; do
  # Remove ".example.com" suffix and split by "." into array
  IFS='.' read -ra SUBS <<< "${subdomain%.example.com}"

  # Output each subdomain on a new line
  for sub in "${SUBS[@]}"; do
    echo "$sub" >> "$OUTPUT_FILE"
  done
done < "$INPUT_FILE"
