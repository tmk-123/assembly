.MODEL SMALL
.STACK 100H

.DATA
; ----------------- Chuỗi thông báo -----------------
StartMessage     DB 'Mini Calculator( + , - , * , / , % )', 13, 10, '$'
InstructionMsg   DB 13, 10, 13, 10, 'Nhap bieu thuc, viet lien khong cach, co dau bang "=" ', 13, 10, '$'
ContinueMsg      DB 'Ban co muon tinh tiep (y/n)? ', 13, 10, '$'
NewLine          DB 10, 13, '$' ; Xuống dòng

.CODE

; ============================ CHƯƠNG TRÌNH CHÍNH ============================
MAIN PROC
    MOV AX, @DATA       ; Tải địa chỉ của đoạn dữ liệu vào AX
    MOV DS, AX          ; Gán AX vào DS để truy cập biến .DATA

    ; In lời chào đầu tiên
    LEA DX, StartMessage
    MOV AH, 09H
    INT 21H

StartCalc:
    ; In hướng dẫn nhập biểu thức
    LEA DX, InstructionMsg
    MOV AH, 09H
    INT 21H

    ; Nhập số thứ nhất và lưu vào BX, toán tử lưu vào AL
    CALL ReadBCD
    PUSH BX             ; Lưu số thứ nhất vào stack
    PUSH AX             ; Lưu toán tử trong AL vào stack

    ; Nhập số thứ hai, kết quả lưu vào BX
    CALL ReadBCD

    ; Lấy lại toán tử và số thứ nhất từ stack
    POP CX              ; CX sẽ chứa toán tử (ban đầu lưu trong AL)
    POP AX              ; AX = số thứ nhất, BX = số thứ hai

    ; Thực hiện phép toán và in kết quả
    CALL Math
    CALL PrintBin

    ; Xuống dòng
    LEA DX, NewLine
    MOV AH, 09H
    INT 21H

    ; Hỏi tiếp tục
    LEA DX, ContinueMsg
    MOV AH, 09H
    INT 21H

    ; Nhập phím từ bàn phím
    MOV AH, 01H
    INT 21H
    CMP AL, 'y'
    JE StartCalc
    CMP AL, 'Y'
    JE StartCalc

    ; Kết thúc chương trình
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; ============================ PHÉP TOÁN ============================
; Thực hiện phép toán giữa AX và BX, toán tử trong CL
Math PROC
    PUSH DX

Operate:
    CMP CL, '+'
    JE Plus
    CMP CL, '-'
    JE Mines
    CMP CL, '*'
    JE Multi
    CMP CL, '/'
    JE Divid
    CMP CL, '%'
    JE Remain

    ; Nếu không hợp lệ, trả về 0
    MOV AX, 0
    MOV BX, 0
    JMP ExitMath

Plus:
    ADD AX, BX
    JMP ExitMath

Mines:
    SUB AX, BX
    JMP ExitMath

Multi:
    MUL BX           ; AX * BX → DX:AX
    ; Kết quả chính là phần thấp trong AX
    JMP ExitMath

Divid:
    MOV DX, 0
    DIV BX           ; AX = AX / BX
    JMP ExitMath

Remain:
    MOV DX, 0
    DIV BX
    MOV AX, DX       ; AX = phần dư
    JMP ExitMath

ExitMath:
    POP DX
    RET
Math ENDP

; ============================ NHẬP SỐ ============================
; Đọc số nguyên từ bàn phím (số thập phân), lưu vào BX
; Nhập xong khi gặp ký tự không phải '0'..'9'
ReadBCD PROC
    PUSH CX
    PUSH DX
    MOV DX, 0         ; Bộ nhớ tạm
    MOV CX, 0
    MOV BX, 0         ; Kết quả cuối

Read:
    MOV AH, 01H
    INT 21H           ; Đọc ký tự từ bàn phím vào AL

    CMP AL, '0'
    JB ExitReadBCD
    CMP AL, '9'
    JA ExitReadBCD

    SUB AL, 30H       ; AL = AL - '0' → chuyển về giá trị số
    MOV CH, 0
    MOV CL, AL

    MOV DX, 10        ; Nhân 10 để tạo hệ thập phân
    MOV AX, BX
    MUL DX            ; AX = BX * 10
    ADD AX, CX        ; Cộng chữ số mới
    MOV BX, AX        ; Lưu lại kết quả vào BX

    JMP Read

ExitReadBCD:
    POP DX
    POP CX
    RET
ReadBCD ENDP

; ============================ IN SỐ ============================
; In giá trị thập phân trong AX, không in số 0 đầu
PrintBin PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, 5         ; Giới hạn 5 chữ số
    MOV SI, 10

    MOV BX, 0
DivTo10:
    XOR DX, DX
    DIV SI            ; AX / 10 → phần dư trong DX
    PUSH DX           ; Lưu chữ số
    INC BX
    CMP AX, 0
    JNE DivTo10       ; Lặp lại nếu còn phần nguyên

    MOV CX, BX
    MOV SI, 0         ; SI = 0 → chưa gặp số khác 0

Print:
    POP DX
    CMP SI, 0
    JNE PrintDigit
    CMP DX, 0
    JNE PrintDigit
    CMP CX, 1
    JE PrintDigit     ; Nếu là chữ số cuối, in luôn
    LOOP Print
    JMP DonePrint

PrintDigit:
    MOV SI, 1
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP Print

DonePrint:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PrintBin ENDP

END MAIN
