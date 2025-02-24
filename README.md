# vivado-on-silicon-mac

Adapted from https://github.com/ichi4096/vivado-on-silicon-mac

## USB

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
./bin/xvcd -v
```

In the container,

```console
source /tools/Xilinx/Vivado/2024.2/settings64.sh
```

```console
hw_server -e "set auto-open-servers xilinx-xvc:host.docker.internal:2542" &
```
