.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

.data
	print_number db "%d: ", 0
    print_digit db "%01X", 0
    print_newline db 13, 10, 0
.code

start:
    ; Перебор позиций единицы
	mov ecx, 0
    ; Общий счётчик при выводе
    mov esi, 1

main_loop:
    ; У нас 5 цифр
    cmp ecx, 5
    jge main_loop_end
    
    ; Маска для остального числа
    mov ebx, 0
subloop:
        cmp ebx, 10000b
        jge subloop_end

        pushad
        push esi
        push offset print_number
        call crt_printf
        add esp, 8
        popad

        inc esi

        ; Копируем маску в eax
        mov eax, ebx
        ; Внутренний счётчик i = 0
        mov edx, 0
subsubloop:
            cmp edx, 5
            jge subsubloop_cycle_end 

            ; i == позиции единицы?
            cmp edx, ecx

            je subsubloop_eq
            jmp subsubloop_not_eq
subsubloop_eq:
                pushad
                push 1
                push offset print_digit
                call crt_printf
                add esp, 8
                popad
                jmp subsubloop_end
subsubloop_not_eq:
                mov edi, eax
                and edi, 1
                shr eax, 1

                cmp edi, 1
                je subsubloop_print_e
                jmp subsubloop_print_f
subsubloop_print_e:
                pushad
                push 0Eh
                push offset print_digit
                call crt_printf
                add esp, 8
                popad
                jmp subsubloop_print_end
subsubloop_print_f:
                pushad
                push 0Fh
                push offset print_digit
                call crt_printf
                add esp, 8
                popad
subsubloop_print_end:

subsubloop_end:
            inc edx
            jmp subsubloop

subsubloop_cycle_end:

        pushad
        push offset print_newline
        call crt_printf
        add esp, 4
        popad

        inc ebx
        jmp subloop
subloop_end:

    inc ecx
    jmp main_loop
main_loop_end:


	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
