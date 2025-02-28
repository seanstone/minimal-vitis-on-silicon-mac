# vivado-on-silicon-mac

Adapted from https://github.com/ichi4096/vivado-on-silicon-mac

## Install Vitis

1. Build Docker image:
```console
make docker
```

2. Download [Vitis installer](https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001_Lin64.bin)

3. Install Vitis:
```console
make Xilinx.img
```

4. Modify vitis script (bin/vitis):
```bash
--gui|-g)
      # $XILINX_VITIS/ide/electron-app/lnx64/vitis-ide --no-sandbox --log-level=debug ${analyzeArgs[@]} > /dev/null 2>&1 &
      $XILINX_VITIS/ide/electron-app/lnx64/vitis-ide --no-sandbox --log-level=debug ${analyzeArgs[@]}
      exit $?
      ;;
```

## USB/IP

Install Docker Desktop >= 4.35.0

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

## xvcd

```console
(cd xvcd && make)
```

```console
./xvcd/bin/xvcd -v
```

In the container,

```console
source /tools/Xilinx/Vivado/2024.2/settings64.sh
```

```console
hw_server -e "set auto-open-servers xilinx-xvc:host.docker.internal:2542" &
```

## References

* https://github.com/ichi4096/vivado-on-silicon-mac
* https://github.com/ichi4096/vivado-on-silicon-mac/issues/37
* https://www.reddit.com/r/FPGA/comments/z2gqk2/vitis_hls_closing_immediately/
* https://docs.docker.com/desktop/features/usbip/
* https://github.com/ichi4096/vivado-on-silicon-mac/issues/52
* https://adaptivesupport.amd.com/s/question/0D54U000091FX0XSAW/vitis-no-longer-opening-ubuntu-2404-vitis-20242?language=en_US
* https://www.hackster.io/whitney-knitter/fix-for-vitis-unified-2023-2-launching-into-blank-screen-4ab565
* https://github.com/electron/electron/issues/10345
* https://stackoverflow.com/questions/42898262/run-dbus-daemon-inside-docker-container
