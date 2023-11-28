print_string_si:
    push ax                     ; Save the current value of AX on the stack

    mov ah, 0x0e                ; Set AH to 0x0e (function code for teletype output)
    call print_next_char        ; Call the subroutine to print the next character

    pop ax                      ; Restore the saved value of AX from the stack
    ret                          ; Return from the subroutine

print_next_char:
    mov al, [si]                ; Load the byte at the memory location pointed to by SI into AL
    cmp al, 0                   ; Compare AL with 0 (null terminator)

    jz if_zero                   ; If AL is 0, jump to the if_zero label

    int 0x10                    ; Invoke BIOS interrupt 0x10 to print the character in AL
    inc si                       ; Increment SI to point to the next character

    jmp print_next_char         ; Jump back to the beginning of the subroutine to process the next character

if_zero:
    ret                          ; Return from the subroutine when a null terminator is encountered
