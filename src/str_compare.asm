compare_strs_si_bx:
    push si                    
    push bx
    push ax

comp:
    mov ah, [bx]               
    cmp [si], ah               
    jne not_equal              

    cmp byte [si], 0           
    je first_zero              

    inc si                     
    inc bx

    jmp comp                   

first_zero:
    cmp byte [bx], 0           
    jne not_equal              

    mov cx, 1                  

    pop si                     
    pop bx
    pop ax

    ret                        

not_equal:
    mov cx, 0                  

    pop si                     
    pop bx
    pop ax

    ret                        