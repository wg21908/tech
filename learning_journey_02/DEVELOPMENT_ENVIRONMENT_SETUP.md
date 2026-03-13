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

    sudo dnf install ctags gitk msmtp mutt git-email  

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

### Setup vim

    touch ~/.vimrc

    # Add Content below to file and save
    filetype plugin indent on
    syntax on
    set title
    set tabstop=8
    set softtabstop=8
    set shiftwidth=8
    set noexpandtab

    # Setup vim as the default editor
    sudo update-alternatives --config editor

### Setup email

1. FYI: git send-email, mutt, and esmtp were installed earlier
2. In your Google account: Turn on 2-Step Verification, Create an app password, and Save that 16-character app password for the configs below.  FYI: While signed in to wg21908@gmail.com Gmail account, go to other browser tab and search "Google App Passwords" to get to page to manage this part.  Appears to be at https://myaccount.google.com/apppasswords, I was able to name my new App Password a name that reflected machine that was making use of it.
3. Copy https://github.com/wg21908/kernel-newbie/blob/main/mail_configs/.msmtprc to $HOME/, then make appropriate modifications
4. chmod 600 ~/.msmtprc
5. Copy https://github.com/wg21908/kernel-newbie/blob/main/mail_configs/.muttrc to $HOME/, then make appropriate modifications
6. chmod 600 ~/.muttrc
7. mkdir -p ~/Mail/inbox/{cur,new,tmp}
8. mkdir -p ~/Mail/sent/{cur,new,tmp}
9. Configure git send-email

        git config --global sendemail.smtpServer smtp.gmail.com  
        git config --global sendemail.smtpServerPort 587  
        git config --global sendemail.smtpEncryption tls  
        git config --global sendemail.smtpUser yourname@gmail.com  
        git config --global sendemail.smtpPass YOUR_16_CHAR_APP_PASSWORD  
        git config --global sendemail.from "Your Name <yourname@gmail.com>"  
        git config --global user.name "Your Name"  
        git config --global user.email "yourname@gmail.com"  
        git config --global format.signoff true  

10. Test mutt can read mail: `mutt`
11. Test mutt can send mail: `mutt -s "mutt test" yourname@gmail.com`
12. If mutt seems to have issues, try `mutt -d 2`, this will cause the creation of files with names beginning .muttdebug, followed by 0, 1, etc., that can help you find the problem. 
13. Test git send-email without actually sending: `git format-patch -1`, and `git send-email --dry-run --to wg21908@gmail.com 0001-*.patch`
14. These commands were required as git configuration to avoid email issue for git send-email, run these: `git config --global user.name "Wes Gibbs"`, `git config --global user.email "wg21908@gmail.com"` and `git config --global --list`
15. Verifications before sending email.  `git log --pretty=full`, do any recent commits contain email addresses like noreply.github, this is an issue that would need to be fixed.  In the case that 1 or N latest commits show bad email, then run `git rebase -i HEAD~N`, where N is the number of recent commits that have bad email, change pick to edit, then `git commit --amend --reset-author --no-edit` and `git rebase --continue`.  
16. Then test a real send to yourself: `git send-email --to yourname@gmail.com 0001-some-patch.patch`
17. Final kernel-safe test: Receive the patch mail, Save it as a file, then Verify it still applies cleanly with git am or patch

### Typical Work Process Flow

    # edit code
    git commit -s 
    git format-patch -1
    git send-email --to maintainer@example.com *.patch

## Questions / Support

Technical support is available when coffee is being supplied.

If you’d like to move forward, please [buy me a coffee](https://buymeacoffee.com/wg21908) and send me an email!