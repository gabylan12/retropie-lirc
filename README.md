# retropie-lirc
A script to create a retropie image with lirc installed


## create image

sudo bash create-image.bash $IMAGE_NAME $SSID $WIFI_PASSWORD

* $IMAGE_NAME is the name of the retropie image, you can download from https://retropie.org.uk/download/
* $SSID ssid  
* $WIFI_PASSWORD the wifi password

## emulate 

sudo bash emulate.bash 
 
## folders

### kernel
the kernel to emulate the image

### lirc

the lirc's files

### log

the output log

### roms

all the roms files in tar.gz format

### scripts

script to upload in the image

### target

the result image