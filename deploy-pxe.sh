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
sudo cp $STARTINGDIR/default /srv/tftp/pxelinux.cfg/default
# sudo touch /srv/tftp/pxelinux.cfg/default



# make the distribution directories
echo "Make directories to hold Ubuntu server/desktop, and Xubuntu desktop"
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
sudo mkdir -p /var/www/ubuntu/jammy/{server,desktop}
sudo mkdir -p /var/www/xubuntu/jammy/desktop



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


# get xubuntu (desktop) - note Canadian mirror
echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/xubuntu-22.04.1-desktop-amd64.iso

# set up the Xubuntu directory structure
echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount xubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
sudo mv xubuntu-22.04.1-desktop-amd64.iso /var/www/xubuntu/jammy/desktop
sudo umount /mnt

# Disable the old apache config file and use the pxe-server.conf file
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
sudo cp $STARTINGDIR/pxe-server.conf /etc/apache/sites-available
sudo a2ensite pxe-server.conf
sudo systemctl restart apache2

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



