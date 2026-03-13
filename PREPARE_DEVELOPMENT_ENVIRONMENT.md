# Linux Kernel Development Environment Setup

## Assumption(s)

- Host is Rocky Linux version 9

## Setup

1. Run the script at https://github.com/wg21908/kernel-newbie/blob/main/scripts/check_versions.sh to identify what software you might be missing.  Install needed software.
2. Run `sudo dnf install gitk esmtp mutt git-email` to install missing software.  Your case may be different, install what you need!
3. Redo step 1 to ensure all software is now present
4. `cd $HOME/git && mkdir -p kernels; cd kernels`
5. `git clone -b staging-testing git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git`
6. `cd staging`
7. `cp /boot/config-$(uname -r) .config`
8. In $HOME/git/kernels/staging/.config file, I updated line to be `CONFIG_LOCALVERSION="-wgibbs-test-01"`
