#!/bin/bash

#
# Script should be run as $USER, not with sudo
#

#
# Since I build Linux kernel as root, we need to give user 
#   and group ownership so that qemu will have proper access to it
#
sudo chown $USER:$USER $HOME/git/linux/arch/x86/boot/bzImage

qemu-system-x86_64 \
  -kernel $HOME/git/linux/arch/x86/boot/bzImage \
  -initrd $HOME/git/linux/initramfs.cpio.gz \
  -append "console=ttyS0 rdinit=/init" \
  -serial mon:stdio -s -S \
  -nographic
