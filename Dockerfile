FROM ubuntu:focal

# Change APT Source for Chinese Users
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list 
RUN sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# Download basic build tools
RUN apt-get update \
    && apt-get install --yes --no-install-recommends wget unzip build-essential \
    git bc swig libncurses5-dev libpython3-dev libssl-dev pkg-config zlib1g-dev \
    libusb-dev libusb-1.0-0-dev python3-pip gawk 

# Create a no-passowrd sudo user
RUN apt update \
    && apt install -y sudo \
    && useradd -m lichee -s /bin/bash && adduser lichee sudo \
    && echo "lichee ALL=(ALL) NOPASSWD : ALL" | tee /etc/sudoers.d/nopasswd4sudo

RUN apt-get update \
    && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Download cross-compile toolchain
RUN wget http://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabi/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi.tar.xz \
    && tar -vxJf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi.tar.xz \ 
    && cp -r gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi /opt/ \
    && echo "PATH=\"$PATH:/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi/bin\"" > /etc/bash.bashrc

# Setting workdir and env
USER lichee
WORKDIR /home/lichee

RUN sudo apt-get update \ 
    && sudo apt-get install -y git zsh \
    && git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && echo "" >> ~/.zshrc \
    && echo "# Add compiler path for v3s" >> ~/.zshrc \
    && echo "PATH=\"$PATH:/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabi/bin\"" >> ~/.zshrc \
    && sudo usermod -s /bin/zsh lichee

RUN sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/zsh"]

ENV ARCH="arm" 
ENV CROSS_COMPILE="arm-linux-gnueabi-"

