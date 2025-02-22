PROJECT_NAME = minimal-vitis-on-silicon-mac
MOUNT_XILINX = 

.PHONY: docker
docker:
	docker build -t $(PROJECT_NAME) .

Xilinx.img:
	truncate -s 120G Xilinx.img.tmp
	docker run --init --rm -it --privileged \
		-e DISPLAY=host.docker.internal:0 \
		-v .:/mnt \
		--platform linux/amd64 $(PROJECT_NAME) \
		sudo -H -u user bash -c "cd /mnt && mkfs.ext4 Xilinx.img.tmp && sudo mkdir -p /tools/Xilinx && sudo mount -o loop Xilinx.img.tmp /tools/Xilinx && sudo chown user:users /tools/Xilinx && ./install.sh"
		mv Xilinx.img.tmp Xilinx.img

.PHONY: docker-bash
docker-bash:
	docker run --init --rm -it --privileged \
		-e DISPLAY=host.docker.internal:0 \
		-v .:/mnt \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--platform linux/amd64 $(PROJECT_NAME) \
		sudo -H -u user bash -c "cd /mnt && sudo mount -o loop Xilinx.img /tools/Xilinx && bash"

.PHONY: docker-vivado
docker-vivado:
	xhost +
	docker run --init --rm -it --privileged \
		-e DISPLAY=host.docker.internal:0 \
		-v .:/mnt \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--platform linux/amd64 $(PROJECT_NAME) \
		sudo -H -u user bash -c "cd /mnt && sudo mount -o loop Xilinx.img /tools/Xilinx && ./start_vivado.sh"

.PHONY: docker-vitis-hls
docker-vitis-hls:
	xhost +
	docker run --init --rm -it --privileged \
		-e DISPLAY=host.docker.internal:0 \
		-v .:/mnt\
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--platform linux/amd64 $(PROJECT_NAME) \
		sudo -H -u user bash -c "cd /mnt && sudo mount -o loop Xilinx.img /tools/Xilinx && ./start_vitis_hls.sh"