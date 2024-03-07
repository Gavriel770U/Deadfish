IDEAL
MODEL SMALL

MACRO print_endline
    push ax
    push bx
    push cx
    push dx

    mov dl, 10
    mov ah, 02h
    int 21h

    mov dl, 13
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
ENDM

STACK 100h

DATASEG
    EOF equ 0
    ZERO equ 0

    READONLY_FILE equ 0

    FILE_READ_MODE equ 0
    FILE_WRITE_MODE equ 1
    FILE_READ_WRITE_MODE equ 2

    COMMANDS_SIZE equ 1000
    INITIAL_COMMAND_SIZE equ ZERO

    FILE_PATH_SIZE equ 255

    INITIAL_ASM_CODE    db  "IDEAL", 10             ; 6  characters
                        db  "MODEL SMALL", 10       ; 12 characters
                        db  "STACK 100h", 10, 13    ; 12 characters
                        db  "DATASEG", 10           ; 8  characters
                        db  "CODESEG", 10           ; 8  characters
                        db  "main:", 10             ; 6  characters
                        db  "    mov ax, @data", 10 ; 18 characters
                        db  "    mov ds, ax",    10 ; 15 characters
                        db  "    xor ax, ax",    10 ; 15 characters

    INITIAL_ASM_CODE_SIZE dw 6+12+12+8+8+6+18+15+15

    FINAL_ASM_CODE      db 10, 13, "exit:", 10      ; 8  characters
                        db "    mov ax, 4c00h", 10  ; 18 characters
                        db "    int 21h", 10        ; 12 characters
                        db 10, "END main"           ; 9 characters

    FINAL_ASM_CODE_SIZE dw 8+18+12+9


    file_handle dw ?
    compiled_file_handle dw ?
    error_message db 'Error', 10, 13, '$'

    file_path_input_message db 'Enter file path: ', 10, 13, '$'
    code_file_path db   FILE_PATH_SIZE ; number of characters + 1
                   db   ? ; number of characters entered by the user
                   db   FILE_PATH_SIZE dup (ZERO) ; characters entered by the user

    compiled_path_input_message db 'Enter path for the compiled file: ', 10, 13, '$'
    compiled_file_path db   FILE_PATH_SIZE ; number of characters + 1
                       db   ? ; number of characters entered by the user
                       db   FILE_PATH_SIZE dup (ZERO) ; characters entered by the user                 


    action_input_message db "[I]nterpret | [C]ompile -> ", '$'
    compilation_optimization_option db "Insert optimization level [1] | [2] -> ", '$'

    commands_length dw ZERO

    commands db COMMANDS_SIZE dup (INITIAL_COMMAND_SIZE)

CODESEG

;----------------------------------------------------------------
proc open_file
    ; [bp+4] offset file_name
    ; [bp+6] offset file_handle
    ; [bp+8] offset error_message
    ; [bp+10] mode [value]

    push bp
    mov bp, sp
    push ax
    push bx
    push dx

    xor ax, ax
    xor bx, bx
    xor dx, dx

    mov ah, 3Dh
    mov al, [byte ptr bp+10]
    mov dx, [bp+4]
    int 21h
    jc open_error
    mov bx, [bp+6]
    mov [bx], ax

    pop dx
    pop bx
    pop ax
    pop bp
    ret 8

open_error:
    mov dx, [bp+8]
    mov ah, 9h
    int 21h

    pop dx
    pop bx
    pop ax
    pop bp
    ret 8
endp open_file
;----------------------------------------------------------------

;----------------------------------------------------------------
proc create_file
    ; [bp+4] offset file_name
    ; [bp+6] offset file_handle
    ; [bp+8] offset error_message
    ; [bp+10] file attributes [value]

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    xor al, al
    mov ah, 3Ch
    mov dx, [bp+4]
    mov bx, [bp+6]
    mov cx, [bp+10]
    int 21h
    jc create_file_error
    mov bx, [bp+6]
    mov [bx], ax

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

create_file_error:
    mov dx, [bp+8]
    mov ah, 09h
    int 21h
    
    pop dx
    pop bx
    pop cx
    pop ax
    pop bp
    ret 8
endp create_file
;----------------------------------------------------------------

;----------------------------------------------------------------
proc close_file
    ; [bp+4] offset file_handle

    push bp
    mov bp, sp
    push ax
    push bx

    xor ax, ax
    xor bx, bx

    mov ah, 3Eh
    mov bx, [bp+4]
    mov bx, [bx]
    int 21h

    pop bx
    pop ax
    pop bp
    ret 2
endp close_file
;----------------------------------------------------------------

;----------------------------------------------------------------
proc read_file
    ; [bp+4] offset file_handle
    ; [bp+6] offset commands
    ; [bp+8] offset commands_length

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    mov ah, 3Fh
    mov bx, [bp+4]
    mov bx, [bx]
    mov cx, COMMANDS_SIZE
    mov dx, [bp+6]
    int 21h

    ; ax stores the length of 
    ; the commands buffer
    mov bx, [bp+8]
    mov [bx], ax

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp read_file
;----------------------------------------------------------------

;----------------------------------------------------------------
proc write_file
    ; [bp+4] offset file_handle
    ; [bp+6] offset buffer
    ; [bp+8] buffer length [value]

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    xor al, al
    mov ah, 40h
    mov bx, [bp+4]
    mov bx, [bx]
    mov cx, [bp+8]
    mov dx, [bp+6]
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp write_file
;----------------------------------------------------------------

;----------------------------------------------------------------
proc print_number
    ; [bp+4] number to print [value]

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov ax, [bp+4]
    mov bx, 10
    xor cx, cx

    print_number_push_loop:
        xor dx, dx
        div bx
        push dx
        inc cl
        cmp ax, ZERO
        jne print_number_push_loop
    print_number_pop_loop:
        pop dx
        add dl, 30h
        mov ah, 02h
        int 21h
        dec cl    
        cmp cl, ZERO
        jne print_number_pop_loop

    print_endline

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
endp print_number
;----------------------------------------------------------------


;----------------------------------------------------------------
proc interpret
    ; [bp+4] offset commands
    ; [bp+6] commands_length [value]

    ; si serves as command pointer
    ; ax serves as the accumulator

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si

    mov si, [bp+4]
    mov cx, [bp+6]

    interpreter_loop:
        xor dx, dx
        mov dl, [byte ptr si]
        cmp dl, 'i'
        je inc_command
        cmp dl, 'd'
        je dec_command
        cmp dl, 's'
        je square_command
        cmp dl, 'o'
        je output_numeric_command
        jmp finish_interpreter_iteration

        inc_command:
            inc ax
            jmp finish_interpreter_iteration
        dec_command:
            dec ax
            jmp finish_interpreter_iteration
        square_command:
            mov bx, ax
            xor dx, dx
            mul bx
            xor dx, dx
            jmp finish_interpreter_iteration
        output_numeric_command:
            push ax
            call print_number
        finish_interpreter_iteration:
            inc si
    loop interpreter_loop

    end_interpretation:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
endp interpret
;----------------------------------------------------------------


;----------------------------------------------------------------
proc compile_o1
    push bp 
    mov bp, sp

    pop bp
    ret
endp compile_o1
;----------------------------------------------------------------

main:
    mov ax, @data
    mov ds, ax
    xor ax, ax

    mov dx, offset action_input_message
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    print_endline

    cmp al, 'I'
    jne skip_call_interpret
    call far cs:main_call_interpret
skip_call_interpret:
    cmp al, 'C'
    jne skip_call_compile
    call far cs:main_call_compile
skip_call_compile:
    call far cs:exit

main_call_interpret:
    mov dx, offset file_path_input_message
    mov ah, 09h
    int 21h

; get file path of the code file
    mov dx, offset code_file_path
    mov ah, 0Ah
    int 21h

; replace the last character with an EOF (0)
    mov si, offset code_file_path + 1
    mov cl, [byte ptr si]
    xor ch, ch
    inc cx
    add si, cx
    mov al, EOF
    mov [byte ptr si], al

    print_endline

    push FILE_READ_MODE
    push offset error_message
    push offset file_handle
    push offset code_file_path + 2
    call open_file

    push offset commands_length
    push offset commands
    push offset file_handle
    call read_file
        
    push offset file_handle
    call close_file

    ; set endline character at 
    ; the end of the commands buffer 
    mov bx, [commands_length]
    mov si, offset commands
    mov al, '$'
    mov [byte ptr si+bx], al

    ; print code file contents
    ;xor al, al
    ;mov dx, offset commands
    ;mov ah, 9h
    ;int 21h

    push [word ptr commands_length]
    push offset commands
    call interpret
    jmp exit

main_call_compile:
    mov dx, offset compilation_optimization_option
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    print_endline

    mov dx, offset compiled_path_input_message
    mov ah, 09h
    int 21h

; get file path of the code file
    xor al, al
    mov dx, offset compiled_file_path
    mov ah, 0Ah
    int 21h

; replace the last character with an EOF (0)
    mov si, offset compiled_file_path + 1
    mov cl, [byte ptr si]
    xor ch, ch
    inc cx
    add si, cx
    mov al, EOF
    mov [byte ptr si], al

    print_endline

    push READONLY_FILE
    push offset error_message
    push offset compiled_file_handle
    push offset compiled_file_path + 2
    call create_file

    push offset compiled_file_handle
    call close_file

    push FILE_READ_WRITE_MODE
    push offset error_message
    push offset compiled_file_handle
    push offset compiled_file_path + 2
    call open_file

    push [INITIAL_ASM_CODE_SIZE]
    push offset INITIAL_ASM_CODE
    push offset compiled_file_handle
    call write_file

    push [FINAL_ASM_CODE_SIZE]
    push offset FINAL_ASM_CODE
    push offset compiled_file_handle
    call write_file

    push offset compiled_file_handle
    call close_file

    call compile_o1

    print_endline

    jmp exit

exit:
    mov ax, 4c00h
    int 21h

END main