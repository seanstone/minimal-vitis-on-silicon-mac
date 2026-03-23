#!/usr/bin/env python3
from pyftdi.ftdi import Ftdi

# List connected FTDI devices first
Ftdi.show_devices()

# Open the device and read EEPROM
ftdi = Ftdi()
ftdi.open(vendor=0x0403, product=0x6010, interface=1)

# Read all 256 bytes of EEPROM
eeprom = ftdi.read_eeprom()
print(f"EEPROM size: {len(eeprom)} bytes")

# Print hex dump
for i in range(0, len(eeprom), 16):
    hex_part = ' '.join(f'{b:02x}' for b in eeprom[i:i+16])
    print(f'{i:04x}: {hex_part}')

ftdi.close()