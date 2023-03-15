#!/bin/bash

# deploy-pxe.sh
#
# by Chaslinux, chaslinux@ gmail.com

### 15/03/2023 - DON'T EXPECT THIS SCRIPT TO WORK - I'm experimenting!!! ###
### *** IMPORTANT *** ###
# This script is is a work in progress
# It's meant to be run on a freshly installed Ubuntu server, only for UEFI booting at the moment

# notes for pfsense: 
# 	add the IP address for tftp server in the Next Server field
#		Default BIOS filename: pxelinux.0
# 		UEFI 32 bit filename: bootx64.efi
#		UEFI 64 bit filename: bootx64.efi

# Note: I am not a programmer, nor a server admin. I just wrote this script to automate
# deployment of a simple PXE server.

# This script is untested as of 15/03/2023

# Starting variables
STARTINGDIR=$(pwd)
CODEDIR=$STARTINGDIR
HOSTNAME=$(cat /etc/hostname)
IPADDRS=$(hostname -I)
IPADDR=$(echo $IPADDRS | sed 's/%20//')
#JAMMYDESKTOP=ubuntu-22.04.2-desktop-amd64.iso
JAMMYSERVER=ubuntu-22.04.2-live-server-amd64.iso
#XUBUNTU=xubuntu-22.04.2-desktop-amd64.iso
#KUBUNTU=kubuntu-22.04.2-desktop-amd64.iso
#LUBUNTU=lubuntu-22.04.2-desktop-amd64.iso
#DEBIAN=debian-11.6.0-amd64-netinst.iso

# Update the system first since we may have new software packages
echo "Updating the system before adding software..."
sudo apt update && sudo apt upgrade -y

# Install necessary server files
sudo apt install tftpd-hpa apache2 -y

# copy the tftp.conf to /etc/apache2/conf-available, enable it, and restart apache2
sudo cp $STARTINGDIR/tftp.conf /etc/apache2/conf-available
sudo a2enconf tftp
sudo systemctl restart apache2

# Make the PXE directories for the tftp files
sudo mkdir -p /srv/tftp/pxelinux.cfg

# Install syslinux for non-UEFI and UEFI, plus tftpd
# We don't install a DHCP server since we're using our router
# for dhcp
#echo "Installing syslinux-common, syslinux-efi, tftpd-hpa, and pxelinux"
#sudo apt install syslinux-common syslinux-efi tftpd-hpa pxelinux 

#echo "Copying syslinux and pxelinux files into the appropriate directories..."
#cd /srv/tftp
#sudo cp /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /srv/tftp/uefi
#sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp/uefi
#sudo cp /usr/lib/syslinux/modules/bios/{ldlinux.c32,libutil.c32,menu.c32} /srv/tftp/
#sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp/

# make the distribution directories
echo "Make directories to hold Ubuntu server/desktop, and Xubuntu desktop"
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
sudo mkdir -p /srv/tftp/debian/bullseye/netinstall

# This is for non-UEFI booting - disabled for now until I can get UEFI grub installs working
#echo "Make the pxelinux.cfg directory and set up default file structure..."
#sudo mkdir -p /srv/tftp/pxelinux.cfg
#cd $STARTINGDIR
#echo "UI menu.c32" > default
#echo "LABEL Ubuntu Jammy 22.04 Desktop" >> default
#echo "	MENU LABEL Ubuntu Desktop" >> default
#echo "	KERNEL ubuntu/jammy/desktop/vmlinuz" >> default
#echo "	INITRD ubuntu/jammy/desktop/initrd" >> default
#echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/desktop/$JAMMYDESKTOP" >> default
#echo "	TEXT HELP" >> default
#echo "		The Ubuntu 22.04 Desktop Live Image" >> default
#echo "	ENDTEXT" >> default
# echo "LABEL Ubuntu Jammy 22.04 Server" >> default
#echo "	MENU LABEL Ubuntu Server" >> default
#echo "	KERNEL ubuntu/jammy/server/vmlinuz" >> default
#echo "	INITRD ubuntu/jammy/server/initrd" >> default
#echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/server/$JAMMYSERVER" >> default
#echo "	TEXT HELP" >> default
#echo "		The Ubuntu 22.04 Server Live Image" >> default
#echo "	ENDTEXT" >> default
# echo "LABEL Xubuntu Jammy 22.04 Desktop" >> default
#echo "	MENU LABEL Xubuntu Desktop" >> default
#echo "	KERNEL xubuntu/jammy/desktop/vmlinuz" >> default
#echo "	INITRD xubuntu/jammy/desktop/initrd" >> default
#echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/xubuntu/jammy/desktop/$XUBUNTU" >> default
#echo "	TEXT HELP" >> default
#echo "		The Xubuntu 22.04 Desktop Live Image" >> default
#echo "	ENDTEXT" >> default
# echo "LABEL Debian Bullseye 11.6.0 Network Installer" >> default
#echo "	MENU LABEL Debian Netinstaller" >> default
#echo "	KERNEL debian/bullseye/netinstall/vmlinuz" >> default
#echo "	INITRD debian/bullseye/netinstall/initrd.gz" >> default
#echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/debian/bullseye/netinstall/$DEBIAN" >> default
#echo "	TEXT HELP" >> default
#echo "		The Debian Network installer" >> default
#echo "	ENDTEXT" >> default
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
#sudo cp $STARTINGDIR/default /srv/tftp/pxelinux.cfg/default

# get Ubuntu Desktop
#if [ ! -f /srv/tftp/ubuntu/jammy/desktop/$JAMMYDESKTOP ]
#	then
#		cd ~
#		echo "Downloading Ubuntu 22.04 desktop..."
#		wget https://releases.ubuntu.com/22.04.1/$JAMMYDESKTOP
#		echo "Mounting Ubuntu Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
#		sudo mount $JAMMYDESKTOP /mnt
#		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
#		sudo mv $JAMMYDESKTOP /srv/tftp/ubuntu/jammy/desktop
#		sudo umount /mnt
#fi

# get Ubuntu Server
if [ ! -f /srv/tftp/ubuntu/jammy/server/$JAMMYSERVER ];
	then
		cd ~
		echo "Downloading Ubuntu 22.04 server..."
		wget https://releases.ubuntu.com/22.04.1/$JAMMYSERVER
		echo "Mounting Ubuntu Server image, coping vmlinuz, initrd, and the ISO to the appropriate directories..."
		sudo mount $JAMMYSERVER /mnt
		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
		sudo mv $JAMMYSERVER /srv/tftp/ubuntu/jammy/server
		sudo umount /mnt
fi

# get Xubuntu (desktop) - note Canadian mirror
#if [ ! -f /srv/tftp/xubuntu/jammy/desktop/$XUBUNTU ];
#	then
#		cd ~
#		echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
#		wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/$XUBUNTU
#		echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
#		sudo mount $XUBUNTU /mnt
#		sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
#		sudo mv $XUBUNTU /srv/tftp/xubuntu/jammy/desktop
#		sudo umount /mnt
#fi

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

# do the UEFI stuff
cd ~
apt download shim-signed
dpkg-deb --fsys-tarfile shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed -O > bootx64.efi
sudo mv bootx64.efi /srv/tftp
apt download grub-efi-amd64-signed
dpkg-deb --fsys-tarfile grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O > grubx64.efi
sudo mv grubx64.efi /srv/tftp
apt download grub-common
dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O > unicode.pf2
sudo mv unicode.pf2 /srv/tftp

echo "Now write the grub.cfg file to " $STARTINGDIR
if [ ! -f $STARTINGDIR/grub.cfg ]; then
	cd $STARTINGDIR
	echo "default=autoinstall" > $STARTINGDIR/grub.cfg
	echo "timeout=30" >> $STARTINGDIR/grub.cfg
	echo "timeout_style=menu"  >> $STARTINGDIR/grub.cfg
	echo 'menuentry "Ubuntu 22.04 server installer - automated" --id=autoinstall {'  >> $STARTINGDIR/grub.cfg
	echo "	linux /jammy/server/vmlinuz ip=dhcp url=http://"$IPADDR"/tftp/jammy/server/"$JAMMYSERVER" autoinstall ds=nocloud-net;s=http://"$IPADDR"/tftp/jammy/server/ root=/dev/ram0" >> $STARTINGDIR/grub.cfg
	echo '	echo "Loading RAM disk..."' >> $STARTINGDIR/grub.cfg
	echo "	initrd jammy/server/initrd" >> $STARTINGDIR/grub.cfg
	echo "}" >> $STARTINGDIR/grub.cfg
fi
sudo mv $STARTINGDIR/grub.cfg /srv/tftp/grub

# make the apache2 files to automate deployment of Ubuntu Server
# note: localadmin and i<3Ubuntu for starting username and password
sudo touch /srv/tftp/jammy/server/meta-data
sudo cp $STARTINGDIR/user-data /srv/tftp/jammy/server

echo "Removing grub.cfg now that it's copied to /srv/tftp/grub/grub.cfg"
rm $STARTINGDIR/grub.cfg