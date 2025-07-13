# Basics
- BIOS loads a bootloader from disk.
- It loads first 512 bytes of boot sector to memory address **0x0000:0x7C00** (segment:offset)

### Why don't we load the bootloader to 0x0000?
- **0x0000 - 0x03FF** contains the Interrupt Vector Table (IVT). 
  - The IVT contains 256 entries x 4 bytes each = 1 KB.
  - This region is critical for BIOS interrupt services.
- **0x0400 - 0x04FF** contains BIOS Data Area (BDA). Stores important hardware info detected by BIOS:
  - Serial port I/O addresses.
  - Keyboard status
  - Memory size
  - Display settings
- **0x0500 - 0x7BFF** contains General BIOS/ Stack/ Scratch area. Some BIOSes use this part for:
  - Temporary stack
  - Disk I/O buffers
  - Keyboard buffer
  - It's not safe to overwrite this unless you're in complete control of the environment

### Understanding the boot.asm code
- [org 0x7C00] tells the assembler that the *boot.asm* code will be loaded at memory address 0x7C00.
``` asm
mov ah, 0x0E
mov al, 'H'
int 0x10
```
- You are calling the BIOS video service (int 0x10).
- **AH = 0x0E** → TTY output mode (prints a character and scrolls if needed).
- **AL = 'H'** → the character to print.
  
```asm
hang:
    jmp hang
```
- This is an infinite loop so that the CPU doesn't continue to random memory.
- Without this, the processor would execute whatever is in memory after the code — likely garbage — and crash.

```asm
times 510 - ($ - $$) db 0
```
- A boot sector must be exactly 512 bytes. This line fills the rest of the bootloader with zeroes up to byte 510.

- ```$``` = current address, ```$$``` = start of the file. So ```($ - $$)``` is the number of bytes used so far.

- ```times 510 - (...)``` pads with zeros.

```asm
dw 0xAA55
```
- This is the boot signature.
- BIOS checks the last two bytes of the boot sector. If they're 0x55AA, it treats the sector as bootable.
- If this value isn't present, BIOS will refuse to boot.
- Here *__dw__* is "Define Word".

### How do actual binary bytes from bootloader look?
- If we run ```hexdump -C build/build.img ``` we can see bytes organization.
```
    00000000  b4 0e b0 48 cd 10 b0 69  cd 10 b0 21 cd 10 eb fe  |...H...i...!....|
    00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
    *
    000001f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 55 aa  |..............U.|
```
- In memory, BIOS loads this boot sector. It copies this at 0x7C00. Then BIOS does ``` jmp 0x7C00 ```. Execution begins at our bootloader!

### What is a stage 2 bootloader?
- BIOS loads only first 512 bytes of the disk.
- We will use BIOS interrupts (``` INT 13 ```) to load another 512 bytes (sector 2)
- Loads it at memory location ``` 0x7E00 ```

```cpp
Disk Layout:
 ┌────────────┬────────────┐
 │ boot.asm   │ stage2.asm │
 │ (512 bytes)│ (512 bytes)│
 └────────────┴────────────┘

Memory Layout at Boot:
 ┌────────────┬────────────┐
 │ 0x7C00     │ 0x7E00     │
 │ boot code  │ stage 2    │
 └────────────┴────────────┘

```

### How storage is laid out?
Basically we are trying to create modular bootloaders.

Disks (floppy, HDD, etc.) are divided into cylinders, heads, and sectors (CHS).

A sector is the smallest addressable block of the disk, usually 512 bytes.

A typical disk is organized like this:

-  Cylinders (CH) – think of this as concentric rings from outside to inside.

-  Heads (DH) – represents the read/write head (like double-sided disks have 2 heads).

-  Sectors (CL) – subdivisions of a track. Sector numbers start from 1.

🔧 In BIOS world, to read a sector, you need to give the CHS address.

### The Makefile
```make
build/boot.img: bootloader/boot.asm bootloader/stage2.asm
	nasm bootloader/boot.asm -f bin -o build/boot1.bin
	nasm bootloader/stage2.asm -f bin -o build/stage2.bin
	cat build/boot1.bin build/stage2.bin > build/boot.img

```

#### Line-by-line breakdown:
- ```build/boot.img:```
  This is the target. It means "To build boot.img, I need..."

- ```bootloader/boot.asm bootloader/stage2.asm```
  These are dependencies — files that must be present or updated.

- The following lines are the commands to run:

  - Assemble boot.asm to boot1.bin

  - Assemble stage2.asm to stage2.bin

  - Concatenate both into boot.img

``` 🧠 The cat step is important because BIOS reads the disk sector by sector. So sector 1 = boot1.bin, sector 2 = stage2.bin.```