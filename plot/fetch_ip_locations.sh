#!/bin/sh
# This script retrieves only the first column from CIDRs.txt.
# Every IP is checked against ip-api.com, which provides
# location data (latitude, longitude), required for plotting
# the IPs on the map. IPs are saved in points.txt as follows:
#
# longitude,latitude
# -----------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Get this directory's path
DIRNAME=$(dirname "$0")

# File that contains the bad CIDRs
CIDRSFILE="${DIRNAME}/../CIDRs.txt"

# Only get IPs (strip owner/company name)
awk '{print $1}' "${CIDRSFILE}" > "${DIRNAME}/cidrs-oneline.txt"

# Read file
while IFS= read -r line; do
    # Get base IP
    base_ip=$(sipcalc "${line}" | awk '/Network address/ {print $4}')

    # Geoip lookup
    latlon=$(geoiplookup $base_ip | grep "City Edition")
    lat=$(echo $latlon | cut -d',' -f7)
    lon=$(echo $latlon | cut -d',' -f8)

    # If points are valid (i.e. they are not empty),
    # then append them to points.txt.
    if ! [[ -z "$lat" && -z "$lon" ]]; then
        echo "$lon,$lat" >> "${DIRNAME}/points.txt"
    fi
done < "${DIRNAME}/cidrs-oneline.txt"
