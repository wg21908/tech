# 1ST Linux Kernel Ticket

## Goal(s)

- Get familiar with the workflow and process for getting something included in a future Linux kernel release.
- A very easy ticket

## Finding a Ticket to Work

- Navigate to https://bugzilla.kernel.org/query.cgi?format=advanced
- Filters Applied:
  - Status: NEW, ASSIGNED, and REOPENED
  - Severity: LOW
  - Creation Date: is greater than -3M 
- At the time of my search, there were only 4 results.
- Ticket https://bugzilla.kernel.org/show_bug.cgi?id=220489 looked to be an easier ticket since it was a man-pages documentation-related ticket.  I could see that the ticket was still assigned to the general group email and that it didn't appear that anyone started looking at it yet.
- To play it safe though, I still emailed the maintainer email address to give them a heads up of my interest and plan to work on the ticket, email archived at https://lore.kernel.org/linux-man/aP0T3yZ0jflUtliV@secra.localdomain/T/#u. 

## Applying the Fix

The steps I followed to carry out the fix are listed below. 

    # Clone Linux kernel codebase to local machine
    git clone https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git

    # Navigate into cloned directory 
    cd man-pages

    # Switch to main branch
    git checkout master
    
    # Ensure we have the latest code
    git pull origin master

    # Create feature branch where we will apply fixes too
    git checkout -b fix-copy_file_range-fallback-doc

    # At this point I made updates to the man2/copy_file_range.2 man-page file
    vim man2/copy_file_range.2

    # Verifying updates didn't make things worse
    make -R check
    
    # Applied more fixes to man2/copy_file_range.2 man-page file due to found issue from check make cmd

## Submitting Fix

    # Adding updated file for file to be committed
    git add man2/copy_file_range.2

    # Adding commit message, giving details of updates made
    git commit --amend --author="Wes Gibbs <wg21908@gmail.com>" --signoff
    
    # Creating patch file locally
    git format-patch origin/master

    # Get details of updates to verify before sending patch by email
    git log --oneline origin/master..

    # Double-check my patch content
    less 0001-*.patch

    # Identify correct recipients
    scripts/get_maintainer.pl 0001-*.patch
    
    # Send in patch file 
    git send-email --to=linux-man@vger.kernel.org \
      --cc=mtk.manpages@gmail.com 0001-Subject-copy_file_range.2-glibc-no-longer-provides-f.patch

    # Optional verification, confirm what I sent matches what will appear on the mailing list
    git send-email --dry-run --to=linux-man@vger.kernel.org --cc=mtk.manpages@gmail.com 0001-*.patch

    # The archive showing the emailed patch can be seen at 
    #   https://lore.kernel.org/linux-man/20251025221258.45073-1-wg21908@gmail.com/T/#u

## Applying Peer Review Feedback

Peer review feedback from Alejandro Colomar "aka: Alex" can be seen at 
https://lore.kernel.org/linux-man/u7yt6in3t7ng6o5nq4kqrls5ldjkr7p6nnihpi7i2upg43cbcb@qm4qani52cdz/

A summary of feedback received is below.

1. This patch doesn't have a Signed-off-by from Sebastian.  Shouldn't he sign it?  Or am I missing something?  
2. Could you please specify the initial version of glibc that wraps it?  
3. Please use semantic newlines.  See man-pages(7)  
4. This link gives me 404 - Unknown commit object

My solutions to feedback is below.  

1. For some reason the default author was not myself but got set to Sebastion, ran this:
   `git commit --amend --author="Wes Gibbs <wg21908@gmail.com>" --signoff` 
3. Modified man/man2/copy_file_range.2 to include "... starting with glibc 2.27, ..." verbiage that it was
   version 2.27 of Linux kernel
4. Modified man/man2/copy_file_range.2 to start new sentences on the next line  
5. I found the correct Git Hash commit URL and applied it in the commenting of the man/man2/copy_file_range.2 file

Steps Completed  

    # Navigate into cloned directory 
    cd man-pages

    # Sync your local tree with upstream
    git checkout master
    git pull origin master
    git checkout fix-copy_file_range-fallback-doc
    git rebase master

    # Edit your file with the new changes
    vim man2/copy_file_range.2

    # Stage the modified file
    git add man2/copy_file_range.2

    # Amend the existing commit with your new updates
    git commit --amend --signoff

    #
    # Start of Good looking commit message body
    #
    
    From: Your Name <your.email@example.com>
    Subject: [PATCH v2] copy_file_range.2: clarify fallback behavior after glibc change
    
    Clarify that glibc no longer provides a fallback implementation of
    copy_file_range(), and that applications must handle ENOSYS themselves.
    
    This update improves the documentation to reflect that the syscall
    may fail if the underlying kernel does not support copy_file_range(),
    and glibc no longer emulates it. The text now explicitly advises
    callers to provide their own fallback copy logic.
    
    Signed-off-by: Your Name <your.email@example.com>
    ---
    v2:
     - Fixed grammar and clarified sentence structure in fallback paragraph.
     - Added explicit mention that glibc 2.38 removed the fallback.
     - Minor style cleanup (line wrapping and formatting).

    #
    # End of Good looking commit message body
    #

    # Generate your v2 patch
    git format-patch -v2 origin/master

    # Verify your patch
    less 0001-*.patch

    Check:
      - From: has your name/email
      - Subject starts with [PATCH v2]
      - The diff includes your new updates
      - The v2 changelog section appears below ---

    #
    # Send the v2 patch
    #   FYI You can find that message ID in your mail client’s headers for the original v1 email (look for 
    #     the Message-ID: field).
    #
    git send-email \
      --to=linux-man@vger.kernel.org \
      --cc=mtk.manpages@gmail.com \
      --in-reply-to=<message-id-of-v1@something> \
      0001-*.patch

    Last submitted patch that addressed PR feedback can be see at 
      https://lore.kernel.org/linux-man/20251102000330.155591-1-wg21908@gmail.com/

## Lessons Learned

- Bugzilla ticket won't get assinged to me.  Emailing maintainers and putting comment in ticket is only
  action needed.
- Bugzilla ticket not likely to get status updated till its officially merged.
- Don't try to respond to email recieved by Gmail or some other non-text based email service.  Use Mutt, Sendmail, Procmail, and Fetchmail Linux email software for communication with MAINTAINERS.

