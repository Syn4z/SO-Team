org 0x7c00			; Set the origin of the program to the bootloader's default address.

mov AL, 0x3			; Set AL register to 0x3, indicating the video mode.
mov AH, 0			; Clear the AH register.
int 0x10			; Trigger an interrupt to set the video mode (80x25 text mode).

mov SI, buffer		; Initialize SI register as a pointer to the buffer.
typing:				; Label for the main input loop.
    mov AH, 0		; Clear AH register.
    int 0x16		; Wait for a keyboard key press and store it in AL.

    cmp AH, 0x0e	; Check if the Backspace key was pressed.
    je backspace_key	; If so, jump to the "backspace_key" label.

    cmp AH, 0x1c	; Check if the Enter key was pressed.
    je enter_key	; If so, jump to the "enter_key" label.

    cmp AL, 0x20	; Check if the entered character is a space or a printable character.
    jge print_character	; If yes, jump to the "print_character" label.

    jmp typing		; Otherwise, continue reading user keyboard inputs.

backspace_key:		; Label for handling the Backspace key.
    cmp SI, buffer	; Check if the buffer is empty.
    je typing		; If empty, go back to the input loop.
    dec SI		    ; Decrement SI to move the pointer back.
    mov byte [SI], 0	; Clear the character at the current position in the buffer.

    mov AH, 03h	    ; Get cursor position.
    mov BH, 0		; Set BH to 0 (video page).
    int 0x10		; Get the current cursor position.

    cmp DL, 0		; Check if DL (column) is at the beginning of the line.
    jz last_line	; If so, move the cursor to the previous line.
    jmp last_character	; Otherwise, move the cursor to the previous character position.

last_character:		; Label for moving the cursor to the previous character position.
    mov AH, 02h	    ; Set cursor position.
    dec DL		    ; Decrement DL (column) to move left.
    int 0x10		; Set the new cursor position.
    jmp space_character	; Jump to space character handling.

last_line:		    ; Label for moving the cursor to the previous line.
    mov AH, 02h	    ; Set cursor position.
    mov DL, 79		; Set DL (column) to 79 (end of line).
    dec DH		; Decrement DH (row) to move up one line.
    int 0x10		; Set the new cursor position.

space_character:	; Label for handling space character.
    mov AH, 0Ah		; Set AH to 0xa (teletype output).
    mov AL, 0x20	; Set AL to 0x20 (space character).
    mov CX, 1		; Set CX to 1 (number of repetitions).
    int 0x10		; Display the space character.
    jmp typing		; Continue reading user input.

enter_key:		    ; Label for handling the Enter key.
    mov AH, 03h	    ; Get cursor position.
    mov BH, 0		; Set BH to 0 (video page).
    int 0x10		; Get the current cursor position.

    sub SI, buffer	; Calculate the difference between SI and the buffer address.
    jz insert_line	; If SI equals the buffer address, jump to insert_line.

    mov AH, 03h	    ; Get cursor position.
    mov BH, 0		; Set BH to 0 (video page).
    int 0x10		; Get the current cursor position.

    cmp DH, 24		; Check if DH (row) is 24 (last row).
    jl print_echo	; If not, jump to print_echo.

    mov AH, 0x06	; Set AH to 0x06 (scroll window up).
    mov AL, 1		; Set AL to 1 (number of lines to scroll).
    mov BH, 0x07	; Set BH to 0x07 (attribute for blank lines).
    mov CX, 0		; Set CX to 0 (upper left corner).
    mov DX, 0x184f	; Set DX to the bottom right corner.
    int 0x10		; Scroll the window up.
    mov DH, 0x17	; Set DH to 0x17 (last visible row).

print_echo:		; Label for printing characters to the screen.
    mov BH, 0		; Set BH to 0 (video page).
    mov AX, 0		; Clear AX register.
    mov ES, AX		; Set ES to 0 (extra segment).
    mov BP, buffer	; Set BP to point to the buffer.

    mov BL, 60h		; Set BL to 60h (color: black on orange).
    mov CX, SI		; Set CX to the current buffer position.
    inc DH		; Increment DH to move to the next row.
    mov DL, 0		; Set DL to 0 (column).

    mov AX, 1301h	; Set AX to 1301h (teletype output, update cursor).
    int 0x10		; Display the character and update the cursor.

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

    add SI, buffer	; Increment SI to move to the next buffer position.

clear_buffer:		; Label for clearing the buffer.
    mov byte [SI], 0	; Clear the character at the current buffer position.
    inc SI		; Increment SI to move to the next buffer position.
    cmp SI, 0		; Compare SI to 0.
    jne clear_buffer	; If not equal, continue clearing the buffer.
    mov SI, buffer	; Reset SI to point to the beginning of the buffer.
    jmp typing		; Continue reading user input.

print_character:	; Label for printing a character.
    cmp AL, 0x7f	; Check if the entered character is a control character.
    jge typing		; If yes, jump back to reading user input.

    cmp SI, buffer + 256	; Check if SI is at the end of the buffer.
    je typing		; If so, jump back to reading user input.

    mov [SI], AL	; Store the entered character in the buffer.
    inc SI		; Increment SI to move to the next buffer position.

    mov AH, 0xe		; Set AH to 0xe (teletype output).
    int 10h		; Display the entered character.
    jmp typing		; Continue reading user input.

buffer: times 256 db 0x0	; Define a buffer of 256 bytes, initialized with null characters.
