org 0x7c00

message: db '@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###@@@FAF-213 Sorin IATCO###', 0

section .text
    global _start

_start:
    ; First sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 2           ; Cylinder number     
    mov cl, 1           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Second sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 2           ; Cylinder number     
    mov cl, 18           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, message   ; Pointer to the string
    int 13h            ; BIOS interrupt

    mov ah, 4ch        ; Function code for program termination
    int 21h             ; DOS interrupt
