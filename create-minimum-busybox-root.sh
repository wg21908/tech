#!/bin/bash

#
# Script should be run as $USER, not with sudo
#

sudo chown -R $USER:$USER $HOME/rootfs

mkdir -p ~/rootfs/{bin,sbin,etc,proc,sys,usr/bin,usr/sbin}
cp -u ~/rootfs/bin/busybox ~/rootfs/bin/

if [ ! -L "$HOME/rootfs/bin/sh" ] && [ ! -e "$HOME/rootfs/bin/sh" ]; then
  ln -s "$HOME/rootfs/bin/busybox" "$HOME/rootfs/bin/sh"
else
  echo "Link or file $HOME/rootfs/bin/sh already exists, skipping."
fi

cat <<'EOF' > ~/rootfs/init
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "Welcome to QEMU test shell!"
exec /bin/sh
EOF
chmod +x ~/rootfs/init
