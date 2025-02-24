# vivado-on-silicon-mac

Adapted from https://github.com/ichi4096/vivado-on-silicon-mac

## USB

Install Docker Desktop >= 4.35.0

```console
$ pip install libusb1
```

```console
$v(cd pyusbip && python pyusbip.py)
```

In the container,

```console
$ sudo nsenter -t 1 -m
```

```console
# usbip list -r host.docker.internal
```

```console
# usbip attach -r host.docker.internal -b 1-1
```

```console
# lsusb
```
