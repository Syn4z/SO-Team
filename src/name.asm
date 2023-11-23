org 0x7c00

section .data
    message db '@@@FAF-213 Sorin IATCO###'

section .text
    global _start

_start:
    mov si, 9         ; Set loop counter to 9

    ; Loop to duplicate the string in the first and last sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 1           ; Cylinder number
    mov cl, 5           ; Sector number
    mov dh, 1           ; Head number
    lea bx, [message]   ; Pointer to the string
    int 13h            ; BIOS interrupt

    duplicate_loop:
        inc cl             ; Increment sector number
        dec si

        mov ah, 03h        ; Function code for write sectors
        mov al, 1           ; Number of sectors to write
        mov ch, 1           ; Cylinder number         
        mov dh, 1           ; Head number
        lea bx, [message]   ; Pointer to the string
        int 13h            ; BIOS interrupt
        
        cmp si, 0
        jnz duplicate_loop

    ; Exit the program
    mov ah, 4ch        ; Function code for program termination
    int 21h             ; DOS interrupt
