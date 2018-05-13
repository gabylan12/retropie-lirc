#!/bin/bash

apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install lirc

echo 'dtoverlay=lirc-rpi,gpio_out_pin=22' | sudo tee --append /boot/config.txt
sed -i -e 's/\#listen         \= \[address\:\]port/listen \= 0.0.0.0\:8765/g' /etc/lirc/lirc_options.conf
rm first-boot.bash
