#!/usr/bin/env bash
set -e

#
# PARAMETERS
# 1 - Name of the retropie image
# 2 - Name of the ssid wifi
# 3 - Wifi passowrd

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Switch to the script folder
cd $(dirname $0) || exit 1

timestamp() { date +"%F_%T_%Z"; }
echo_process() { echo -e "\e[1;94m$(timestamp) [kodi] $*\e[0m"; }

# LOG AND UMOUNT
exec &> >(tee -a "log/kodi-build-$(date +%Y-%m-%d_%H%M%S).log")

# Load config, create temporary build folder, cleanup
sourcefolder=.
buildfolder=/tmp/build-kodi-image
imagefile=target/kodi.img
rm -f $imagefile
umount $buildfolder/boot &>/dev/null || true
umount $buildfolder/root &>/dev/null || true
#rm -rf $buildfolder

# PRE-REQUISITES
echo_process "Downloading prerequisites... "
#apt update
#apt --yes install git wget curl unzip kpartx libarchive-zip-perl

#EXTRACT IMAGE
echo_process "Extract retropie image... "
mkdir -p target
gunzip -c $1 > $imagefile
qemu-img resize $imagefile +12G
#qemu-img resize $imagefile +5G

#MOUNT THE IMAGE
echo_process "Mounting the image for modifications... "
growpart $imagefile	 2
kpartx -asv $imagefile
e2fsck -f -y /dev/mapper/loop0p2
resize2fs /dev/mapper/loop0p2
mkdir -p $buildfolder/boot $buildfolder/root
dosfslabel /dev/mapper/loop0p1 "KODI"
mount -o rw -t vfat /dev/mapper/loop0p1 $buildfolder/boot
mount -o rw -t ext4 /dev/mapper/loop0p2 $buildfolder/root


#NETWORK SETTINGS
echo_process "Setting hostname, reactivating SSH... "
sed -i "s/127.0.1.1.*/127.0.1.1 $hostname/" $buildfolder/root/etc/hosts
echo "kodi" > $buildfolder/root/etc/hostname
touch $buildfolder/boot/ssh
echo 'network={' | sudo tee --append $buildfolder/root/etc/wpa_supplicant/wpa_supplicant.conf
echo "ssid=\"$2\"" | sudo tee --append $buildfolder/root/etc/wpa_supplicant/wpa_supplicant.conf
echo "psk=\"$3\"" | sudo tee --append $buildfolder/root/etc/wpa_supplicant/wpa_supplicant.conf
echo '}' | sudo tee --append $buildfolder/root/etc/wpa_supplicant/wpa_supplicant.conf


#FIRST-BOOT
echo_process "Injecting 'rc.local', 'first-boot.bash' and 'openhabian.conf'... "
#cp $sourcefolder/scripts/first-boot.bash $buildfolder/boot/first-boot.bash
cp $sourcefolder/scripts/first-boot.bash $buildfolder/root/home/pi/first-boot.bash

#LIRC
#/etc/modules
echo_process "setting lirc'... "

echo 'lirc_rpi gpio_out_pin=22' | sudo tee --append $buildfolder/root/etc/modules
#/etc/lirc/hardware.conf
mkdir -p $buildfolder/root/etc/lirc
cp $sourcefolder/lirc/hardware.conf $buildfolder/root/etc/lirc
#/boot/config
touch $buildfolder/root/boot/config.txt
echo 'dtoverlay=lirc-rpi,gpio_out_pin=22' | sudo tee --append $buildfolder/root/boot/config.txt
#/etc/lirc/lircd.conf
cp $sourcefolder/lirc/lircd.conf $buildfolder/root/etc/lirc


#INJECTING ROMS
echo_process "Injecting roms nes roms..."
tar -xvf $sourcefolder/roms/nes-roms.tar.gz --directory $buildfolder/root/home/pi/RetroPie/roms
echo_process "Injecting roms snes roms..."
tar -xvf $sourcefolder/roms/snes-roms.tar.gz --directory $buildfolder/root/home/pi/RetroPie/roms
echo_process "Injecting roms atari roms..."
tar -xvf $sourcefolder/roms/atari2600-roms.tar.gz --directory $buildfolder/root/home/pi/RetroPie/roms
echo_process "Injecting roms mame roms..."
tar -xvf $sourcefolder/roms/mame-mame4all-roms.tar.gz --directory $buildfolder/root/home/pi/RetroPie/roms
echo_process "Injecting roms megadrive roms..."
tar -xvf $sourcefolder/roms/megadrive-roms.tar.gz --directory $buildfolder/root/home/pi/RetroPie/roms

#CLOSE THE IMAGE
echo_process "Closing up image file... "
sync
umount $buildfolder/boot
umount $buildfolder/root
kpartx -dv $imagefile