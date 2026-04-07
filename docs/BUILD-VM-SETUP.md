# Build VM Setup — Windows + Ubuntu VM

## Pré-requis hardware
- **Disque** : 200 GB minimum alloués à la VM
- **RAM** : 8 GB minimum (16 GB recommandé)
- **CPU** : 4 cores minimum (8 recommandé — build parallèle)

## 1. Installer la VM Ubuntu

### Option A : VirtualBox (gratuit)
1. Télécharger VirtualBox : https://www.virtualbox.org/
2. Télécharger Ubuntu 24.04 Server : https://ubuntu.com/download/server
3. Créer la VM : 200 GB disque dynamique, 8 GB RAM, 4+ CPU
4. Installer Ubuntu Server (pas besoin du desktop)

### Option B : WSL2 (plus simple, pas de VM)
```powershell
wsl --install -d Ubuntu-24.04
```
Attention : WSL2 a une limite de disque par défaut à 256 GB, suffisant.

## 2. Installer les dépendances build

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential gcc g++ git wget cpio unzip rsync bc \
  libncurses5-dev python3 python3-setuptools swig \
  dosfstools mtools genimage libconfuse-dev \
  file bison flex libssl-dev device-tree-compiler \
  u-boot-tools lzop libmp3lame-dev python3-dev \
  libglib2.0-dev qt5-default libssl-dev || true
```

## 3. Cloner les repos

```bash
# BSP (build rapide ~1-2h)
git clone https://github.com/Yumi-Lab/SmartPi-BSP-kernel-linux.git
cd SmartPi-BSP-kernel-linux
make build

# Batocera (build long ~4-8h)
git clone https://github.com/Yumi-Lab/Batocera-SmartPiOne.git
cd Batocera-SmartPiOne
make h3-build
```

## 4. Résultat

### BSP
```
SmartPi-BSP-kernel-linux/buildroot/output/images/sdcard.img
```

### Batocera
```
Batocera-SmartPiOne/output/h3/images/batocera/smartpi-one/batocera*.img
```

## 5. Flasher depuis Windows

Copier l'image de la VM vers Windows puis :
```bash
# Depuis la VM, partager via SCP ou dossier partagé
scp buildroot/output/images/sdcard.img user@windows-ip:/path/
```

Flasher avec **Rufus** ou **Win32DiskImager** sur la SD card.
Pour SmartPi One H3 : utiliser `dd` (pas Balena Etcher).

## Temps de build estimés

| Projet | Premier build | Rebuild (cache) |
|--------|--------------|-----------------|
| **SmartPi-BSP** | 1-2h | 5-15 min |
| **Batocera** | 4-8h | 1-2h |
