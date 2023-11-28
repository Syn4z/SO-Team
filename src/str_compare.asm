compare_strs_si_bx:
    push si                     ; Save the current value of SI on the stack
    push bx                     ; Save the current value of BX on the stack
    push ax                     ; Save the current value of AX on the stack

comp:
    mov ah, [bx]                ; Load a byte from the memory location pointed to by BX into AH
    cmp [si], ah                ; Compare the byte at the memory location pointed to by SI with AH
    jne not_equal               ; If not equal, jump to the not_equal label

    cmp byte [si], 0            ; Compare the byte at the memory location pointed to by SI with 0 (null terminator)
    je first_zero               ; If equal, jump to the first_zero label

    inc si                      ; Increment SI to point to the next character
    inc bx                      ; Increment BX to point to the next character

    jmp comp                    ; Jump back to the beginning of the loop to compare the next characters

first_zero:
    cmp byte [bx], 0            ; Compare the byte at the memory location pointed to by BX with 0 (null terminator)
    jne not_equal               ; If not equal, jump to the not_equal label

    mov cx, 1                   ; Set CX to 1 to indicate that the strings are equal

    pop si                      ; Restore the saved value of SI from the stack
    pop bx                      ; Restore the saved value of BX from the stack
    pop ax                      ; Restore the saved value of AX from the stack

    ret                         ; Return from the subroutine

not_equal:
    mov cx, 0                   ; Set CX to 0 to indicate that the strings are not equal

    pop si                      ; Restore the saved value of SI from the stack
    pop bx                      ; Restore the saved value of BX from the stack
    pop ax                      ; Restore the saved value of AX from the stack

    ret                         ; Return from the subroutine
