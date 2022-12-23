# initramfs as rootfs

## Reference
1. https://raspberrypi.stackexchange.com/questions/101720/run-raspbian-in-ram
2. https://lyngvaer.no/log/create-linux-initramfs


## Steps to build
1. Download [boot](https://downloads.raspberrypi.org/raspios_lite_armhf/boot.tar.xz) and [root](https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz) from [rpi download site](https://downloads.raspberrypi.org/raspios_lite_armhf/).

2. Untar files from step 1.
    ```shell
    mkdir -p boot root && \
    tar -xf boot.tar.xz -C boot && \
    tar -xf root.tar.xz -C root
    ```

2. Build `root` partition into `initramfs` (.cpio.gz format archive)
    ```shell
    cd root && \
    find . | cpio -ov --format=newc | gzip -9 > initrd
    ```

3. Copy `initrd` from step 2 into boot folder.
    ```shell
    cp initrd ../boot
    ```

4. Edit `config.txt` and add this line at the end.
    ```shell
    initramfs initrd followkernel
    ```

5. Edit `cmdline.txt` as below.
    ```shell
    console=serial0,115200 console=tty1 elevator=deadline rootwait dwc_otg.lpm_enable=0 rootfstype=ramfs
    ```

6. Format usb/sdcard as `fat` partition and copy content of `boot` folder into it.

7. Boot Raspberry Pi from the usb/sdcard. First boot took longer due to unpacking the whole rootfs into initramfs. Once booted up, the sdcard/usb can be unplug without issue. Poweroff will flush everything out of memory. 

## Issues
1. Right now the rootfs is mounted as `ramfs` through initramfs. 
Downside of using `ramfs`:
    - Lack of proper filestorage support. e.g.: `df -h` won't list `ramfs`. 
        ```shell
        pi@raspberrypi:~ $ df -aT
        Filesystem     Type        1K-blocks  Used Available Use% Mounted on
        none           rootfs              0     0         0    - /         <-
        sysfs          sysfs               0     0         0    - /sys
        proc           proc                0     0         0    - /proc
        devtmpfs       devtmpfs      3779208     0   3779208   0% /dev
        ...
        ...
        ```
    - Only possible way to check the usage is through `top` memory buffer. 
        ```shell
        Tasks: 127 total,   1 running, 126 sleeping,   0 stopped,   0 zombie
        %Cpu(s):  0.2 us,  0.3 sy,  0.0 ni, 99.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
        MiB Mem :   7874.9 total,   6630.0 free,     50.2 used,   1194.8 buff/cache  <-
        MiB Swap:      0.0 total,      0.0 free,      0.0 used.   6497.3 avail Mem
        ```
    - `ramfs` will consumed all available memory if not carefully monitored and causes OOM kill.

2. if `rootfstype=ramfs` is not specified in `cmdline.txt`, `tmpfs` (**not 100% sure yet**) will be used instead of ramfs. Only 50% of ram will be utilized as rootfs but one severe issue is the number of inode is only 25k which is way too less (not even enough for raspbian to run correctly.)
