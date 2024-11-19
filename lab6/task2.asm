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
	value db 00h, 00h, 00h, 00h, 0h, 0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h,0h, 0h, 0h
	n dd 4
	res db 36 dup(?) 
	get_value_fmt db "%08x %08x %08x %08x %08x %08x %08x %08x %08x", 0
	print_value_fmt db "%08x %08x %08x %08x %08x %08x %08x %08x %08x", 13, 10, 0
	get_n_fmt db "%d", 0
.code

; 36 байт
; division (char *a, int n, char* res);
division proc
	pushad
	mov ebp, dword ptr [esp + 4 + 8 * 4]   ; ebp - адрес a
	mov eax, dword ptr [esp + 12 + 8 * 4]  ; eax - адрес res
	
	; Копируем данные в res
	mov ecx, 0
	division_copy_cycle:
	mov dh, byte ptr [ebp + ecx]
	mov byte ptr [eax + ecx], dh
	inc ecx
	cmp ecx, 36
	jl division_copy_cycle

	; В счётчик пишем n
	mov ecx, dword ptr [esp + 8 + 8 * 4]
	cmp ecx, 0

	jle division_immediate_end

	division_shift_cycle_n:
	; Сохраняем текущий счётчик в edx
	mov edx, ecx
	mov ecx, 35
	
	; Сброс CF флага
	clc
	pushfd
	division_shift_cycle_shift:
	; Восстанавливаем CF
	popfd
	jc significant_set
	jmp significant_not_set
	significant_set:
	; Если CF установлен, тогда будем добавлять перенесённый бит
	shr byte ptr [eax + ecx], 1
	; Сохраняем флаги
	pushfd
	; Добавляем перенесённый бит
	add byte ptr [eax + ecx], 10000000b
	jmp significant_end
	significant_not_set:
	; Если CF не установлен, просто выполняем сдвиг
	shr byte ptr [eax + ecx], 1
	; Сохраняем флаги
	pushfd
	jmp significant_end
	significant_end:
	
	; У нас 36 байтов, поэтому проверяем
	dec ecx
	jge division_shift_cycle_shift
	popfd
	
	mov ecx, edx
	dec ecx
	jne division_shift_cycle_n
	
	division_immediate_end:
	popad
	ret 12
division endp

start: 
	push offset value
	push offset value + 4
	push offset value + 8
	push offset value + 12
	push offset value + 16
	push offset value + 20
	push offset value + 24
	push offset value + 28
	push offset value + 32
	push offset get_value_fmt
	call crt_scanf
	add esp, 40

	push offset n
	push offset get_n_fmt
	call crt_scanf
	add esp, 8

	push offset res
	push n
	push offset value
	call division

	lea ebp, res
	mov eax, dword ptr [ebp]
	push eax
	mov eax, dword ptr [ebp + 4]
	push eax
	mov eax, dword ptr [ebp + 8]
	push eax
	mov eax, dword ptr [ebp + 12]
	push eax
	mov eax, dword ptr [ebp + 16]
	push eax
	mov eax, dword ptr [ebp + 20]
	push eax
	mov eax, dword ptr [ebp + 24]
	push eax
	mov eax, dword ptr [ebp + 28]
	push eax
	mov eax, dword ptr [ebp + 32]
	push eax
	push offset print_value_fmt
	call crt_printf

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
