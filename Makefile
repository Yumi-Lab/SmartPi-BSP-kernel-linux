BUILDROOT_VERSION = 2024.02.8
BUILDROOT_URL = https://buildroot.org/downloads/buildroot-$(BUILDROOT_VERSION).tar.gz
BUILDROOT_DIR = buildroot

.PHONY: all download configure build clean

all: build

download:
	@if [ ! -d "$(BUILDROOT_DIR)" ]; then \
		echo "Downloading Buildroot $(BUILDROOT_VERSION)..."; \
		wget -q $(BUILDROOT_URL) -O /tmp/buildroot.tar.gz; \
		tar xf /tmp/buildroot.tar.gz; \
		mv buildroot-$(BUILDROOT_VERSION) $(BUILDROOT_DIR); \
		rm /tmp/buildroot.tar.gz; \
	fi

configure: download
	@echo "Configuring SmartPi One BSP..."
	cp configs/smartpi_one_defconfig $(BUILDROOT_DIR)/configs/
	cp -r board/smartpi-one $(BUILDROOT_DIR)/board/
	cd $(BUILDROOT_DIR) && make smartpi_one_defconfig

build: configure
	@echo "Building SmartPi One BSP..."
	cd $(BUILDROOT_DIR) && make -j$$(nproc)
	@echo ""
	@echo "=== Build complete ==="
	@echo "Image: $(BUILDROOT_DIR)/output/images/sdcard.img"
	@echo "Flash: dd if=$(BUILDROOT_DIR)/output/images/sdcard.img of=/dev/sdX bs=1M"

menuconfig: configure
	cd $(BUILDROOT_DIR) && make menuconfig

linux-menuconfig: configure
	cd $(BUILDROOT_DIR) && make linux-menuconfig

clean:
	@if [ -d "$(BUILDROOT_DIR)" ]; then \
		cd $(BUILDROOT_DIR) && make clean; \
	fi

distclean:
	rm -rf $(BUILDROOT_DIR)
