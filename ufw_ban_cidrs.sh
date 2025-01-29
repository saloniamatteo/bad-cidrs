#!/bin/sh
# This script reads the CIDRs.txt file and,
# line-by-line, each CIDR is banned using ufw.
# Each banned CIDR is prepended as a DENY IN rule.
# Additionally, a comment is added.
# ------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Print usage and exit
if [[ $@ =~ "-h" || $@ =~ "--help" ]]; then
	printf "Usage: $0 [-h, --help] [-d, --dry-run] [-s, --silent]
-h,--help     Display this help message
-d,--dry-run  Do not run ufw; only show which CIDRs would be banned
-s,--silent   Do not print 'Skipping (already inserted)' messages
"
	exit 0
fi

# Get this directory's path
DIRNAME=$(dirname "$0")

# Where our CIDRs file is stored
CIDRS_FILE="$DIRNAME/CIDRs.txt"

# Check if file exists
if ! [ -e "$CIDRS_FILE" ]; then
	echo "Cannot find file $CIDRS_FILE!"
	exit 1
fi

# Check if we are root
if [ $(whoami) = "root" ]; then
	root=""
elif [ $(which doas) ]; then
	root="doas"
else
	root="sudo"
fi

# Read file
while IFS= read -r line; do
	# Split CIDR & Comment
	cidr=$(echo $line | awk '{print $1}')
	comment=$(echo $line | awk '{print $2}')

	# Check if CIDR is already added
	$root ufw status | grep "$cidr" >/dev/null 2>&1
	exit_status=$?

	# If CIDR is found, skip re-adding the rule
	if [ $exit_status -eq 0 ]; then
		# Should we echo it?
		if ! [[ $@ =~ "-s" || $@ =~ "--silent" ]]; then
			echo "Skipping $cidr (already inserted)"
		fi
	else
		echo "CIDR: $cidr ($comment)";

		# Dry run: only show what would be added
		if ! [[ $@ =~ "-d" || $@ =~ "--dry-run" ]]; then
			$root ufw prepend deny from "$cidr" comment "$comment"
		fi
	fi
done < "$CIDRS_FILE"
