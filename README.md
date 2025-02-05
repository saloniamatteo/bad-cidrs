## Bad CIDRs
Curated list of known bad CIDRs (scanners, crawlers, etc.)

Useful files:
- `CIDRs.txt`: file containing the bad CIDRs.
- `endlessh.sh`: create endlessh report, including WHOIS info (using `host.sh`)
- `get_ufw_banned.sh`: shell script to aid in creating the CIDRs.txt list; prints all of the banned hosts in UFW (`DENY IN`)
- `host.sh`: shell script to aid in creating the CIDRs.txt list; prints WHOIS info
- `host_rec.sh`: run this on a file contaning a column of IP addresses & run `host.sh` for each IP
- `ufw_ban_cidrs.sh`: shell script that reads the data provided in CIDRs.txt, and bans it using UFW

## Donate
Support this project: [salonia.it/donate](https://salonia.it/donate)

## Motivation
As the days pass, my server gets lots of mail & web spam, as well as numerous vulnerability checks.
This is "fine", as I am convinced my server's security is not too bad.
However, this gets annoying when this traffic starts getting more frequent.

Thus, I created this project to help me expand & deploy an IP blocklist,
which can be easily implemented in under a minute, with the `ufw_ban_cidrs.sh` script above.

## CIDRs
Format:
Column 1 | Column 2
---------|--------------------
CIDR     | Comment (CIDR name)

Examples:

```
1.160.0.0/12	Hinet
1.192.0.0/13	Chinanet
1.234.0.0/14	SK-Broadband
1.6.53.0/24	Sify
```

The CIDRs listed in the `CIDRs.txt` file come from various sources:
- SSH honeypot/tarpit (see [endlessh](https://github.com/skeeto/endlessh))
- Fail2ban logs from vulnerability scans (postfix, nginx, ...)
- Manual log reviewing

Safe to say, if a CIDR is listed, it means somebody in that network did something that shouldn't have been done.

Note: most Chinese CIDRs are listed, not because I want to arbitrarily censor countries,
but because most scanners have a Chinese IP. Obviously, other countries are listed as well.

## Banning listed CIDRs with ufw
Adding the listed CIDRs to ufw is really easy, and only takes one command:

```
./ufw_ban_cidrs.sh
```

Additionally, the following options can be used:
- `-h`, `--help`: Display help message
- `-d`, `--dry-run`: Do not run ufw; only show which CIDRs would be banned
- `-s`, `--silent`: Do not print 'Skipping (already inserted)' messages

Adding the whole list takes anywhere between 5 to 10 minutes on a modern machine.
