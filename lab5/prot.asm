.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

; Тестовые данные: 
; 1 5 5
; 1 2 3 4 5
; 5 4 3 2 1
; -295

; 1 2 6
; 10 99
; 32 1
; 215

; 1 5 4
; 1 24 31 4 89
; 29 -13 -12 42 123
; -555785

.data
	output_str db "%d", 13, 10, 0

.code

is_simple proc
	pushad
	mov eax, [esp + 4 + 8 * 4] ; eax = a
	mov ecx, 2                 ; i = 2

is_simple_cycle:
	mov edx, ecx          ; edx = i
	imul edx, edx         ; edx = edx * edx = i ^ 2
	cmp edx, eax          ; edx сравнить с eax или i ^ 2 сравнить с a
	jg is_simple_simple   ; i ^ 2 > a ? 
	mov ebx, ecx          ; ebx = i
	mov esi, eax          ; esi = eax = a
	cdq                   ; Расширяем eax до edx:eax
	idiv ebx              ; edx:eax / ebx = a / i
	mov eax, esi          ; Возвращаем обратно из esi сохранённое значение в eax
	cmp edx, 0            ; Сравниваем остаток от деления edx с нулём
	je is_simple_not_simple  ; Если остаток от деления равен 0, то число не простое, и мы выходим из цикла.
	
	inc ecx               ; i++
	jmp is_simple_cycle   ; Топаем на начало цикла

is_simple_simple:
	popad
	mov eax, 1
	ret 4

is_simple_not_simple:
	popad
	mov eax, 0
	ret 4

is_simple endp

is_simple_from_to proc
	pushad
	mov esi, [esp + 4 + 8 * 4] ; esi = b
	mov edi, [esp + 8 + 8 * 4] ; edi = a

	mov ecx, edi ; ecx = esi = a, i = a

is_simple_from_to_cycle:
	cmp ecx, esi ; i сравниваем с b
	jg is_simple_from_to_cycle_end ; i > b ? прыгаем к концу цикла, иначе - проверяем число
	push ecx
	call is_simple

	cmp eax, 0 ; Результат выполнения true?
	jg is_simple_from_to_print ; Если да, то выводим i
	jmp is_simple_from_to_print_end ; Если нет, то пропускаем и сразу топаем к увеличению i.

is_simple_from_to_print:
	pushad
	push ecx
	push offset output_str
	call crt_printf
	add esp, 8
	popad

is_simple_from_to_print_end:
	inc ecx ; i++
	jmp is_simple_from_to_cycle ; Топаем к началу цикла

is_simple_from_to_cycle_end:
	popad
	ret 8
is_simple_from_to endp

start: 
    push 2
    push 100
	call is_simple_from_to

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
