#!/usr/bin/env python3
"""Debug EEPROM access on FT2232H — test read, write, and readback of single words.

Usage:
    1. Boot with CS held high (factory defaults)
    2. Release CS
    3. Run: ./debug_eeprom.py
"""
import struct
import sys
from pyftdi.ftdi import Ftdi


def read_eeprom_raw(ftdi):
    """Read all 256 bytes via USB control transfers."""
    data = bytearray(256)
    usb = ftdi.usb_dev
    for addr in range(128):  # 128 words × 2 bytes = 256
        raw = usb.ctrl_transfer(
            0xC0,   # bmRequestType: vendor, device-to-host
            0x90,   # bRequest: READ_EEPROM
            0,      # wValue
            addr,   # wIndex: word address
            2,      # length
        )
        data[addr * 2] = raw[0]
        data[addr * 2 + 1] = raw[1]
    return bytes(data)


def write_eeprom_word(ftdi, addr, word):
    """Write one 16-bit word to EEPROM."""
    usb = ftdi.usb_dev
    usb.ctrl_transfer(
        0x40,   # bmRequestType: vendor, host-to-device
        0x91,   # bRequest: WRITE_EEPROM
        word,   # wValue: data
        addr,   # wIndex: word address
    )


def hexdump(data, label=""):
    if label:
        print(label)
    for i in range(0, len(data), 16):
        hex_part = ' '.join(f'{b:02x}' for b in data[i:i+16])
        print(f'  {i:04x}: {hex_part}')


def main():
    url = 'ftdi://ftdi:2232h/1'
    print(f"Opening {url}...")
    ftdi = Ftdi()
    ftdi.open_from_url(url)

    # Step 1: Read current EEPROM content
    print("\n=== Step 1: Read EEPROM (raw USB control transfers) ===")
    raw = read_eeprom_raw(ftdi)
    hexdump(raw, "Raw read via ctrl_transfer 0x90:")

    # Also try pyftdi's built-in read for comparison
    builtin = ftdi.read_eeprom()
    if raw != builtin:
        print("\nWARNING: raw read differs from ftdi.read_eeprom()!")
        hexdump(builtin, "ftdi.read_eeprom():")
    else:
        print("\nftdi.read_eeprom() matches raw read.")

    # Step 2: Write a test pattern to word 0 and read back
    print("\n=== Step 2: Write test pattern to word 0 ===")
    original_word0 = struct.unpack_from('<H', raw, 0)[0]
    test_word = 0x1234

    print(f"  Original word[0] = 0x{original_word0:04x}")
    print(f"  Writing  word[0] = 0x{test_word:04x}")
    write_eeprom_word(ftdi, 0, test_word)

    # Small delay — some EEPROMs need write cycle time
    import time
    time.sleep(0.1)

    # Read back
    readback = read_eeprom_raw(ftdi)
    rb_word0 = struct.unpack_from('<H', readback, 0)[0]
    print(f"  Readback word[0] = 0x{rb_word0:04x}")

    if rb_word0 == test_word:
        print("  >>> WRITE WORKS! Restoring original value...")
        write_eeprom_word(ftdi, 0, original_word0)
        time.sleep(0.1)
        check = read_eeprom_raw(ftdi)
        ck = struct.unpack_from('<H', check, 0)[0]
        print(f"  Restored word[0] = 0x{ck:04x} ({'OK' if ck == original_word0 else 'FAILED'})")
    elif rb_word0 == original_word0:
        print("  >>> Write had NO EFFECT — EEPROM may be write-protected (WP pin held low)")
    else:
        print(f"  >>> UNEXPECTED value — got 0x{rb_word0:04x}, expected 0x{test_word:04x} or 0x{original_word0:04x}")
        print("  Possible causes:")
        print("    - CS pin not fully released (still floating/high)")
        print("    - Bus contention (another device on the I2C/SPI bus)")
        print("    - EEPROM in bad state (needs power cycle)")

    # Step 3: Try reading multiple times to check stability
    print("\n=== Step 3: Read stability test (3 consecutive reads of word 0) ===")
    for i in range(3):
        r = read_eeprom_raw(ftdi)
        w = struct.unpack_from('<H', r, 0)[0]
        print(f"  Read {i}: word[0] = 0x{w:04x}")

    ftdi.close()
    print("\nDone.")


if __name__ == '__main__':
    main()
