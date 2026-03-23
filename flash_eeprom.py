#!/usr/bin/env python3
"""Flash a known-good EEPROM binary to an FT2232H chip via PyFTDI.

Usage:
    ./flash_eeprom.py ftdi_dumps/pynqz2_ftdi.bin              # flash as-is
    ./flash_eeprom.py ftdi_dumps/pynqz2_ftdi.bin --serial MY01 # patch serial
    ./flash_eeprom.py ftdi_dumps/pynqz2_ftdi.bin --dry-run     # show what would be written

This bypasses Xilinx program_ftdi (which requires Docker/Linux) by writing
the raw EEPROM image directly via USB control transfers on macOS.
"""
import argparse
import struct
import sys
from pyftdi.ftdi import Ftdi


def compute_checksum(data: bytearray) -> int:
    """FT2232H EEPROM checksum: XOR each 16-bit word then rotate left by 1.

    Algorithm (from pyftdi/libftdi): seed 0xAAAA, for each word in 0x00..0x7E:
      checksum ^= word
      checksum = rotate_left_1(checksum)
    Result stored little-endian at 0xFE-0xFF.
    """
    chk = 0xAAAA
    for i in range(0, len(data) - 2, 2):
        chk ^= struct.unpack_from('<H', data, i)[0]
        chk = ((chk << 1) & 0xFFFF) | ((chk >> 15) & 1)
    return chk


def patch_serial(data: bytearray, new_serial: str):
    """Replace the serial number string in the EEPROM image.

    FTDI EEPROM string layout (FT2232H, 256-byte EEPROM):
      Byte 0x0E: offset (in bytes) to manufacturer string descriptor
      Byte 0x0F: length of manufacturer string descriptor
      Byte 0x10: offset to product string descriptor
      Byte 0x11: length of product string descriptor
      Byte 0x12: offset to serial string descriptor
      Byte 0x13: length of serial string descriptor

    Each string descriptor: [length_byte, 0x03, UTF-16LE chars...]
    """
    serial_offset = data[0x12]
    old_serial_len = data[0x13]

    # Build new USB string descriptor: [total_len, 0x03, UTF-16LE...]
    encoded = new_serial.encode('utf-16-le')
    new_desc_len = 2 + len(encoded)

    if new_desc_len > old_serial_len:
        print(f"ERROR: new serial '{new_serial}' ({new_desc_len}B) exceeds "
              f"allocated space ({old_serial_len}B)", file=sys.stderr)
        sys.exit(1)

    # Write descriptor
    data[serial_offset] = new_desc_len
    data[serial_offset + 1] = 0x03
    data[serial_offset + 2 : serial_offset + 2 + len(encoded)] = encoded

    # Zero-pad remainder
    pad_start = serial_offset + new_desc_len
    pad_end = serial_offset + old_serial_len
    for i in range(pad_start, pad_end):
        data[i] = 0x00

    # Update length in header
    data[0x13] = new_desc_len

    # Recompute checksum
    chk = compute_checksum(data)
    struct.pack_into('<H', data, len(data) - 2, chk)

    print(f"Patched serial: '{new_serial}' ({new_desc_len}B, was {old_serial_len}B)")


def hexdump(data: bytes, label: str = ""):
    if label:
        print(f"\n{label}")
    for i in range(0, len(data), 16):
        hex_part = ' '.join(f'{b:02x}' for b in data[i:i+16])
        print(f'  {i:04x}: {hex_part}')


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('binfile', help='EEPROM binary file (256 bytes)')
    parser.add_argument('--serial', help='Override serial number in the image')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show hex dump but do not write')
    parser.add_argument('--url', default='ftdi://ftdi:2232h/1',
                        help='PyFTDI device URL (default: ftdi://ftdi:2232h/1)')
    args = parser.parse_args()

    # Load binary
    with open(args.binfile, 'rb') as f:
        data = bytearray(f.read())

    if len(data) != 256:
        print(f"ERROR: expected 256 bytes, got {len(data)}", file=sys.stderr)
        sys.exit(1)

    # Verify source checksum
    expected_chk = struct.unpack_from('<H', data, 254)[0]
    actual_chk = compute_checksum(data)
    if expected_chk != actual_chk:
        print(f"WARNING: source checksum mismatch: file=0x{expected_chk:04x}, "
              f"computed=0x{actual_chk:04x}")

    print(f"Source: {args.binfile}")

    # Decode strings from the binary for display
    for name, off_idx in [('Manufacturer', 0x0E), ('Product', 0x10), ('Serial', 0x12)]:
        off = data[off_idx]
        length = data[off_idx + 1]
        if off and length > 2:
            desc_bytes = data[off + 2 : off + length]
            try:
                s = desc_bytes.decode('utf-16-le')
                print(f"  {name}: {s}")
            except UnicodeDecodeError:
                print(f"  {name}: (decode error)")

    # Patch serial if requested
    if args.serial:
        patch_serial(data, args.serial)

    hexdump(data, "EEPROM image to flash:")

    if args.dry_run:
        print("\n--dry-run: not writing to device.")
        return

    # Confirm
    print(f"\nAbout to write 256 bytes to {args.url}")
    resp = input("Proceed? [y/N] ")
    if resp.lower() != 'y':
        print("Aborted.")
        return

    # Open device
    ftdi = Ftdi()
    # Parse URL to get vid/pid
    ftdi.open_from_url(args.url)

    # Read current EEPROM for comparison
    current = ftdi.read_eeprom()
    diffs = sum(1 for a, b in zip(current, data) if a != b)
    print(f"Differences from current EEPROM: {diffs} bytes")

    # Write word-by-word via USB control transfers
    usb_dev = ftdi.usb_dev
    for i in range(0, 256, 2):
        word = struct.unpack_from('<H', data, i)[0]
        addr = i // 2
        usb_dev.ctrl_transfer(
            0x40,   # bmRequestType: vendor, host-to-device
            0x91,   # bRequest: WRITE_EEPROM
            word,   # wValue: data word
            addr,   # wIndex: word address
        )

    print("Write complete. Verifying...")

    # Verify
    verify = ftdi.read_eeprom()
    if verify == bytes(data):
        print("Verification OK — EEPROM matches.")
    else:
        mismatches = [(i, verify[i], data[i])
                      for i in range(256) if verify[i] != data[i]]
        print(f"VERIFICATION FAILED — {len(mismatches)} byte(s) differ:")
        for i, got, exp in mismatches[:10]:
            print(f"  0x{i:02x}: got 0x{got:02x}, expected 0x{exp:02x}")

    ftdi.close()
    print("\nDone. Unplug and replug the board for the new EEPROM to take effect.")


if __name__ == '__main__':
    main()
