#!/bin/bash

if [ $# -ne 1 ]; then
 echo "One parameter required: the device of the serial interface"
 echo "$0 <device>"
 echo "e.g.:"
 echo "$0 ttyUSB0"
 exit 1
fi

DEVICE=$1

# check the serial connection

if [ ! -c $DEVICE ]; then
 echo "$DEVICE does not exist"
 exit 1
fi

if [ ! -f esptool.py ]; then
 echo "Cannot found the required tool:"
 echo "esptool.py"
 exit 1
fi

./esptool.py --port $DEVICE read_mac

if [ $? -ne 0 ]; then
 echo "Error reading the MAC -> set the device into the bootloader!"
 exit 1
fi

./esptool.py --port $DEVICE write_flash 0x00000 ESP01/0x00000.bin 0x10000 ESP01/0x10000.bin
