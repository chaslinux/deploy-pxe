#!/bin/bash

# deploy-pxe.sh
#
# by Chaslinux, chaslinux@ gmail.com

# notes for pfsense: 
# 	add the IP address for tftp server in the Next Server field
#		Default BIOS filename: pxelinux.0
# 	UEFI 32 bit filename: ldlinux.e32
#		UEFI 64 bit filename: ldlinux.e64

### *** IMPORTANT *** ###

# 09/21/2022
# This script is NOT finished. It's just a start
STARTINGDIR=$(pwd)
HOSTNAME=$(cat /etc/hostname)

echo "Updating the system before adding software..."
sudo apt update && sudo apt upgrade -y

# Install syslinux for non-UEFI and UEFI, plus tftpd
# We don't install a DHCP server since we're using our router
# for dhcp
echo "Installing syslinux-common, syslinux-efi, tftpd-hpa, pxelinux, and apache2..."
sudo apt install syslinux-common syslinux-efi tftpd-hpa pxelinux apache2 -y

echo "Copying syslinux and pxelinux files into the appropriate directories..."
cd /srv/tftp
sudo chown tftp:tftp /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi32/ldlinux.e32 /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /srv/tftp
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp
sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp

echo "Make the pxelinux.cfg directory and set up default file structure..."
sudo mkdir -p /srv/tftp/pxelinux.cfg
cd $STARTINGDIR
echo "UI menu.c32" > default
echo "LABEL Ubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Ubuntu Desktop" >> default
echo "	KERNEL ubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD ubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/desktop/ubuntu-22.04.1-desktop-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		The Ubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Ubuntu Jammy 22.04 Server" >> default
echo "	MENU LABEL Ubuntu Server" >> default
echo "	KERNEL ubuntu/jammy/server/vmlinuz" >> default
echo "	INITRD ubuntu/jammy/server/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/server/ubuntu-22.04.1-live-server-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		The Ubuntu 22.04 Server Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Xubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Xubuntu Desktop" >> default
echo "	KERNEL xubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD xubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/xubuntu/jammy/desktop/xubuntu-22.04.1-desktop-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		The Xubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Kubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Kubuntu Desktop" >> default
echo "	KERNEL kubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD kubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/kubuntu/jammy/desktop/kubuntu-22.04.1-desktop-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		The Kubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" >> default

echo "LABEL Lubuntu Jammy 22.04 Desktop" >> default
echo "	MENU LABEL Lubuntu Desktop" >> default
echo "	KERNEL lubuntu/jammy/desktop/vmlinuz" >> default
echo "	INITRD lubuntu/jammy/desktop/initrd" >> default
echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/lubuntu/jammy/desktop/lubuntu-22.04.1-desktop-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		The Lubuntu 22.04 Desktop Live Image" >> default
echo "	ENDTEXT" default

echo "LABEL Gparted 1.4.0 (Disk Partitioning)" >> default
echo "	MENU LABEL Garted (Disk Partitioning)" >> default
echo "	KERNEL gparted/vmlinuz" >> default
echo "	APPEND INITRD=gparted/initrd.img boot=live config components union=overlay username=user noswap noeject vga=788 fetch=http://$HOSTNAME/gparted/gparted-live-1.4.0-5-amd64.iso" >> default
echo "	TEXT HELP" >> default
echo "		Gparted (Disk Paritioning) Live Image" >> default
echo "	ENDTEXT" default
sudo cp $STARTINGDIR/default /srv/tftp/pxelinux.cfg/default

# make the distribution directories
echo "Make directories to hold Ubuntu server/desktop, and Xubuntu desktop"
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
sudo mkdir -p /srv/tftp/kubuntu/jammy/desktop
sudo mkdir -p /srv/tftp/lubuntu/jammy/desktop
sudo mkdir -p /var/www/ubuntu/jammy/{server,desktop}
sudo mkdir -p /var/www/xubuntu/jammy/desktop
sudo mkdir -p /var/www/kubuntu/jammy/desktop
sudo mkdir -p /var/www/lubuntu/jammy/desktop
sudo mkdir -p /srv/tftp/gparted
sudo mkdir -p /var/www/gparted

# change to the current user home directory
echo "Downloading Ubuntu Server 22.04..."
cd ~
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso

# set up Ubuntu server software directory structure
echo "Mounting Ubuntu Server image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount ubuntu-22.04.1-live-server-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
sudo mv ubuntu-22.04.1-live-server-amd64.iso /var/www/ubuntu/jammy/server
sudo umount /mnt

# get Ubuntu Desktop
echo "Downloading Ubuntu 22.04 desktop..."
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-desktop-amd64.iso

# set up Ubuntu desktop directory structure
echo "Mounting Ubuntu Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount ubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
sudo mv ubuntu-22.04.1-desktop-amd64.iso /var/www/ubuntu/jammy/desktop
sudo umount /mnt

# get Xubuntu (desktop) - note Canadian mirror
echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/xubuntu-22.04.1-desktop-amd64.iso

# set up the Xubuntu directory structure
echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount xubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
sudo mv xubuntu-22.04.1-desktop-amd64.iso /var/www/xubuntu/jammy/desktop
sudo umount /mnt

# get Kubuntu (desktop) 
echo "Downloading Kubuntu 22.04 Desktop image"
wget https://cdimage.ubuntu.com/kubuntu/releases/22.04.1/release/kubuntu-22.04.1-desktop-amd64.iso

# set up the Kubuntu directory structure
echo "Mounting Kubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount kubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/kubuntu/jammy/desktop
sudo mv kubuntu-22.04.1-desktop-amd64.iso /var/www/kubuntu/jammy/desktop
sudo umount /mnt

# get Lubuntu (desktop)
echo "Downloading Lubuntu 22.04 Desktop image"
wget https://cdimage.ubuntu.com/lubuntu/releases/22.04.1/release/lubuntu-22.04.1-desktop-amd64.iso

# set up the Lubuntu directory structure
echo "Mounting Lubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount lubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/lubuntu/jammy/desktop
sudo mv lubuntu-22.04.1-desktop-amd64.iso /var/www/lubuntu/jammy/desktop
sudo umount /mnt

# get Gparted live tools
echo "Downloading Gparted 1.4.0 live"
wget https://downloads.sourceforge.net/gparted/gparted-live-1.4.0-5-amd64.iso

# set up the gparted directory structure
echo "Mounting gparted image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount gparted-live-1.4.0-5-amd64.iso /mnt
sudo cp /mnt/live/{initrd.img,vmlinuz} /srv/tftp/gparted
sudo mv gparted-live-1.4.0-5-amd64.iso /var/www/gparted
sudo umount /mnt

# Disable the old apache config file and use the pxe-server.conf file
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
sudo cp $STARTINGDIR/pxe-server.conf /etc/apache/sites-available
sudo a2ensite pxe-server.conf
sudo systemctl restart apache2


# open port 69/udp on the local machine firewall
echo "Opening UDP port 69 on local firewall..."
sudo ufw allow 69/udp



