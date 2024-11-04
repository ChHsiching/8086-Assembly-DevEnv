DATA SEGMENT
    msgInput db '请输入成绩 (0-100)：', 0
    msgSorted db '排序后的成绩为：', 0
    scores db 10 dup(0)      ; 存储最多10个成绩
    numScores db 0           ; 当前成绩数量
    newline db 10, 0         ; 换行符
DATA ENDS

STACK SEGMENT STACK
    db 128 dup(0)            ; 定义128字节的堆栈空间
STACK ENDS

BSS SEGMENT
    buffer db 4 dup(?)       ; 用于存储用户输入的成绩
BSS ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

_start:
    ; 初始化数据段
    mov ax, DATA
    mov ds, ax

    ; 输入成绩
    mov cx, 10               ; 循环计数器
input_loop:
    ; 打印提示信息
    lea dx, msgInput
    call print_string

    ; 读取输入并转换为数字
    call read_input
    call string_to_number

    ; 存储成绩
    mov [scores + numScores], al
    inc numScores
    loop input_loop

    ; 排序成绩
    call bubble_sort

    ; 打印排序后的成绩
    lea dx, msgSorted
    call print_string

    ; 输出排序后的成绩
    mov cx, numScores
print_loop:
    mov al, [scores + cx - 1]
    call print_number
    ; 换行
    lea dx, newline
    call print_string
    loop print_loop

    ; 结束程序
    mov ax, 4C00h
    int 21h

; 从标准输入读取字符串
read_input:
    mov ah, 0Ah              ; DOS中断读入
    lea dx, buffer
    int 21h
    ret

; 字符串转数字
string_to_number:
    xor ax, ax               ; 清空 AX
    mov si, buffer
    inc si                   ; 跳过长度字节
convert_digit:
    mov bl, [si]             ; 读取一个字符
    cmp bl, 0Dh              ; 检测回车
    je end_conversion
    sub bl, '0'              ; 转换为数字
    add al, bl
    inc si
    jmp convert_digit
end_conversion:
    ret

; 冒泡排序算法
bubble_sort:
    mov cx, numScores
sort_outer:
    dec cx
    jz end_sort
    mov bx, 0
sort_inner:
    mov al, [scores + bx]
    mov dl, [scores + bx + 1]
    cmp al, dl
    jbe skip_swap
    ; 交换 AL 和 DL
    mov [scores + bx], dl
    mov [scores + bx + 1], al
skip_swap:
    inc bx
    cmp bx, cx
    jl sort_inner
    jmp sort_outer
end_sort:
    ret

; 打印字符串
print_string:
    mov ah, 09h              ; DOS中断显示字符串
    int 21h
    ret

; 打印数字
print_number:
    xor cx, cx               ; 清空计数器
    mov bx, 10
print_convert:
    xor dx, dx
    div bx                   ; AX = AX / 10, DX = AX % 10
    push dx                  ; 保存余数
    inc cx
    test ax, ax
    jnz print_convert

print_result:
    pop ax                   ; 恢复余数
    add al, '0'              ; 转换为字符
    mov [buffer], al
    lea dx, buffer
    call print_string
    loop print_result
    ret

CODE ENDS
    END _start
