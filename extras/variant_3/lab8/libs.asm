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

; sort_inner(float* a, int length)
sort_inner proc
    pushad

    mov ecx, 0
sort_inner_loop:
    

    popad
    ret 8
sort_inner endp


; int sort_stdcall_noarg (float* a, int length, float* pos_res, float* neg_res, int* pos_count)
sort_stdcall_noarg proc
    push ebp
    mov ecx, [esp + 8]       ; ecx = a
    mov edx, [esp + 8 + 4]   ; edx = length

    ; pos_count = 0
    mov edi, dword ptr [esp + 8 + 16]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; ebx будет нашим счётчиком
    mov ebx, 0





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



    add esp, 12
    pop ebp
    ret
sort_cdecl_noarg endp

; int sort_fastcall_noarg (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_fastcall_noarg proc
    push ebp
    ; ecx = a
    ; edx = length

    ; neg_count = 0
    mov edi, dword ptr [esp + 8 + 8]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub esp, 12
    ; ebx будет нашим счётчиком
    mov ebx, 0
    ; Обнуление eax
    xor eax, eax



    add esp, 12
    pop ebp
    ret 3 * 4
sort_fastcall_noarg endp

; int sort_stdcall (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_stdcall proc stdcall a: DWORD, len: DWORD, pos_res: DWORD, neg_res: DWORD, neg_count: DWORD
    push esi
    mov ecx, a       ; ecx = a
    mov edx, len   ; edx = length

    ; neg_count = 0
    mov edi, dword ptr [neg_count]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub esp, 12
    ; ebx будет нашим счётчиком
    mov ebx, 0
    ; Обнуление eax
    xor eax, eax



    add esp, 12
    pop esi
    ret
sort_stdcall endp

; int sort_cdecl (int* a, int length, int* pos_res, int* neg_res, int* neg_count)
sort_cdecl proc c a: DWORD, len: DWORD, pos_res: DWORD, neg_res: DWORD, neg_count: DWORD
push esi
    mov ecx, a       ; ecx = a
    mov edx, len   ; edx = length

    ; neg_count = 0
    mov edi, dword ptr [neg_count]
    mov dword ptr [edi], 0

    ; Используемые аргументы

    ; Выделяем место под локальную переменную current, j, current_comparing
    sub esp, 12
    ; ebx будет нашим счётчиком
    mov ebx, 0
    ; Обнуление eax
    xor eax, eax



    add esp, 12
    pop esi
    ret
sort_cdecl endp

end DllMain