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
sudo touch /srv/tftp/pxelinux.cfg/default
#sudo echo "default menu.c32" > /srv/tftp/pxelinux.cfg/default
#sudo echo "MENU TITLE Main Menu" > /srv/tftp/pxelinux.cfg/default
#sudo echo "LABEL Desktop Linux" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		MENU LABEL Desktop Linux" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		KERNEL menu.c32" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		APPEND pxelinux.cfg/desktop_linux" > /srv/tftp/pxelinux.cfg/default
#sudo echo "LABEL Linux Servers" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		MENU LABEL Linux Servers" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		KERNEL menu.c32" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		APPEND pxelinux.cfg/linux_servers" > /srv/tftp/pxelinux.cfg/default
#sudo echo "LABEL Tools" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		MENU LABEL Tools" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		KERNEL menu.c32" > /srv/tftp/pxelinux.cfg/default
#sudo echo "		APPEND pxelinux.cfg/tools" > /srv/tftp/pxelinux.cfg/default

#echo "Making the pxelinux.cfg/desktop_linux menu..."
#sudo touch /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "MENU TITLE Desktop Linux" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "LABEL Main Menu" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		MENU LABEL Main Menu" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		KERNEL menu.c32" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		APPEND pxelinux.cfg/default" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "LABEL Debian Netinstall" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		MENU LABEL Debian Netinstall" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		KERNEL debian/bullseye/vmlinuz" > /srv/tftp/pxelinux.cfg/desktop_linux
#sudo echo "		INITRD debian/bullseye/initrd.gz" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux
# sudo echo "" > /srv/tftp/pxelinux.cfg/desktop_linux


# make the distribution directories
echo "Make directories to hold Debian, Ubuntu server/desktop, Xubuntu desktop, and Fedora server/desktop..."
#sudo mkdir -p /srv/tftp/debian/bullseye
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
#sudo mkdir -p /srv/tftp/fedora/36/{server,desktop}


# change to the current user home directory
echo "Downloading Ubuntu Server 22.04..."
cd ~
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso

# set up Ubuntu server software directory structure
echo "Mounting Ubuntu Server image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount ubuntu-22.04.1-live-server-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
sudo mv ubuntu-22.04.1-live-server-amd64.iso /srv/tftp/ubuntu/jammy/server
sudo umount /mnt

# get Ubuntu Desktop
echo "Downloading Ubuntu 22.04 desktop..."
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-desktop-amd64.iso

# set up Ubuntu desktop directory structure
echo "Mounting Ubuntu Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount ubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
sudo mv ubuntu-22.04.1-desktop-amd64.iso /srv/tftp/ubuntu/jammy/desktop
sudo umount /mnt

# get debian
#echo "Downloading the Debian 11.4.0 netinstall image"
#wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.4.0-amd64-netinst.iso

# set up debian directory structure
#echo "Mounting Debian image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
#sudo mount debian-11.4.0-amd64-netinst.iso /mnt
#sudo cp /mnt/install.amd/{initrd.gz,vmlinuz} /srv/tftp/debian/bullseye
#sudo mv debian-11.4.0-amd64-netinst.iso /srv/tftp/debian/bullseye
#sudo umount /mnt

# get xubuntu (desktop) - note Canadian mirror
echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/xubuntu-22.04.1-desktop-amd64.iso

# set up the Xubuntu directory structure
echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount xubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
sudo mv xubuntu-22.04.1-desktop-amd64.iso /srv/tftp/xubuntu/jammy/desktop
sudo umount /mnt

# get fedora (GNOME)
#echo "Downloading the Fedora Desktop 36-1.5 image..."
#wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-36-1.5.iso

# Set up the Fedora Desktop structure
#echo "Mounting Fedora Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
#sudo mount Fedora-Workstation-Live-x86_64-36-1.5.iso /mnt
#sudo cp /mnt/isolinux/{initrd.img,vmlinuz} /srv/tftp/fedora/36/desktop
#sudo mv Fedora-Workstation-Live-x86_64-36-1.5.iso /srv/tftp/fedora/36/desktop
#sudo umount /mnt

# Get fedora (server)
#echo "Downloading Fedora Server 36 netinstall image..."
#wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/x86_64/iso/Fedora-Server-netinst-x86_64-36-1.5.iso

#echo "Mounting Fedora Server image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
#sudo mount Fedora-Server-netinst-x86_64-36-1.5.iso /mnt
#sudo cp /mnt/isolinux/{initrd.img,vmlinuz} /srv/tftp/fedora/36/server
#sudo mv Fedora-Server-netinst-x86_64-36-1.5.iso /srv/tftp/fedora/36/server
#sudo umount /mnt


# open port 69/udp on the local machine firewall
echo "Opening UDP port 69 on local firewall..."
sudo ufw allow 69/udp



