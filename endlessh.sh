#!/bin/sh
# Get connected endlessh hosts & send a mail

# Email options
# Change these!!
SUBJECT="Endlessh Report"
SENDER="endlessh@example.com"
RECIPIENT="postmaster@example.com"

# Create hosts list
hosts=$(grep "ACCEPT host" /var/log/syslog | awk "{print \$7}" | sed "s/host=::ffff://g" | sort -u)

# Temporarily copy hosts list to /tmp
echo "${hosts}" > /tmp/endlessh-report-tmp

# Get hosts info
# Change this!
hosts_info=$(/path/to/bad-cidrs/host_rec.sh /tmp/endlessh-report-tmp)

# Remove tmp file
rm /tmp/endlessh-report-tmp

# Get number of hosts
host_count=$(echo "${hosts}" | wc -l)

# Create mail message
message=$(cat <<EOF
Subject: ${SUBJECT}
To: ${RECIPIENT}
From: ${SENDER}

Hi,
this is the endlessh report.
Today ${host_count} host(s) tried to connect.

Hosts
================
${hosts}

Hosts WHOIS info
================
${hosts_info}

***

Generated at $(date).
EOF
)

# Send mail message
echo -e "${message}" | sendmail -t
