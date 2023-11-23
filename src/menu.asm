org 0x7c00			; Set the origin of the program to the bootloader's default address.

section .data
    menu db "Menu", 0
    menu_len equ $ - menu
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

section .text
	global _start

_start:
	jmp print_menu

print_menu:
    mov bp, menu
    call print_char
    call insert_line

	mov bp, option1
	call print_char
	call insert_line

	mov bp, option2
	call print_char
	call insert_line

	mov bp, option3
	call print_char
	call insert_line

	mov bp, input
	call print_char
	call insert_line

    ; TODO: Change hardcoded values
	; Move the cursor to a specific position after printing the menu
    mov ah, 02h     ; Set cursor position.
    mov bh, 0       ; Set BH to 0 (video page).
    mov dh, 4
    mov dl, input_len       ; Set DL to the desired column.
    int 10h         ; Set the new cursor position.

print_char:
	mov al, [bp]     ; Load the character from the buffer
	cmp al, 0        ; Check if it's the null terminator
	je reached_end  ; If it is, we reached the end

	mov ah, 0xe
	int 10h

	inc bp
	jmp print_char

reached_end:
	ret

insert_line:		; Label for inserting a new line.
    cmp DH, 24		; Check if DH (row) is 24 (last row).
    je scroll_down	; If so, jump to scroll_down.

    mov AH, 03h	    ; Get cursor position.
    mov BH, 0		; Set BH to 0 (video page).
    int 0x10		; Get the current cursor position.
    jmp cursor_down	; Continue moving the cursor down.

scroll_down:		; Label for scrolling down the screen.
    mov AH, 0x06	; Set AH to 0x06 (scroll window up).
    mov AL, 1		; Set AL to 1 (number of lines to scroll).
    mov BH, 0x07	; Set BH to 0x07 (attribute for blank lines).
    mov CX, 0		; Set CX to 0 (upper left corner).
    mov DX, 0x184f	; Set DX to the bottom right corner.
    int 0x10		; Scroll the window up.
    mov DH, 0x17	; Set DH to 0x17 (last visible row).

cursor_down:		; Label for moving the cursor down by one line.
    mov AH, 02h	    ; Set cursor position.
    mov BH, 0		; Set BH to 0 (video page).
    inc DH		; Increment DH to move down one row.
    mov DL, 0		; Set DL to 0 (column).
    int 0x10		; Set the new cursor position.
    ret
