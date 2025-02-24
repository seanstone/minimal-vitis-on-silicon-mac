FROM --platform=linux/amd64 ubuntu:22.04
RUN apt update && apt upgrade -y && apt upgrade -y

# create user "user" with password "pass"
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:pass" | chpasswd'

# sudo
RUN apt install -y --no-install-recommends sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# dependencies for Vivado
RUN apt install -y --no-install-recommends \
    python3-pip python3-dev build-essential git gcc-multilib g++ \
    ocl-icd-opencl-dev libjpeg62-dev libc6-dev-i386 graphviz make \
    unzip libtinfo5 xvfb libncursesw5 locales libswt-gtk-4-jni

# install dependencies for Vitis
RUN apt-get install -y --no-install-recommends \
    libnss3 libasound2 libsecret-1-0 \
    libxtst6 file

# install x11-utils for xlsclients
RUN apt-get install -y --no-install-recommends \
    x11-utils

# install ncdu for calculating disk space usage
RUN apt-get install -y --no-install-recommends \
    ncdu

# install usbutils for lsusb
RUN apt-get install -y --no-install-recommends \
    usbutils

# Set the locale, because Vivado crashes otherwise
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN mkdir -p /tools/Xilinx

USER user

# Without this, Vivado will crash when synthesizing
ENV LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-3.so.0"