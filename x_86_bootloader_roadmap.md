# 🧠 x86 Bootloader Project Roadmap (Using QEMU)

This roadmap will take you from zero to writing your own x86 bootloader and a basic C kernel. You’ll be using `nasm`, `qemu`, `make`, and optionally `ld` and `gcc` for C support later.

---

## 📦 Project Structure

```
x86-bootloader/
├── bootloader/            # Bootloader stage 1 and stage 2
│   ├── boot.asm
│   └── stage2.asm
├── kernel/                # Optional: Kernel in C
│   └── kernel.c
├── build/                 # Output directory
│   └── boot.img
├── Makefile
└── README.md
```

---

## ⚙️ Phase 0: Setup Environment

### ✅ Install dependencies

```bash
sudo apt install nasm qemu make
```

### ✅ Confirm tools are available

```bash
nasm -v
qemu-system-i386 --version
```

---

## 🔹 Phase 1: Hello World Bootloader

### 🧾 Goal:

- Write a 512-byte MBR bootloader that prints text using BIOS interrupt

### 📄 `boot.asm`

```asm
[org 0x7C00]
    mov ah, 0x0E
    mov al, 'H'
    int 0x10
    mov al, 'i'
    int 0x10
hang:
    jmp hang

times 510 - ($ - $$) db 0
    dw 0xAA55
```

### 🔨 Build & Run

```bash
nasm boot.asm -f bin -o build/boot.img
qemu-system-i386 -drive format=raw,file=build/boot.img
```

---

## 🔹 Phase 2: Multistage Bootloader

### 🧾 Goal:

- Load a second-stage bootloader or kernel from disk

### 🛠️ Skills:

- Use INT 13h to read sectors
- Store bootloader at 0x7C00, stage2 at 0x7E00
- Jump to stage2

---

## 🔹 Phase 3: Enter Protected Mode

### 🧾 Goal:

- Set up GDT and enter 32-bit protected mode

### 🛠️ Skills:

- Create GDT descriptor table
- Update CR0 and segment registers
- Disable interrupts safely

---

## 🔹 Phase 4: Boot C Kernel

### 🧾 Goal:

- Load and jump to a C kernel compiled with `gcc`

### 🛠️ Skills:

- Write linker script
- Compile C code with freestanding flags
- Implement UART/text output from memory-mapped IO

---

## 🔹 Phase 5: Basic Kernel Features (Optional)

### 🧾 Goal:

- Implement a simple shell, memory map, keyboard driver

### 🛠️ Ideas:

- Build malloc
- Add page tables
- Create task switcher/scheduler

---

## 📘 Resources

- [https://wiki.osdev.org/Main\_Page](https://wiki.osdev.org/Main_Page)
- [https://github.com/cfenollosa/os-tutorial](https://github.com/cfenollosa/os-tutorial)
- [https://github.com/SamyPesse/How-to-Make-a-Computer-Operating-System](https://github.com/SamyPesse/How-to-Make-a-Computer-Operating-System)
- [https://littleosbook.github.io/](https://littleosbook.github.io/)

---

## 🧠 Notes

- BIOS loads MBR to 0x7C00
- You only have 512 bytes in MBR (stage 1)
- Real mode = 16-bit, Protected mode = 32-bit

---

## 🗂️ Next Steps

- Document everything in `README.md`
- Push to GitHub for others to learn
- Create issues and TODOs for tracking
- Make commits at every stage

