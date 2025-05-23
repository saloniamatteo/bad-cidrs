## Bad CIDRs
Curated list of known bad CIDRs (scanners, crawlers, etc.)

Useful files:
- `CIDRs.txt`: file containing the bad CIDRs.
- `CIDRs6.txt`: bad IPv6 CIDRs.
- `endlessh.sh`: create endlessh report, including WHOIS info (using `host.sh`)
- `get_ufw_banned.sh`: aids in creating the CIDRs.txt list; prints all of the banned hosts in UFW (`DENY IN`)
- `host.sh`: prints info of a given IP (CIDR, range, owner/company)
- `host_rec.sh`: reads a file containing a column of IPs, and runs `host.sh` for each IP
- `ufw_ban_cidrs.sh`: reads the data provided in CIDRs.txt (or CIDRs6.txt), and bans it using UFW

## Donate
Support this project: [salonia.it/donate](https://salonia.it/donate)

## Stats
Map showing where all currently inserted bad CIDRs originate from:
![world_map](img/world_map.png)

Top 20 countries where bad CIDRs originate from:
![countries](img/countries.png)

Top 20 owners/companies where bad CIDRs originate from:
![owners](img/owners.png)

You can generate the plots above using the following commands:
- World map: `make map`
- Top 20 countries: `make countries`
- Top 20 owners/companies: `make owners`

Or just run `make all`. This takes less than 20 seconds on an i7-7820HQ.

Requirements:
- `awk`
- `curl`
- `gnuplot`
- `grep`
- `jq`
- `sed`
- `sipcalc`
- `country_asn.csv` file (read below)

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
1.160.0.0/12    Hinet
1.192.0.0/13    Chinanet
1.234.0.0/14    SK-Broadband
1.6.53.0/24     Sify
```

The CIDRs listed in the `CIDRs.txt` & `CIDRs6.txt` file come from various sources:
- SSH honeypot/tarpit (see [endlessh](https://github.com/skeeto/endlessh))
- Fail2ban logs from vulnerability scans (postfix, nginx, ...)
- Manual log reviewing

Safe to say, if a CIDR is listed, it means somebody in that network did something that shouldn't have been done.

Note: most Chinese & Russian CIDRs are listed, not because I want to arbitrarily censor countries,
but because most scanners' IPs come from those countries. Obviously, other countries are listed as well.

## `host.sh` script
This script is used to aid in creating the CIDRs.txt list.

It is possible to use it without any further configuration,
however further features exist to return more data.

You can obtain the `country_asn.csv` file from the following:
[ipinfo.io/products/free-ip-database](https://ipinfo.io/products/free-ip-database)

(Choose IP to Country + ASN, CSV)

The file is approximately 225 MB.

Example execution (no CSV DB):

```bash
$ ./host.sh 98.80.1.2
IP: 98.80.1.2
route: 98.80.0.0/13
origin: AS14618
descr: Amazon EC2 IAD Prefix
route: 98.80.0.0/13
origin: AS16509
descr: Amazon EC2 IAD Prefix
```

Please note that the values above are returned exactly
as written in the WHOIS lookup response.

Example execution (with CSV DB):

```bash
$ ./host.sh 98.80.1.2
IP: 98.80.1.2
CIDR: 98.80.0.0/13
Range: 98.80.0.0 - 98.95.255.255
Country: United States (US)
Continent: North America (NA)
ASN: AS14618
Company: "Amazon.com, Inc."
Website: amazon.com
```

The values above are fetched from each column of the CSV file.

## Banning listed CIDRs with ufw
Adding the listed CIDRs to ufw is really easy, and only takes one command:

```
./ufw_ban_cidrs.sh
```

Additionally, the following options can be used:
- `-6`, `--ipv6`: Ban IPv6 CIDRs from `CIDRs6.txt` (default: IPv4)
- `-d`, `--dry-run`: Do not run ufw; only show which CIDRs would be banned
- `-f`, `--flags`: Print flags and exit (debugging only)
- `-h`, `--help`: Display help message
- `-k`, `--skip`: Skip checking if rule already exists
- `-s`, `--silent`: Do not print 'Skipping (already inserted)' messages

Using the `-k` option skips an unnecessary step: the script will not check if a CIDR is already inserted.

With this flag, adding the whole list takes around 3 minutes on an i5-11400.
