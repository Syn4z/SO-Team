org 0x7c00

message: db '@@@FAF-213 Sorin IATCO###', 0

section .text
    global _start

_start:
    ; Initialization
    mov si, 10          ; Set loop counter to 10

read_sector_loop:
    ; Read existing data from the sector into the buffer
    mov ah, 02h         ; Function code for read sectors
    mov al, 1           ; Number of sectors to read
    mov ch, 1           ; Cylinder number     
    mov cl, 5           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, buffer      ; Pointer to the buffer
    int 13h             ; BIOS interrupt

    ; Concatenate the new message to the existing data
    mov di, buffer
    add di, 27          ; Move to the end of the existing data
    mov si, message
    add si, 0           ; Pointer to the new message
    rep movsb           ; Copy the new message to the buffer

    ; Write the updated data back to the sector
    mov ah, 03h         ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 1           ; Cylinder number     
    mov cl, 5           ; Sector number    
    mov dh, 1           ; Head number
    mov bx, buffer      ; Pointer to the buffer
    int 13h             ; BIOS interrupt

    ; Loop control
    dec si
    cmp si, 0
    jnz read_sector_loop

    ; Program termination
    mov ah, 4ch         ; Function code for program termination
    int 21h             ; DOS interrupt

buffer: resb 512     ; Buffer to store the sector data
