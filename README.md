# deploy-pxe
Deploy a PXE sever on Ubuntu Server 22.04, downloads tfptd, syslinux, pxelinux, and several ISOs, then sets up directories for each with vmlinuz, initrd, and the ISO files.

09/09/2022 - this is an unfinished script, things todo:

- set up pxelinux.cfg/default
- set up apache2 for deployment of live images
- set up automatic installations
