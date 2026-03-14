# Learning Journey 02 — Development & Practice notes

This directory contains notes and walkthroughs for setting up a Linux kernel
development environment and performing a practice run. Read these in the
order below: first the environment setup, then the practice run. A third file
(`THE_REAL_DEAL.md`) describing an official ticket will be added soon.

Files
-
- [LINUX_NATIVE_BASED_DEV_ENV](LINUX_NATIVE_BASED_DEV_ENV.md):
  - Purpose: step-by-step host setup for building and contributing to the
    Linux kernel (Rocky Linux 9 in the author's case).
  - Key contents: resources/links used, assumptions, package installation
    checks, how to retrieve the kernel source, creating tags, copying an
    existing kernel config, using `scripts/config` to clear signed-key
    settings, `make olddefconfig`, build/install steps (`make -j$(nproc)`,
    `sudo make modules_install install`), and GRUB configuration tips for
    Rocky 9 (timeout/menu visibility).
  - Additional: detailed vim/email/git-send-email setup (including using a
    Google App Password), testing send-email, and a typical workflow for
    preparing and emailing patches.

- [QEMU_VM_BASED_TESTING](QEMU_VM_BASED_TESTING.md):
  - Intention: an upcoming file where I'll describe the steps to setup a Virtual Machine (VM)
    based Linux kernel develop environment.  This development environment will be based
    on the popular Linux QEMU technology.
    
- [PRACTICE_RUN](PRACTICE_RUN.md):
  - Purpose: a concise checklist for a practice change and verification loop.
  - Key contents: git basics (branching, fetching, rebasing), how to
    configure the kernel for a ticket (copying /boot config, setting
    CONFIG_LOCALVERSION), example of making a temporary change (example
    printk added to `drivers/bluetooth/btusb.c`), build/install steps,
    how to verify with `dmesg`, and how to revert the practice change
    (`git reset --hard HEAD`).

- THE_REAL_DEAL (coming soon):
  - Intention: an upcoming file where I'll describe an official ticket
    (C and/or Assembly changes) you work on for the Linux kernel, including
    the problem, design notes, and patch workflow.

How to use these notes
-
- Step 1.0: Follow the steps in [LINUX_NATIVE_BASED_DEV_ENV.md](LINUX_NATIVE_BASED_DEV_ENV.md)
  to prepare your Linux native kernel development environment and verify email/git tooling.
- Step 1.1: Follow the steps in [QEMU_VM_BASED_DEV_ENVIRONMENT.md](QEMU_VM_BASED_DEV_ENVIRONMENT.md)
  to prepare your QEMU/VM kernel development environment.
- Step 2: Use [PRACTICE_RUN.md](PRACTICE_RUN.md) to make a
  small, reversible change and exercise the build/send/test loop.
- Step 3: When `THE_REAL_DEAL.md` is added, use it as the reference for the
  official ticket workflow and to track the work you submit upstream.
  
## Questions / Support

Technical support is available when coffee is being supplied.

If you’d like to move forward, please [buy me a coffee](https://buymeacoffee.com/wg21908) and send me an email!
