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

# 09/09/2022
# This script is NOT finished. It's just a start

echo "Updating the system before adding software..."
sudo apt update && sudo apt upgrade -y

# Install syslinux for non-UEFI and UEFI, plus tftpd
# We don't install a DHCP server since we're using our router
# for dhcp
echo "Installing syslinux-common, syslinux-efi, tftpd-hpa, pxelinux, and apache2"
sudo apt install syslinux-common syslinux-efi tftpd-hpa pxelinux apache2 -y

cd /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi32/ldlinux.e32 /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /srv/tftp
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp
sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp

sudo mkdir -p /srv/tftp/pxelinux.cfg
sudo touch /srv/tftp/pxelinux.cfg/default

# make the distribution directories
sudo mkdir -p /srv/tftp/debian/bullseye
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}
sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
sudo mkdir -p /srv/tftp/fedora/36/{server,desktop}


# change to the current user home directory
cd ~
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso

# set up Ubuntu server software directory structure
sudo mount ubuntu-22.04.1-live-server-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
sudo mv ubuntu-22.04.1-live-server-amd64.iso /srv/tftp/ubuntu/jammy/server
sudo umount /mnt

# get Ubuntu Desktop
wget https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-desktop-amd64.iso

# set up Ubuntu desktop directory structure
sudo mount ubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
sudo mv ubuntu-22.04.1-desktop-amd64.iso /srv/tftp/ubuntu/jammy/desktop
sudo umount /mnt

# get debian
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.4.0-amd64-netinst.iso

# set up debian directory structure
sudo mount debian-11.4.0-amd64-netinst.iso /mnt
sudo cp /mnt/install.amd/{initrd.gz,vmlinuz} /srv/tftp/debian/bullseye
sudo mv debian-11.4.0-amd64-netinst.iso /srv/tftp/debian/bullseye
sudo umount /mnt

# get xubuntu (desktop) - note Canadian mirror
wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/xubuntu-22.04.1-desktop-amd64.iso

# set up the Xubuntu directory structure
sudo mount xubuntu-22.04.1-desktop-amd64.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
sudo mv xubuntu-22.04.1-desktop-amd64.iso /srv/tftp/xubuntu/jammy/desktop
sudo umount /mnt

# get fedora (GNOME)
wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-36-1.5.iso

# Set up the Fedora Desktop structure
sudo mount Fedora-Workstation-Live-x86_64-36-1.5.iso /mnt
sudo cp /mnt/isolinux/{initrd.img,vmlinuz} /srv/tftp/fedora/36/desktop
sudo mv Fedora-Workstation-Live-x86_64-36-1.5.iso /srv/tftp/fedora/36/desktop
sudo umount /mnt

# Get fedora (server)
wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/x86_64/iso/Fedora-Server-netinst-x86_64-36-1.5.iso

sudo mount Fedora-Server-netinst-x86_64-36-1.5.iso /mnt
sudo cp /mnt/isolinux/{initrd.img,vmlinuz} /srv/tftp/fedora/36/server
sudo mv Fedora-Server-netinst-x86_64-36-1.5.iso /srv/tftp/fedora/36/server
sudo umount /mnt


# open port 69/udp on the local machine firewall
sudo ufw allow 69/udp



