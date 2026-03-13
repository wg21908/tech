#!/bin/bash

cd ~/rootfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /home/secra/git/linux/initramfs.cpio.gz
