FROM --platform=linux/amd64 ubuntu:24.04
RUN apt update && apt upgrade -y

# create user "user" with password "pass"
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:pass" | chpasswd'

# sudo
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# dependencies for Vivado
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    python3-pip python3-dev build-essential git gcc-multilib g++ \
    ocl-icd-opencl-dev libjpeg62-dev libc6-dev-i386 graphviz make \
    unzip libtinfo6 xvfb libncursesw6 locales libswt-gtk-4-jni

# dependencies for Vitis
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libnss3 libasound2t64 libsecret-1-0 \
    libxtst6 file \
    libgtk2.0-0 libswt-gtk-4-java xorg \
    x11-utils libpcre3

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xdg-utils

# misc utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ncdu usbutils iputils-ping htop nano

# misc utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bison flex libncurses-dev

# dependencies for buildroot
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget cpio rsync bc

# dependencies for uboot
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libssl-dev uuid-dev libgnutls28-dev

# dependencies for genimage
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    mtools

# Set the locale, because Vivado crashes otherwise
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN mkdir -p /tools/Xilinx

USER user
WORKDIR /home/user

RUN mkdir -p /home/user/images