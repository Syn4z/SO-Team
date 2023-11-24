copy_input_to_n_input:
    mov di, n_input
    mov si, input
    mov cx, 64
    rep movsb
    ret