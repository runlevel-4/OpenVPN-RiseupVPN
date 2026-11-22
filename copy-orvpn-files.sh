#!/bin/bash

# check for sudo
if [ "$EUID" -ne 0 ]; then
	echo -e "Not using super cow powers...exiting"
	exit 1
else
	echo "Using super cow powers...continuing"
fi

dest_dir=/usr/lib/orvpn

# create the /usr/lib/orvpn directory
mkdir $dest_dir

# copy the contents of the orvpn-files directory to /usr/lib/orvpn
echo -e "Copying orvpn to /usr/lib\n"
cp -r orvpn-files/* $dest_dir

# setup the vpn
cd $dest_dir
bash setup-orvpn.sh

# create a symlink to /usr/bin
ln -s $dest_dir/orvpn.ovpn /usr/bin

# create desktop shortcut
cp $dest_dir/orvpn.desktop ~/Desktop
