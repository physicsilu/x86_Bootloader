[BITS 16]           ; This is a directive that tells the assembler to treat this code as 16-bit code
[ORG 0x7C00]        ; This is the origin address where the bootloader will be loaded in memory


CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

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
    ; mov si, msg     ; This basically points to the inintial character of the message if I understand it right.

; print:
;     lodsb           ; loads byte at DS:SI to AL register and increments SI
;     cmp al, 0       ; This is like our end character. We defined '0' to be that. Now if 0 gets loaded into AL, we are done.
;     je done         ; Jump if equal
;     mov ah, 0x0E
;     int 0x10
;     jmp print       ; This is an unconditional jump. Basically a loop.

; done:
;     cli
;     hlt             ; Stop further CPU execution
; msg: db 'Hello World!', 0


load_Protected_Mode:
    cli
    ; Load the GDT (Global Descriptor Table)
    lgdt [gdt_descriptor] ; Load the GDT descriptor
    ; Enable protected mode
    mov eax, cr0
    or al, 0x1      ; Set the PE (Protection Enable) bit in CR0
    mov cr0, eax
    jmp CODE_OFFSET:Protected_Mode_Main ; Far jump to flush the CPU pipeline


;GDT (Global Descriptor Table) Implementation

gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code segment descriptor (base=0, limit=4GB, ring 0)
    dw 0xFFFF       ; Limit (low)
    dw 0x0000       ; Base (low)
    db 0x00         ; Base (mid)
    db 10011010b    ; Access byte: present, ring 0, code, executable, readable
    db 11001111b    ; Flags (4K granularity) + Limit (high)
    db 0x00         ; Base (high)

    ; Data segment descriptor (base=0, limit=4GB, ring 0)
    dw 0xFFFF       ; Limit (low)
    dw 0x0000       ; Base (low)
    db 0x00         ; Base (mid)
    db 10010010b    ; Access byte: present, ring 0, code, executable, readable
    db 11001111b    ; Flags (4K granularity) + Limit (high)
    db 0x00         ; Base (high)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT limit
    dd gdt_start               ; GDT base address

[BITS 32]
Protected_Mode_Main:
    ; Set up the data segment
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x9C00  ; Set up the stack pointer. This location is chosen to avoid stack overflow with the bootloader size. 
    mov esp, ebp

    in al, 0x92
    or al, 2
    out 0x92, al     ; Enable A20 line

    ; mov ax, 0xb800
    ; mov es, ax       ; Set ES to video memory segment
    mov ebx, 0xb8000   ; Start writing at the beginning of video memory


    ; Print a message to indicate that we are in protected mode
    mov al, 'A'
    mov ah, 0x0F
    mov [ebx], ax ; Write character to video memory at the start of the screen

    mov si, loading_msg
    call print_string_16

    hlt

print_string_16:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0F
    mov [ebx], ax ; Write character to video memory
    inc ebx
    inc ebx
    jmp print_string_16
.done:
    ret
loading_msg db "Loading kernel in protected mode...", 0


times 510 - ($ - $$) db 0  ; This is basically padding with zeros.
dw 0xAA55           ; This is the boot signature. No matter what's there in the first 510 bytes, this is what tells the BIOS that it's a bootloader.