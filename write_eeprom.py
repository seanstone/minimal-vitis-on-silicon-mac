#!/usr/bin/env python3
from pyftdi.eeprom import FtdiEeprom

eeprom = FtdiEeprom()
eeprom.open('ftdi://ftdi:2232h/1')

eeprom.set_manufacturer_name('my vendor co')
eeprom.set_product_name('my product desc')
eeprom.set_serial_number('0ABC01')

# Commit to hardware
eeprom.commit(dry_run=False)