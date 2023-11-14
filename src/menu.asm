org 0x7c00  ; Origin of the bootloader program

section .data
	option1 db "1. Key to Flp ", 0
	option1_len equ $ - option1
	option2 db "2. Flp to RAM ", 0
	option2_len equ $ - option2
	option3 db "3. RAM to Flp ", 0
	option3_len equ $ - option3
	input db "Write your choice: ", 0
	input_len equ $ - input
	wrong_input db "Invalid input", 0
	wrong_input_len equ $ - wrong_input
	row db 0
	column db 0
	
section .text
	global _start

_start:
	mov ah, 0  ; Video mode
	mov al, 0x3  ; 80x25 text mode
	int 10h 
	
print_menu:
	mov si, option1
	call print_option
	mov si, option2
	call print_option
	mov si, option3
	call print_option
	mov si, input
	call print_option

print_option:
	mov al, [si]     ; Load the character from the buffer
	cmp al, 0        ; Check if it's the null terminator
	je reached_end  ; If it is, we reached the end

	mov ah, 0x0e  ; Teletype output
	int 10h

	inc si  ; Next character in the buffer
	jmp print_option

reached_end:
	ret  ; Return from the function

write_newline:
	cmp dh, 24				; If at the last line of the terminal...
	je scroll_down				; Scroll screen down 1 line

	;Query Cursor Position and Size
	mov ah, 0x03				; DL, DH store cursor (x,y) positions
	mov bh, 0
	int 0x10

	jmp move_down	

move_down:
	mov ah, 0x02				; Move the cursor at the start of the line below this one
	mov bh, 0
	inc dh
	mov dl, 0
	int 0x10

scroll_down:
	mov ah, 0x06
	mov al, 1
	mov bh, 0x07				; Draw new line as White on Black
	mov cx, 0					; (0,0): Top-left corner of the screen
	mov dx, 0x184f				; (79,24): Bottom-right corner of the screen
	int 0x10
	mov dh, 0x17		
