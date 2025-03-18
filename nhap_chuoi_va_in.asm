.model small
.stack 100h
.data
    msg1 db 10,13, "chuoi da nhap la: $"
    string db 100 dup('$') ; vi khong tự tạo $ nen dup 100 lần

.code
main proc
    mov ax, @data
    mov ds, ax ; vi @data la mot hang so, ds khong the luu truc tiep hang so, phai thong qua ax

    lea dx, string
    mov ah, 10 ; 10 = 0A(hệ 16)
    int 21h

    lea dx, msg1
    mov ah, 9
    int 21h

    lea dx, string + 2 ; lấy địa chỉ ký tự đầu tiên nhập vào vì str lưu: độ dài tối đa, độ dài đã nhập, các ký tự
    int 21h

    mov ah, 4CH
    int 21h
main endp
end
    