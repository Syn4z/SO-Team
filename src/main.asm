org 1000h
bits 16

jmp start                     ; сразу переходим в start

%include "print_string.asm"
%include "str_compare.asm"

; ====================================================

start:
    cli                                ; запрещаем прерывания, чтобы наш код 
                                       ; ничто лишнее не останавливало
    mov ah, 0x00              ; очистка экрана
    mov al, 0x03
    int 0x10

    mov sp, 0x7c00            ; инициализация стека

mainloop:
    ; mov si, new_line
    ; call print_string_si
    ; mov si, help_desc         ; печатаем текст help
    ; call print_string_si
    call get_input            ; вызываем функцию ожидания ввода
    jmp mainloop              ; повторяем mainloop...

get_input:
    mov bx, 0                 ; инициализируем bx как индекс для хранения ввода

input_processing:
    mov ah, 0x0               ; параметр для вызова 0x16
    int 0x16                  ; получаем ASCII код

    cmp al, 0x0d              ; если нажали enter
    je check_the_input        ; то вызываем функцию, в которой проверяем, какое
                              ; слово было введено

    cmp al, 0x8               ; если нажали backspace
    je backspace_pressed

    cmp al, 0x3               ; если нажали ctrl+c
    je stop_cpu

    mov ah, 0x0e              ; во всех противных случаях - просто печатаем
                              ; очередной символ из ввода
    int 0x10

    mov [input+bx], al        ; и сохраняем его в буффер ввода
    inc bx                    ; увеличиваем индекс

    cmp bx, 256               ; если input переполнен
    je check_the_input        ; то ведем себя так, будто был нажат enter

    jmp input_processing      ; и идем заново

stop_cpu:
    mov si, goodbye           ; печатаем прощание
    call print_string_si

    jmp $                     ; и останавливаем компьютер
                              ; $ означает адрес текущей инструкции

backspace_pressed:
    cmp bx, 0                 ; если backspace нажат, но input пуст, то
    je input_processing       ; ничего не делаем

    mov ah, 0x0e              ; печатаем backspace. это значит, что каретка
    int 0x10                  ; просто передвинется назад, но сам символ не сотрется

    mov al, ' '               ; поэтому печатаем пробел на том месте, куда
    int 0x10                  ; встала каретка

    mov al, 0x8               ; пробел передвинет каретку в изначальное положение
    int 0x10                  ; поэтому еще раз печатаем backspace

    dec bx
    mov byte [input+bx], 0    ; и убираем из input последний символ

    jmp input_processing      ; и возвращаемся обратно

check_the_input:
    inc bx
    mov byte [input+bx], 0    ; в конце ввода ставим ноль, означающий конец
                              ; стркоки (тот же '\0' в Си)

    mov si, new_line          ; печатаем символ новой строки
    call print_string_si

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

    mov si, help_command      ; в si загружаем заранее подготовленное слово help
    mov bx, input             ; а в bx - сам ввод
    call compare_strs_si_bx   ; сравниваем si и bx (введено ли help)
    cmp cx, 1                 ; compare_strs_si_bx загружает в cx 1, если ; строки равны друг другу
    je equal_help             ; равны => вызываем функцию отображения
                              ; текста help
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
    mov si, input
    call print_string_si

    call convert_input_int
    mov al, [result]
    mov [n], al

    mov si, new_line
    call print_string_si
    mov si, head_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

head_processing:
    mov si, input
    call print_string_si

    call convert_input_int
    mov al, [result]
    mov [head], al

    mov si, new_line
    call print_string_si

    mov si, track_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done


track_processing:
    mov si, input
    call print_string_si

    call convert_input_int
    mov al, [result]
    mov [track], al

    mov si, new_line
    call print_string_si
    mov si, sector_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done


sector_processing:
    mov si, input
    call print_string_si

    call convert_input_int
    mov al, [result]
    mov [sector], al

    mov si, new_line
    call print_string_si

    cmp byte [ram_flag], 1
    je read_floppy

    mov si, string_prompt
    call print_string_si

    inc byte [var_flag]
    jmp done

ram_processing:
    jmp read_floppy

string_processing:
    mov si, input
    call print_string_si
    mov si, new_line
    call print_string_si

    jmp fill_write_buffer

equal_option_2:
    mov si, variables_2
    call print_string_si
    mov si, n_prompt
    call print_string_si

    inc byte [ram_flag]
    inc byte [var_flag]

    jmp done

equal_random_string:
    mov si, new_line          ; печатаем символ новой строки
    call print_string_si

    mov si, input
    call print_string_si

    mov si, new_line          ; печатаем символ новой строки
    call print_string_si

    jmp done

; done очищает всю переменную input
done:
    cmp bx, 0                 ; если зашли дальше начала input в памяти
    je exit                   ; то вызываем функцию, идующую обратно в mainloop

    dec bx                    ; если нет, то инициализируем очередной байт нулем
    mov byte [input+bx], 0

    jmp done                  ; и делаем то же самое заново

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

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

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

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

;    cmp ah, 0
;    je print_ram

    mov si, new_line
    call print_string_si

    mov byte [ram_flag], 0
    mov byte [var_flag], 0

    jmp clear_buffer

print_ram:
    mov si, success_ram
    call print_string_si
    mov bx, [ram_start]
    mov es, bx
    mov bp, [ram_end]

    jmp done


; 0x0d - символ возварата картки, 0xa - символ новой строки
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
success_ram: db "Successfully written to RAM", 0

new_line: db 0x0d, 0xa, 0

q: db 0
n: db 0
head: db 0
track: db 0
sector: db 0
ram_start: dw 0x6c80
ram_end: dw 0x6b0
var_flag: db 0
ram_flag: db 0
result: db 0

floppy_buffer: times 512 db 0
input: times 256 db 0
