.model small
.stack 100h
.data
    str db 256 dup('$')
    msg1 db 10, 13, 'Chuyen sang chuoi in thuong: $'
    msg2 db 10, 13, 'Chuyen sang chuoi in hoa: $'
.code
main proc
    MOV AX, @data
    MOV DS, AX

    LEA DX, str
    MOV AH, 10
    INT 21H

    MOV AH, 9
    LEA DX, msg1; in chuỗi thì lưu trong DX
    INT 21H
    CALL inthuong

    MOV AH, 9
    LEA DX, msg2
    INT 21H
    CALL inhoa

    MOV AH, 4CH
    INT 21H
MAIN endp

inthuong proc
    LEA SI, str + 2 ;source index : lưu chỉ mục, trỏ đến vị trí đầu tiên của chuỗi
    Lap1:
        MOV DL, [SI] ;lấy kí tự hiện tại từ bộ nhớ, dùng [] để lấy giá trị từ con trỏ
        CMP DL, 'A'
        JL In1 ;jump if less
        CMP DL, 'Z'
        JG In1 ;jump if greater
        ADD DL, 32; nếu thuộc A->Z cộng 32
    
    In1:
        MOV AH, 2 ;in ký tự
        INT 21H
        INC SI ;increment SI
        CMP [SI], '$'
        JNE Lap1 ;jump if not equal
    RET
inthuong endp

inhoa proc
    LEA SI, str + 2
    Lap2:
        MOV DL, [SI]
        CMP DL, 'a'
        JL In2
        CMP DL, 'z'
        JG In2
        SUB DL, 32
    In2:
        MOV AH, 2
        INT 21H
        INC SI
        CMP [SI], '$'
        JNE Lap2
    RET ; return
inhoa endp
end
