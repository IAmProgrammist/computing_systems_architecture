.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

.data
	max_num dw 4095
	print_digit db "%d%d%d%d%d%d %d%d%d%d%d%d", 13, 10, 0
.code

; output (short a)
output proc
	; short sum = 0;
	; short left[12] = {};
	sub esp, 13 * 2
	mov dword ptr [esp], 0
	mov dword ptr [esp + 4], 0
	mov dword ptr [esp + 8], 0
	mov dword ptr [esp + 12], 0
	mov dword ptr [esp + 16], 0
	mov dword ptr [esp + 20], 0
	mov word ptr [esp + 24], 0 
	; Сохранение регистров
	pushad
	; + 4 - адрес возврата
	; + 13 * 2 - локальные переменные
	; + 8 * 4 - сохранённые регистры
	mov ax, word ptr [esp + 4 + 13 * 2 + 8 * 4]

	; Для 12 цифр в цикле
	mov ecx, 12
cycle:
	mov dx, ax
	; Заносим маску
	mov bx, 1
	; Выполняем побитовое и над последней цифрой числа
	and ax, bx
	; Добавляем количество единиц в переменную sum
	add word ptr [esp + 8 * 4], ax
	; В ebp записываем эффективный адрес
	lea ebp, [esp + 8 * 4 + 13 * 2]
	; После чего вычитаем счётчик
	sub ebp, ecx
	sub ebp, ecx
	; И записываем в left[ecx] результат выполнения
	mov word ptr [ebp], ax
	; Выполняем побитовый сдвиг вправо
	mov ax, dx
	shr ax, 1

	dec ecx
	jne cycle

	; Считем сумму
	movsx ecx, word ptr [esp + 8 * 4]
	mov eax, 3
	cmp ecx, eax
	je print_val
	jmp dont_print

	print_val:

	movsx eax, word ptr [esp + 8 * 4 + 1 * 2]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 2 * 2 + 4]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 3 * 2 + 4 * 2]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 4 * 2 + 4 * 3]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 5 * 2 + 4 * 4]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 6 * 2 + 4 * 5]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 7 * 2 + 4 * 6]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 8 * 2 + 4 * 7]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 9 * 2 + 4 * 8]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 10 * 2 + 4 * 9]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 11 * 2 + 4 * 10]
	push eax
	movsx eax, word ptr [esp + 8 * 4 + 12 * 2 + 4 * 11]
	push eax
	push offset print_digit
	call crt_printf
	add esp, 52

	dont_print:

	; Восстановление регистров
	popad
	add esp, 13 * 2
	ret 2
output endp

start: 
	mov cx, max_num
	main_cycle:
	
	mov ax, cx
	push ax
	call output

	dec cx
	jge main_cycle


	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
