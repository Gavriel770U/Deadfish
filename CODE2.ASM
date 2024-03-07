IDEAL
MODEL SMALL
STACK 100h
DATASEG
CODESEG
main:
    mov ax, @data
    mov ds, ax
    xor ax, ax

exit:
    mov ax, 4c00h
    int 21h

END main