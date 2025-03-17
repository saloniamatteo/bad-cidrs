#!/bin/bash
# This script prints the current IP & its related info.
#
# If "country_asn.csv" is available, instead print the following:
# - CIDR
# - IP Range
# - Country
# - Continent
# - ASN
# - Company
# - Website
#
# Otherwise, print the following:
# - CIDR
# - Description
# - ASN
#
# The WHOIS query is sent to the Internet Routing Registry (RADdb)
# -----------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Check if we have a parameter
if [ $# -ne 1 ]; then
    echo "Usage: $0 <IP>"
    exit 1
fi

# Echo given IP
echo "IP: $1"

# Get this directory's path
DIRNAME=$(dirname "$0")

# country_asn.csv location
# You can get this file from the following website:
# https://ipinfo.io/products/free-ip-database
# (Choose IP to Country + ASN, CSV)
# The file is approximately 225 MB.
CSVFILE="$DIRNAME/country_asn.csv"

# Check if the file "country_asn.csv" exists
if [ ! -f "${CSVFILE}" ]; then
    # Since we do not have the file, try to get
    # as much info from the WHOIS lookup as possible.
    # Check the following:
    # - Route: CIDR
    # - Descr: Description
    # - Origin: ASN
    # NOTE: multiple entries are allowed here
    whois -h whois.radb.net $1 \
    | grep -i "route\|descr\|origin" \
    | sed 's/:[ ]\+/: /g'

    exit
fi

# NOTE: before countinuing, make sure sipcalc is installed
which sipcalc >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "Please make sure 'sipcalc' is installed and available in PATH"
    echo "https://github.com/sii/sipcalc"
    exit
fi

# The country_asn.csv file exists.
# Perform a WHOIS lookup, retrieving only the first CIDR (route).
# NOTE: no multiple entries allowed (hence grep -m1)
cidr=$(
whois -h whois.radb.net $1 \
| grep -im1 "route" \
| sed 's/:[ ]\+/: /g' \
| awk '{print $2}'
)

# Check if CIDR isn't empty
if [ ! -z "${cidr}" ]; then
    # Print CIDR
    echo "CIDR: ${cidr}"

    # Check if address is IPv4 or IPv6
    grep "ipv4" <<<$(sipcalc "${cidr}") >/dev/null 2>&1

    if [ $? != 0 ]; then
        is_ipv4=0
    else
        is_ipv4=1
    fi

    if [ $is_ipv4 = 1 ]; then
        # Get first IP address
        start_ip=$(sipcalc "${cidr}" | awk '/Network address/ {print $4}')

        # Replace start IP dots (.) with escaped dots (\.)
        # so that the regex works properly
        start_ip=$(sed "s/\./\\\./g" <<<$start_ip)
    else
        # Get network prefix
        start_ip=$(sipcalc "${cidr}" | awk '/Compressed address/ {print $4}')
    fi

    # Find the line in the file
    query=$(grep "^${start_ip}" "${CSVFILE}")

    # Check query
    if [ ! -z "${query}" ]; then
        # Calculate range from CIDR instead of relying on DB data (IPv4 only)
        if [ $is_ipv4 = 1 ]; then
            range=$(sipcalc ${cidr} | awk '/Network range/ {print $4 " " $5 " " $6}')
        else
            range=$(cut -d',' -f1,2 <<<$query | sed "s/,/ - /")
        fi

        country=$(cut -d',' -f3 <<<$query)
        country_name=$(cut -d',' -f4 <<<$query)

        continent=$(cut -d',' -f5 <<<$query)
        continent_name=$(cut -d',' -f6 <<<$query)

        asn=$(cut -d',' -f7 <<<$query)

        # Try to fetch company name
        company=$(cut -d',' -f8 <<<$query)

        # Check if the company name starts with a double quote (")
        if [[ $company == \"* ]]; then
            # If it does, we must instead fetch the full text
            # between the double quotes, stripping them
            # Example: "My Company" -> My Company
            company=$(grep -oP '"[^"]+"' <<<$query | sed 's/"//g')
        fi

        website=$(awk -F, '{print $NF}' <<<$query)

        #echo "Range: ${start_range} - ${end_range}"
        echo "Range: ${range}"
        echo "Country: ${country_name} (${country})"
        echo "Continent: ${continent_name} (${continent})"
        echo "ASN: ${asn}"
        echo "Company: ${company}"
        echo "Website: ${website}"
    else
        echo "Notice: unable to retrieve data for given CIDR."
    fi
else
    echo "Notice: unable to retrieve CIDR for IP '$1'"
    echo "Either the DNS query failed, or the given IP is reserved for local use."
fi
