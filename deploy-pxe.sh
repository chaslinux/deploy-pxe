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
# 	
#		UEFI 64 bit filename: boot/bootx64.efi

# Note: I am not a programmer, nor a server admin. I just wrote this script to automate
# deployment of a simple PXE server.

# I believe most of this (pxelinux.cfg/default) is old, as there's a lot of references to
# setting up grub instead. This just worked for me. I'm happy to add better contributions.

#


STARTINGDIR=$(pwd)
HOSTNAME=$(cat /etc/hostname)
UBUNTUDESKTOP=ubuntu-22.04.1-desktop-amd64.iso
UBUNTUSERVER=ubuntu-22.04.1-live-server-amd64.iso
XUBUNTU=xubuntu-22.04.1-desktop-amd64.iso
KUBUNTU=kubuntu-22.04.1-desktop-amd64.iso
LUBUNTU=lubuntu-22.04.1-desktop-amd64.iso

echo "Updating the system before adding software..."
sudo apt update && sudo apt upgrade -y

# Install syslinux for non-UEFI and UEFI, plus tftpd
# We don't install a DHCP server since we're using our router
# for dhcp
echo "Installing syslinux-common, syslinux-efi, tftpd-hpa, pxelinux, and apache2..."
sudo apt install syslinux-common syslinux-efi tftpd-hpa pxelinux apache2 -y

echo "Copying syslinux and pxelinux files into the appropriate directories..."
cd /srv/tftp
sudo mkdir -p /srv/tftp/boot/grub
sudo mkdir -p /srv/tftp/boot/grub/x86_64-efi
sudo mkdir -p /srv/tftp/boot/syslinux/bios
sudo chown -R tftp:tftp /srv/tftp

# make the distribution directories
echo "Make directories to hold Ubuntu server/desktop, and Xubuntu desktop"
sudo mkdir -p /srv/tftp/ubuntu/jammy/{server,desktop}

# sudo mkdir -p /srv/tftp/xubuntu/jammy/desktop
# sudo mkdir -p /srv/tftp/kubuntu/jammy/desktop
# sudo mkdir -p /srv/tftp/lubuntu/jammy/desktop
# sudo mkdir -p /var/www/ubuntu/jammy/{server,desktop}
# sudo mkdir -p /var/www/xubuntu/jammy/desktop
# sudo mkdir -p /var/www/kubuntu/jammy/desktop
# sudo mkdir -p /var/www/lubuntu/jammy/desktop

# change to the current user home directory
echo "Downloading Ubuntu Server 22.04..."
cd ~
wget https://releases.ubuntu.com/22.04.1/$UBUNTUSERVER

# set up Ubuntu server software directory structure
echo "Mounting Ubuntu Server image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
sudo mount $UBUNTUSERVER /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/server
sudo cp /mnt/EFI/boot/bootx64.efi /srv/tftp/boot
sudo cp /mnt/EFI/boot/grubx64.efi /srv/tftp/boot
sudo cp /mnt/boot/grub/fonts/unicode.pf2 /srv/tftp/boot/grub/font.pf2
# sudo cp /mnt/boot/grub/grub.cfg /srv/tftp/boot/grub - disabled because we'll make our own later
sudo cp /mnt/boot/grub/x86_64-efi/{command.lst,crypto.lst,fs.lst,terminal.lst} /srv/tftp/boot/grub/x86_64-efi

sudo mv $UBUNTUSERVER /var/www/ubuntu/jammy/server
sudo umount /mnt

sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /srv/tftp/boot/syslinux/bios
sudo cp /usr/lib/syslinux/modules/bios/libutil.c32 /srv/tftp/boot/syslinux/bios
sudo cp /usr/lib/syslinux/modules/bios/menu.c32 /srv/tftp/boot/syslinux/bios
sudo cp /usr/lib/syslinux/modules/bios/vesamenu.c32 /srv/tftp/boot/syslinux/bios

# sudo cp /usr/lib/syslinux/modules/efi64/{ldlinux.e64,libutil.c32,menu.c32} /srv/tftp
# sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp
sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp

echo "Make the pxelinux.cfg directory and set up default file structure..."
sudo mkdir -p /srv/tftp/pxelinux.cfg
cd $STARTINGDIR
echo "UI boot/syslinux/bios/menu.c32" > default
# echo "LABEL Ubuntu Jammy 22.04 Desktop" >> default
# echo "	MENU LABEL Ubuntu Desktop" >> default
# echo "	KERNEL ubuntu/jammy/desktop/vmlinuz" >> default
# echo "	INITRD ubuntu/jammy/desktop/initrd" >> default
# echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/desktop/$UBUNTUDESKTOP" >> default
# echo "	TEXT HELP" >> default
# echo "		The Ubuntu 22.04 Desktop Live Image" >> default
# echo "	ENDTEXT" >> default

echo "LABEL Ubuntu Jammy 22.04 Server" >> default
echo "	MENU LABEL Ubuntu Server" >> default
echo "	KERNEL ubuntu/jammy/server/vmlinuz" >> default
echo "	INITRD ubuntu/jammy/server/initrd" >> default
# echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/server/$UBUNTUSERVER" >> default
echo "  APPEND ip=dhcp cloud-config-url=/dev/null url=http://$HOSTNAME/ubuntu/jammy/server/ubuntu-22.04.1-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://$HOSTNAME/ubuntu/jammy/server/" >> default
echo "	TEXT HELP" >> default
echo "		The Ubuntu 22.04 Server Live Image" >> default
echo "	ENDTEXT" >> default

# echo "LABEL Xubuntu Jammy 22.04 Desktop" >> default
# echo "	MENU LABEL Xubuntu Desktop" >> default
# echo "	KERNEL xubuntu/jammy/desktop/vmlinuz" >> default
# echo "	INITRD xubuntu/jammy/desktop/initrd" >> default
# echo "	APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://$HOSTNAME/xubuntu/jammy/desktop/$XUBUNTU" >> default
# echo "	TEXT HELP" >> default
# echo "		The Xubuntu 22.04 Desktop Live Image" >> default
# echo "	ENDTEXT" >> default

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

# Set up a simple grub.cfg right now just for Ubuntu Server installs
echo "set timeout=30" > grub.cfg

echo "loadfont unicode" >> grub.cfg

echo "set menu_color_normal=white/black" >> grub.cfg
echo "set menu_color_highlight=black/light-gray" >> grub.cfg

echo "menuentry \"Install Ubuntu Jammy (22.04)\" {" >> grub.cfg
echo "        set gfxpayload=keep" >> grub.cfg
echo "        linux   ubuntu/jammy/server/vmlinuz ip=dhcp cloud-config-url=/dev/null url=http://$HOSTNAME/ubuntu/jammy/server/ubuntu-22.04.1-live-server-amd64.iso autoinstall ds=\"nocloud-net;s=http://$HOSTNAME/ubuntu/jammy/server\"" >> grub.cfg
echo "        initrd  ubuntu/jammy/server/initrd" >> grub.cfg
echo "}" >> grub.cfg
# copy the grub.conf to the correct directory
sudo cp $STARTINGDIR/grub.cfg /srv/tftp/grub

# set up user-data file
echo "#cloud-config" > user-data
echo "autoinstall:" >> user-data
echo "  identity:" >> user-data
echo "    hostname: jammy-minimal" >> user-data
# note this password should be ubuntu, but may not work as I had a different result running mkpasswd --method=sha-512 ubuntu
echo "    password: \$6\$gnqbMUzHhQzpDEw.$.cCNVVDsDfj5Feebh.5O4VbOmib7tyjmeI2ZsFP7VK2kWwgJFbfjvXo3chpeAqCgXWVIW9oNQ/Ag85PR0IsKD/" >> user-data
echo "    username: ubuntu" >> user-data
echo "  version: 1" >> user-data
# set up meta-data
touch meta-data
sudo cp {user-data,meta-data} /var/www/ubuntu/jammy/server



# get Ubuntu Desktop
# echo "Downloading Ubuntu 22.04 desktop..."
# wget https://releases.ubuntu.com/22.04.1/$UBUNTUDESKTOP

# set up Ubuntu desktop directory structure
# echo "Mounting Ubuntu Desktop image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# sudo mount $UBUNTUDESKTOP /mnt
# sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/ubuntu/jammy/desktop
# sudo mv $UBUNTUDESKTOP /var/www/ubuntu/jammy/desktop
# sudo umount /mnt

# get Xubuntu (desktop) - note Canadian mirror
# echo "Downloading the Xubuntu 22.04 desktop image from Canada, eh..."
# wget http://mirror.csclub.uwaterloo.ca/xubuntu-releases/22.04/release/$XUBUNTU

# set up the Xubuntu directory structure
# echo "Mounting Xubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# sudo mount $XUBUNTU /mnt
# sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/xubuntu/jammy/desktop
# sudo mv $XUBUNTU /var/www/xubuntu/jammy/desktop
# sudo umount /mnt

# get Kubuntu (desktop) 
# echo "Downloading Kubuntu 22.04 Desktop image"
# wget https://cdimage.ubuntu.com/kubuntu/releases/22.04.1/release/$KUBUNTU

# set up the Kubuntu directory structure
# echo "Mounting Kubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# sudo mount $KUBUNTU /mnt
# sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/kubuntu/jammy/desktop
# sudo mv $KUBUNTU /var/www/kubuntu/jammy/desktop
# sudo umount /mnt

# get Lubuntu (desktop)
# echo "Downloading Lubuntu 22.04 Desktop image"
# wget https://cdimage.ubuntu.com/lubuntu/releases/22.04.1/release/$LUBUNTU

# set up the Lubuntu directory structure
# echo "Mounting Lubuntu image, copying vmlinuz, initrd, and the ISO to the appropriate directories..."
# sudo mount $LUBUNTU /mnt
# sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/lubuntu/jammy/desktop
# sudo mv $LUBUNTU /var/www/lubuntu/jammy/desktop
# sudo umount /mnt

# Disable the old apache config file and use the pxe-server.conf file
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
sudo cp $STARTINGDIR/pxe-server.conf /etc/apache/sites-available
sudo a2ensite pxe-server.conf
sudo systemctl restart apache2


# open port 69/udp on the local machine firewall
echo "Opening UDP port 69 on local firewall..."
sudo ufw allow 69/udp

# new stuff related to grub and UEFI secure booting - Oct 7, 2022
# this is shamelessly ripped from https://www.youtube.com/watch?v=E_OlsA1hF4k&t=17s 
# and will remain a comment until I can unpack all of this and convert it to simpler steps
# Some of this looks nasty (chmod 777 on /srv/tftp and incorrect)


# cd /tmp
# apt-get download shim.signed -y
# dpkg-deb --fsys-tarfile /tmp/shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed -O mark /srv/tftp/bootx64.efi

# apt download grub-efi-amd64-signed
# dpkg-deb --fsys-tarfile /tmp/grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O mark  /srv/tftp/grubx64.efi

# apt download grub-common
# dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O mark /srv/tftp/unicode.pf2

# mkdir -p /srv/tftp/grub

# This goes into separate file /srv/tftp/grub/grub.cfg

#default=autoinstall
#timeout=30
#timeout_style=menu
#menuentry "22 server Installer - automated" --id=autoinstall 
#    linux ubuntu/jammy/server/vmlinuz ip=dhcp url=http://$HOSTNAME/ubuntu/jammy/server/jammy-live-server-amd64.iso autoinstall ds='nocloud-net;s=http://$HOSTNAME/ubuntu/jammy/server' cloud-config-url=/dev/null root=/dev/ram0
#    echo "Loading Ram Disk..."
#    initrd ubuntu/jammy/server/initrd

# touch /srv/tftp/focal/meta-data

# You may generate your own password by:
#  mkpasswd --method=sha-512 ubuntu

#edit installation configure

# nano /srv/tftp/focal/user-data
##cloud-config < this stays a comment
#autoinstall:
#  version: 1
#  # use interactive-sections to avoid an automatic reboot
#  interactive-sections:
#    - locale
#  apt:
#    # even set to no/false, geoip lookup still happens
#    #geoip: no
#    preserve_sources_list: false
#    primary:
#    - arches: [amd64]
#      uri: http://fi.archive.ubuntu.com/ubuntu
#    - arches: [default]
#      uri: http://ports.ubuntu.com/ubuntu-ports
#  identity:
 # keyboard: 
  #locale: en_US.UTF-8
#  user-data:
#    timezone: Europe/Helsinki
  # interface name will probably be different
#  network:
#  ssh:
#    allow-pw: true
#    authorized-keys: []
#    install-server: true
  # this creates an efi partition, /boot partition, and root(/) lvm volume
#  storage:
#    config:

#CHECK links

#chown tftp: -R /srv/tftp/
#chmod 777 -R /srv/tftp/    <--- wtf no, don't let the world write here, that's crazy (chaslinux)


