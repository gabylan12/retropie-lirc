#!/bin/bash

apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install lirc

rm first-boot.bash
