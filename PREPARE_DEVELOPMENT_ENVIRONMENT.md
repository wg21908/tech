# Linux Kernel Development Environment Setup

## Assumption(s)

- Host is Rocky Linux version 9

## Setup

### Verify important packages

Run the script at https://github.com/wg21908/kernel-newbie/blob/main/scripts/check_versions.sh to identify what software you might be missing.  Install needed software.

### Install important packages

Run `sudo dnf install gitk esmtp mutt git-email` to install missing software.  Your case may be different, install what you need!

### Verify important packages

Redo step 1 to ensure all software is now present

### Retrieve Linux Kernel Source and Prepare for Build

    cd $HOME/git && mkdir -p kernels; cd kernels
    git clone -b staging-testing git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git
    cd staging

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
