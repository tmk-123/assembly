.MODEL SMALL
.STACK 100H

.DATA
; ----------------- Chuỗi thông báo -----------------
StartMessage     DB 'NHOM 8 KTMT', 13, 10, 'MINI CALCULATOR( + , - , * , / , % )', 13, 10, '$'
InstructionMsg   DB 13, 10, 13, 10, 'Nhap bieu thuc, viet lien khong cach, co dau bang "=" ', 13, 10, '$'
ContinueMsg      DB 'Ban co muon tinh tiep (y/n)? ', 13, 10, '$'
NewLine          DB 10, 13, '$' ; Xuống dòng

.CODE

; ============================ CHƯƠNG TRÌNH CHÍNH ============================
MAIN PROC
    MOV AX, @DATA       ; Tải địa chỉ của đoạn dữ liệu vào AX
    MOV DS, AX          ; Gán AX vào DS để truy cập .DATA

    ; In lời chào đầu tiên
    LEA DX, StartMessage
    MOV AH, 9
    INT 21H

    StartCalc:
        ; In hướng dẫn nhập biểu thức
        LEA DX, InstructionMsg
        MOV AH, 9
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
        MOV AH, 9
        INT 21H

        ; Hỏi tiếp tục
        LEA DX, ContinueMsg
        MOV AH, 9
        INT 21H

        ; Nhập phím từ bàn phím
        MOV AH, 1
        INT 21H
        CMP AL, 'y'
        JE StartCalc

        ; Kết thúc chương trình
        MOV AH, 4CH
        INT 21H
MAIN ENDP

; ============================ TÍNH TOÁN ============================
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
    MOV DX, 0         ; Khởi tạo bằng 0
    MOV CX, 0
    MOV BX, 0         ; Kết quả cuối

    Read:
        MOV AH, 1
        INT 21H           ; Đọc ký tự từ bàn phím vào AL

        CMP AL, '0'
        JL ExitReadBCD
        CMP AL, '9'
        JG ExitReadBCD

        SUB AL, '0'       ; AL = AL - '0' → chuyển về giá trị số, 48 là '0'
        MOV CH, 0
        MOV CL, AL

        MOV DX, 10        ; Nhân 10 để tạo hệ thập phân
        MOV AX, BX
        MUL DX            ; AX = BX * 10
        ADD AX, CX        ; Cộng chữ số mới
        MOV BX, AX        ; Lưu lại kết quả vào BX

        JMP Read

    ExitReadBCD:
        RET
ReadBCD ENDP

; ============================ IN SỐ ============================
; In giá trị thập phân trong AX, không in số 0 đầu
PrintBin PROC
    MOV SI, 10        ; Chia cho 10 để tách chữ số
    MOV BX, 0         ; BX dùng để đếm số chữ số thực tế đã tách ra

    DivTo10:
        XOR DX, DX          ; Đảm bảo DX = 0 trước khi chia (vì DIV = DX:AX / SI)
        DIV SI              ; AX / 10, thương lưu lại trong AX, dư trong DX (chính là 1 chữ số)
        PUSH DX             ; Đẩy chữ số (phần dư) vào stack để in ngược lại sau
        INC BX              ; Tăng đếm số chữ số
        CMP AX, 0
        JNE DivTo10         ; Nếu còn phần thương ≠ 0 → tiếp tục chia
        MOV CX, BX          ; CX lưu số chữ số
        MOV SI, 0           ; SI = 0 → chưa gặp số khác 0

    Print:
        POP DX              ; Lấy chữ số (dư) từ stack ra (từ trái sang phải)
        CMP SI, 0
        JNE PrintDigit      ; Nếu đã gặp số khác 0, thì in luôn
        CMP DX, 0
        JNE PrintDigit      ; Nếu chữ số ≠ 0 thì in (bắt đầu in từ đây)
        CMP CX, 1           
        JE PrintDigit       ; Nếu là chữ số cuối cùng, phải in (để in số 0)
        LOOP Print          ; Nếu chưa đến cuối và DX = 0 → bỏ qua
        JMP DonePrint       ; Khi in xong tất cả thì kết thúc

    PrintDigit:
        MOV SI, 1           ; Đánh dấu đã gặp số khác 0
        ADD DL, '0'         ; Chuyển số sang mã ASCII (VD: 3 → '3')
        MOV AH, 02H
        INT 21H             ; Gọi ngắt 21H để in ký tự trong DL
        LOOP Print          ; Tiếp tục in đến hết

    DonePrint:
        RET
PrintBin ENDP

END MAIN
