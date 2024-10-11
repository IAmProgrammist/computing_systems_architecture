.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib
 
.data
	a db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	b db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
	r db 16 dup(0)
	output_str db "%08x %08x %08x %08x", 0

.code
start: 
	; Первые 4 байта умножаемого и множителя
	mov eax, dword ptr a[0]
	mov ebx, dword ptr b[0]
	mul ebx
	mov dword ptr r[0], eax
	mov dword ptr r[4], edx

	; Первые 4 байта умножаемого и вторые 4 байта множителя
	mov eax, dword ptr a[4]
	mul ebx
	add dword ptr r[4], eax
	adc dword ptr r[8], edx
	adc dword ptr r[12], 0
	
	; Вторые 4 байта умножаемого и первые 4 байта множителя
	mov eax, dword ptr a[0]
	mov ebx, dword ptr b[4]
	mul ebx
	add dword ptr r[4], eax
	adc dword ptr r[8], edx
	adc dword ptr r[12], 0

	; Вторые 4 байта умножаемого и множителя
	mov eax, dword ptr a[4]
	mul ebx
	add dword ptr r[8], eax
	adc dword ptr r[12], edx

	push dword ptr r[0]
	push dword ptr r[4]
	push dword ptr r[8]
	push dword ptr r[12]
	push offset output_str
	call crt_printf
	add esp, 5*4

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
