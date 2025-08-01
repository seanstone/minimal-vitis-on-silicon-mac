# vivado-on-silicon-mac

Adapted from https://github.com/ichi4096/vivado-on-silicon-mac

## Setup

### Install Vitis

1. Build Docker image:
```console
make docker
```

2. Download [Vitis installer 2025.1](https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin) or [Vitis installer 2024.2](https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001_Lin64.bin)

3. Install Vitis:
```console
make VERSION=2024.2 Xilinx.img
```
If this step is interrupted or fails, remove `Xilinx.img` and try again.

### Build xvcd

```console
(cd xvcd && make)
```

---

## Usage

### Launch xvcd for JTAG over FTDI

```console
./xvcd/bin/xvcd -v
```

### Launch Vivado

```console
make VERSION=2024.2 vivado
```

### Launch Vitis

```console
make VERSION=2024.2 vitis
```

### Program the on-board FTDI chip

Install Docker Desktop >= 4.35.0

Then,

```console
pip install libusb1
```

```console
(cd pyusbip && python pyusbip.py)
```

In the container,

```console
sudo nsenter -t 1 -m
```

```console
usbip list -r host.docker.internal
```

```console
usbip attach -r host.docker.internal -b 1-1
```

```console
lsusb
```

```console
exit
```

```console
program_ftdi -write -ftdi FT2232H -serial 0ABC01 -vendor "my vendor co" -board "my board" -desc "my product desc"
```

---

## References

* https://github.com/ichi4096/vivado-on-silicon-mac
* https://docs.docker.com/desktop/features/usbip/
* https://github.com/ichi4096/vivado-on-silicon-mac/issues/52

---

## Issues

### Vitis may hang while using

Attempt to fix (does not work).

Modify vitis script (`/tools/Xilinx/2025.1/Vitis/bin/vitis`):
```bash
# $XILINX_VITIS/ide/electron-app/lnx64/vitis-ide --no-sandbox --log-level=debug $workspace_path ${analyzeArgs[@]} > /dev/null 2>&1 &
$XILINX_VITIS/ide/electron-app/lnx64/vitis-ide --no-sandbox --log-level=debug --disable-gpu --disable-software-rasterizer $workspace_path ${analyzeArgs[@]}
```

* https://github.com/ichi4096/vivado-on-silicon-mac/issues/37
* https://www.reddit.com/r/FPGA/comments/z2gqk2/vitis_hls_closing_immediately/
* https://adaptivesupport.amd.com/s/question/0D54U000091FX0XSAW/vitis-no-longer-opening-ubuntu-2404-vitis-20242?language=en_US
* https://www.hackster.io/whitney-knitter/fix-for-vitis-unified-2023-2-launching-into-blank-screen-4ab565
* https://github.com/electron/electron/issues/10345
* https://stackoverflow.com/questions/42898262/run-dbus-daemon-inside-docker-container
