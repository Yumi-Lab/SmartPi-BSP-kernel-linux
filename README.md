# SmartPi-BSP-kernel-linux

Minimal Board Support Package for [SmartPi One](https://www.yumi-lab.com) (Allwinner H3) — Buildroot-based, boots in 5 seconds.

The lightest possible Linux image for the SmartPi One. No desktop, no package manager, no bloat. Just a kernel, a shell, WiFi and SSH. The perfect starting point to build your own embedded project.

## Hardware

| Spec | Detail |
|------|--------|
| **Board** | SmartPi One (Yumi Lab) |
| **SoC** | Allwinner H3 — Cortex-A7 quad-core @ 1.2 GHz |
| **RAM** | 1 GB DDR3 (576 MHz, custom ZQ/ODT tuning) |
| **GPU** | Mali-400 MP2 (GLES 2.0) |
| **WiFi** | RTL8188EU (on-board) |
| **Storage** | MicroSD |
| **Video** | HDMI 1080p + Composite |

## What's inside

| Component | Detail | Size |
|-----------|--------|------|
| **Kernel** | Linux 6.6.56 LTS (mainline sunxi) | ~5 MB |
| **U-Boot** | 2023.01, nanopi_m1 + custom DRAM tuning | ~400 KB |
| **libc** | musl (lightweight, no glibc bloat) | ~600 KB |
| **Init** | BusyBox init (no systemd) | — |
| **Shell** | BusyBox ash + nano editor | ~1 MB |
| **WiFi** | wpa_supplicant + RTL8188EU firmware | ~1.2 MB |
| **SSH** | Dropbear (lightweight SSH server + client) | ~200 KB |
| **Network** | udhcpc (DHCP) + iproute2 + iptables | ~500 KB |
| **Monitoring** | htop | ~100 KB |
| **Total rootfs** | | **~15 MB** |

### What's NOT inside (by design)

- No systemd — BusyBox init, boots in seconds
- No apt/dpkg — no package manager overhead
- No glibc — musl libc, 3x lighter
- No NetworkManager — wpa_supplicant direct
- No man pages, locales, docs — bare minimum
- No desktop environment — console only

## Quick start

### Build

Requires a Linux x86_64 machine (native, VM, or WSL2). See [docs/BUILD-VM-SETUP.md](docs/BUILD-VM-SETUP.md) for Windows users.

```bash
git clone https://github.com/Yumi-Lab/SmartPi-BSP-kernel-linux.git
cd SmartPi-BSP-kernel-linux
make build
```

First build takes **~1-2 hours** (downloads + compiles the entire toolchain, kernel, and packages).
Subsequent rebuilds: **5-15 minutes** (Buildroot cache).

Output: `buildroot/output/images/sdcard.img`

### Flash

```bash
# Find your SD card device (e.g. /dev/sdb)
lsblk

# Flash (replace /dev/sdX with your device)
sudo dd if=buildroot/output/images/sdcard.img of=/dev/sdX bs=1M status=progress
sync
```

> **Warning**: Do NOT use Balena Etcher with Allwinner H3 images — use `dd` only.

### First boot

1. Insert SD card into SmartPi One, power on
2. Console available on **HDMI** or **UART** (ttyS0, 115200 baud)
3. Login: `root` / `yumi`

### Configure WiFi

```bash
# Generate WiFi config
wpa_passphrase "YourSSID" "YourPassword" > /etc/wpa_supplicant.conf

# Start WiFi
/etc/init.d/S45wifi start

# Check IP
ip addr show wlan0
```

### SSH access

From another machine on the same network:
```bash
ssh root@<SmartPi-IP>
```

## Customize

```bash
make menuconfig         # Add/remove Buildroot packages
make linux-menuconfig   # Kernel configuration
make build              # Rebuild image
```

### Add packages examples

Open `make menuconfig` and enable:
- **Python** → `BR2_PACKAGE_PYTHON3`
- **Node.js** → `BR2_PACKAGE_NODEJS`
- **Docker** → not recommended on 1GB RAM H3
- **Klipper** → custom package needed
- **GPIO tools** → `BR2_PACKAGE_LIBGPIOD` + `BR2_PACKAGE_LIBGPIOD_TOOLS`

## Project structure

```
SmartPi-BSP-kernel-linux/
├── configs/
│   └── smartpi_one_defconfig       # Buildroot defconfig (all build options)
├── board/smartpi-one/
│   ├── uboot.config.fragment       # U-Boot DRAM tuning (576MHz, ZQ, ODT)
│   ├── genimage.cfg                # SD card partition layout (boot + rootfs)
│   ├── post-build.sh               # Runs after rootfs build
│   ├── post-image.sh               # Generates final SD card image
│   ├── boot/
│   │   └── extlinux.conf           # Kernel boot parameters
│   └── rootfs-overlay/             # Files injected into the rootfs
│       └── etc/
│           ├── init.d/
│           │   ├── S40network      # Ethernet auto-start
│           │   └── S45wifi         # WiFi auto-start
│           └── issue               # Login banner
├── docs/
│   └── BUILD-VM-SETUP.md           # Build guide for Windows + Ubuntu VM
├── Makefile                        # Top-level build wrapper
└── .github/workflows/
    └── build.yml                   # CI build on self-hosted runner
```

## How it works

```
Power On
  → U-Boot (nanopi_m1 + SmartPi DRAM tuning)
    → Linux kernel 6.6 (sun8i-h3-nanopi-m1.dtb)
      → BusyBox init
        → S40network (Ethernet DHCP)
        → S45wifi (WiFi if configured)
        → Dropbear SSH
        → Login prompt (tty0/ttyS0)

Boot time: ~5 seconds to login prompt
RAM usage: ~30-50 MB idle
```

## Use cases

This BSP is a foundation layer. Build on top of it:

| Project | What to add |
|---------|-------------|
| **Retrogaming** | RetroArch, EmulationStation, libretro cores |
| **3D Printer (Klipper)** | Klipper, Moonraker, Fluidd/Mainsail |
| **IoT Gateway** | MQTT, Node-RED, GPIO tools |
| **Home automation** | Home Assistant core, Zigbee/Z-Wave |
| **Network appliance** | Pi-hole, WireGuard, hostapd |
| **Education** | Python, Jupyter, GPIO tutorials |

## Related projects

| Project | Description |
|---------|-------------|
| [RetroMi](https://github.com/Yumi-Lab/RetroMi) | Full retrogaming image (RetroPie + EmulationStation on Armbian) |
| [Batocera-SmartPiOne](https://github.com/Yumi-Lab/Batocera-SmartPiOne) | Batocera retrogaming distribution for SmartPi One |
| [SmartPi-armbian](https://github.com/Yumi-Lab/SmartPi-armbian) | Armbian-based server image for SmartPi One |

## Build requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **OS** | Linux x86_64 (Ubuntu 22.04+) | Ubuntu 24.04 |
| **Disk** | 15 GB | 30 GB |
| **RAM** | 4 GB | 8 GB |
| **CPU** | 2 cores | 4+ cores |
| **Time** | 2 hours | 1 hour (8 cores) |

## License

MIT — Free to use, modify, and redistribute.
