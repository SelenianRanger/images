# ----------------------------------
# Generic Wine image w/ steamcmd support
# Environment: Debian 19 Buster + WineHQ
# Minimum Panel Version: 0.7.15
# ----------------------------------
FROM debian:buster-slim

LABEL author="Sina" maintainer="selenianranger@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Add i386 arch
RUN dpkg --add-architecture i386 \
 && apt update \
 && apt upgrade -y

## install required packages
RUN apt install -y --no-install-recommends iproute2 cabextract wget curl lib32gcc1 libntlm0 ca-certificates winbind xvfb tzdata locales xauth

# Install winehq-stable and with recommends
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
 && apt-add-repository https://dl.winehq.org/wine-builds/debian/ \
 && wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add - \
 && echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list \
 && apt-get update \
 && apt install -y --install-recommends winehq-stable

# Set up Winetricks
RUN	wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
 && chmod +x /usr/sbin/winetricks \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && useradd -m -d /home/container container
 
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
CMD	 ["/bin/bash", "/entrypoint.sh"]