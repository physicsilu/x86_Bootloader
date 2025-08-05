; ; This is the next bootloader file which the first one loads.

; ; [org 0x7E00]

; ;     mov si, msg 

; ; loop:
; ;     lodsb
; ;     or al, al
; ;     jz hang
; ;     mov ah, 0x0E
; ;     int 0x10
; ;     jmp loop

; ; hang:
; ;     jmp $

; ; msg db "Stage 2 bootloader successfully loaded!", 0

; ; This code is to load a mini kernel. The kernel is written in C.
; [org 0x7E00]

;     mov si, stage2_msg

; .print_loop:
;     lodsb
;     or al, al 
;     jz load_kernel
;     mov ah, 0x0E
;     int 0x10
;     jmp .print_loop

; load_kernel:
;     mov ah, 0x02 ; BIOS read sector function
;     mov al, 0x09 ; load 1 sector
;     mov ch, 0x00 ; Cylinder 0
;     mov cl, 0x03 ; Sector 3
;     mov dh, 0x00 ; Head
;     mov dl, 0x80 ; HDD
;     mov bx, 0x0000  ; This is where Kernel will be loaded.
;     mov es, bx
;     mov bx, 0x8000  ; offset {ES:BX}
;     int 0x13    ; BIOS interrupt
    
;     jc disk_error

;     mov ah, 0x0E
;     mov al, '>'
;     int 0x10

;     mov ax, 0x0000
;     mov ss, ax
;     mov sp, 0x7C00

;     jmp 0x0000:0x8000

; disk_error:
;     mov si, disk_msg

; .print_disk_error:
;     lodsb
;     or al, al 
;     jz hang
;     mov ah, 0x0E
;     int 0x10
;     jmp .print_disk_error

; hang:
;     jmp $

; stage2_msg db "Stage2 bootloader loaded successfully!", 0
; disk_msg db "Kernel load failed!", 0

; times 512 - ($ - $$) db 0

; Stage 2 bootloader with Protected Mode transition

[org 0x7E00]
[bits 16]

; --- Load the kernel from disk ---
load_kernel:
    mov si, loading_msg
    call print_string_16

    mov ah, 0x02    ; BIOS read function
    mov al, 25       ; Read 4 sectors (2KB) for our small kernel
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x03    ; Sector 3
    mov dh, 0x00    ; Head 0
    mov dl, [0x7DF0]    ; Drive 0x80 (HDD)
    mov bx, 0x8000  ; Load address
    int 0x13
    jc disk_error

    ; --- Switch to Protected Mode ---
    cli             ; 1. Disable interrupts
    lgdt [gdt_descriptor] ; 2. Load the GDT descriptor
    mov eax, cr0    ; 3. Set the PE bit in CR0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:p_mode_start ; 4. Far jump to flush the CPU pipeline

disk_error:
    mov si, disk_error_msg
    call print_string_16
    jmp $

; Helper to print strings in 16-bit real mode
print_string_16:
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

; --- Global Descriptor Table (GDT) ---
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code segment descriptor (base=0, limit=4GB, ring 0)
CODE_SEG equ $ - gdt_start
    dw 0xFFFF       ; Limit (low)
    dw 0x0          ; Base (low)
    db 0x0          ; Base (mid)
    db 0b10011010   ; Access byte: present, ring 0, code, executable, readable
    db 0b11001111   ; Flags (4K granularity) + Limit (high)
    db 0x0          ; Base (high)

    ; Data segment descriptor (base=0, limit=4GB, ring 0)
DATA_SEG equ $ - gdt_start
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 0b10010010   ; Access byte: present, ring 0, data, writable
    db 0b11001111
    db 0x0
gdt_end:

; GDT Descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT limit
    dd gdt_start               ; GDT base address

; --- Messages ---
loading_msg db "Loading kernel...", 0
disk_error_msg db "Disk read error!", 0

[bits 32]
p_mode_start:
    ; Set up segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up the stack
    mov esp, 0x7C00 ; Stack starts below the original bootloader area

    ; Jump to the kernel's entry point
    jmp 0x8000