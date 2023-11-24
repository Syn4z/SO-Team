org 0x7c00

section .data
    message_1: times 10 db "@@@FAF-213 Sorin IATCO###"
    ; message_2: times 10 db "@@@FAF-213 Dinu GUTU###"
    ; message_3: times 10 db "@@@FAF-213 Ciprian BOTNARI###"

section .text
    global _start

_start:
    ; Print string
    mov ah, 0eh         ; Function code for print string
    mov al, 0           ; Page number
    mov bh, 0           ; Display page number
    mov bl, 7           ; Text attribute
    mov cx, 10          ; Number of characters to print
    mov bp, message_1     ; Pointer to the string
    int 10h             ; BIOS interrupt

    ; First sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 2           ; Cylinder number     
    mov cl, 1           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message_1   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Second sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 2           ; Cylinder number     
    mov cl, 18           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message_1   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; mov ah, 4ch        ; Function code for program termination
    ; int 21h             ; DOS interrupt
