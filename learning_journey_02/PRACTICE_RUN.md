# Practice Run

## Assumption(s)

- You've run through everything in the [Developer Setup README](learning_journey_02/README.md)
- You still have the local copy of git clone -b staging-testing git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git cloned to your machine

## Steps

### Git Basics

1. Go into correct part of the repository with `cd $HOME/git/kernels/staging`
2. See the current branch with `git branch`
3. Create my feature branch with `git checkout -b ticket-number-short-description`
4. Get the latest source with `git fetch origin`
5. View commits with `git log --oneline`
6. View the history of the staging repository with `git log origin/staging-testing`
7. Update our branch to include the changes in the staging tree. The safest way to do this is to "rebase" your branch with `git rebase origin/staging-testing`.

### Configure the Kernel

1. Duplicating my current configuration with `cp /boot/config-$(uname -r) .config`
2. In $HOME/git/kernels/staging/.config file, I updated line to be CONFIG_LOCALVERSION="-wgibbs-test-NN" where "wgibbs-test" should be a better very short description of ticket being worked and NN should be the numeric of the number of attempts it takes me to fix the issue. 
3. Changes to avoid error when copying config from source Rocky Linux distro with `scripts/config --file .config --set-str SYSTEM_TRUSTED_KEYS ""` and `scripts/config --file .config --set-str SYSTEM_REVOCATION_KEYS ""`
4. Silently update any new configuration values to their default with `make olddefconfig`


## Making Temporary Change

1. `vim drivers/bluetooth/btusb.c `
2. Find the probe function

         static int btusb_probe(struct usb_interface *intf,
                             const struct usb_device_id *id)
           {
                   struct usb_endpoint_descriptor *ep_desc;
                   struct gpio_desc *reset_gpio;
                   struct btusb_data *data;
                   struct hci_dev *hdev;
                   unsigned ifnum_base;
                   int i, err, priv_size;
           
                   printk(KERN_DEBUG "I can modify the Linux Kernel\n");

3. Save the file

### Compile the Kernel

1. Building the kernel with `make -j$(nproc)`
2. Install changes with `sudo make modules_install install`
3. Verify the new kernel got a boot entry with `sudo grubby --default-kernel` and `sudo grubby --info=ALL | less`
4. Set GRUB menu to always be visible on Rocky 9 with `sudo grub2-editenv - unset menu_auto_hide`
5. Set a longer GRUB Timeout with `sudo vi /etc/default/grub` and putting following settings in place.

    GRUB_TIMEOUT=60  
    GRUB_TIMEOUT_STYLE=menu  

6. Now, update grub with `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`
7. Now, you can run the kernel by reboot your machine and selecting the kernel from the grub menu, the kernel that you specified in step 2 of "Configure the Kernel" section

## Test the Changes

- `dmesg | less`
- Search for your printk in the log file by typing "/I can modify"

## Revert Changes

This is just a practice run, nothing official, so we will get rid up updates with `git reset --hard HEAD`

## Questions / Support

Technical support is available when coffee is being supplied.

If you’d like to move forward, please [buy me a coffee](https://buymeacoffee.com/wg21908) and send me an email!
