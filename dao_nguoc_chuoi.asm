.model small
.stack 100 ;100h gây lỗi
.data
    str db 50 dup('$')
    msg1 db 10, 13, "Chuoi da duoc dao nguoc: $"
.code
main proc
    mov ax, @data
    mov ds, ax

    lea dx, str
    MOV AH, 10 ;0ah
    INT 21H

    lea dx, msg1
    mov ah, 9
    INT 21h

    ;vd 12345 : 256, 5, 1, 2, 3, 4, 5
    MOV CL, [str + 1] ;chuyển chiều dài chuỗi vừa nhập vào CL
    LEA SI, str + 2

    Lap:
        push [SI]
        INC SI
        LOOP Lap ; giảm CL đi 1 dừng nếu CL = 0
    
    MOV CL, [str + 1]; chuyển lại tiếp vì vừa lặp CL = 0
    Lap2:
        pop DX; lấy dữ liệu từ pop vào DX
        MOV AH, 2; in ký tự
        INT 21H
        LOOP Lap2

    MOV AH, 4CH 
    INT 21H
main endp
end