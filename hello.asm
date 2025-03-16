.model small
.stack 100H
.data
    CRLF DB 13, 10, '$' ;ky tu xuong dong
    ChaoTay DB 'ChaoTay$'
    ChaoTa DB 'chaota$'

.code
main proc
    MOV AX, @data ; nạp địa chỉ của .data vào ax
    MOV DS, AX ; trỏ thanh ghi về đầu đoạn data

    MOV AH, 9 ; lệnh gọi 09h từ ngắt 21(int 21h) in một xâu ký tự
                ; khi đó AH có giá trị là 9, in tiếp chuỗi thì không cần gọi lại

    LEA DX, ChaoTay ; nạp địa chỉ chaotay vào DX(địa chỉ chuỗi phải lưu trong DX)
    INT 21H
    
    LEA DX, CRLF
    INT 21H
    
    LEA DX, ChaoTa
    INT 21H

    MOV AH, 4CH ; trở về DOS
    INT 21H
main endp
end