IDEAL
MODEL SMALL
STACK 100h

DATASEG
    EOF equ 0
    ZERO equ 0
    MEMORY_SIZE equ 1000
    INITIAL_MEMORY_VALUE equ 0

    COMMANDS_SIZE equ 1000
    INITIAL_COMMAND_SIZE equ 0

    FILE_PATH_SIZE equ 255

    file_handle dw ?
    error_message db 'Error', 10, 13, '$'

    file_path_input_message db 'Enter file path: ', 10, 13, '$'
    code_file_path db   FILE_PATH_SIZE ; number of characters + 1
                   db   ? ; number of characters entered by the user
                   db   FILE_PATH_SIZE dup (ZERO) ; characters eneterd by the user

    commands_length dw 0

    memory db MEMORY_SIZE dup(INITIAL_MEMORY_VALUE)

    commands db COMMANDS_SIZE dup(INITIAL_COMMAND_SIZE)

CODESEG

;----------------------------------------------------------------
proc open_file
    ; [bp+4] offset file_name
    ; [bp+6] offset file_handle
    ; [bp+8] offset error_message

    push bp
    mov bp, sp
    push ax
    push bx
    push dx

    xor ax, ax
    xor bx, bx
    xor dx, dx

    mov ah, 3Dh
    xor al, al ; set read-only mode
    mov dx, [bp+4]
    int 21h
    jc open_error
    mov bx, [bp+6]
    mov [bx], ax

    pop dx
    pop bx
    pop ax
    pop bp
    ret 6

open_error:
    mov dx, [bp+8]
    mov ah, 9h
    int 21h

    pop dx
    pop bx
    pop ax
    pop bp
    ret 6
endp open_file
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
proc interpret
    ; [bp+4] offset commands
    ; [bp+6] commands_length [value]

    ; si will be command pointer

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di

    mov si, [bp+4]
    mov cx, [bp+6]

    interpreter_loop:
        ; TODO
    loop interpreter_loop

    end_interpretation:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
endp interpret
;----------------------------------------------------------------
main:
    mov ax, @data
    mov ds, ax
    xor ax, ax

    mov dx, offset file_path_input_message
    mov ah, 09h
    int 21h

; get file path of the code file
    mov dx, offset code_file_path
    mov ah, 0Ah
    int 21h

; replace the last character with a EOF (0)
    mov si, offset code_file_path + 1
    mov cl, [byte ptr si]
    xor ch, ch
    inc cx
    add si, cx
    mov al, EOF
    mov [byte ptr si], al

    mov dl, 10
    mov ah, 02h
    int 21h

    mov dl, 13
    mov ah, 02h
    int 21h


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
    xor al, al
    mov dx, offset commands
    mov ah, 9h
    int 21h

    jmp exit

exit:
    mov ax, 4c00h
    int 21h

END main