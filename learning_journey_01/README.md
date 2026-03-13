# Learning Journey 01 — Linux kernel orientation & first contribution notes

This directory contains introductory notes for getting oriented in Linux kernel
development and documenting a first upstream contribution. The files below move
from broad context, to source-tree familiarity, to evidence of patch
submission, and finally to a detailed write-up of a first real ticket.

Files
-
- [KERNEL_DEVEL_TASKS.md](KERNEL_DEVEL_TASKS.md):
  - Purpose: a high-level introduction to the kinds of work Linux kernel
    developers do and which tasks are most approachable for beginners.
  - Key contents: examples of bug fixing, driver development, performance work,
    subsystem contributions, documentation/testing, and a beginner path that
    starts with style/documentation cleanups before moving to small bug fixes.
  - Additional: starter resources such as Kernel Newbies, LKML, LWN, and
    suggested ways to identify newcomer-friendly work.

- [LINUX_SOURCE_DIR_TREE.md](LINUX_SOURCE_DIR_TREE.md):
  - Purpose: a quick reference for the top-level Linux kernel source
    directories.
  - Key contents: a table explaining major directories like `arch/`,
    `drivers/`, `fs/`, `include/`, `kernel/`, `mm/`, `net/`, `scripts/`,
    `security/`, `tools/`, and `virt/`.
  - Additional: useful as a mental map when navigating the kernel source tree
    for the first time.

- [LINUX_KERNEL_PATCH_SUBMISSIONS.md](LINUX_KERNEL_PATCH_SUBMISSIONS.md):
  - Purpose: a visual record of patch submission activity.
  - Key contents: a sequence of images documenting the submission process and
    related correspondence/results.
  - Additional: complements the written ticket notes by preserving screenshots
    from the workflow.

- [1ST_LINUX_KERNEL_TICKET.md](1ST_LINUX_KERNEL_TICKET.md):
  - Purpose: a detailed walkthrough of selecting, fixing, submitting, and
    revising a first Linux kernel-related ticket.
  - Key contents: how the ticket was found in Kernel Bugzilla, maintainer
    outreach, the local workflow for cloning the relevant repository, making a
    documentation fix, validating changes, generating/sending patches, and
    handling review feedback with a `v2` submission.
  - Additional: includes concrete commands, links to lore.kernel.org threads,
    example commit message structure, and lessons learned from the experience.

How to use these notes
-
- Step 1: Start with [KERNEL_DEVEL_TASKS.md](KERNEL_DEVEL_TASKS.md)
  for a broad overview of what Linux kernel work looks like and where beginners
  can realistically contribute.
- Step 2: Read [LINUX_SOURCE_DIR_TREE.md](LINUX_SOURCE_DIR_TREE.md)
  to build a basic mental model of the kernel source layout before diving into
  actual changes.
- Step 3: Review [LINUX_KERNEL_PATCH_SUBMISSIONS.md](LINUX_KERNEL_PATCH_SUBMISSIONS.md)
  to see the visual side of the submission process.
- Step 4: Finish with [1ST_LINUX_KERNEL_TICKET.md](1ST_LINUX_KERNEL_TICKET.md)
  for the full narrative of a real first ticket, from ticket discovery through
  reviewer feedback and resubmission.
