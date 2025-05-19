#!/bin/sh
# This script reads the CIDRs.txt file and,
# line-by-line, each CIDR is banned using ufw.
# Each banned CIDR is prepended as a DENY IN rule.
# Additionally, a comment is added.
# ------------------------------------------------
# Written by Matteo Salonia (matteo@salonia.it)

# Assign flags
F_HELP=0		# Print help
F_IPV6=0		# Ban IPv6 CIDRs
F_DRY_RUN=0		# Dry run
F_FLAGS=0		# Print flags
F_SKIP=0		# Skip checking if the rule already exists
F_SILENT=0		# Do not print 'skipping (already inserted)' messages

[[ $@ =~ "-h" || $@ =~ "--help" ]] && F_HELP=1
[[ $@ =~ "-6" || $@ =~ "--ipv6" ]] && F_IPV6=1
[[ $@ =~ "-d" || $@ =~ "--dry-run" ]] && F_DRY_RUN=1
[[ $@ =~ "-f" || $@ =~ "--flags" ]] && F_FLAGS=1
[[ $@ =~ "-k" || $@ =~ "--skip" ]] && F_SKIP=1
[[ $@ =~ "-s" || $@ =~ "--silent" ]] && F_SILENT=1

# Print usage and exit
if [ $F_HELP = 1 ]; then
	printf "Usage: $0 [options]
-6,--ipv6     Ban IPv6 CIDRs from CIDRs6.txt (default: IPv4)
-d,--dry-run  Do not run ufw; only show which CIDRs would be banned
-f,--flags    Print flags and exit (debugging only)
-h,--help     Display this help message
-k,--skip     Skip checking if the rule already exists
-s,--silent   Do not print 'Skipping (already inserted)' messages

If this is a new installation/empty ruleset, -k/--skip is recommended.
"
	exit 0
fi

# Print flags and exit
if [ $F_FLAGS = 1 ]; then
	printf "Flags:
F_HELP=$F_HELP
F_IPV6=$F_IPV6
F_DRY_RUN=$F_DRY_RUN
F_FLAGS=$F_FLAGS
F_SKIP=$F_SKIP
F_SILENT=$F_SILENT
"
	exit 0
fi

# Get this directory's path
DIRNAME=$(dirname "$0")

# CIDRS_FILE: Where our CIDRs file is stored
# UFW_RULES_FILE: Where ufw rules are stored
if [ $F_IPV6 = 0 ]; then
	CIDRS_FILE="$DIRNAME/CIDRs.txt"
	UFW_RULES_FILE="/etc/ufw/user.rules"
else
	CIDRS_FILE="$DIRNAME/CIDRs6.txt"
	UFW_RULES_FILE="/etc/ufw/user6.rules"
fi

# Check if files exist
if ! [ -e "$CIDRS_FILE" ]; then
	echo "Cannot find CIDRs file ($CIDRS_FILE)!"
	exit 1
fi

if ! [ -e "$UFW_RULES_FILE" ]; then
	echo "Cannot find ufw rules file ($UFW_RULES_FILE)!"
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
	if [ $F_SKIP = 0 ]; then
		# Instead of checking via ufw, check directly /etc/ufw/user.rules
		# Times:
		# - via "ufw status": 0.077s
		# - via "grep $UFW_RULES_FILE": 0.001s
		#
		# Keeping this line just in case. Shouldn't be needed.
		#$root ufw status | grep "$cidr" >/dev/null 2>&1

		grep "$cidr" $UFW_RULES_FILE >/dev/null 2>&1
		exit_status=$?
	fi

	# If CIDR is found, skip re-adding the rule
	if [[ $exit_status -eq 0 && $F_SKIP = 0 ]]; then
		# Should we echo it?
		if [ $F_SILENT = 0 || $F_DRY_RUN = 1 ]; then
			echo "Skipping $cidr (already inserted)"
		fi
	else
		# Should we echo it?
		if [ $F_SILENT = 0 || $F_DRY_RUN = 1 ]; then
			echo "CIDR: $cidr ($comment)";
		fi

		# Dry run: only show what would be added
		if [ $F_DRY_RUN = 0 ]; then
			$root ufw prepend deny from "$cidr" comment "$comment"
		fi
	fi
done < "$CIDRS_FILE"
