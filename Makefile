MOUNT_DIR := /home/user/$(shell basename $(CURDIR))
IMAGE_DIR := $(MOUNT_DIR)

LD_PRELOAD += /lib/x86_64-linux-gnu/libudev.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libselinux.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libz.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libgdk-3.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libpcre2-8.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libpangocairo-1.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libpango-1.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libcairo-gobject.so.2
LD_PRELOAD += /lib/x86_64-linux-gnu/libgio-2.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libgobject-2.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libglib-2.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libfontconfig.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libXinerama.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libXi.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libXrandr.so.2
LD_PRELOAD += /lib/x86_64-linux-gnu/libXcursor.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libcap.so.2
LD_PRELOAD += /lib/x86_64-linux-gnu/libcairo.so.2
LD_PRELOAD += /lib/x86_64-linux-gnu/libfribidi.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libepoxy.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libxkbcommon.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libwayland-client.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libwayland-cursor.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libwayland-egl.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libX11.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libXext.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libXdamage.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libXfixes.so.3
LD_PRELOAD += /lib/x86_64-linux-gnu/libXcomposite.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libpangoft2-1.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libharfbuzz.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libthai.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libgmodule-2.0.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libpng16.so.16
LD_PRELOAD += /lib/x86_64-linux-gnu/libjpeg.so.8
LD_PRELOAD += /lib/x86_64-linux-gnu/libmount.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libffi.so.8
LD_PRELOAD += /lib/x86_64-linux-gnu/libfreetype.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libXrender.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libxcb.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libxcb-render.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libxcb-shm.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libpixman-1.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libgraphite2.so.3
LD_PRELOAD += /lib/x86_64-linux-gnu/libdatrie.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libblkid.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libbz2.so.1.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libbrotlidec.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libXau.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libXdmcp.so.6
LD_PRELOAD += /lib/x86_64-linux-gnu/libbrotlicommon.so.1
LD_PRELOAD += /lib/x86_64-linux-gnu/libbsd.so.0
LD_PRELOAD += /lib/x86_64-linux-gnu/libmd.so.0

DOCKER_CMD = docker run --init --rm -it --privileged --pid=host \
		-e DISPLAY=host.docker.internal:0 \
		-e LD_PRELOAD="$(LD_PRELOAD)" \
		-e JAVA_TOOL_OPTIONS="-Dsun.java2d.xrender=false" \
		-e JAVA_OPTS="-Dsun.java2d.xrender=false" \
		-v .:$(MOUNT_DIR) \
		--platform linux/amd64 minimal-vitis-on-silicon-mac

INIT_CMD = sudo mount -o loop $(IMAGE_DIR)/Xilinx.img /tools/Xilinx && source /tools/Xilinx/Vitis/2024.2/settings64.sh

.PHONY: docker
docker:
	docker build -t minimal-vitis-on-silicon-mac .

Xilinx.img.tmp:
	truncate -s 120G Xilinx.img
	$(DOCKER_CMD) bash -c "mkfs.ext4 $(IMAGE_DIR)/Xilinx.img.tmp"

Xilinx.img: Xilinx.img.tmp
	$(DOCKER_CMD) bash -c "sudo mkdir -p /tools/Xilinx && sudo mount -o loop $(IMAGE_DIR)/Xilinx.img.tmp /tools/Xilinx && sudo chown user:users /tools/Xilinx && (cd $(IMAGE_DIR) && ./install.sh)"
	mv Xilinx.img.tmp Xilinx.img

.PHONY: bash
bash:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && bash"

.PHONY: vivado
vivado:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && vivado"

.PHONY: vitis
vitis:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && vitis"