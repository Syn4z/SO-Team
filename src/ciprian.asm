org 0x7c00

section .data
    message: times 10 db "@@@FAF-213 Ciprian BOTNARI###"

section .text
    global _start

_start:
    ; First sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 28           ; Track number     
    mov cl, 3           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Last sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 30           ; Track number     
    mov cl, 1           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message   ; Pointer to the string
    int 13h            ; BIOS interrupt

    mov ah, 4ch        ; Function code for program termination
    int 21h             ; DOS interrupt
