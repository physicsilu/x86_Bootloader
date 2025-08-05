BUILD = build
BOOTLOADER = bootloader
KERNEL = kernel

BOOT_BIN = $(BUILD)/boot.bin
STAGE2_BIN = $(BUILD)/stage2.bin
KERNEL_OBJ = $(BUILD)/kernel.o
KERNEL_BIN = $(BUILD)/kernel.bin
PADDED_KERNEL_BIN = $(BUILD)/kernel_padded.bin
IMG = $(BUILD)/boot.img

CC = gcc
LD = ld
CFLAGS = -ffreestanding -nostdlib -m32 -fno-pic -fno-pie
LDFLAGS = -m elf_i386 -Ttext=0x8000 --entry=_start --oformat binary

all: $(IMG)

# 1. Stage 1 Bootloader (512 bytes, MBR)
$(BOOT_BIN): $(BOOTLOADER)/boot.asm
	nasm -f bin $< -o $@

# 2. Stage 2 Bootloader (loaded by Stage 1)
$(STAGE2_BIN): $(BOOTLOADER)/stage2.asm
	nasm -f bin $< -o $@

# 3. Kernel Object (compiled from C)
$(KERNEL_OBJ): $(KERNEL)/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

# 4. Kernel Binary (raw flat binary, linked at 0x8000)
$(KERNEL_BIN): $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $< -o $@

# 5. Pad kernel to 512-byte sector alignment
$(PADDED_KERNEL_BIN): $(KERNEL_BIN)
	dd if=$< of=$@ bs=512 conv=sync

# 6. Final Disk Image: bootloader + stage2 + padded kernel
$(IMG): $(BOOT_BIN) $(STAGE2_BIN) $(PADDED_KERNEL_BIN)
	cat $(BOOT_BIN) $(STAGE2_BIN) $(PADDED_KERNEL_BIN) > $@

# 7. Run in QEMU
run: $(IMG)
	qemu-system-i386 -drive format=raw,file=$(IMG)

# 8. Clean
clean:
	rm -f $(BUILD)/*.bin $(BUILD)/*.img $(BUILD)/*.o
