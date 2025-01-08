.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

; Здесь Бога нет тем более

.data
	value db 0h, 0h, 0h, 0h, 0h, 0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h
	n dd 4
	res db 18 dup(?) 
	get_value_fmt db "%04x %08x %08x %08x %08x", 0
	print_value_fmt db "%04x %08x %08x %08x %08x", 13, 10, 0
	get_n_fmt db "%d", 0
.code

; 18 байт
; multiply (char *a, int n, char* res);
multiply proc
	pushad
	mov ebp, dword ptr [esp + 4 + 8 * 4]   ; ebp - адрес a
	mov eax, dword ptr [esp + 12 + 8 * 4]  ; eax - адрес res
	
	; Копируем данные в res
	mov ecx, 0
multiply_copy_cycle:
		mov dh, byte ptr [ebp + ecx]
		mov byte ptr [eax + ecx], dh
		inc ecx
		cmp ecx, 18
		jl multiply_copy_cycle

	; В счётчик пишем n
	mov ecx, dword ptr [esp + 8 + 8 * 4]
	cmp ecx, 0

	jle multiply_immediate_end

multiply_shift_cycle_n:
		; Сохраняем текущий счётчик в edx
		mov edx, ecx
		mov ecx, 0
		
		; Сброс CF флага
		clc
		pushfd
multiply_shift_cycle_shift:
			; Восстанавливаем CF
			popfd
			jc significant_set
			jmp significant_not_set
significant_set:
				; Если CF установлен, тогда будем добавлять перенесённый бит
				shl byte ptr [eax + ecx], 1
				; Сохраняем флаги
				pushfd
				; Добавляем перенесённый бит
				add byte ptr [eax + ecx], 1b
				jmp significant_end
significant_not_set:
				; Если CF не установлен, просто выполняем сдвиг
				shl byte ptr [eax + ecx], 1
				; Сохраняем флаги
				pushfd
				jmp significant_end
significant_end:
		
			; У нас 36 байтов, поэтому проверяем
			inc ecx
			cmp ecx, 18
			jl multiply_shift_cycle_shift

		popfd

		mov ecx, edx
		dec ecx
		jne multiply_shift_cycle_n
multiply_immediate_end:
	popad
	ret 12
multiply endp

start: 
	push offset value
	push offset value + 4
	push offset value + 8
	push offset value + 12
	push offset value + 16
	push offset get_value_fmt
	call crt_scanf
	add esp, 24

	push offset n
	push offset get_n_fmt
	call crt_scanf
	add esp, 8

	push offset res
	push n
	push offset value
	call multiply

	lea ebp, res
	mov eax, dword ptr [ebp]
	push eax
	mov eax, dword ptr [ebp + 4]
	push eax
	mov eax, dword ptr [ebp + 8]
	push eax
	mov eax, dword ptr [ebp + 12]
	push eax
	mov eax, 0
	mov ax, word ptr [ebp + 16]
	push eax
	push offset print_value_fmt
	call crt_printf

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
