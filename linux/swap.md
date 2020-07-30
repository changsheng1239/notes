## Disable swap
1. swapoff -a
2. edit /etc/fstab and comment any swap entries if present.
3. sudo systemctl mask dev-sdXX.swap (where XX is the swap partition. Also useful to do it for all possible partitions so that if there is a swap partition on any other drive it will not be mounted)

## Enable swap
1. sudo systemctl unmask dev-sdXX.swap