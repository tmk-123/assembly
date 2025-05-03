.MODEL SMALL 
.STACK 100H 
.DATA 

; Chuỗi thông báo sẽ được in ra
StartMessage DB 'Simple Calculator( + , - , * , / , % )',0AH, '$'
NewLine DB 10, 13, '$' ; xuống dòng

.CODE 
;****************************************************************MAIN
MAIN PROC
MOV AX,@DATA 
MOV DS,AX 

; nạp địa chỉ chuỗi, xuất chuỗi
LEA DX,StartMessage 
MOV AH,09H 
INT 21H 

; xuống dòng trước khi nhập
LEA DX, NewLine
MOV AH, 09h
INT 21h

CALL ReadBCD    ; đọc số thứ nhất vào BX, toán tử vào AL
PUSH BX         ; lưu số vừa đọc
PUSH AX         ; lưu toán tử trong AL

CALL ReadBCD    ; đọc số thứ hai vào BX
POP CX          ; lấy toán tử ra CX
POP AX          ; lấy số thứ nhất ra AX, số thứ hai đang ở BX

CALL Math       ; thực hiện phép toán, kết quả lưu ở AX
CALL PrintBin   ; in kết quả AX ra màn hình

; ngắt chương trình để thoát
MOV AH,4CH 
INT 21H 

MAIN ENDP 

;****************************************************************Các thủ tục (Functions)

; Thực hiện phép toán trên AX và BX
; Kết quả trả về trong AX (trong phép nhân thì AX, BX)
; CL chứa toán tử (+, -, *, /, %)
Math PROC 
    PUSH DX

    Operate:
        CMP CL,'+'        ; kiểm tra phép cộng
        JE Plus 
        CMP CL,'-'        ; kiểm tra phép trừ
        JE Mines 
        CMP CL,'*'        ; kiểm tra phép nhân
        JE Multi 
        CMP CL,'/'        ; kiểm tra phép chia
        JE Divid
        CMP CL,'%'        ; kiểm tra phép chia lấy dư
        JE Remain
        ; nếu không tìm thấy phép toán hợp lệ
        MOV AX,0000H ; reset AX, BX về 0
        MOV BX,0000H
        JMP ExitMath

    Plus:
        ADD AX,BX
        JMP ExitMath

    Mines:
        SUB AX,BX
        JMP ExitMath
    
    Multi:
        MUL BX           ; nhân AX * BX -> kết quả 32 bit (DX:AX)
        MOV BX,DX        ; lưu phần cao vào BX
        JMP ExitMath
    
    Divid:
        MOV DX,0000H 
        DIV BX           ; chia AX cho BX, kết quả lưu trong AX
        JMP ExitMath 
    
    Remain:
        MOV DX,0000H 
        DIV BX           ; chia AX cho BX
        MOV AX,DX        ; lấy phần dư
        JMP ExitMath 

    ExitMath:
        POP DX 
        RET ; return

Math ENDP

; Đọc một số hệ thập phân BCD từ bàn phím
; trả về số trong BX và ký tự cuối cùng trong AL
ReadBCD PROC 
    PUSH CX 
    PUSH DX 
    MOV DX,0000H    ; kết quả ban đầu
    MOV CX,0000H    ; bộ đếm
    MOV BX,0000H    ; giá trị tạm

    Read:
        ; đọc một phím từ bàn phím
        MOV AH,01H
        INT 21H 

        CMP AL,'0'
        JB ExitReadBCD     ; thoát nếu nhỏ hơn '0'
        CMP AL,'9'
        JA ExitReadBCD     ; thoát nếu lớn hơn '9'

        SUB AL,30H         ; chuyển từ ký tự sang hệ Hex, 30H là ký tự '0', nghĩa là AL = AL - '0'
        MOV CH,00H         ; clear CH = 0 để lưu giá trị mới của CL
        MOV CL,AL

        MOV DX,10D         ; DX = 10
        MOV AX,BX          ; chuyển kết quả cũ vào AX
        MUL DX             ; nhân 10 vào AX(kết quả lưu trong AX)

        ADD AX,CX          ; cộng thêm chữ số mới
        MOV BX,AX          ; lưu kết quả vào BX

        JMP Read 
    
    ExitReadBCD:
        POP DX 
        POP CX
        RET 

ReadBCD ENDP

; In giá trị nhị phân trong AX (dạng 5 chữ số thập phân)
; Lưu ý: Lưu giữ các thanh ghi CX, SI, DX, AX
PrintBin PROC
    PUSH AX 
    PUSH CX
    PUSH DX
    PUSH SI 

    MOV CX,5         ; 5 chữ số
    MOV SI,10D       ; chia cho 10

    DivTo10:
        MOV DX,0000H
        DIV SI        ; chia cho 10, phần dư trong DX, để tách từng chữ số
        PUSH DX       ; lưu phần dư vào stack
        LOOP DivTo10
    
    MOV CX,5         ; in 5 lần
    Print:
        POP DX        ; lấy từng chữ số ra
        ADD DX,30H    ; chuyển sang mã ASCII
        MOV AH,02H
        INT 21H       ; in ra màn hình
        LOOP Print    ; lặp đến hết

    ; khôi phục các thanh ghi
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PrintBin ENDP

END MAIN
