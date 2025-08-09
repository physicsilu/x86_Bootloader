# Simple x86 Bootloader

## Overview
A minimal bootloader written in 16-bit x86 assembly.  
It starts in **real mode**, sets up a **Global Descriptor Table (GDT)**, switches to **protected mode**, and prints a message directly to VGA text memory.

## Features
- 512-byte boot sector with `0xAA55` signature
- Initializes segment registers and stack
- Sets up GDT (code + data segments)
- Enables A20 line
- Switches to protected mode
- Prints text to screen via `0xB8000` VGA buffer

## Build & Run
Requirements: **NASM**, **QEMU**  
```bash
nasm -f bin ./bootloader/boot.asm -o ./bin/boot.bin # 'make all' will basically run this. 'make clean' will delete the build.
qemu-system-x86_64 -drive format=raw,file=./bin/boot.bin # 'sh execute.sh' will do this job
```
## Next Steps
- Writing a mini kernel `kernel.c` which prints a hello statement.
- Loading that kernel using this bootloader.