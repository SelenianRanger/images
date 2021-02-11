# ----------------------------------
# Generic Wine image w/ steamcmd support
# Environment: Ubuntu 18.04 + WineHQ
# Minimum Panel Version: 0.7.9
# ----------------------------------
FROM debian:buster-slim

LABEL author="Sina" maintainer="selenianranger@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

## Add i386 arch
RUN dpkg --add-architecture i386 \
 && apt update -y \
 && apt upgrade -y

## install required packages
RUN apt install -y --no-install-recommends iproute2 wget curl lib32gcc1 libntlm0 ca-certificates winbind xvfb tzdata locales xauth gnupg2 software-properties-common

## Install winehq-stable and with recommends
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
 && apt-add-repository 'deb http://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
 && wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key | apt-key add - \
 && echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04 ./" > /etc/apt/sources.list.d/wine-obs.list \
 && apt-get update \
 && apt install -y --install-recommends winehq-stable

## Set up Winetricks
RUN	wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
 && chmod +x /usr/sbin/winetricks \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && useradd -m -d /home/container container
 
## Remove unnecassary packages
RUN apt autoremove --purge && apt clean

ENV HOME=/home/container
ENV WINEPREFIX=/home/container/.wine
ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV DISPLAY_DEPTH=16
ENV AUTO_UPDATE=1
ENV XVFB=1

USER container
WORKDIR	/home/container

COPY ./entrypoint.sh /entrypoint.sh
CMD	["/bin/bash", "/entrypoint.sh"]