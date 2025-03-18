.model small
.stack 100h
.data 
    msg1 db "Nhap mot ky tu: $"
    msg2 db 13, 10, "Ky tu chuyen sang hoa la: $" 
    char db ?, '$'

.code
main proc
    mov ax, @data
    mov ds, ax  ; giup ds tro den data
                ; ds luu dia chi segment(doan du lieu) con dx chua dia chi ma 21h in ra
    
    lea dx, msg1
    mov ah, 9
    int 21h
    
    mov ah, 1
    int 21h 
    sub al, 20h  ; tru di 32, int 21h 1 luu o AL
    mov char, al 
    
    lea dx, msg2
    mov ah, 9
    int 21h
             
    lea dx, char         
    mov ah, 9
    int 21h
    
    mov ah, 4ch
    int 21h
    
main endp
end