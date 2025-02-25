PROJECT_NAME = minimal-vitis-on-silicon-mac

DOCKER_CMD = docker run --init --rm -it --privileged --pid=host \
		-e DISPLAY=host.docker.internal:0 \
		-e LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-3.so.0" \
		-e JAVA_TOOL_OPTIONS="-Dsun.java2d.xrender=false" \
		-e JAVA_OPTS="-Dsun.java2d.xrender=false" \
		-v .:/mnt \
		--platform linux/amd64 $(PROJECT_NAME)

INIT_CMD = sudo mount -o loop /mnt/Xilinx.img /tools/Xilinx && source /tools/Xilinx/Vitis/2024.2/settings64.sh

.PHONY: docker
docker:
	docker build -t $(PROJECT_NAME) .

Xilinx.img.tmp:
	truncate -s 120G Xilinx.img
	$(DOCKER_CMD) bash -c "cd /mnt && mkfs.ext4 Xilinx.img.tmp"

Xilinx.img: Xilinx.img.tmp
	$(DOCKER_CMD) bash -c "cd /mnt && sudo mkdir -p /tools/Xilinx && sudo mount -o loop Xilinx.img.tmp /tools/Xilinx && sudo chown user:users /tools/Xilinx && ./install.sh"
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