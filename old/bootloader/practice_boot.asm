;;;;;;;;;;;;;;;;;;;;;;; Bootloader to print string on screen ;;;;;;;;;;;;;;
; [org 0x7C00]

;     mov si, msg

; .loop: 
;     lodsb
;     or al, al
;     jz .done
;     mov ah, 0x0E
;     int 0x10
;     jmp .loop

; .done: 
;     jmp .done

; msg db "Hey! this is my code!", 0

; times 510 - ($ - $$) db 0
; dw 0xAA55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [org 0x7C00]
; ; Bootloader code for a simple bootable disk image
;     mov ah, 0x0E      
;     mov al, 'H'        ; Print 'H'
;     int 0x10          ; BIOS interrupt to print character
;     mov al, 'i'        ; Print 'i'
;     int 0x10          ; BIOS interrupt to print character
;     mov al, '!'        ; Print '!'
;     int 0x10          ; BIOS interrupt to print character

; hang:
;     jmp hang           ; Infinite loop to hang the system

; times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros
; dw 0xAA55          ; Boot signature (must be at the end of the boot sector)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ; Bootloader that prints a string to the screen
; [org 0x7C00]

;     mov si, msg       ; Point to the strart of the message

; .loop:
;     lodsb          ; Load byte at DS:SI into AL and increment SI
;     cmp al, 0         ; Check if the byte is null (end of string)
;     je .done          ; If it is null, jump to done
;     mov ah, 0x0E      ; BIOS teletype output function
;     int 0x10         ; Call BIOS interrupt to print character
;     jmp .loop         ; Repeat for the next character

; .done:
;     jmp $         ; Infinite loop to hang the system

; msg db "Hello from my bootloader!", 0 ; Null-terminated string

; times 510 - ($ - $$) db 0 ; Fill the rest of the boot sector with zeros
; dw 0xAA55          ; Boot signature (must be at the end of the boot sector)