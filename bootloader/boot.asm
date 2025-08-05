[BITS 16]           ; This is a directive that tells the assembler to treat this code as 16-bit code
[ORG 0x7C00]        ; This is the origin address where the bootloader will be loaded in memory

; This is the basic set-up.
start:
    cli             ; Disable interrupts
    mov ax, 0x0000
    ; DS, ES and SS are segment registers. We can't directly load address into them. We have to do it via another register.
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; This is the stack pointer and we point it to 0x7c00 and the stack grows downwards.
    sti             ; Enable interrupts
    mov si, msg     ; This basically points to the inintial character of the message if I understand it right.

print:
    lodsb           ; loads byte at DS:SI to AL register and increments SI
    cmp al, 0       ; This is like our end character. We defined '0' to be that. Now if 0 gets loaded into AL, we are done.
    je done         ; Jump if equal
    mov ah, 0x0E
    int 0x10
    jmp print       ; This is an unconditional jump. Basically a loop.

done:
    cli
    hlt             ; Stop further CPU execution
msg: db 'Hello World!', 0

times 510 - ($ - $$) db 0  ; This is basically padding with zeros.
dw 0xAA55           ; This is the boot signature. No matter what's there in the first 510 bytes, this is what tells the BIOS that it's a bootloader.