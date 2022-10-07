FROM ubuntu:20.04

RUN apt-get update \
    && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Change APT Source for Chinese Users
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# Download basic build tools
RUN apt-get install --yes --no-install-recommends wget unzip build-essential \
    git bc swig libncurses5-dev libpython3-dev libssl-dev pkg-config zlib1g-dev \
    libusb-dev libusb-1.0-0-dev python3-pip gawk \
    && rm -rf /var/lib/apt/lists/*

# Download cross-compile toolchain
RUN wget http://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabi/gcc-linaro-7.5-2019.12-x86_64_arm-linux-gnueabi.tar.xz \
    && tar -vxJf gcc-linaro-7.5-2019.12-x86_64_arm-linux-gnueabi.tar.xz \ 
    && cp -r gcc-linaro-7.5-2019.12-x86_64_arm-linux-gnueabi /opt/ \
    && echo "PATH=\"$PATH:/opt/gcc-linaro-7.5-2019.12-x86_64_arm-linux-gnueabi/bin\"" > /etc/bash.bashrc

# Setting workdir and env
WORKDIR /home/lichee

ENV ARCH="arm" 
ENV CROSS_COMPILE="arm-linux-gnueabi-"

