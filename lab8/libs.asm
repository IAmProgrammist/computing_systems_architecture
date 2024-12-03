.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

.code
DllMain proc hlnstDLL:dword, reason: dword, unused: dword
mov eax, 1
ret
DllMain endp

; ARGUMENT_AMOUNT 12

; int sort_stdcall_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_stdcall_noarg proc
    push ebp
    mov ecx, [esp + 8]       ; ecx = a
    mov edx, [esp + 8 + 4]   ; edx = length

    ; neg_count = 0
    mov edi, dword ptr [esp + 8 + 16]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub esp, 12
    ; ebx будет нашим счётчиком
    mov ebx, 0
    ; Обнуление eax
    xor eax, eax

sort_stdcall_noarg_loop_a:
        ; ebp = a
        mov ebp, ecx
        ; current = a[ebx]
        mov edi, dword ptr [ebp + ebx * 4]
        mov dword ptr [esp], edi

        ; current > 0?
        cmp dword ptr [esp], 0

        jge sort_stdcall_noarg_current_pos_zero_more
        jmp sort_stdcall_noarg_current_pos_zero_less


sort_stdcall_noarg_current_pos_zero_more:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 8]
            ; j = pos_count
            mov dword ptr [esp + 4], eax
            push eax
            push edx
            mov eax, dword ptr [esp + 8 + 4]
            mov edx, 4
            mul edx
            mov dword ptr [esp + 8 + 4], eax 
            pop edx
            pop eax

sort_stdcall_noarg_current_pos_zero_more_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp dword ptr [esp + 4], 0
                je sort_stdcall_noarg_current_pos_zero_more_loop_end
                ; current_comparing = pos_res - 1
                lea edi, dword ptr [ebp - 4]
                ; current_comparing = pos_res - 1 + j
                add edi, dword ptr [esp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [edi]
                ; current_comparing > current ?
                cmp edi, dword ptr [esp]

                jg sort_stdcall_noarg_current_pos_zero_more_loop_current_more
                jmp sort_stdcall_noarg_current_pos_zero_more_loop_current_less

sort_stdcall_noarg_current_pos_zero_more_loop_current_more:
                    push eax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = pos_res
                    mov edi, ebp
                    ; edi = pos_res + j
                    add edi, dword ptr [esp + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [edi], eax

                    pop eax
                    jmp sort_stdcall_noarg_current_pos_zero_more_loop_current_end


sort_stdcall_noarg_current_pos_zero_more_loop_current_less:
                    jmp sort_stdcall_noarg_current_pos_zero_more_loop_end


sort_stdcall_noarg_current_pos_zero_more_loop_current_end:
                sub dword ptr [esp + 4], 4
                jmp sort_stdcall_noarg_current_pos_zero_more_loop

sort_stdcall_noarg_current_pos_zero_more_loop_end:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 8]
            ; current_comparing = pos_res
            lea edi, dword ptr [ebp]
            ; current_comparing = pos_res + j
            add edi, dword ptr [esp + 4]
            push eax
            mov eax, dword ptr [esp + 4]
            mov dword ptr [edi], eax
            pop eax

            ; pos_count++
            inc eax
            jmp sort_stdcall_noarg_current_pos_zero_end

sort_stdcall_noarg_current_pos_zero_less:
            ; ebp = neg_res
            ; swap a
            mov edi, [esp + 8 + 12 + 16]
            xor eax, dword ptr [edi]
            xor dword ptr [edi], eax 
            xor eax, dword ptr [edi]


            ; ebp = neg_res
            mov ebp, [esp + 8 + 12 + 12]
            ; j = pos_count
            mov dword ptr [esp + 4], eax
            push eax
            push edx
            mov eax, dword ptr [esp + 8 + 4]
            mov edx, 4
            mul edx
            mov dword ptr [esp + 8 + 4], eax 
            pop edx
            pop eax

sort_stdcall_noarg_current_pos_zero_less_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp dword ptr [esp + 4], 0
                je sort_stdcall_noarg_current_pos_zero_less_loop_end
                ; current_comparing = pos_res - 1
                lea edi, dword ptr [ebp - 4]
                ; current_comparing = pos_res - 1 + j
                add edi, dword ptr [esp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [edi]
                ; current_comparing > current ?
                cmp edi, dword ptr [esp]

                jg sort_stdcall_noarg_current_pos_zero_less_loop_current_more
                jmp sort_stdcall_noarg_current_pos_zero_less_loop_current_less

sort_stdcall_noarg_current_pos_zero_less_loop_current_more:
                    push eax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = pos_res
                    mov edi, ebp
                    ; edi = pos_res + j
                    add edi, dword ptr [esp + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [edi], eax

                    pop eax
                    jmp sort_stdcall_noarg_current_pos_zero_less_loop_current_end


sort_stdcall_noarg_current_pos_zero_less_loop_current_less:
                    jmp sort_stdcall_noarg_current_pos_zero_less_loop_end


sort_stdcall_noarg_current_pos_zero_less_loop_current_end:
                sub dword ptr [esp + 4], 4
                jmp sort_stdcall_noarg_current_pos_zero_less_loop

sort_stdcall_noarg_current_pos_zero_less_loop_end:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 12]
            ; current_comparing = pos_res
            lea edi, dword ptr [ebp]
            ; current_comparing = pos_res + j
            add edi, dword ptr [esp + 4]
            push eax
            mov eax, dword ptr [esp + 4]
            mov dword ptr [edi], eax
            pop eax


            inc eax
            ; swap b
            mov edi, [esp + 8 + 12 + 16]
            xor eax, dword ptr [edi]
            xor dword ptr [edi], eax 
            xor eax, dword ptr [edi]
            
            jmp sort_stdcall_noarg_current_pos_zero_end

sort_stdcall_noarg_current_pos_zero_end:

        ; ebx++
        inc ebx
        ; Если ebx < length, переходим на следующую итерацию цикла
        cmp ebx, edx
        jl sort_stdcall_noarg_loop_a

    add esp, 12
    pop ebp
    ret 5 * 4
sort_stdcall_noarg endp

; int sort_cdecl_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_cdecl_noarg proc
push ebp
    mov ecx, [esp + 8]       ; ecx = a
    mov edx, [esp + 8 + 4]   ; edx = length

    ; neg_count = 0
    mov edi, dword ptr [esp + 8 + 16]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub esp, 12
    ; ebx будет нашим счётчиком
    mov ebx, 0
    ; Обнуление eax
    xor eax, eax

sort_cdecl_noarg_loop_a:
        ; ebp = a
        mov ebp, ecx
        ; current = a[ebx]
        mov edi, dword ptr [ebp + ebx * 4]
        mov dword ptr [esp], edi

        ; current > 0?
        cmp dword ptr [esp], 0

        jge sort_cdecl_noarg_current_pos_zero_more
        jmp sort_cdecl_noarg_current_pos_zero_less


sort_cdecl_noarg_current_pos_zero_more:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 8]
            ; j = pos_count
            mov dword ptr [esp + 4], eax
            push eax
            push edx
            mov eax, dword ptr [esp + 8 + 4]
            mov edx, 4
            mul edx
            mov dword ptr [esp + 8 + 4], eax 
            pop edx
            pop eax

sort_cdecl_noarg_current_pos_zero_more_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp dword ptr [esp + 4], 0
                je sort_cdecl_noarg_current_pos_zero_more_loop_end
                ; current_comparing = pos_res - 1
                lea edi, dword ptr [ebp - 4]
                ; current_comparing = pos_res - 1 + j
                add edi, dword ptr [esp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [edi]
                ; current_comparing > current ?
                cmp edi, dword ptr [esp]

                jg sort_cdecl_noarg_current_pos_zero_more_loop_current_more
                jmp sort_cdecl_noarg_current_pos_zero_more_loop_current_less

sort_cdecl_noarg_current_pos_zero_more_loop_current_more:
                    push eax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = pos_res
                    mov edi, ebp
                    ; edi = pos_res + j
                    add edi, dword ptr [esp + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [edi], eax

                    pop eax
                    jmp sort_cdecl_noarg_current_pos_zero_more_loop_current_end


sort_cdecl_noarg_current_pos_zero_more_loop_current_less:
                    jmp sort_cdecl_noarg_current_pos_zero_more_loop_end


sort_cdecl_noarg_current_pos_zero_more_loop_current_end:
                sub dword ptr [esp + 4], 4
                jmp sort_cdecl_noarg_current_pos_zero_more_loop

sort_cdecl_noarg_current_pos_zero_more_loop_end:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 8]
            ; current_comparing = pos_res
            lea edi, dword ptr [ebp]
            ; current_comparing = pos_res + j
            add edi, dword ptr [esp + 4]
            push eax
            mov eax, dword ptr [esp + 4]
            mov dword ptr [edi], eax
            pop eax

            ; pos_count++
            inc eax
            jmp sort_cdecl_noarg_current_pos_zero_end

sort_cdecl_noarg_current_pos_zero_less:
            ; ebp = neg_res
            ; swap a
            mov edi, [esp + 8 + 12 + 16]
            xor eax, dword ptr [edi]
            xor dword ptr [edi], eax 
            xor eax, dword ptr [edi]


            ; ebp = neg_res
            mov ebp, [esp + 8 + 12 + 12]
            ; j = pos_count
            mov dword ptr [esp + 4], eax
            push eax
            push edx
            mov eax, dword ptr [esp + 8 + 4]
            mov edx, 4
            mul edx
            mov dword ptr [esp + 8 + 4], eax 
            pop edx
            pop eax

sort_cdecl_noarg_current_pos_zero_less_loop:
                ; j <= 0? Да - выход, нет - проверяем.
                cmp dword ptr [esp + 4], 0
                je sort_cdecl_noarg_current_pos_zero_less_loop_end
                ; current_comparing = pos_res - 1
                lea edi, dword ptr [ebp - 4]
                ; current_comparing = pos_res - 1 + j
                add edi, dword ptr [esp + 4]
                ; current_comparing = *(pos_res - 1 + j)
                mov edi, dword ptr [edi]
                ; current_comparing > current ?
                cmp edi, dword ptr [esp]

                jg sort_cdecl_noarg_current_pos_zero_less_loop_current_more
                jmp sort_cdecl_noarg_current_pos_zero_less_loop_current_less

sort_cdecl_noarg_current_pos_zero_less_loop_current_more:
                    push eax
                    ; eax = pos_res[j - 1]
                    mov eax, edi
                    ; edi = pos_res
                    mov edi, ebp
                    ; edi = pos_res + j
                    add edi, dword ptr [esp + 8]
                    ; pos_res[j] = pos_res[j - 1]
                    mov dword ptr [edi], eax

                    pop eax
                    jmp sort_cdecl_noarg_current_pos_zero_less_loop_current_end


sort_cdecl_noarg_current_pos_zero_less_loop_current_less:
                    jmp sort_cdecl_noarg_current_pos_zero_less_loop_end


sort_cdecl_noarg_current_pos_zero_less_loop_current_end:
                sub dword ptr [esp + 4], 4
                jmp sort_cdecl_noarg_current_pos_zero_less_loop

sort_cdecl_noarg_current_pos_zero_less_loop_end:
            ; ebp = pos_res
            mov ebp, [esp + 8 + 12 + 12]
            ; current_comparing = pos_res
            lea edi, dword ptr [ebp]
            ; current_comparing = pos_res + j
            add edi, dword ptr [esp + 4]
            push eax
            mov eax, dword ptr [esp + 4]
            mov dword ptr [edi], eax
            pop eax


            inc eax
            ; swap b
            mov edi, [esp + 8 + 12 + 16]
            xor eax, dword ptr [edi]
            xor dword ptr [edi], eax 
            xor eax, dword ptr [edi]
            
            jmp sort_cdecl_noarg_current_pos_zero_end

sort_cdecl_noarg_current_pos_zero_end:

        ; ebx++
        inc ebx
        ; Если ebx < length, переходим на следующую итерацию цикла
        cmp ebx, edx
        jl sort_cdecl_noarg_loop_a

    add esp, 12
    pop ebp
    ret
sort_cdecl_noarg endp

; int sort_fastcall_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_fastcall_noarg proc
    ret 3 * 4
sort_fastcall_noarg endp

; int sort_stdcall (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_stdcall proc stdcall a: DWORD, len: DWORD, pos_res: DWORD, neg_res: DWORD, neg_count: DWORD
sort_stdcall endp

; int sort_cdecl (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_cdecl proc c a: DWORD, len: DWORD, pos_res: DWORD, neg_res: DWORD, neg_count: DWORD
sort_cdecl endp

end DllMain

; Как же я ЕБАЛ это говнище, господи...