; This is the next bootloader file which the first one loads.

[org 0x7E00]

    mov si, msg 

loop:
    lodsb
    or al, al
    jz hang
    mov ah, 0x0E
    int 0x10
    jmp loop

hang:
    jmp $

msg db "Stage 2 bootloader successfully loaded!", 0