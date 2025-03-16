.model small
.stack 100h
.data
    kytu1 DB "Hay nhap mot ky tu: $"
    kytu2 DB 13, 10, "Ky tu da nhap: $"
    output DB ? ; khởi tạo biến không giá trị đầu

.code
main proc
    MOV AX, @data ; @data biểu diễn địa chỉ bắt đầu của segment data
    MOV DS, AX

    LEA DX, kytu1
    MOV AH, 9
    INT 21H
    
    MOV AH, 1 
    INT 21H 
    MOV output, AL ;ký tự vừa nhập tự động lưu vào thanh ghi AL

    LEA DX, kytu2
    MOV AH, 9
    INT 21H

    MOV AH, 2
    MOV DL, output ;DL được dùng để in ký tự trong lệnh AH,2
    INT 21H 
    
    MOV AH, 4CH
    INT 21H
main endp
end