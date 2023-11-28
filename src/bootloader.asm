org 7c00h                  ; Set the origin to the default bootloader start address

mov ah, 0h                 ; Set up the registers for the BIOS interrupt call
int 13h                    ; Invoke BIOS interrupt 13h to reset disk drives

; Reset the disk
mov ax, 0000h              ; Clear the AX register
mov es, ax                 ; Set ES (Extra Segment) register to 0000h
mov bx, 1000h              ; Set BX register to the memory address where the NASM script will be loaded

; Load the NASM script into memory using BIOS interrupt 13h
mov ah, 02h                ; Function code 02h for reading sectors
mov al, 3                  ; Number of sectors to read
mov ch, 0                  ; Cylinder number
mov cl, 2                  ; Sector number
mov dh, 0                  ; Head number
mov dl, 0                  ; Drive number

int 13h                    ; Invoke BIOS interrupt 13h to read sectors into memory

; Jump to the loaded NASM script
jmp 0000h:1000h            ; Jump to the memory location where the NASM script is loaded

; Pad the bootloader to 510 bytes with zeros
times 510 - ($ - $$) db 0  ; Fill the remaining space in the bootloader with zeros

dw 0AA55h                  ; Add the 16-bit boot signature to the last two bytes of the bootloader
