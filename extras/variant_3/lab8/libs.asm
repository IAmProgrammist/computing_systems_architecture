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

; select_sort(int* a, int length)
select_sort proc
    pushad
    mov    ebp, esp
    mov    ecx, [ebp + 32 + 4 + 4] ; Количество чисел
    mov    ebx, [ebp + 32 + 4] ; Адрес числа

    sub    ecx, 1       ; Готово если 0 или 1 элемент
    jbe    select_sort_end

select_sort_outer_loop:
        mov    edx, ecx      ; Количество сравнений
        mov    esi, ebx      ; Начало неотсортированного массива
        mov    eax, [esi]    ; Минимум (число)
        mov    edi, esi      ; Минимум (адрес)
select_sort_inner_loop:
            add    esi, 4

            cmp [esi], eax

            jg     select_sort_not_smaller
            mov    eax, [esi]    ; Значение минимума
            mov    edi, esi      ; Адрес минимума
select_sort_not_smaller:
            dec    edx
            jnz    select_sort_inner_loop

        mov    edx, [ebx]    ; Обмен элементов
        mov    [ebx], eax
        mov    [edi], edx

        add    ebx, 4       ; Передвинуть границу отсортированного массива
        dec    ecx
        jnz    select_sort_outer_loop
select_sort_end:
    popad
    ret    8
select_sort endp


; int* sort_stdcall_noarg(int* a, int start, int end, int* res)
sort_stdcall_noarg proc
    push ebp
    push edi
    push esi
    push ebx

    mov ecx, [esp + 20]       ; ecx = a
    mov edx, [esp + 20 + 4]   ; edx = start
    mov edi, [esp + 20 + 8]   ; edi = end
    mov ebx, [esp + 20 + 12]  ; ebx = res 

    mov eax, 0

    ; Копируем данные в res
sort_stdcall_noarg_copyloop:
    ; start > end?
    cmp edx, edi
    jg sort_stdcall_noarg_copyloop_end
    
    ; ebp = res + eax * 4
    mov ebp, ebx
    add ebp, eax
    add ebp, eax
    add ebp, eax
    add ebp, eax

    push edi
    push eax
    ; edi = a + start * 4
    mov edi, ecx
    add edi, edx
    add edi, edx
    add edi, edx
    add edi, edx

    ; res[eax] = a[start]
    mov eax, dword ptr [edi]
    mov dword ptr [ebp], eax
    pop eax
    pop edi

    ; start++
    ; eax++
    inc eax
    inc edx

    jmp sort_stdcall_noarg_copyloop
sort_stdcall_noarg_copyloop_end:

    push eax
    push ebx
    call select_sort

    mov eax, ebx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret 4 * 4
sort_stdcall_noarg endp

; int sort_cdecl_noarg (int* a, int start, int end, int* res)
sort_cdecl_noarg proc
    push ebp
    push edi
    push esi
    push ebx

    mov ecx, [esp + 20]       ; ecx = a
    mov edx, [esp + 20 + 4]   ; edx = start
    mov edi, [esp + 20 + 8]   ; edi = end
    mov ebx, [esp + 20 + 12]  ; ebx = res 

    mov eax, 0

    ; Копируем данные в res
sort_cdecl_noarg_copyloop:
    ; start > end?
    cmp edx, edi
    jg sort_cdecl_noarg_copyloop_end
    
    ; ebp = res + eax * 4
    mov ebp, ebx
    add ebp, eax
    add ebp, eax
    add ebp, eax
    add ebp, eax

    push edi
    push eax
    ; edi = a + start * 4
    mov edi, ecx
    add edi, edx
    add edi, edx
    add edi, edx
    add edi, edx

    ; res[eax] = a[start]
    mov eax, dword ptr [edi]
    mov dword ptr [ebp], eax
    pop eax
    pop edi

    ; start++
    ; eax++
    inc eax
    inc edx

    jmp sort_cdecl_noarg_copyloop
sort_cdecl_noarg_copyloop_end:

    push eax
    push ebx
    call select_sort

    mov eax, ebx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret
sort_cdecl_noarg endp

; int sort_fastcall_noarg(int* a, int start, int end, int* res)
sort_fastcall_noarg proc
    push ebp
    push edi
    push esi
    push ebx

    mov edi, [esp + 20]   ; edi = end
    mov ebx, [esp + 20 + 4]  ; ebx = res 

    mov eax, 0

    ; Копируем данные в res
sort_fastcall_noarg_copyloop:
    ; start > end?
    cmp edx, edi
    jg sort_fastcall_noarg_copyloop_end
    
    ; ebp = res + eax * 4
    mov ebp, ebx
    add ebp, eax
    add ebp, eax
    add ebp, eax
    add ebp, eax

    push edi
    push eax
    ; edi = a + start * 4
    mov edi, ecx
    add edi, edx
    add edi, edx
    add edi, edx
    add edi, edx

    ; res[eax] = a[start]
    mov eax, dword ptr [edi]
    mov dword ptr [ebp], eax
    pop eax
    pop edi

    ; start++
    ; eax++
    inc eax
    inc edx

    jmp sort_fastcall_noarg_copyloop
sort_fastcall_noarg_copyloop_end:

    push eax
    push ebx
    call select_sort

    mov eax, ebx
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret 2 * 4
sort_fastcall_noarg endp

; int sort_stdcall(int* a, int start, int end, int* res)
sort_stdcall proc stdcall a: DWORD, index_start: DWORD, index_end: DWORD, res: DWORD
    push edi
    push esi
    push ebx

    mov eax, 0

    ; Копируем данные в res
sort_stdcall_copyloop:
    ; start > end?
    mov esi, index_start
    cmp esi, index_end
    jg sort_stdcall_copyloop_end
    
    ; ebx = res + eax * 4
    mov ebx, res
    add ebx, eax
    add ebx, eax
    add ebx, eax
    add ebx, eax

    push edi
    push eax
    ; edi = a + start * 4
    mov edi, a
    add edi, index_start
    add edi, index_start
    add edi, index_start
    add edi, index_start

    ; res[eax] = a[start]
    mov eax, dword ptr [edi]
    mov dword ptr [ebx], eax
    pop eax
    pop edi

    ; start++
    ; eax++
    inc eax
    inc index_start

    jmp sort_stdcall_copyloop
sort_stdcall_copyloop_end:

    push eax
    push res
    call select_sort

    mov eax, res
    pop ebx
    pop esi
    pop edi
    ret
sort_stdcall endp

; int sort_cdecl(int* a, int start, int end, int* res)
sort_cdecl proc c a: DWORD, index_start: DWORD, index_end: DWORD, res: DWORD
    push edi
    push esi
    push ebx

    mov eax, 0

    ; Копируем данные в res
sort_cdecl_copyloop:
    ; start > end?
    mov esi, index_start
    cmp esi, index_end
    jg sort_cdecl_copyloop_end
    
    ; ebx = res + eax * 4
    mov ebx, res
    add ebx, eax
    add ebx, eax
    add ebx, eax
    add ebx, eax

    push edi
    push eax
    ; edi = a + start * 4
    mov edi, a
    add edi, index_start
    add edi, index_start
    add edi, index_start
    add edi, index_start

    ; res[eax] = a[start]
    mov eax, dword ptr [edi]
    mov dword ptr [ebx], eax
    pop eax
    pop edi

    ; start++
    ; eax++
    inc eax
    inc index_start

    jmp sort_cdecl_copyloop
sort_cdecl_copyloop_end:

    push eax
    push res
    call select_sort

    mov eax, res
    pop ebx
    pop esi
    pop edi
    ret
sort_cdecl endp

end DllMain