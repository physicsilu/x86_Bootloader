; This is a Stage 1 bootloader. This basically loads another bootloader and does it's stuff.

[org 0x7C00]

start:
    ; Load second sector (512 bytes) into memory 0x7E00
    mov ah, 0x02    ; BIOS read sector function
    mov al, 0x01    ; No of sectors to read
    mov ch, 0x00    ; cylinder = 0
    mov cl, 0x02    ; Sector = 2 (boot is in sector 1)
    mov dh, 0x00    ; Head = 0
    mov dl, 0x80    ; Drive 0 (floppy) or 0x80 for HDD
    mov bx, 0x0000  ; ES:BX = destination memory
    mov es, bx      ; ES is used for string and interrupt operations
    mov bx, 0x7E00
    int 0x13        ; BIOS disk interrupt

    jc disk_error   ; Jump if carry flag is set (error)

    jmp 0x0000:0x7E00   ; Jump to stage 2

disk_error:
    mov si, error_msg

print_error:
    lodsb
    or al, al
    jz hang
    mov ah, 0x0E
    int 0x10
    jmp print_error

hang:
    jmp $

error_msg db "Disk error!", 0

times 510 - ($ - $$) db 0
dw 0xAA55