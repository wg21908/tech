# Virtual Machine (VM) Based Development Environment

## About this page



## Resources

This document is based on the following resource. 

- https://kernelnewbies.org/OutreachyfirstpatchAlt?action=show&redirect=OPWfirstpatchAlt

## Steps

## Installation

I'm working on Rocky Linux 9.  It appears that everything is already installed at this point.  Either it was installed by default or I installed it in the past and don't remember.  In any case, the command below would get things installed for you.

    lscpu | grep Virtualization                                                  # This tells you if your system is capable of running QEMU
    sudo dnf -y install qemu-kvm qemu-img virt-install virt-manager              # This installs QEMU and other related useful software
    sudo dnf -y install virt-manager                                             # This installs the Qemu KVM User Interface.
    qemu-system-x86_64 --version                                                 # This tells you the installed version of QEMU
    lsmod | grep kvm                                                             # Check virtualization acceleration 

## Basic QEMU Command to Boot Your Custom Kernel

    qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -cpu host \
    -m 4096 \
    -smp 4 \
    -kernel /boot/vmlinuz-7.0.0-rc1-practice-run-01+ \
    -initrd /boot/initramfs-7.0.0-rc1-practice-run-01+.img \
    -append "root=/dev/sda1 console=ttyS0" \
    -nographic

    qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -m 4096 -smp 4 -kernel /boot/vmlinuz-7.0.0-rc1-practice-run-01+ -initrd /boot/initramfs-7.0.0-rc1-practice-run-01+.img -append "root=/dev/sda1 console=ttyS0" -nographic

## Create QEMU VM and Connect with TigerVNC

1. Downloading Rocky Linux 9 Minimal ISO from https://rockylinux.org/download
2. `cd ~/Downloads`
3. Run a Linux ISO with `qemu-system-x86_64 -machine q35 -m 4096 -smp 4 -cdrom Rocky-9.7-x86_64-minimal.iso -boot d`
4. Install TigerVNC with `dnf -y install tigervnc`
5. Connect to headless VM with TigerVNC with `vncviewer localhost:5900` 

## Create a Virtual Disk

- `qemu-img create -f qcow2 rockyvm.qcow2 40G`

## Install OS Into Disk

- `qemu-system-x86_64 -m 4096 -smp 4 -cdrom Rocky-9.iso -drive file=rockyvm.qcow2,format=qcow2 -boot d`

## Boot Installed VM

## Enable Hardware Acceleration

`qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -smp 4 -drive file=rockyvm.qcow2`

## Boot a Custom Kernel

This is one of the biggest reasons kernel developers use QEMU.  You can test: kernel modules, boot issues, new kernels, driver development without breaking your real machine.  Perfect for your Linux kernel experiments.

`qemu-system-x86_64 -kernel arch/x86/boot/bzImage -append "console=ttyS0 root=/dev/sda rw" -hda rootfs.img -nographic`

## Networking for VM

Default NAT networking

`qemu-system-x86_64 -enable-kvm -m 2048 -hda rockyvm.qcow2 -net nic -net user`

## Port Forwarding

Example: SSH into VM

- qemu-system-x86_64 -enable-kvm -m 2048 -hda rockyvm.qcow2 -net nic -net user,hostfwd=tcp::2222-:22
- SSH from host with `ssh localhost -p 2222`

## Snapshots

Changes disappear when VM shuts down.  Perfect for dangerous testing.

- Start VM in snapshot mode with `qemu-system-x86_64 -enable-kvm -m 2048 -hda rockyvm.qcow2 -snapshot`

## Run Headless

Output goes to terminal

- `qemu-system-x86_64 -enable-kvm -m 2048 -hda rockyvm.qcow2 -nographic`

## Emulate Other CPU Architectures

- ARM with `qemu-system-aarch64`
- Raspberry PI with `qemu-system-arm`
- RISC-V with `qemu-system-riscv64`

## Kernel Debugging

- Start kernel with gdb debugging: with `qemu-system-x86_64 -s -S -kernel bzImage`
- Then run `gdb vmlinux`
- Connect with `target remote :1234`

## GUI Alternative

Blah, blah, blah

    Run the Virtual Manager application with `virt-manager`
    Choose "Local install media (ISO image or CDROM)
    Choose Forward
    Click the Browse button 
    Click the 'Browse Local' button to downloaded ISO in ~/Downloads directory
    Open
    Forward
    Accept default Memory and CPUs then select Forward
    Accept default 'Enable storage for this virtual machine', 20.0 for 'Create a dsik image for the virtual machine', and leave 'Select or create custom image' unselected, then select Forward
    Either accept default Name or type in another name for your new VM, then select Forward
    Run through OS installation in the QEMU/KVM window to create the VM
    
