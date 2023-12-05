org 1000h                ; Set the origin of the program to 1000h
bits 16                  ; Set the code generation to 16-bit

jmp start

%include "print_string.asm"   ; Include external assembly code for string printing
%include "str_compare.asm"    ; Include external assembly code for string comparison

start:                   ; Start of the program
    mov ah, 0x00         ; Set AH register for video services
    mov al, 0x03         ; Set AL register for text mode
    int 0x10             ; Call BIOS video interrupt

    mov sp, 1000h        ; Set the stack pointer

    ; Reset all variables
    mov byte [n], 0
    mov byte [head], 0
    mov byte [track], 0
    mov byte [sector], 0
    mov word [ram_start], 0
    mov word [ram_end], 0
    mov byte [var_flag], 0
    mov byte [ram_flag], 0
    mov byte [q_flag], 0
    mov byte [ram_success], 0
    call clear_buffer

    mov si, help_desc     ; Load the address of help_desc into SI
    call print_string_si

mainloop:                ; Main loop label
    call get_input
    jmp mainloop

get_input:              ; Subroutine to get user input
    mov bx, 0            ; Initialize BX register

input_processing:       ; Label for input processing loop
    mov ah, 0x0          ; Set AH register for keyboard services
    int 0x16              ; Call BIOS keyboard interrupt

    cmp al, 0x3           ; Compare input with Ctrl+C
    je start

    cmp al, 0x0d          ; Compare input with Enter key
    je check_the_input

    cmp al, 0x8           ; Compare input with Backspace
    je backspace_pressed

    mov ah, 0x0e          ; Set AH register for teletype output
    int 0x10              ; Call BIOS video interrupt

    mov [input+bx], al    ; Store the input character in the buffer
    inc bx                ; Increment the buffer index

    cmp bx, 255           ; Check if the buffer is full
    je check_the_input

    jmp input_processing

stop_cpu:                ; Label for stopping the CPU
    mov si, goodbye       ; Load the address of the goodbye message into SI
    call print_string_si

    jmp $

backspace_pressed:      ; Subroutine for processing Backspace key
    cmp bx, 0             ; Check if the buffer is empty
    je input_processing

    mov ah, 0x0e          ; Set AH register for teletype output
    int 0x10              ; Call BIOS video interrupt

    mov al, ' '           ; Print a space to erase the character
    int 0x10              ; Call BIOS video interrupt

    mov al, 0x8           ; Move the cursor back (Backspace)
    int 0x10              ; Call BIOS video interrupt

    dec bx                ; Decrement the buffer index
    mov byte [input+bx], 0 ; Set the removed character to null

    jmp input_processing

check_the_input:         ; Label for checking the input
    inc bx                ; Increment the buffer index
    mov byte [input+bx], 0 ; Set the end of the string

    mov si, new_line      ; Load the address of new_line into SI
    call print_string_si

    ; Q processing
    cmp byte [q_flag], 1  ; Check if Q flag is set
    je q_processing

    ; RAM processing
    cmp byte [ram_flag], 2 ; Check if RAM flag is set to 2
    je segment_processing

    cmp byte [ram_flag], 3 ; Check if RAM flag is set to 3
    je address_processing

    ; Option 1 processing
    cmp byte [var_flag], 1 ; Check if var_flag is set to 1
    je n_processing

    cmp byte [var_flag], 2 ; Check if var_flag is set to 2
    je head_processing

    cmp byte [var_flag], 3 ; Check if var_flag is set to 3
    je track_processing

    cmp byte [var_flag], 4 ; Check if var_flag is set to 4
    je sector_processing

    cmp byte [var_flag], 5 ; Check if var_flag is set to 5
    je string_processing

    mov si, help_command   ; Load the address of help_command into SI
    mov bx, input          ; Load the address of input into BX
    call compare_strs_si_bx
    cmp cx, 1              ; Compare the result of string comparison
    je equal_help

    ; Option 1
    mov si, option_1       ; Load the address of option_1 into SI
    mov bx, input          ; Load the address of input into BX
    call compare_strs_si_bx ; Call subroutine to compare strings in SI and BX
    cmp cx, 1              ; Compare the result of string comparison
    je equal_option_1

    ; Option 2
    mov si, option_2       ; Load the address of option_2 into SI
    mov bx, input          ; Load the address of input into BX
    call compare_strs_si_bx
    cmp cx, 1              ; Compare the result of string comparison
    je equal_option_2

    ; Option 3
    mov si, option_3       ; Load the address of option_3 into SI
    mov bx, input          ; Load the address of input into BX
    call compare_strs_si_bx
    cmp cx, 1              ; Compare the result of string comparison
    je equal_option_3

    cmp cx, 0              ; Compare the result of string comparison
    je equal_random_string

equal_help:              ; Label for equal help strings
    mov si, help_desc      ; Load the address of help_desc into SI
    call print_string_si

    jmp done

equal_option_1:          ; Label for equal option_1 strings
    mov si, variables_1    ; Load the address of variables_1 into SI
    call print_string_si
    mov si, n_prompt       ; Load the address of n_prompt into SI
    call print_string_si

    inc byte [var_flag]    ; Increment var_flag
    jmp done

n_processing:            ; Label for processing n input
    call convert_input_int
    mov al, [result]      ; Load the result into AL register
    mov [n], al           ; Store the result in the variable n

    mov si, head_prompt    ; Load the address of head_prompt into SI
    call print_string_si

    inc byte [var_flag]    ; Increment var_flag
    jmp done

head_processing:         ; Label for processing head input
    call convert_input_int ; Call subroutine to convert input to integer
    mov al, [result]      ; Load the result into AL register
    mov [head], al        ; Store the result in the variable head

    mov si, track_prompt   ; Load the address of track_prompt into SI
    call print_string_si

    inc byte [var_flag]    ; Increment var_flag
    jmp done

track_processing:        ; Label for processing track input
    call convert_input_int
    mov al, [result]      ; Load the result into AL register
    mov [track], al       ; Store the result in the variable track

    mov si, sector_prompt  ; Load the address of sector_prompt into SI
    call print_string_si

    inc byte [var_flag]    ; Increment var_flag
    jmp done

sector_processing:       ; Label for processing sector input
    call convert_input_int
    mov al, [result]      ; Load the result into AL register
    mov [sector], al      ; Store the result in the variable sector

    cmp byte [ram_flag], 1 ; Check if RAM flag is set to 1
    je ram_processing

    mov si, string_prompt  ; Load the address of string_prompt into SI
    call print_string_si

    inc byte [var_flag]    ; Increment var_flag
    jmp done

ram_processing:          ; Label for processing RAM input
    mov si, ram_start_prompt ; Load the address of ram_start_prompt into SI
    call print_string_si

    inc byte [ram_flag]    ; Increment ram_flag
    jmp done

segment_processing:     ; Label for processing segment input
    mov si, ram_start      ; Load the address of ram_start into SI
    call read_address_process_input

    mov si, ram_end_prompt ; Load the address of ram_end_prompt into SI
    call print_string_si

    inc byte [ram_flag]    ; Increment ram_flag
    jmp done

address_processing:     ; Label for processing address input
    mov si, ram_end        ; Load the address of ram_end into SI
    call read_address_process_input

    mov si, new_line       ; Load the address of new_line into SI
    call print_string_si

    cmp byte [q_flag], 2  ; Compare q_flag with 2
    je ram_to_floppy

    jmp read_floppy

read_address_process_input: ; Subroutine for processing address input
   mov di, input           ; Load the address of input into DI

address_processing_input: ; Label for processing address input loop
   cmp di, input + 4       ; Compare DI with the end of the address input
   je address_processing_input_done

   mov al, [di + 2]        ; Load the high byte of the address
   shl al, 4               ; Shift it left by 4 bits
   or al, [di + 3]         ; OR it with the low nibble of the high byte
   mov ah, [di]            ; Load the low byte of the address
   shl ah, 4               ; Shift it left by 4 bits
   or ah, [di + 1]         ; OR it with the low nibble of the low byte
   mov word [si], ax       ; Store the 16-bit result in the destination address
   add di, 4               ; Move to the next 4 bytes
   add si, 2               ; Move to the next 2 bytes
   inc bl                  ; Increment a counter (not used)

   jmp address_processing_input

address_processing_input_done: ; Label for finishing address input processing
    ret

string_processing:        ; Label for processing string input
    jmp fill_write_buffer

equal_option_2:           ; Label for equal option_2 strings
    mov si, variables_2    ; Load the address of variables_2 into SI
    call print_string_si
    mov si, n_prompt       ; Load the address of n_prompt into SI
    call print_string_si

    inc byte [ram_flag]    ; Increment ram_flag
    inc byte [var_flag]    ; Increment var_flag

    jmp done

equal_option_3:
    mov si, variables_3       ; Set SI to point to variables description
    call print_string_si
    mov si, q_prompt          ; Set SI to point to "q = "
    call print_string_si

    inc byte [q_flag]         ; Increment q_flag (a flag indicating the presence of 'q' command)

    jmp done

q_processing:
    call convert_input_int
    mov al, [result]           ; Move the result to AL
    mov [q], al                ; Store the result in q

    mov si, head_prompt        ; Set SI to point to "head = "
    call print_string_si

    inc byte [var_flag]         ; Increment var_flag
    inc byte [var_flag]         ; Increment var_flag again
    inc byte [ram_flag]         ; Increment ram_flag
    inc byte [q_flag]           ; Increment q_flag

    jmp done

equal_random_string:
    mov si, new_line            ; Set SI to point to a new line
    call print_string_si       ; Print a new line

    mov si, input               ; Set SI to point to the input buffer
    call print_string_si       ; Print the contents of the input buffer

    mov si, new_line            ; Set SI to point to a new line
    call print_string_si       ; Print a new line

    jmp done

done:
    cmp bx, 0                   ; Compare buffer index with 0
    je exit

    dec bx                      ; Decrement buffer index
    mov byte [input+bx], 0      ; Null-terminate the input string

    jmp done

exit:
    ret

convert_input_int:
    mov si, input               ; Set SI to point to the input buffer
    mov byte [result], 0        ; Clear the result variable
    xor ax, ax                  ; Clear AX register
    xor cx, cx                  ; Clear CX register

    next_digit:
        lodsb                   ; Load byte at address SI into AL, increment SI
        cmp al, 0               ; Check for end of string
        je stop
        sub al, '0'             ; Convert from ASCII to number
        movzx ax, al            ; Zero-extend AL into AX
        imul cx, 10             ; Multiply CX by 10
        add cx, ax              ; Add AX to CX
        add [result], cx        ; Add CX to result
        jmp next_digit

    stop:
        ret

fill_write_buffer:
    mov si, input              ; Move the address of 'input' to source index register
    mov di, floppy_buffer      ; Move the address of 'floppy_buffer' to destination index register
    xor ax, ax                 ; Clear AX register
    xor bx, bx                 ; Clear BX register

    loop_buffer:
        cmp ax, 512             ; Compare the value in AX with 512
        je write_to_floppy
        cmp byte [n], 0         ; Compare the value at memory location 'n' with 0
        je write_to_floppy

        mov bl, byte [si]       ; Move the byte at the address in SI to BL
        mov byte [di], bl       ; Move the byte in BL to the address in DI

        inc ax                  ; Increment the value in AX
        inc si                  ; Increment the value in SI
        inc di                  ; Increment the value in DI

        cmp byte [si], 0        ; Compare the byte at the address in SI with 0
        jne loop_buffer
        mov si, input           ; Move the address of 'input' to SI
        dec byte [n]            ; Decrement the byte at the address in 'n'

        jmp loop_buffer

clear_buffer:
    cmp byte [di], 0            ; Compare the byte at the address in DI with 0
    je done

    mov byte [di], 0            ; Move 0 to the byte at the address in DI
    inc di                      ; Increment the value in DI
    cmp di, floppy_buffer + 512 ; Compare the value in DI with the address of 'floppy_buffer' + 512
    je done

    jmp clear_buffer

write_to_floppy:
    ; set the address of the first sector to write
    mov ah, 03h                 ; Set AH register to 3 (disk write)
    mov al, 1                   ; Set AL register to 1 (number of sectors to write)
    mov ch, [track]             ; Move the value at the address in 'track' to CH
    mov cl, [sector]            ; Move the value at the address in 'sector' to CL
    mov dl, 0                   ; Set DL register to 0 (floppy disk drive)
    mov dh, [head]              ; Move the value at the address in 'head' to DH
    mov bx, floppy_buffer       ; Move the address of 'floppy_buffer' to BX
    int 13h                     ; Call BIOS interrupt 13h

    mov si, error_message       ; Move the address of 'error_message' to SI
    call print_string_si

    ; print error code
    mov al, '0'                 ; Move the ASCII value of '0' to AL
    add al, ah                  ; Add the value in AH to AL
    mov ah, 0eh                 ; Set AH register to 0eh (teletype output)
    int 10h                     ; Call BIOS interrupt 10h

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    mov byte [var_flag], 0      ; Move 0 to the byte at the address in 'var_flag'

    jmp clear_buffer

read_floppy:
    mov ah, 02h                 ; Set AH register to 2 (disk read)
    mov al, [n]                 ; Move the value at the address in 'n' to AL
    mov ch, [track]             ; Move the value at the address in 'track' to CH
    mov cl, [sector]            ; Move the value at the address in 'sector' to CL
    mov dl, 0                   ; Set DL register to 0 (floppy disk drive)
    mov dh, [head]              ; Move the value at the address in 'head' to DH
    mov bx, [ram_start]         ; Move the value at the address in 'ram_start' to BX
    mov es, bx                  ; Move the value in BX to ES (Extra Segment)
    mov bx, [ram_end]           ; Move the value at the address in 'ram_end' to BX
    int 13h                     ; Call BIOS interrupt 13h

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    mov si, error_message       ; Move the address of 'error_message' to SI
    call print_string_si

    ; print error code
    mov al, '0'                 ; Move the ASCII value of '0' to AL
    add al, ah                  ; Add the value in AH to AL
    mov [ram_success], al       ; Move the value in AL to the byte at the address in 'ram_success'
    mov ah, 0eh                 ; Set AH register to 0eh (teletype output)
    int 10h                     ; Call BIOS interrupt 10h

    mov byte [ram_flag], 0      ; Move 0 to the byte at the address in 'ram_flag'
    mov byte [var_flag], 0      ; Move 0 to the byte at the address in 'var_flag'

    cmp byte [ram_success], 0   ; Compare the byte at the address in 'ram_success' with 0
    jne print_ram

    cmp byte [ram_success], 0   ; Compare the byte at the address in 'ram_success' with 0
    je print_fail_statement

print_ram:
    call clear_screen

    mov si, success_ram         ; Move the address of 'success_ram' to SI
    call print_string_si

    call print_ram_volume

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    jmp done

print_fail_statement:
    call clear_screen
    mov si, fail_ram            ; Move the address of 'fail_ram' to SI
    call print_string_si

    jmp done

clear_screen:
    mov ax, 0x0003              ; Set AX register to 0x0003 (video mode number for text mode 80x25)
    int 0x10                    ; Call BIOS interrupt 0x10
    ret                         

print_ram_volume:
    mov ax, 0x1301              ; Set AX register to 0x1301 (BIOS function to write text to the screen)
    mov bx, [ram_start]         ; Move the value at the address in 'ram_start' to BX
    mov es, bx                  ; Move the value in BX to ES (Extra Segment)
    mov bx, 0x0007              ; Set BX register to 0x0007 (attribute for text)
    mov cx, 1024                 ; Set CX register to 512 (number of characters to print)
    mov bp, [ram_end]           ; Move the value at the address in 'ram_end' to BP
    int 0x10                    ; Call BIOS interrupt 0x10

    ret

ram_to_floppy:
    xor dx, dx                  ; Clear DX register
    mov ax, [q]                 ; Move the value at the address in 'q' to AX
    mov cx, 512                 ; Set CX register to 512
    div cx                       ; Divide AX by CX, result in AX, remainder in DX

    inc al
    mov [num_of_sectors], al                     ; Decrement the value in AX

ram_copy_interrupt:
    mov bx, [ram_start]         ; Move the value at the address in 'ram_start' to ES (Extra Segment)
    mov es, bx
    mov bx, [ram_end]           ; Move the value at the address in 'ram_end' to BX
    
    mov ah, 03h                 ; Set AH register to 3 (disk write)
    mov al, [q]                   ; Set AL register to 1 (number of sectors to write)
    mov ch, [track]             ; Move the value at the address in 'track' to CH
    mov cl, [sector]            ; Move the value at the address in 'sector' to CL
    mov dl, 0                   ; Set DL register to 0 (floppy disk drive)
    mov dh, [head]              ; Move the value at the address in 'head' to DH
    int 13h                     ; Call BIOS interrupt 13h

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    mov si, error_message       ; Move the address of 'error_message' to SI
    call print_string_si

    ; print error code
    mov al, '0'                 ; Move the ASCII value of '0' to AL
    add al, ah                  ; Add the value in AH to AL
    mov ah, 0eh                 ; Set AH register to 0eh (teletype output)
    int 10h                     ; Call BIOS interrupt 10h

    mov byte [ram_flag], 0      ; Move 0 to the byte at the address in 'ram_flag'
    mov byte [var_flag], 0      ; Move 0 to the byte at the address in 'var_flag'
    mov byte [q_flag], 0        ; Move 0 to the byte at the address in 'q_flag'

    mov si, new_line            ; Move the address of 'new_line' to SI
    call print_string_si

    jmp clear_buffer

; Data section
help_desc: db "1 - keyboard to flp, 2 - floppy to ram, 3 - ram to floppy", 0x0d, 0xa, 0
variables_1: db "n, head, track, sector, string", 0x0d, 0xa, 0
variables_2: db "n, head, track, sector, start, end", 0x0d, 0xa, 0
variables_3: db "q, head, track, sector, start, end", 0x0d, 0xa, 0
q_prompt: db "q = ", 0
n_prompt: db "n = ", 0
head_prompt: db "head = ", 0
track_prompt: db "track = ", 0
sector_prompt: db "sector = ", 0
string_prompt: db "string = ", 0
ram_start_prompt: db "start addr = ", 0
ram_end_prompt: db "end addr = ", 0
num_of_sectors: db 0

goodbye: db 0x0d, 0xa, "Exiting...", 0x0d, 0xa, 0
help_command: db "help", 0
option_1: db "1", 0
option_2: db "2", 0
option_3: db "3", 0
success_ram: db "Successfully wrote to RAM", 0
fail_ram: db "Failed to write to RAM", 0
error_message: db "Error message: ", 0

new_line: db 0x0d, 0xa, 0

q: db 0
n: db 0
head: db 0
track: db 0
sector: db 0
ram_start: dw 0
ram_end: dw 0
var_flag: db 0
ram_flag: db 0
q_flag: db 0
result: db 0
ram_success: db 0

floppy_buffer: times 512 db 0
input: times 256 db 0
