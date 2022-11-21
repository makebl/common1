#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) ImmortalWrt.org


function install_mustrelyon(){
sudo apt-get update -y
sudo apt-get full-upgrade -y
sudo apt-get install -y rename ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
}

function update_apt_source(){
sudo apt-get install -y apt-transport-https gnupg2
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get install -y nodejs gcc g++ make
sudo apt-get update -y
sudo apt-get install -y yarn

node --version
yarn --version
}

function install_dependencies(){
svn co -r96154 "https://github.com/openwrt/openwrt/trunk/tools/padjffs2/src" "padjffs2"
pushd "padjffs2"
make
rm -rf "/usr/bin/padjffs2"
cp -fp "padjffs2" "/usr/bin/padjffs2"
popd

svn co -r19250 "https://github.com/openwrt/luci/trunk/modules/luci-base/src" "po2lmo"
pushd "po2lmo"
make po2lmo
rm -rf "/usr/bin/po2lmo"
cp -fp "po2lmo" "/usr/bin/po2lmo"
popd

curl -fL "https://build-scripts.immortalwrt.eu.org/modify-firmware.sh" -o "/usr/bin/modify-firmware"
chmod 0755 "/usr/bin/modify-firmware"
popd

sudo apt-get autoremove -y --purge
sudo apt-get clean
}

function main(){
	install_mustrelyon
	update_apt_source
	install_dependencies
}

main
