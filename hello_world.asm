.model small
.stack 100h
.data 
    msg db 'Hello, World!$' ;db la define byte , msg la ten bien "message"   

.code
main proc
    mov ax, @data ;nap dia chi data vao thanh ghi ax
    mov ds, ax ;dua dia chi du lieu vao ds(data segment)
    
    mov dx, offset msg ;lay dia chi msg vao dx
    mov ah, 09h ;chuc nang in chuoi cua INT 21H
    int 21h ;goi dos de hien thi chuoi
    
    mov ax, 4ch ;ket thuc chuong trinh
    int 21h
                   
main endp
end main