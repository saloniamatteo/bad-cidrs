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

# Create empty data array
data_array=()

# Create empty points array
points=()

makerequest() {
    # Convert data accordingly
    array_string=$(printf "[%s]" "$(IFS=,; echo "${data_array[*]}")")

    # Get location data
    # Sample response:
    # [{"lat":0,"lon":0},{"lat":0,"lon":0}]
    points+=$(curl "http://ip-api.com/batch?fields=lat,lon" --data "${array_string}" 2>/dev/null)

    # Flush data_array
    data_array=()
}

# Read file
while IFS= read -r line; do
    # Get base IP
    base_ip=$(sipcalc "${line}" | awk '/Network address/ {print $4}')

    # If array size is equal to 100, send batch request
    if [ ${#data_array[@]} -eq 100 ]; then
        makerequest
    else
        # Add base IP to array
        data_array+=("\"${base_ip}\"")
    fi
done < "${DIRNAME}/cidrs-oneline.txt"

# Check if data_array is empty: if it isn't, complete pending tasks
if ! [ -z $data_array ]; then
    makerequest
fi

# Parse response and save it into our points file
jq -r '.[] | "\(.lon),\(.lat)"' <<<$points > "${DIRNAME}/points.txt"
