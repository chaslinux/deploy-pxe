#!/bin/bash

# deploy-pxe.sh
#
# by Chaslinux, chaslinux@ gmail.com

### 10/18/2022 - DON'T EXPECT THIS SCRIPT TO WORK - I'm experimenting!!! ###
### *** IMPORTANT *** ###
# This script is is a work in progress
# It's meant to be run on a freshly installed Ubuntu server, and it will overwrite pxelinux.cfg/default


# notes for pfsense: 
# 	add the IP address for tftp server in the Next Server field
#		Default BIOS filename: pxelinux.0
# 		UEFI 32 bit filename: syslinux.efi
#		UEFI 64 bit filename: syslinux.efi

# Note: I am not a programmer, nor a server admin. I just wrote this script to automate
# deployment of a simple PXE server.

# I believe most of this (pxelinux.cfg/default) is old, as there's a lot of references to
# setting up grub instead. This just worked for me. I'm happy to add better contributions.

STARTINGDIR=$(pwd)
CODEDIR=$STARTINGDIR
HOSTNAME=$(cat /etc/hostname)
IPADDRS=$(hostname -I)
IPADDR=$(echo $IPADDRS | sed 's/%20//')
UBUNTUDESKTOP=ubuntu-22.04.1-desktop-amd64.iso
UBUNTUSERVER=ubuntu-22.04.1-live-server-amd64.iso
XUBUNTU=xubuntu-22.04.1-desktop-amd64.iso
KUBUNTU=kubuntu-22.04.1-desktop-amd64.iso
LUBUNTU=lubuntu-22.04.1-desktop-amd64.iso

sudo mkdir -p /srv/tftp/pxelinux.cfg

echo "Updating the system before adding software..."
sudo apt update && sudo apt upgrade -y

# Install syslinux for non-UEFI and UEFI, plus tftpd
# We don't install a DHCP server since we're using our router
# for dhcp
echo "Installing syslinux-common, syslinux-efi, tftpd-hpa, and pxelinux"
sudo apt install syslinux-common syslinux-efi tftpd-hpa pxelinux 

echo "Copying syslinux and pxelinux files into the appropriate directories..."
cd /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /srv/tftp
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /srv/tftp
sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp

# make the distribution directories
echo "Make directories to hold Ubuntu server/desktop, and Xubuntu desktop"
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop

echo "Make the pxelinux.cfg directory and set up default file structure..."
sudo mkdir -p /srv/tftp/pxelinux.cfg
cd $STARTINGDIR
echo "UI menu.c32" > default
echo "LABEL Ubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Ubuntu Desktop" >> default
echo "	KERNEL ubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD ubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/desktop/$UBUNTUDESKTOP" >> default
echo "	TEXT HELP" >> default
echo "		The Ubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Ubuntu Jammy 22.04 Server" >> default
echo "	MENU LABEL Ubuntu Server" >> default
echo "	KERNEL ubuntu/jammy/server/vmlinuz" >> default
echo "	INITRD ubuntu/jammy/server/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/server/$UBUNTUSERVER" >> default
echo "	TEXT HELP" >> default
echo "		The Ubuntu 22.04 Server Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Xubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Xubuntu Desktop" >> default
echo "	KERNEL xubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD xubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/xubuntu/jammy/desktop/$XUBUNTU" >> default
echo "	TEXT HELP" >> default
echo "		The Xubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" >> default

# echo "LABEL Kubuntu Jammy 22.04 Desktop" >> default
# echo "	MENU LABEL Kubuntu Desktop" >> default
# echo "	KERNEL kubuntu/jammy/desktop/vmlinuz" >> default
# echo "	INITRD kubuntu/jammy/desktop/initrd" >> default
# echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/kubuntu/jammy/desktop/$KUBUNTU" >> default
# echo "	TEXT HELP" >> default
# echo "		The Kubuntu 22.04 Desktop Live Image" >> default
# echo "	ENDTEXT" >> default

# echo "LABEL Lubuntu Jammy 22.04 Desktop" >> default
# echo "	MENU LABEL Lubuntu Desktop" >> default
# echo "	KERNEL lubuntu/jammy/desktop/vmlinuz" >> default
# echo "	INITRD lubuntu/jammy/desktop/initrd" >> default
# echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/lubuntu/jammy/desktop/$LUBUNTU" >> default
# echo "	TEXT HELP" >> default
# echo "		The Lubuntu 22.04 Desktop Live Image" >> default
# echo "	ENDTEXT" >> default

sudo cp $STARTINGDIR/default /srv/tftp/pxelinux.cfg/default

# get Ubuntu Desktop
if [ ! -f /srv/tftp/ubuntu/jammy/desktop/$UBUNTUDESKTOP ]
	then
		echo "Downloading Ubuntu 22.04 desktop..."
		wget https://releases.ubuntu.com/22.04.1/$UBUNTUDESKTOP
		echo "Mounting Ubuntu Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
		sudo mount $UBUNTUDESKTOP /mnt
		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
		sudo mv $UBUNTUDESKTOP /srv/tftp/ubuntu/jammy/desktop
		sudo umount /mnt
fi

if [ ! -f /srv/tftp/ubuntu/jammy/server/$UBUNTUSERVER ]
	then
		echo "Downloading Ubuntu 22.04 server..."
		wget https://releases.ubuntu.com/22.04.1/$UBUNTUSERVER
		echo "Mounting Ubuntu Server image, coping vmlinuz, initrd, and the ISO to the appropriate directories..."
		sudo mount $UBUNTUSERVER /mnt
		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
		sudo mv $UBUNTUSERVER /srv/tftp/ubuntu/jammy/server
		sudo umount /mnt
fi

# get Xubuntu (desktop) - note Canadian mirror
if [ ! -f /srv/tftp/xubuntu/jammy/desktop/$XUBUNTU ]
	then
		cd ~
		echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
		wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/$XUBUNTU
		echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
		sudo mount $XUBUNTU /mnt
		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
		sudo mv $XUBUNTU /srv/tftp/xubuntu/jammy/desktop
		sudo umount /mnt
fi

# get Kubuntu (desktop) 
# if [ ! -f /srv/tftp/kubuntu/jammy/desktop/$KUBUNTU ]
# 	then
# 		echo "Downloading Kubuntu 22.04 Desktop image"
# 		wget https://cdimage.ubuntu.com/kubuntu/releases/22.04.1/release/$KUBUNTU
# 		echo "Mounting Kubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# 		sudo mount $KUBUNTU /mnt
# 		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/kubuntu/jammy/desktop
# 		sudo mv $KUBUNTU /srv/tftp/kubuntu/jammy/desktop
# 		sudo umount /mnt
# fi

# get Lubuntu (desktop)
# if [ ! -f /srv/tftp/lubuntu/jammy/desktop/$LUBUNTU ]
# 	then
# 		echo "Downloading Lubuntu 22.04 Desktop image"
# 		wget https://cdimage.ubuntu.com/lubuntu/releases/22.04.1/release/$LUBUNTU
# 		echo "Mounting Lubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# 		sudo mount $LUBUNTU /mnt
# 		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/lubuntu/jammy/desktop
# 		sudo mv $LUBUNTU /var/www/lubuntu/jammy/desktop
# 		sudo umount /mnt
# fi

# open port 69/udp on the local machine firewall
echo "Opening UDP port 69 on local firewall..."
sudo ufw allow 69/udp

