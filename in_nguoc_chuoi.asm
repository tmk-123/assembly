.model small
.stack 100h
.data
    str db 50 dup('$')
.code
main proc
    mov ax, @data
    mov ds, ax
    mov cx, 0

    start:
        inc cx
        mov ah, 1
        int 21h
        cmp al, "#"
        je print ;jump if equal
        push ax ; push được 16bit, không phải AL
        jmp start
    
    print:
        mov ah, 2
        mov dl, ' ' ; dùng dl để in ký tự
        int 21H

        dec cx
        pop dx
        int 21h

        cmp cx, 1
        jne print

        mov ah, 4CH
        int 21h

main endp