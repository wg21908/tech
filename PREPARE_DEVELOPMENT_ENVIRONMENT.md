# Linux Kernel Development Environment Setup

## Resources 

This document is based on following resources.  I converted steps to be applicable to Rocky Linux 9.  

1. https://kernelnewbies.org/OutreachyfirstpatchSetup
2. https://kernelnewbies.org/FirstKernelPatch

## Assumption(s)

- Host is Rocky Linux version 9

## Setup 1

The content that follows comes from the first resource defined in Resources section.

### Verify important packages

Run the script at https://github.com/wg21908/kernel-newbie/blob/main/scripts/check_versions.sh to identify what software you might be missing.  Install needed software.

### Install important packages

Your case may be different, install what you need!  Below is what I needed!  

    sudo dnf install ctags gitk esmtp mutt git-email  

### Verify important packages

Redo step 1 to ensure all software is now present

### Retrieve Linux Kernel Source and Prepare for Build

    cd $HOME/git && mkdir -p kernels; cd kernels
    git clone -b staging-testing git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git
    cd staging

### Make ctags

    make tags

### Duplicating your current config

    cp /boot/config-$(uname -r) .config`
    
    # In $HOME/git/kernels/staging/.config file, I updated line to be CONFIG_LOCALVERSION="-wgibbs-test-01"

### Changes to avoid error when copying config from source Rocky Linux distro

    scripts/config --file .config --set-str SYSTEM_TRUSTED_KEYS ""
    scripts/config --file .config --set-str SYSTEM_REVOCATION_KEYS ""

### Silently update any new configuration values to their default

    make olddefconfig

### Building the kernel

    make -j$(nproc)

### Installing the kernel

    sudo make modules_install install

### Verify the new kernel got a boot entry

    sudo grubby --default-kernel
    sudo grubby --info=ALL | less

### GRUB menu to always be visible on Rocky 9

    sudo grub2-editenv - unset menu_auto_hide

### Longer GRUB Timeout

    sudo vi /etc/default/grub

    GRUB_TIMEOUT=60
    GRUB_TIMEOUT_STYLE=menu
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg

### Running the kernel

You will (usually) need to reboot into your new kernel. 

## Setup 2

The content that follows comes from the second resource defined in Resources section.
