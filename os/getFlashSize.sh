#!/bin/bash

if [ $# -ne 1 ]; then
 echo "One parameter required: the device of the serial interface"
 echo "$0 <device>"
 echo "e.g.:"
 echo "$0 /dev/ttyUSB0"
 exit 1
fi

DEVICE=$1

TMPFILE=espIDs.txt

echo "Read the manufacturer ID and a chip ID"
./esptool.py --port $DEVICE flash_id | tee $TMPFILE
manufactor=$(cat $TMPFILE | grep Manufacturer | cut -d ':' -f 2 | xargs)
device=$(cat $TMPFILE | grep Device | cut -d ':' -f 2 | xargs)

# Get the lookup table 
if [ ! -f  flashchips.h ]; then
    wget https://code.coreboot.org/p/flashrom/source/file/HEAD/trunk/flashchips.h
fi


echo "$manufactor $device"
exit 0
