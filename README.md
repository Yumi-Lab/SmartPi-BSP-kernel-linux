# SmartPi-BSP-kernel-linux

Minimal Board Support Package for SmartPi One (Allwinner H3) — Buildroot-based, boots in 5 seconds.

## What's inside

| Component | Detail |
|-----------|--------|
| **Kernel** | Linux 6.6.56 LTS (mainline sunxi) |
| **U-Boot** | 2023.01, nanopi_m1 + custom DRAM (576MHz) |
| **libc** | musl (lightweight) |
| **Init** | BusyBox init (no systemd) |
| **Shell** | BusyBox ash + nano |
| **WiFi** | wpa_supplicant + RTL8188EU firmware |
| **SSH** | Dropbear |
| **Network** | udhcpc + iproute2 |
| **Rootfs** | ~15 MB |

## Build

```bash
# On a Linux x86_64 machine (or self-hosted runner)
make build
```

First build takes ~1-2 hours. Output: `buildroot/output/images/sdcard.img`

## Flash

```bash
dd if=buildroot/output/images/sdcard.img of=/dev/sdX bs=1M status=progress
```

## First boot

1. Insert SD card, power on
2. Console on HDMI or UART (115200 baud)
3. Login: `root` / `yumi`
4. Configure WiFi:

```bash
wpa_passphrase "MySSID" "MyPassword" > /etc/wpa_supplicant.conf
/etc/init.d/S45wifi start
```

5. SSH from your PC: `ssh root@<IP>`

## Customize

```bash
make menuconfig         # Buildroot packages
make linux-menuconfig   # Kernel config
make build              # Rebuild
```

## Project structure

```
configs/smartpi_one_defconfig   # Buildroot config (kernel, packages, toolchain)
board/smartpi-one/
  ├── uboot.config.fragment     # DRAM tuning for SmartPi One
  ├── genimage.cfg              # SD card partition layout
  ├── post-build.sh             # Post-build hooks
  ├── post-image.sh             # Image generation
  ├── boot/extlinux.conf        # Boot config
  └── rootfs-overlay/           # Files injected into rootfs
       └── etc/init.d/          # Init scripts (network, wifi)
```

## License

MIT
