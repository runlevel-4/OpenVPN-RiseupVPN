#!/bin/bash

# check for sudo
if [ "$EUID" -ne 0 ]; then
	echo "Not using super cow powers :( ...exiting"
	exit 1
else
	echo "Running with super cow powers...continuing"
fi

# package manager array (feel free to fork this and let me know which other ones to add)
pkgmgr=("apt" "pacman" "dnf" "xbps-install")
#dest_dir=/usr/lib/orvpn
vpn_file=orvpn.ovpn

# find the current package manager
for pm in ${pkgmgr[@]}; do
	command -v $pm >/dev/null 2>&1 && echo "Found $pm" && pm_found=$pm
done

case $pm_found in
	apt)
		echo "apt package manager detected...Ubuntu/Debian."
			apt update && apt upgrade -y
			apt install -y openvpn jq curl
		;;
	pacman)
		echo "pacman package manager detected...you use Arch btw."
			pacman -Syu
			pacman -Sy openvpn jq curl
		;;
	dnf)
		echo "dnf package manager detected...I tip my hat to you."
			dnf update
			dnf install -y openvpn jq curl
		;;
	xbps-install)
		echo "xbps package manager detected...welcome to the Void."
			xbps-install -Syu
			xbps-install -Sy openvpn jq curl
		;;
	*)
		echo "None of the common package managers were detected...please run the install command for your package manager to install openvpn and jq."
		exit 1
		;;
esac

#cd $dest_dir || exit 1

# get RiseupVPN keys and certs
echo "Downloading Riseup VPN certs and private key..."
curl -Os https://api.black.riseup.net/3/cert 
curl -Os https://black.riseup.net/ca.crt

# get RiseupVPN JSON file
echo "Downloading Riseup VPN gateways..."
curl -Os https://api.black.riseup.net/3/config/eip-service.json

# initialize the $vpn_file config file
echo "Building OpenVPN config file..."
printf 'client\ndev tun\nproto tcp\nnobind\npersist-key\npersist-tun\npull-filter ignore "ping"\npull-filter ignore "ping-restart"\nkeepalive 10 20\nserver-poll-timeout 10\nconnect-retry 1 2\nconnect-retry-max 1\ncipher AES-256-GCM\ndata-ciphers AES-256-GCM\nremote-cert-tls server\nverb 3\nremote-random\n' > $vpn_file

# parse JSON with jq to get a list of the gateway IPs
parse_gateways=$(jq -r '.gateways[].ip_address' eip-service.json)

# add the gateways to the OpenVPN config file
for line in $parse_gateways; do
	echo "remote $line 1194"
done >> $vpn_file

# parse cert with awk to get the private key and cert
pk=$(echo "<key>" >> $vpn_file; awk '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/' cert >> $vpn_file; echo "</key>" >> $vpn_file)
cert=$(echo "<cert>" >> $vpn_file; awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' cert >> $vpn_file; echo "</cert>" >> $vpn_file)
ca=$(echo "<ca>" >> $vpn_file; cat ca.crt >> $vpn_file; echo "</ca>" >> $vpn_file)

# add the private key and cers to the OpenVPN config file
$pk; $cert; $ca

echo "OpenVPN config file built"
