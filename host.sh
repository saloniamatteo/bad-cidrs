#!/bin/sh
# This script outputs the current IP, performs a WHOIS lookup,
# and only gets lines containing "inetnum" & "netname".
# Excessive whitespace after the ':' is reduced to 1 space.
# ------------------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Check if we have a parameter
if [ $# -ne 1 ]; then
    echo "Usage: $0 <IP>"
    exit 1
fi

# This is where the magic happens
whois $1 | grep "inetnum\|netname" | sed 's/:[ ]\+/: /g'
