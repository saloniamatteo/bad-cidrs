#!/bin/sh
# This script retrieves only the first column from CIDRs.txt,
# then each line is ran through host.sh, fetching only the country.
# -----------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Get this directory's path
DIRNAME=$(dirname "$0")

# If this isn't present, the data cannot be retrieved.
# You can get this file from the following website:
# https://ipinfo.io/products/free-ip-database
# (Choose IP to Country + ASN, CSV)
# The file is approximately 225 MB.
CSVFILE="${DIRNAME}/../country_asn.csv"

# File that contains the bad CIDRs
CIDRSFILE="${DIRNAME}/../CIDRs.txt"

# Only get IPs (strip owner/company name)
awk '{print $1}' "${CIDRSFILE}" > "${DIRNAME}/cidrs-oneline.txt"

# Read file
while IFS= read -r line; do
    # Get base IP
    base_ip=$(sipcalc "${line}" | awk '/Network address/ {print $4}')

    # Replace start IP dots (.) with escaped dots (\.)
    # so that the regex works properly
    base_ip=$(sed "s/\./\\\./g" <<<$base_ip)

    # Fetch record from country_asn.csv
    country_name=$(grep "^${base_ip}" "${CSVFILE}" | cut -d',' -f4)

    # Wrap country name in quotes, so that gnuplot does not complain
    # Only add if not empty
    ! [ -z "${country_name}" ] && echo "\"${country_name}\"" >> "${DIRNAME}/countries-list.txt"
done < "${DIRNAME}/cidrs-oneline.txt"

# Remove unneded file
rm "${DIRNAME}/cidrs-oneline.txt"
