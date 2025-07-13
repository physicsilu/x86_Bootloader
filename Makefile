BUILD = build
BOOTLOADER = bootloader

# Output files
BOOT_BIN = $(BUILD)/boot.bin
STAGE2_BIN = $(BUILD)/stage2.bin
IMG = $(BUILD)/boot.img

all: $(IMG)

# Concatenate both bootloader and stage2 into one disk image
$(IMG): $(BOOT_BIN) $(STAGE2_BIN)
	cat $(BOOT_BIN) $(STAGE2_BIN) > $(IMG)

# Assemble boot.asm into 512-byte MBR
$(BOOT_BIN): $(BOOTLOADER)/boot.asm
	nasm -f bin $< -o $@

# Assemble stage2.asm into raw binary
$(STAGE2_BIN): $(BOOTLOADER)/stage2.asm
	nasm -f bin $< -o $@

run: $(IMG)
	qemu-system-i386 -drive format=raw,file=$(IMG)

clean:
	rm -f $(BUILD)/*.bin $(BUILD)/*.img
