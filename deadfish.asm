IDEAL
MODEL SMALL
STACK 100h

DATASEG

    ZERO equ 0
    MEMORY_SIZE equ 1000
    INITIAL_MEMORY_VALUE equ 0

    COMMANDS_SIZE equ 1000
    INITIAL_COMMAND_SIZE equ 0

    file_name db 'code.txt', 0
    file_handle dw ?
    error_message db 'Error', 10, 13, '$'

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

main:
    mov ax, @data
    mov ds, ax
    xor ax, ax

    push offset error_message
    push offset file_handle
    push offset file_name
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