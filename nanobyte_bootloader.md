```
These notes are made after referring to "Building a bootloader" playlist by **nanobyte** YouTube channel.
```

# How a computer starts up?
- BIOS is copied from ROM to RAM.
- BIOS starts executing code
  - initializes hardware
  - runs some tests (power-on self test)
- BIOS searches for an OS to start
- BIOS loads and starts the OS
- OS runs

# How does the BIOS find an OS?
- **Legacy booting**
  - BIOS loads first sector of each bootable device into memory (at location 0x7C00)
  - BIOS checks for 0xAA55 signature
  - If found, it starts executing code
- **EFI (Extensible Firmware Interface)**
  - EFI (more precisely, UEFI) is a modern replacement for BIOS — the firmware that runs when your computer first powers on and initializes the hardware before booting an OS.
  - BIOS looks into special EFI partitions
  - OS must be compiled as an EFI program

# What's the difference between a Directive and an Instruction?
- A Directive gives a clue to the assembler that will affect how the program gets compiled (**Not translated to machine code**)
- An Instruction is translated to a machine code instruction that CPU will execute.

```asm
org ; is a directive
bits ; is also a directive (specifies mode like, 16 bit or 32 bit)
```

# Memory Segmentation
- 8086 has 20 bit address bus. So 1MB can basically be addressed. 
- But the registers available are of 16 bit.
- So, to handle this, **Segment:Offset** addressing is used. **Physical Address = Segment\*16 + Offset**
- Some special registers are used to specify currently active segments:
  - CS: currently running code segment
  - DS: data segment
  - SS: stack segment
  - ES, FS, GS - extra segments

# Real mode (16 bit)
- When your computer first boots, it starts in real mode, which mimics the original 8086 CPU.
- 16 bit registers and 20 bit address space. **segment:offset** is used for addressing.
- No memory protection.
- Access to BIOS interrupts.
- Used by bootloaders.

# Protected mode (32 bit)
- 32 bit registers and 4GB address space.
- Enables memory protection: no access to other program's memory.
- Virtual memory and paging are possible.
- No BIOS interrupts available.