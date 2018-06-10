#!/bin/bash
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi


apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install lirc

echo 'dtoverlay=lirc-rpi,gpio_out_pin=22' | sudo tee --append /boot/config.txt
sed -i -e 's/\#listen         \= \[address\:\]port/listen \= 0.0.0.0\:8765/g' /etc/lirc/lirc_options.conf
sed -i "s/device = auto/device = \/dev\/lirc0/" /etc/lirc/lirc_options.conf
/usr/share/lirc/lirc-old2new
rm first-boot.bash
