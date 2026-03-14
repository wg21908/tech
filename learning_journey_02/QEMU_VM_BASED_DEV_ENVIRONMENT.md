# Virtual Machine (VM) Based Development Environment

## About this page

Update me!

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
    egrep -c '(vmx|svm)' /proc/cpuinfo                                           # CPU supports virtualization, above 0, your good

## Create Disk

    qemu-img create -f qcow2 practice.qcow2 40G

## Verify the Disk

    qemu-img info practice.qcow2

## Create VM Ready for Connection   

    sudo qemu-system-x86_64 \
        -enable-kvm \
        -machine q35 \
        -cpu host \
        -m 4096 \
        -smp 4 \
        -cdrom Rocky-9.7-x86_64-minimal.iso \
        -drive file=practice.qcow2,format=qcow2 \
        -boot d

## Install TigerVNC 

    dnf -y install tigervnc   

## Connect and Install Rocky Linux onto Disk

Open a new terminal, then run the following command, inside the VM run through the steps to install the OS

    vncviewer localhost:5900

## Close Window and Cleanup Processw

    ps aux | grep qemu | grep practice
    kill -9 <PID Identified above>

## Connect to VM with Installed OS

    sudo qemu-system-x86_64 \
        -enable-kvm \
        -cpu host \
        -m 2048 \
        -smp 2 \
        -kernel /boot/vmlinuz-7.0.0-rc1-practice-run-01+ -initrd /boot/initramfs-7.0.0-rc1-practice-run-01+.img \
        -append "root=/dev/rlm/root console=ttyS0 nokaslr earlyprintk=serial rd.shell panic=1" \
        -drive file=practice.qcow2,format=qcow2 \
        -nographic

    
