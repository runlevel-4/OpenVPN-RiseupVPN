# Riseup VPN Config Script

A shell script that creates an OpenVPN config file that connects to the [Riseup VPN](https://riseup.net/en/vpn)

## Prerequisites

- Linux
- Root or `sudo` privileges

## Usage

```bash
git clone https://github.com/runlevel-4/OpenVPN-RiseupVPN
cd OpenVPN-RiseupVPN
chmod +x riseup_vpn_automation.sh
./riseup_vpn_automation.sh
```

The script checks for sudo privileges and OpenVPN and jq before attempting to configure and start the VPN connection.

## Troubleshooting

- If the connection fails, run the script from a terminal and inspect OpenVPN's output.

## Disconnect
`sudo pkill openvpn` or `CTRL + C`
