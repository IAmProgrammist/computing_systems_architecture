EXTERN printf: PROC

.CODE

; int sort_fastcall_x64 (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_fastcall_x64 proc
    push rdi
    push rsi
    push rbx
    push rbp
    ; rcx = a
    ; edx = length
    ; r8 = pos_res
    ; r9 = neg_res

    ; neg_count = 0
    mov rdi, qword ptr [rsp + 32 + 40]
    mov dword ptr [rdi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub rsp, 16
    ; rbx будет нашим счётчиком
    mov rbx, 0
    ; Обнуление eax
    xor rax, rax

sort_fastcall_x64_loop_a:
        ; rsi = a
        mov rsi, rcx
        ; current = a[rbx]
        mov edi, dword ptr [rsi + rbx * 4]
        mov dword ptr [rsp], edi

        ; current > 0?
        cmp dword ptr [rsp], 0

        jge sort_fastcall_x64_current_pos_zero_more
        jmp sort_fastcall_x64_current_pos_zero_less


sort_fastcall_x64_current_pos_zero_more:
            ; rsi = pos_res
            mov rsi, r8
            ; j = pos_count
            mov qword ptr [rsp + 4], rax
            push rax
            push rdx
            mov rax, qword ptr [rsp + 16 + 4]
            mov rdx, 4
            mul rdx
            mov qword ptr [rsp + 16 + 4], rax 
            pop rdx
            pop rax

sort_fastcall_x64_current_pos_zero_more_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp qword ptr [rsp + 4], 0
                je sort_fastcall_x64_current_pos_zero_more_loop_end
                ; current_comparing = pos_res - 1
                lea rdi, qword ptr [rsi - 4]
                ; current_comparing = pos_res - 1 + j
                add rdi, qword ptr [rsp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [rdi]
                ; current_comparing > current ?
                cmp edi, dword ptr [rsp]

                jg sort_fastcall_x64_current_pos_zero_more_loop_current_more
                jmp sort_fastcall_x64_current_pos_zero_more_loop_current_less

sort_fastcall_x64_current_pos_zero_more_loop_current_more:
                    push rax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = pos_res
                    mov rdi, rsi
                    ; edi = pos_res + j
                    add rdi, qword ptr [rsp + 4 + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [rdi], eax

                    pop rax
                    jmp sort_fastcall_x64_current_pos_zero_more_loop_current_end


sort_fastcall_x64_current_pos_zero_more_loop_current_less:
                    jmp sort_fastcall_x64_current_pos_zero_more_loop_end


sort_fastcall_x64_current_pos_zero_more_loop_current_end:
                sub qword ptr [rsp + 4], 4
                jmp sort_fastcall_x64_current_pos_zero_more_loop

sort_fastcall_x64_current_pos_zero_more_loop_end:
            ; rsi = pos_res
            mov rsi, r8
            ; current_comparing = pos_res
            mov rdi, rsi
            ; current_comparing = pos_res + j
            add rdi, qword ptr [rsp + 4]
            push rax
            mov eax, dword ptr [rsp + 8]
            mov dword ptr [rdi], eax
            pop rax

            ; pos_count++
            inc rax
            jmp sort_fastcall_x64_current_pos_zero_end

sort_fastcall_x64_current_pos_zero_less:
            ; rsi = neg_res
            ; swap a
            mov rdi, qword ptr [rsp + 32 + 16 + 40]
            xor eax, dword ptr [rdi]
            xor dword ptr [rdi], eax 
            xor eax, dword ptr [rdi]


            ; rsi = neg_res
            mov rsi, r9
            ; j = pos_count
            mov qword ptr [rsp + 4], rax
            push rax
            push rdx
            mov rax, qword ptr [rsp + 16 + 4]
            mov rdx, 4
            mul rdx
            mov qword ptr [rsp + 16 + 4], rax 
            pop rdx
            pop rax

sort_fastcall_x64_current_pos_zero_less_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp qword ptr [rsp + 4], 0
                je sort_fastcall_x64_current_pos_zero_less_loop_end
                ; current_comparing = pos_res - 1
                lea rdi, qword ptr [rsi - 4]
                ; current_comparing = pos_res - 1 + j
                add rdi, qword ptr [rsp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [rdi]
                ; current_comparing > current ?
                cmp edi, dword ptr [rsp]

                jg sort_fastcall_x64_current_pos_zero_less_loop_current_more
                jmp sort_fastcall_x64_current_pos_zero_less_loop_current_less

sort_fastcall_x64_current_pos_zero_less_loop_current_more:
                    push rax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = neg_res
                    mov rdi, rsi
                    ; edi = neg_res + j
                    add rdi, qword ptr [rsp + 4 + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [rdi], eax

                    pop rax
                    jmp sort_fastcall_x64_current_pos_zero_less_loop_current_end


sort_fastcall_x64_current_pos_zero_less_loop_current_less:
                    jmp sort_fastcall_x64_current_pos_zero_less_loop_end


sort_fastcall_x64_current_pos_zero_less_loop_current_end:
                sub qword ptr [rsp + 4], 4
                jmp sort_fastcall_x64_current_pos_zero_less_loop

sort_fastcall_x64_current_pos_zero_less_loop_end:
            ; rsi = pos_res
            mov rsi, r9
            ; current_comparing = pos_res
            mov rdi, rsi
            ; current_comparing = pos_res + j
            add rdi, qword ptr [rsp + 4]
            push rax
            mov eax, dword ptr [rsp + 8]
            mov dword ptr [rdi], eax
            pop rax

            ; pos_count++
            inc rax
            ; swap b
            mov rdi, qword ptr [rsp + 32 + 16 + 40]
            xor eax, dword ptr [rdi]
            xor dword ptr [rdi], eax 
            xor eax, dword ptr [rdi]
            
            jmp sort_fastcall_x64_current_pos_zero_end

sort_fastcall_x64_current_pos_zero_end:

        ; rbx++
        inc rbx
        ; Если rbx < length, переходим на следующую итерацию цикла
        cmp rbx, rdx
        jl sort_fastcall_x64_loop_a

    add rsp, 16

    pop rbp
    pop rbx
    pop rsi
    pop rdi
    ret
sort_fastcall_x64 endp

sum_numbers_fastcall PROC
    MOV RAX, RCX    ; Первый аргумент находится в RCX
    ADD RAX, RDX    ; Второй аргумент находится в RDX
    ADD RAX, R8     ; Третий аргумент находится в R8
    ADD RAX, R9     ; Четвёртый аргумент находится в R9
    ADD RAX, [RSP + 5*8]    ; Остальные аргументы находятся в стеке, начиная с адреса RSP + 40
    ; 40 байт - это теневое хранилище для 4 регистров и адреса возврата
    mov rax, 201
    RET
sum_numbers_fastcall ENDP 

; КГ Лаб 5, АВС лаб 8

END 