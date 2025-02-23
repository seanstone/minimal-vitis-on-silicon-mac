# vivado-on-silicon-mac

Adapted from https://github.com/ichi4096/vivado-on-silicon-mac

## usbip

Install Docker Desktop >= 4.35.0

```console
brew install rust
```

```console
(cd usbip && cargo build --examples)
```

```console
(cd usbip && env RUST_LOG=info cargo run --example host)
```