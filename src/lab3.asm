org 0x7c00  ; Origin of the bootloader program

section .data
	buffer times 256 db 0x0  ; 256-byte buffer initialized to zeros
	x_coord dw 0  ; X-coord for cursor position
	y_coord dw 0  ; Y-coord for cursor position

section .text
	global _start

_start:
	mov ah, 0  ; Video mode
	mov al, 0x3  ; 80x25 text mode
	int 10h    

	mov si, buffer     ; Initialize SI register to point to the buffer
	mov word [x_coord], 0 
	mov word [y_coord], 0

keyboard_read:
	mov ah, 00h  ; Read a character from the keyboard
	int 16h       ; Keyboard BIOS interrupt

	cmp al, 0x08  ; backspace (ASCII code 0x08)
	je input_backspace

	cmp al, 0x0D  ; enter key (ASCII code 0x0D)
	je input_enter

	cmp al, 0x20	; Is a printable character.
    	jge echo_char	
    	
    	jmp keyboard_read

input_backspace:
	cmp word [x_coord], 0 
	je prev_line

	dec word [x_coord]

	mov ah, 02h  ; Set the cursor position
	mov bh, 0
	mov dl, [x_coord]  ; Column
	int 10h

	mov ah, 0Ah  ; Write character in teletype mode
	mov bh, 0  ; Page
	mov al, ' '  ; Space character
	mov cx, 2  ; Counter
	int 10h
	
	cmp si, buffer
	je keyboard_read  ; If SI is at the start, go back to reading

	dec si
	mov byte [si], 0  ; Set the character in the buffer to 0 (null terminator)

	jmp keyboard_read

prev_line:
	cmp word [y_coord], 0
	je keyboard_read

	dec word [y_coord]
	mov word [x_coord], 79  ; Set the x_coord to the rightmost column

	mov ah, 02h  ; Set the cursor position
	mov bh, 0
	mov dl, [x_coord]  ; Column
	mov dh, [y_coord]  ; Row
	int 10h

	jmp keyboard_read

input_enter:
	cmp word [y_coord], 24
	je keyboard_read

	call new_line

	cmp si, buffer
	je keyboard_read
	
	call new_line
	call buffer_spacing
	call print_buffer

	.loop:
		call new_line
		dec cx
		cmp cx, 0
		jg .loop

	call new_line

	mov si, buffer  ; Reset SI to the start of the buffer
	xor cx, cx
	jmp clear_buffer

print_buffer:
    mov si, buffer   ; Point SI to the beginning of the buffer
    jmp print_char

print_char:
    mov al, [si]     ; Load the character from the buffer
    cmp al, 0        ; Check if it's the null terminator
    je buffer_empty  ; If it is, the buffer is empty

    mov ah, 0x0e  ; Teletype output
    int 10h

    inc si  ; Next character in the buffer
    jmp print_char

buffer_empty:
    ret  ; Return from the function

; New line additions for large inputs
buffer_spacing:
    cmp si, buffer + 80
    jle .spacing_1 
    
    cmp si, buffer + 160 
    jle .spacing_2 
    
    cmp si, buffer + 240 
    jle .spacing_3 
    
    call new_line  
    call new_line
    call new_line
    mov cx, 4 
    ret

.spacing_1:
    mov cx, 1
    ret 

.spacing_2:
    call new_line
    mov cx, 2
    ret 

.spacing_3:
    call new_line
    call new_line
    mov cx, 3
    ret 

clear_buffer:
    mov byte [si], 0  ; Replace byte in the buffer with 0
    inc si
    inc cx
    cmp cx, 256
    jl clear_buffer_continue

    mov si, buffer  ; Reset SI to the beginning of the buffer
    mov word [x_coord], 0  ; Reset X-coordinate to 0
    jmp keyboard_read

clear_buffer_continue:
    jmp clear_buffer

new_line:
    inc word [y_coord]  ; Increment the Y-coordinate for a new line
    mov word [x_coord], 0  ; Reset X-coordinate to 0

    mov ah, 02h  ; Set the cursor position
    mov dh, [y_coord]  ; Row
    mov dl, [x_coord]  ; Column
    int 10h 
    ret

echo_char:
    cmp al, 0x7f 	; Omit delete char
    jge keyboard_read

    cmp si, buffer + 256  ; Buffer limit
    je keyboard_read

    mov [si], al  ; Store the character in the buffer at the current position
    inc si 

    inc word [x_coord]
    
    mov ah, 0Eh  ; Teletype output
    int 10h
    
    jmp keyboard_read 
