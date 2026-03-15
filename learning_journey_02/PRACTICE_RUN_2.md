# Linux Kernel Debugging in QEMU with `gdb`  
## Practice Run: Add a Reliable `pr_info()` Message and Debug `start_kernel()`

This walkthrough shows how to:

1. modify a Linux kernel C source file that is **highly likely to execute on every boot**
2. print a message at kernel runtime so you know your modified kernel is actually running
3. boot that kernel inside QEMU
4. attach `gdb`
5. debug the **same source file and function** where you placed the print

The source file used here is:

- **File:** `init/main.c`
- **Function:** `start_kernel()`

This is a strong candidate because `start_kernel()` is part of the common kernel boot path and is expected to run on every normal boot.

---

## Goal

Add this message:

```c
pr_info("WES: start_kernel reached after console_init\n");
```

Then:

- rebuild the kernel
- boot it in QEMU
- attach `gdb`
- break in `start_kernel()`
- step through execution around the inserted line
- understand exactly what is happening

---

## Prerequisites

You should already have:

- a Linux kernel source tree
- a successful or mostly successful kernel build environment
- `qemu-system-x86_64`
- `gdb`
- build tools such as `gcc`, `make`, etc.

Example package install on Rocky Linux 9:

```bash
sudo dnf install -y gcc make gdb qemu-kvm qemu-img bc bison flex elfutils-libelf-devel openssl-devel ncurses-devel
```

---

## Step 1 — Move into the kernel source tree

```bash
cd /path/to/linux-source
```

Example:

```bash
cd ~/kernel-dev/linux
```

---

## Step 2 — Modify `init/main.c`

Open the file:

```bash
vi init/main.c
```

Search for the `start_kernel()` function.

Inside that function, locate this line:

```c
console_init();
```

Immediately after it, add:

```c
pr_info("WES: start_kernel reached after console_init\n");
```

So that section looks similar to this:

```c
console_init();
pr_info("WES: start_kernel reached after console_init\n");
```

### Why place it here?

This is a good location because:

- `start_kernel()` is on the main boot path
- `console_init()` sets up the console subsystem
- putting the message after `console_init()` improves the chances that the message is visible on the console during boot
- the message also lands in the kernel log buffer

---

## Step 3 — Confirm useful kernel config options

Check for these options:

```bash
grep -E 'CONFIG_DEBUG_INFO=|CONFIG_GDB_SCRIPTS=|CONFIG_FRAME_POINTER=' .config
```

You want to see values like:

```text
CONFIG_DEBUG_INFO=y
CONFIG_GDB_SCRIPTS=y
CONFIG_FRAME_POINTER=y
```

If any are missing, run:

```bash
make menuconfig
```

Then enable the relevant options.

### What these options do

- `CONFIG_DEBUG_INFO=y`  
  Includes debug symbols so `gdb` can map machine code back to source code and line numbers.

- `CONFIG_GDB_SCRIPTS=y`  
  Enables Linux kernel GDB helper scripts such as `lx-symbols` and `lx-dmesg`.

- `CONFIG_FRAME_POINTER=y`  
  Helps produce more reliable stack traces and makes debugging easier.

---

## Step 4 — Build the kernel

Build the kernel:

```bash
make -j"$(nproc)"
```

Then build the GDB helper scripts:

```bash
make scripts_gdb
```

### What to expect

At the end of the build, two especially important files should exist:

- `vmlinux`  
  The uncompressed ELF image with debug symbols.  
  This is the file `gdb` uses.

- `arch/x86/boot/bzImage`  
  The compressed bootable kernel image.  
  This is the file QEMU boots.

You can verify:

```bash
ls -lh vmlinux arch/x86/boot/bzImage
```

---

## Step 5 — Boot the kernel in QEMU

Run:

```bash
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "console=ttyS0 nokaslr" \
  -initrd /boot/initramfs-$(uname -r).img \
  -nographic \
  -m 4096 \
  -s -S
```

### What each option means

- `-kernel arch/x86/boot/bzImage`  
  Boots your newly built kernel directly.

- `-append "console=ttyS0 nokaslr"`  
  Passes kernel command line arguments:
  - `console=ttyS0` sends boot output to the serial console
  - `nokaslr` disables kernel address randomization so addresses line up with debug symbols

- `-initrd /boot/initramfs-$(uname -r).img`  
  Supplies an initramfs.  
  For an early learning run, using the host initramfs is often enough to get started.

- `-nographic`  
  Keeps QEMU in the terminal rather than opening a graphical window.

- `-m 4096`  
  Gives the guest 4 GB of RAM.

- `-s`  
  Starts QEMU’s built-in GDB server on TCP port `1234`.

- `-S`  
  Starts the virtual CPU in a paused state so the guest does **not** begin executing until `gdb` tells it to continue.

### Important note

At this point QEMU appears to “hang,” but that is expected.  
It is paused and waiting for `gdb` to attach.

---

## Step 6 — Start `gdb` against `vmlinux`

Open a second terminal and run:

```bash
cd /path/to/linux-source
gdb vmlinux
```

### Why use `vmlinux` and not `bzImage`?

- `vmlinux` contains symbols and debug information
- `bzImage` is the compressed boot image and is not what you want for source-level debugging

If `gdb` complains about loading kernel helper scripts, add this to `~/.gdbinit`:

```gdb
add-auto-load-safe-path /path/to/linux-source
```

Then start `gdb` again.

---

## Step 7 — Attach `gdb`, set breakpoints, and understand what happens line by line

Inside `gdb`, run:

```gdb
target remote :1234
lx-symbols
break start_kernel
continue
```

Here is what each command does and what is occurring internally.

### 7.1 `target remote :1234`

```gdb
target remote :1234
```

#### What this does

This tells `gdb` to connect to QEMU’s built-in GDB server running on TCP port `1234`.

#### What is occurring behind the scenes

- QEMU was launched with `-s -S`
- `-s` means QEMU opened a GDB server
- `-S` means the guest CPU is still paused
- when `gdb` connects, it gains control over the paused VM
- `gdb` can now inspect registers, memory, and execution state of the guest kernel

At this moment:

- the guest kernel has **not started running normally yet**
- the CPU is paused at a very early point
- you are now attached before significant boot code has executed

You can verify the connection with commands like:

```gdb
info registers
```

That shows the virtual CPU register state at the point QEMU is paused.

---

### 7.2 `lx-symbols`

```gdb
lx-symbols
```

#### What this does

Loads Linux kernel debugging symbols and prepares helper commands supplied by the kernel GDB scripts.

#### What is occurring behind the scenes

- `gdb` already has the `vmlinux` symbol table
- `lx-symbols` helps synchronize symbol handling for the kernel and later for modules
- it also enables Linux-specific helper commands like:
  - `lx-dmesg`
  - `lx-current`
  - `lx-symbols`

At this point, `gdb` becomes much more kernel-aware.

---

### 7.3 `break start_kernel`

```gdb
break start_kernel
```

#### What this does

Sets a breakpoint at the beginning of the `start_kernel()` function in `init/main.c`.

#### What is occurring behind the scenes

- `gdb` uses the debug symbols in `vmlinux`
- it resolves the C function name `start_kernel`
- it maps that symbol to a memory address in the kernel image
- it plants a breakpoint at that location in the guest

A breakpoint means:

- when the guest CPU reaches that instruction
- execution will stop
- control returns to `gdb`

You can confirm the breakpoint with:

```gdb
info breakpoints
```

---

### 7.4 `continue`

```gdb
continue
```

#### What this does

Tells QEMU to let the guest CPU start running.

#### What is occurring behind the scenes

Now the guest begins executing boot code.

As the kernel starts:

- early architecture-specific setup runs
- generic initialization proceeds
- eventually execution reaches `start_kernel()`
- the breakpoint triggers
- QEMU pauses the guest CPU again
- `gdb` regains control exactly at that function entry

At this point, you should see output similar to:

```text
Breakpoint 1, start_kernel () at init/main.c:...
```

That means:

- the VM is no longer just paused at an arbitrary startup point
- it has now executed real boot code
- it stopped exactly where you asked

---

### 7.5 See where you are in the source

Now run:

```gdb
list
```

This prints source lines around the current execution point.

You can also run:

```gdb
list start_kernel
```

That shows the source around the `start_kernel()` function.

#### What this means

You are now looking at the actual C source lines that correspond to the next machine instructions to be executed by the guest CPU.

---

### 7.6 Step through the function carefully

Use:

```gdb
next
```

or

```gdb
step
```

### Difference between `next` and `step`

- `next`  
  executes the current source line, but if that line calls another function, `gdb` does not descend into it

- `step`  
  executes the current source line and steps into called functions when possible

For this walkthrough, `next` is usually better at first because `start_kernel()` calls many internal functions and stepping into every single one becomes overwhelming quickly.

---

### 7.7 Watch the code advance

A useful pattern is:

```gdb
list
next
list
next
list
```

This lets you repeatedly:

1. view the current source lines
2. execute one source line
3. view the new current location

#### What is occurring each time you press `next`

For each `next`:

- the guest CPU resumes briefly
- it executes the machine instructions corresponding to the current source line
- if that source line includes a function call, that function is executed as one unit from your perspective
- the guest CPU pauses again at the next source line in the current function
- control returns to `gdb`

So `gdb` is repeatedly doing this:

1. resume guest CPU
2. let it execute just enough instructions
3. stop again at the next relevant source position
4. show you where you are now

---

### 7.8 Set a breakpoint exactly on your inserted `pr_info()` line

Once you can see your inserted line in the listing, set a breakpoint on it.

Example:

```gdb
break init/main.c:LINE_NUMBER
```

Replace `LINE_NUMBER` with the actual line number shown by `list`.

For example:

```gdb
break init/main.c:1234
```

Then:

```gdb
continue
```

#### What this does

This is more precise than manually stepping dozens of lines.

It tells `gdb`:

- run freely until execution reaches this exact source line
- then stop before that line executes

This is one of the cleanest ways to observe your inserted print statement.

---

### 7.9 Inspect the current state before executing your `pr_info()`

Once stopped at your inserted line, run:

```gdb
list
bt
info registers
```

#### What each tells you

- `list`  
  shows the source around the current line

- `bt`  
  shows the current call stack

- `info registers`  
  shows the CPU register contents at this exact stop point

This gives you a snapshot of the kernel state immediately before your print executes.

---

## Step 8 — Execute the inserted line and observe exactly what happens

Once stopped on your inserted line, use:

```gdb
next
```

This is the key moment of the exercise.

---

### 8.1 What `next` means on the `pr_info()` line

Suppose the current source line is:

```c
pr_info("WES: start_kernel reached after console_init\n");
```

When you type:

```gdb
next
```

`gdb` resumes the guest CPU and lets it execute the machine instructions for that line.

#### Conceptually, this one source line expands into lower-level work

Even though you only see one C line, the kernel is actually doing much more underneath. Conceptually:

1. the `pr_info()` macro expands into logging infrastructure
2. a printk-style logging function is called
3. the message string is handled by the kernel logging subsystem
4. the formatted message is written into the kernel log buffer
5. if console conditions allow, the message is also emitted to the active console
6. control returns to `start_kernel()`
7. `gdb` stops at the next source line in that function

So from your perspective, one `next` executes one C line.  
From the CPU’s perspective, many instructions and helper calls may have just occurred.

---

### 8.2 What you should expect after `next`

After running `next`, one of these will happen:

#### Case A — You return to the next source line in `start_kernel()`

This is the normal expectation.

You will see `gdb` stop at the following source line.

That means:

- your `pr_info()` line has already executed
- the message should now exist in the kernel log buffer
- boot has not fully resumed yet because `gdb` stopped at the next line

#### Case B — Console output appears immediately in the QEMU terminal

If console output is active and permitted at the current log level, you may also see:

```text
WES: start_kernel reached after console_init
```

in the QEMU terminal.

That means the line not only entered the log buffer, but also reached the visible console.

---

### 8.3 Verify the message from inside `gdb`

Try:

```gdb
lx-dmesg
```

Then search visually for:

```text
WES: start_kernel reached after console_init
```

#### What this proves

It proves your modified kernel source line actually ran.

Not just compiled.  
Not just linked.  
Actually executed at runtime.

---

### 8.4 Use `list` again to see where execution is now

Run:

```gdb
list
```

You should now see the source lines after your inserted print.

This confirms that the current instruction pointer has advanced beyond your added line.

---

### 8.5 Step a few more lines if you want

You can continue to walk through the function:

```gdb
next
next
next
```

Each `next` means:

- the guest CPU resumes briefly
- the next source line executes
- control returns to `gdb`

This helps you build intuition that the kernel is not magical; it is still code, line by line, function by function, just at a lower level and with more moving parts than user-space software.

---

### 8.6 Resume normal execution

When you are done inspecting around your inserted line, let the kernel continue booting:

```gdb
continue
```

#### What is occurring now

- QEMU resumes the guest CPU normally
- the guest keeps executing kernel boot code
- unless another breakpoint is hit, `gdb` will not interrupt again
- the kernel continues toward later initialization and eventually userspace

At this point, the kernel is no longer being single-stepped.  
It is running freely until:

- another breakpoint is reached
- an exception occurs
- or you manually interrupt from `gdb`

---

### 8.7 What to look for in the QEMU console

As the guest continues booting, you should expect to see regular boot messages in the terminal because of:

```text
console=ttyS0
```

Among them, you want to look for:

```text
WES: start_kernel reached after console_init
```

If you see it, you have validated all of the following:

- you edited the intended file
- you rebuilt the intended kernel
- QEMU booted the modified kernel
- the `start_kernel()` path executed
- your inserted line ran successfully

That is a very solid end-to-end kernel development sanity check.

---

## Step 9 — Useful `gdb` commands during the session

Inside `gdb`, these commands are especially useful:

```gdb
target remote :1234
lx-symbols
break start_kernel
continue
list
next
step
bt
info registers
lx-dmesg
info breakpoints
```

### Quick reminder of what they do

- `target remote :1234`  
  connect to QEMU GDB server

- `lx-symbols`  
  load kernel/module debugging helpers

- `break start_kernel`  
  break at function entry

- `continue`  
  resume guest execution until next breakpoint

- `list`  
  show source code

- `next`  
  execute one source line without stepping into called functions

- `step`  
  execute one source line and step into called functions

- `bt`  
  show backtrace

- `info registers`  
  show CPU register state

- `lx-dmesg`  
  display kernel log buffer

- `info breakpoints`  
  list configured breakpoints

---

## Step 10 — Example condensed session

### Terminal 1: start QEMU

```bash
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "console=ttyS0 nokaslr" \
  -initrd /boot/initramfs-$(uname -r).img \
  -nographic \
  -m 4096 \
  -s -S
```

### Terminal 2: run `gdb`

```bash
cd /path/to/linux-source
gdb vmlinux
```

Inside `gdb`:

```gdb
target remote :1234
lx-symbols
break start_kernel
continue
list
next
list
break init/main.c:LINE_NUMBER
continue
list
bt
info registers
next
lx-dmesg
continue
```

---

## Step 11 — Common pitfalls

### 1. `gdb` cannot find `start_kernel`
Make sure you are opening:

```bash
gdb vmlinux
```

not `bzImage`.

---

### 2. The VM boots but your message does not appear
Possible reasons:

- you edited the wrong source tree
- you booted an old `bzImage`
- your kernel rebuild did not complete correctly
- the message is in the log buffer but not visible on console

Check with:

```gdb
lx-dmesg
```

or later with `dmesg` inside the guest.

---

### 3. Source lines do not match execution cleanly
Possible causes:

- missing debug symbols
- optimization settings
- wrong `vmlinux` relative to the `bzImage` you booted

Make sure the `vmlinux` and `bzImage` came from the same build.

---

### 4. Host initramfs does not match your custom kernel well
Using:

```bash
-initrd /boot/initramfs-$(uname -r).img
```

is convenient for learning, but not always ideal.  
Eventually you may want an initramfs built specifically for your custom kernel.

---

## Step 12 — Why this exercise matters

This practice run proves an important kernel-development workflow:

- you can modify kernel C source
- rebuild the kernel
- boot it in QEMU
- attach `gdb`
- stop inside your modified function
- execute the modified line under debugger control
- verify the message at runtime

That is a strong foundation for later work such as:

- debugging other boot functions
- instrumenting scheduler paths
- tracing driver initialization
- investigating system calls
- studying memory-management behavior

---

## Recommended next experiments

After this works, good next targets are:

- `rest_init()`
- `kernel_init()`
- `do_basic_setup()`

These are also in boot/initialization paths and make good follow-on learning exercises.

---

## Inserted code snippet used in this walkthrough

```c
pr_info("WES: start_kernel reached after console_init\n");
```

---

## File and function used

- **File:** `init/main.c`
- **Function:** `start_kernel()`

---