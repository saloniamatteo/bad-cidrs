#!/bin/sh
# This script reads the CIDRs.txt file and,
# line-by-line, each CIDR is banned using ufw.
# Each banned CIDR is prepended as a DENY IN rule.
# Additionally, a comment is added.
# ------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

if [[ "$@" == "-h" || "$@" == "--help" ]]; then
	echo "Usage: $0 [-h, --help] [-d, --dry-run]"
	exit 0
fi

CIDRS_FILE="CIDRs.txt"

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
	$root ufw status verbose | grep "$cidr" >/dev/null 2>&1
	exit_status=$?

	# If CIDR is found, skip re-adding the rule
	if [ $exit_status -eq 0 ]; then
		echo "Skipping $CIDR as it is already present"
	else
		# Dry run: only show what would be added
		if [[ "$1" == "-d" || "$1" == "--dry-run" ]]; then
			echo "CIDR: $cidr; Comment: $comment";
		else
			$root ufw prepend deny from "$cidr" comment "$comment"
		fi
	fi
done < "$CIDRS_FILE"
