OS := $(shell uname)
ifeq ($(OS),Darwin)

CURRENT_MAKEFILE_DIR := $(CURDIR)/$(dir $(lastword $(MAKEFILE_LIST)))

export VERSION ?= 2025.2

MAJOR_VERSION := $(word 1,$(subst ., ,$(VERSION)))
ifeq ($(shell test $(MAJOR_VERSION) -ge 2025; echo $$?),0)
VITIS_DIR := /tools/Xilinx/$(VERSION)/Vitis
else
VITIS_DIR := /tools/Xilinx/Vitis/$(VERSION)
endif

DOCKER_CMD = docker run --init --rm -it --privileged --pid=host \
		-e DISPLAY=host.docker.internal:0 \
		-e LD_PRELOAD="$(LD_PRELOAD)" \
		-e JAVA_TOOL_OPTIONS="-Dsun.java2d.xrender=false" \
		-e JAVA_OPTS="-Dsun.java2d.xrender=false" \
		-e DBUS_SESSION_BUS_ADDRESS="unix:path=/var/run/dbus/system_bus_socket" \
		-e XIL_DISABLE_WEBTALK=1 \
		-e VERSION="${VERSION}" \
		-v $(CURRENT_MAKEFILE_DIR)/Xilinx.img:/Xilinx.img \
		-v $(CURRENT_MAKEFILE_DIR)/start-hw-server.sh:/usr/bin/start-hw-server.sh \
		-v $(CURDIR):/home/user/$(shell basename $(CURDIR)) \
		$(DOCKER_VARS) \
		--platform linux/amd64 minimal-vitis-on-silicon-mac

INIT_CMD := sudo mount -o loop /Xilinx.img /tools/Xilinx \
	&& source $(VITIS_DIR)/settings64.sh \
	&& sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf \
	&& cd /home/user/$(shell basename $(CURDIR))

ifeq ($(dir $(lastword $(MAKEFILE_LIST))),./)
Xilinx.img:
	truncate -s 150G Xilinx.img
	$(DOCKER_CMD) bash -c "mkfs.ext4 /Xilinx.img"
	$(DOCKER_CMD) bash -c "sudo mkdir -p /tools/Xilinx && sudo mount -o loop /Xilinx.img /tools/Xilinx && sudo chown user:users /tools/Xilinx && (cd /home/user/$(shell basename $(CURDIR)) && ./install.sh)"
endif

.PHONY: docker
docker:
	docker build --platform=linux/amd64 -t minimal-vitis-on-silicon-mac $(CURRENT_MAKEFILE_DIR)

.PHONY: xvcd
xvcd: $(CURRENT_MAKEFILE_DIR)/xvcd/bin/xvcd
	$(CURRENT_MAKEFILE_DIR)/xvcd/bin/xvcd -v

$(CURRENT_MAKEFILE_DIR)/xvcd/bin/xvcd:
	$(MAKE) -C $(CURRENT_MAKEFILE_DIR)/xvcd

.PHONY: vitis-fix
vitis-fix:
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && cd $(VITIS_DIR)/lib/lnx64.o/Ubuntu/ \
		&& sudo mv libstdc++.so libstdc++.so.bkup \
		&& sudo mv libstdc++.so.6 libstdc++.so.6.bkup \
		&& sudo ln -s /lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6 \
		&& sudo ln -s /lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so \
		"

.PHONY: bash
bash:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && bash"

.PHONY: vivado
vivado:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && vivado"

# If this does not work, start Vitis by running bash first, then run vitis
.PHONY: vitis
vitis:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && vitis"

%:
	xhost +
	$(DOCKER_CMD) bash -c "$(INIT_CMD) && make $* $(MAKEOVERRIDES)"

endif
