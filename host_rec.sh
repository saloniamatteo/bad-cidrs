#!/bin/sh
# This script aids in the creation of the CIDRs.txt list.
# Given an input file, each line is ran through host.sh,
# and info is outputted to stdout.
# The input file should have the following structure:
# host1
# host2
# host3
# ...
# (aka, only have 1 ip per line)
# ------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Check if we have a parameter
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Get this directory's path
DIRNAME=$(dirname "$0")

# host.sh script location
HOSTSCRIPT="$DIRNAME/host.sh"

# Read file
while IFS= read -r line; do
    # Run host.sh $ip
    $HOSTSCRIPT "$line"

    # Add a newline for clarity
    echo
done < "$1"
