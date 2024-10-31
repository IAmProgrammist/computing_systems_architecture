.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib

; Тестовые данные:
; x = -5, y = 5, z = 1, a = 62
; x = -5, y = -5, z = 2, a = -10
; x = 1, y = -5, z = 1, a = -4

.data
	x db 0
	y dd 0
	z dw 0
	input_str db "%hhd %d %hu", 0
	output_str db "%d", 0

.code
start: 
    ; Вводим x, y, z
	push offset z
	push offset y
	push offset x
	push offset input_str
	call crt_scanf
	add esp, 4*4

	xor eax, eax   ; Очищаем eax
	movsx edx, x   ; edx = x
	add eax, edx   ; eax = eax + edx = x
	mov edx, y     ; edx = y
	add eax, edx   ; eax = x + y
	movsx edx, z   ; edx = z
	add eax, edx   ; eax = x + y + z

	cmp eax, 0     ; Сравниваем x + y + z с нулём
	; Если x + y + z > 0, идём к sum_gzero
	jg sum_gzero
	; Иначе топаем к sum_lezero
	jmp sum_lezero

	sum_gzero:
		movsx eax, x   ; eax = x
		imul eax, eax  ; eax = eax * eax = x ^ 2
		add eax, 32    ; eax = eax + 32 = x ^ 2 + 32
		movsx edx, x   ; edx = x
		movsx ebx, z   ; ebx = z
		imul edx, ebx  ; edx = edx * ebx = x * z
		sub eax, edx   ; eax = eax - edx = x ^ 2 + 32 - x * z
		jmp sum_end

	sum_lezero:
		movsx eax, x  ; eax = x
		cmp eax, 0    ; Сравниваем eax с нулём
		jg x_gzero    ; Если x > 0, топаем к x_gzero
		; Иначе - x_lezero
		jmp x_lezero
		x_gzero:
			movsx eax, z ; eax = z
			mov ebx, y   ; ebx = y
			add eax, ebx ; eax = eax + ebx = z + y
			jmp x_end    ; Выходим из условия

		x_lezero:
			mov ebx, 2    ; ebx = 2
			movsx eax, z  ; eax = z
			cdq           ; eax = eax:edx
			idiv ebx      ; eax = eax / ebx = z / 2
			mov ebx, y    ; ebx = y
			imul eax, ebx ; eax = eax * ebx = (z / 2) * y
			movsx ebx, x  ; ebx = x
			add eax, ebx  ; eax = eax + ebx = (z / 2) * y + x
			jmp x_end     ; Выходим из условия

		x_end:
		jmp sum_end ; Выходим из условия

	sum_end:

	; Выводим результат
	push eax
	push offset output_str
	call crt_printf
	add esp, 4 * 2

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
