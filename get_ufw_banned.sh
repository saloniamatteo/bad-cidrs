#!/bin/sh
# This script creates a banned_hosts.txt file,
# by getting UFW DENY IN hosts,
# printing only the CIDR & comment columns,
# sorting the list, and writing to the file.
# ---------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Check if we are root
if [ $(whoami) = "root" ]; then
	root=""
elif [ $(which doas) ]; then
	root="doas"
else
	root="sudo"
fi

# This is where the magic happens
$root ufw status verbose \
| awk '/DENY IN/ {print $4, $5, $6, $7}' \
| sed 's/#/	/g' \
| sort -g > banned_hosts.txt
