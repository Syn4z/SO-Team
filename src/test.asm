section .data
    counter db 0

section .text
    global _start

_start:
    ; Check the value of the counter
    cmp byte [counter], 0
    je print_h       ; Jump to print_h if counter is 0

    cmp byte [counter], 1
    je print_e       ; Jump to print_e if counter is 1

    cmp byte [counter], 2
    je print_l       ; Jump to print_l if counter is 2

    cmp byte [counter], 3
    je print_l       ; Jump to print_l if counter is 3

    cmp byte [counter], 4
    je print_o       ; Jump to print_o if counter is 4

    cmp byte [counter], 5
    je exit

    ; inc byte [counter]
    ; jmp _start

print_h:
    mov al, 'h'    
    mov ah, 0x0e  
    int 10h
    inc byte [counter]
    jmp _start 

print_e:
    mov al, 'e'    
    mov ah, 0x0e  
    int 10h
    inc byte [counter]
    jmp _start 

print_l:
    mov al, 'l'    
    mov ah, 0x0e  
    int 10h
    inc byte [counter]
    jmp _start 

print_o:
    mov al, 'o'    
    mov ah, 0x0e  
    int 10h
    inc byte [counter]
    jmp _start 

exit:
    mov ah, 0x4c
    int 0x21
