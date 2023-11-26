org 1000h

start:
    ; First sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 54           ; Cylinder number     
    mov cl, 7           ; Sector number    
    mov dl, 0
    mov dh, 1           ; Head number
    mov bx, student_1   ; Pointer to the string
    int 13h            ; BIOS interrupt
    ; Second sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 55           ; Cylinder number     
    mov cl, 6           ; Sector number    
    mov dl, 0
    mov dh, 0           ; Head number
    mov bx, student_1   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Third sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 65           ; Cylinder number     
    mov cl, 5           ; Sector number    
    mov dl, 0
    mov dh, 1           ; Head number
    mov bx, student_2   ; Pointer to the string
    int 13h            ; BIOS interrupt
    ; Fourth sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 65           ; Cylinder number     
    mov cl, 6           ; Sector number    
    mov dl, 0
    mov dh, 2           ; Head number
    mov bx, student_2   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Fifth sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 66           ; Cylinder number     
    mov cl, 17           ; Sector number    
    mov dl, 0
    mov dh, 1           ; Head number
    mov bx, student_3   ; Pointer to the string
    int 13h            ; BIOS interrupt
    ; Sixth sector
    mov ah, 03h        ; Function code for write sectors
    mov al, 1           ; Number of sectors to write
    mov ch, 67           ; Cylinder number     
    mov cl, 6           ; Sector number    
    mov dl, 0
    mov dh, 0           ; Head number
    mov bx, student_3   ; Pointer to the string
    int 13h            ; BIOS interrupt

    ; Print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

student_1: times 10 db "@@@FAF-213 Ciprian BOTNARI###"
student_2: times 10 db "@@@FAF-213 Dinu GUTU###"
student_3: times 10 db "@@@FAF-213 Sorin IATCO###"
