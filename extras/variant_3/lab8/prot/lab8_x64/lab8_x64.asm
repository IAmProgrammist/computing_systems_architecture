EXTERN printf: PROC

.CODE

; select_sort(int* a, int length)
select_sort proc
    push rax
    push rbx
    push rcx
    push rdx
    push rbp
    push rsp
    push rsi
    push rdi

    mov    rbp, rsp
    mov    rcx, [rbp + 64 + 8 + 8] ; Количество чисел
    mov    rbx, [rbp + 64 + 8] ; Адрес числа

    sub    rcx, 1       ; Готово если 0 или 1 элемент
    jbe    select_sort_end

select_sort_outer_loop:
        mov    rdx, rcx      ; Количество сравнений
        mov    rsi, rbx      ; Начало неотсортированного массива
        mov    eax, [rsi]    ; Минимум (число)
        mov    rdi, rsi      ; Минимум (адрес)
select_sort_inner_loop:
            add    rsi, 4

            cmp [rsi], eax

            jg     select_sort_not_smaller
            mov    eax, [rsi]    ; Значение минимума
            mov    rdi, rsi      ; Адрес минимума
select_sort_not_smaller:
            dec    rdx
            jnz    select_sort_inner_loop

        mov    edx, [rbx]    ; Обмен элементов
        mov    [rbx], eax
        mov    [rdi], edx

        add    rbx, 4       ; Передвинуть границу отсортированного массива
        dec    rcx
        jnz    select_sort_outer_loop
select_sort_end:

    pop rdi
    pop rsi
    pop rsp
    pop rbp
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret    16
select_sort endp

; int sort_fastcall_x64 (int* a, int start, int end, int* res)
sort_fastcall_x64 proc
    push rdi
    push rsi
    push rbx
    push rbp
    mov r10, rcx
    mov r11d, edx
    ; r10 = rcx = a
    ; r11d = edx = index_start
    ; r8d = index_end
    ; r9 = res

    movsxd r11, r11d
    movsxd r8, r8d

    mov rax, 0

    ; Копируем данные в res
sort_fastcall_x64_copyloop:
    ; start > end?
    mov rsi, r11
    cmp rsi, r8
    jg sort_fastcall_x64_copyloop_end
    
    ; ebx = res + eax * 4
    mov rbx, r9
    add rbx, rax
    add rbx, rax
    add rbx, rax
    add rbx, rax

    push rdi
    push rax
    ; edi = a + start * 4
    mov rdi, r10
    add rdi, r11
    add rdi, r11
    add rdi, r11
    add rdi, r11

    ; res[eax] = a[start]
    mov eax, dword ptr [rdi]
    mov dword ptr [rbx], eax
    pop rax
    pop rdi

    ; start++
    ; eax++
    inc eax
    inc r11

    jmp sort_fastcall_x64_copyloop
sort_fastcall_x64_copyloop_end:

    push rax
    push r9
    call select_sort

    mov rax, r9

    pop rbp
    pop rbx
    pop rsi
    pop rdi
    ret
sort_fastcall_x64 endp

END 