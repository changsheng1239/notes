# [RPi Ramdisk](https://github.com/ali1234/rpi-ramdisk)

## Installation
### Prerequisite
```shell
# install pydo
apt install python3-pip
git clone git://github.com/ali1234/pydo
cd pydo && pip3 install .

# add multiarch support for i386
dpkg --add-architecture i386 && apt update

# install build dependencies
sudo apt install libc6:i386 libstdc++6:i386 libgcc1:i386 \
                 libncurses5:i386 libtinfo5:i386 zlib1g:i386 \
                 build-essential git bc python zip wget gettext \
                 autoconf automake libtool pkg-config autopoint \
                 bison flex libglib2.0-dev gobject-introspection \
                 multistrap fakeroot fakechroot proot cpio \
                 qemu-user binfmt-support makedev libssl-dev \
                 gtk-doc-tools valac python3.8-minimal

# import keys for multistrap apt
gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 9165938D90FDDD2E # raspbian-archive-keyring
gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 82B129927FA3303E # raspberrypi-archive-keyring
```

### Build
```shell
git clone https://github.com/ali1234/rpi-ramdisk.git
cd rpi-ramdisk && git submodule update --init --recursive
pydo --init
cp configs/qmldemo.config.py config.py
pydo :build

```
