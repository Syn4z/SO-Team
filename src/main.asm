org 1000h
bits 16

jmp start                    

%include "print_string.asm"
%include "str_compare.asm"

start:
    mov ah, 0x00              
    mov al, 0x03
    int 0x10

    mov sp, 1000h 

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

    mov si, help_desc
    call print_string_si

mainloop:
    call get_input            
    jmp mainloop              

get_input:
    mov bx, 0                 

input_processing:
    mov ah, 0x0               
    int 0x16                  

    cmp al, 0x3           
    je start

    cmp al, 0x0d                
    je check_the_input          
                                

    cmp al, 0x8               
    je backspace_pressed

    mov ah, 0x0e             
                              
    int 0x10

    mov [input+bx], al        
    inc bx                    

    cmp bx, 255               
    je check_the_input       

    jmp input_processing     

stop_cpu:
    mov si, goodbye          
    call print_string_si

    jmp $                     
                              

backspace_pressed:
    cmp bx, 0                 
    je input_processing       

    mov ah, 0x0e              
    int 0x10                 

    mov al, ' '                
    int 0x10                   

    mov al, 0x8                
    int 0x10                   

    dec bx
    mov byte [input+bx], 0     

    jmp input_processing       

check_the_input:
    inc bx
    mov byte [input+bx], 0     
                               

    mov si, new_line           
    call print_string_si

    ; Q processing
    cmp byte [q_flag], 1
    je q_processing

    ; RAM processing
    cmp byte [ram_flag], 2
    je segment_processing

    cmp byte [ram_flag], 3
    je address_processing

    ; Option 1 processing
    cmp byte [var_flag], 1
    je n_processing

    cmp byte [var_flag], 2
    je head_processing

    cmp byte [var_flag], 3
    je track_processing

    cmp byte [var_flag], 4
    je sector_processing

    cmp byte [var_flag], 5
    je string_processing

    mov si, help_command       
    mov bx, input              
    call compare_strs_si_bx    
    cmp cx, 1                  
    je equal_help              
                               
    ; Option 1
    mov si, option_1
    mov bx, input
    call compare_strs_si_bx
    cmp cx, 1
    je equal_option_1

    ; Option 2
    mov si, option_2
    mov bx, input
    call compare_strs_si_bx
    cmp cx, 1
    je equal_option_2

    mov si, option_3
    mov bx, input
    call compare_strs_si_bx
    cmp cx, 1
    je equal_option_3

    cmp cx, 0
    je equal_random_string

equal_help:
    mov si, help_desc
    call print_string_si

    jmp done

equal_option_1:
    mov si, variables_1
    call print_string_si
    mov si, n_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

n_processing:
    call convert_input_int
    mov al, [result]
    mov [n], al

    mov si, head_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

head_processing:
    call convert_input_int
    mov al, [result]
    mov [head], al

    mov si, track_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

track_processing:
    call convert_input_int
    mov al, [result]
    mov [track], al

    mov si, sector_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

sector_processing:
    call convert_input_int
    mov al, [result]
    mov [sector], al

    cmp byte [ram_flag], 1
    je ram_processing

    mov si, string_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

ram_processing:
    mov si, ram_start_prompt
    call print_string_si

    inc byte [ram_flag]
    jmp done

segment_processing:
    mov si, ram_start
    call read_address_process_input

    mov si, ram_end_prompt
    call print_string_si

    inc byte [ram_flag]
    jmp done

address_processing:
    mov si, ram_end
    call read_address_process_input

    mov si, new_line
    call print_string_si

    cmp byte [q_flag], 2
    je ram_to_floppy

    jmp read_floppy

read_address_process_input:
   mov di, input

address_processing_input:
   cmp di, input + 4
   je address_processing_input_done

   mov al, [di + 2]
   shl al, 4
   or al, [di + 3]
   mov ah, [di]
   shl ah, 4
   or ah, [di + 1]
   mov word [si], ax
   add di, 4
   add si, 2
   inc bl

   jmp address_processing_input

address_processing_input_done:
    ret

string_processing:
    jmp fill_write_buffer

equal_option_2:
    mov si, variables_2
    call print_string_si
    mov si, n_prompt
    call print_string_si

    inc byte [ram_flag]
    inc byte [var_flag]

    jmp done

equal_option_3:
    mov si, variables_3
    call print_string_si
    mov si, q_prompt
    call print_string_si

    inc byte [q_flag]

    jmp done

q_processing:
    call convert_input_int
    mov al, [result]
    mov [q], al

    mov si, head_prompt
    call print_string_si

    inc byte [var_flag]
    inc byte [var_flag]
    inc byte [ram_flag]
    inc byte [q_flag]

    jmp done

equal_random_string:
    mov si, new_line           
    call print_string_si

    mov si, input
    call print_string_si

    mov si, new_line           
    call print_string_si

    jmp done

 
done:
    cmp bx, 0                  
    je exit                    

    dec bx                     
    mov byte [input+bx], 0

    jmp done                   

exit:
    ret

convert_input_int:
    mov si, input     ; Point SI to your input
    mov byte [result], 0
    xor ax, ax        ; Clear AX
    xor cx, cx        ; Clear CX

    next_digit:
        lodsb           ; Load byte at address SI into AL, increment SI
        cmp al, 0       ; Check for end of string
        je stop         ; If end of string, jump to done
        sub al, '0'     ; Convert from ASCII to number
        movzx ax, al    ; Zero-extend AL into AX
        imul cx, 10 ; Multiply CX by 10
        add cx, ax
        add [result], cx      ; Add AX to CX
        jmp next_digit  ; Repeat for next digit

    stop:
        ret

fill_write_buffer:
    mov si, input
    mov di, floppy_buffer
    xor ax, ax
    xor bx, bx

    loop_buffer:
        cmp ax, 512
        je write_to_floppy
        cmp byte [n], 0
        je write_to_floppy

        mov bl, byte [si]
        mov byte [di], bl

        inc ax
        inc si
        inc di

        cmp byte [si], 0
        jne loop_buffer
        mov si, input
        dec byte [n]

        jmp loop_buffer

clear_buffer:
    cmp byte [di], 0
    je done

    mov byte [di], 0
    inc di
    cmp di, floppy_buffer + 512		; Exit loop if at the end of buffer
    je done

    jmp clear_buffer

write_to_floppy:
    ; set the address of the first sector to write
    mov ah, 03h
    mov al, 1
    mov ch, [track]
    mov cl, [sector]
    mov dl, 0
    mov dh, [head]
    mov bx, floppy_buffer
    int 13h

    mov si, error_message
    call print_string_si

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    mov si, new_line
    call print_string_si

    mov si, new_line
    call print_string_si

    mov byte [var_flag], 0

    jmp clear_buffer

read_floppy:
    mov ah, 02h
    mov al, [n]
    mov ch, [track]
    mov cl, [sector]
    mov dl, 0
    mov dh, [head]
    mov bx, [ram_start]
    mov es, bx
    mov bx, [ram_end]
    int 13h

    mov si, new_line
    call print_string_si

    mov si, error_message
    call print_string_si

    ; print error code
    mov al, '0'
    add al, ah
    mov [ram_success], al
    mov ah, 0eh
    int 10h

    mov byte [ram_flag], 0
    mov byte [var_flag], 0

    cmp byte [ram_success], 0
    jne print_ram

    cmp byte [ram_success], 0
    je print_fail_statement

print_ram:
    call clear_screen

    mov si, success_ram
    call print_string_si

    call print_ram_volume

    mov si, new_line
    call print_string_si

    jmp done

print_fail_statement:
    call clear_screen
    mov si, fail_ram
    call print_string_si

    jmp done

clear_screen:
    mov ax, 0x0003  ; Video mode number (0x03 for text mode 80x25)
    int 0x10        ; BIOS interrupt 0x10
    ret ; return to the caller

print_ram_volume:
    mov ax, 0x1301
    mov bx, [ram_start]
    mov es, bx
    mov bx, 0x0007
    mov cx, 512
    mov bp, [ram_end]
    int 0x10

    ret

ram_to_floppy:
	xor dx, dx
	mov ax, [q]
	mov cx, 512
	div cx								; DX = count % 512, AX = count / 512

	cmp dx, 0
	jne ram_copy_interrupt				; Don't copy the last sector too if there's nothing to copy from it
	dec ax

ram_copy_interrupt:
	mov ah, 03h
    mov al, 1
    mov ch, [track]
    mov cl, [sector]
    mov dl, 0
    mov dh, [head]
	mov es, [ram_start]
	mov bx, [ram_end]
	int 13h

	mov si, new_line
    call print_string_si

    mov si, error_message
    call print_string_si

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    mov byte [ram_flag], 0
    mov byte [var_flag], 0
    mov byte [q_flag], 0

    mov si, new_line
    call print_string_si

    jmp clear_buffer


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
