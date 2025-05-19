#!/bin/sh
# This script retrieves only the first column from CIDRs.txt,
# then each line is ran through host.sh, fetching only the country.
# -----------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Get this directory's path
DIRNAME=$(dirname "$0")

# File that contains the bad CIDRs
CIDRSFILE="${DIRNAME}/../CIDRs.txt"

# Only get IPs (strip owner/company name)
awk '{print $1}' "${CIDRSFILE}" > "${DIRNAME}/cidrs-oneline.txt"

# Countries array
countries=()

# Read file
while IFS= read -r line; do
    # Get base IP
    base_ip=$(sipcalc "${line}" | awk '/Network address/ {print $4}')

    # Get country
    country=$(geoiplookup $base_ip \
        | grep "Country Edition" \
        | sed "s/GeoIP Country Edition: //" \
        | cut -d ',' -f2)

    # If country does not contain "not found" nor "error", nor is it empty,
    # wrap it in quotes, and append it to our file
    if ! [[ "${country}" =~ "not found" || "${country}" =~ "error" || -z "${country}" ]]; then
        countries+=("${country}")
    fi
done < "${DIRNAME}/cidrs-oneline.txt"

# Write to file
printf '"%s"\n' "${countries[@]}" > "${DIRNAME}/countries-list.txt"

# Remove unneded file
rm "${DIRNAME}/cidrs-oneline.txt"
