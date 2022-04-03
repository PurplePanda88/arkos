#!/bin/bash

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f linux-headers-4.4.189_4.4.189-2_arm64.deb

if [ ! -f "linux-headers-4.4.189_4.4.189-2_arm64.deb" ]; then
	printf "\nThe linux header deb did not download correctly or is missing. Either rerun this script or manually download it from the git and place it in this current folder then run this script again.\n"
	exit
fi

sudo dpkg -i linux-headers-4.4.189_4.4.189-2_arm64.deb

# Apply some patches to fix some possible compile issues with gcc 9
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/module.patch -O - | sudo patch
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/compiler.patch -O - | sudo patch

# Fix vermagic description so it properly matches
sudo sed -i "/#define UTS_RELEASE/c\#define UTS_RELEASE \"4.4.189\"" /usr/src/linux-headers-4.4.189/include/generated/utsrelease.h

# Install some typically important and handy build tools
sudo apt update -y && sudo apt-get --reinstall install -y build-essential bc bison flex libssl-dev python linux-libc-dev libc6-dev
cd /usr/src/linux-headers-4.4.189/

# This fix dkms Exec format errors
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/headers-debian-byteshift.patch -O - | sudo patch -p1

sudo make scripts
cd ~