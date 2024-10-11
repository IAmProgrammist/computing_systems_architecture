.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib
 
.data
	a db 2Ah,  97h, 2Eh, 7Ch, 62h, 37h, 81h, 21h, 24h, 78h, 0C3h,  97h, 0C4h, 09h, 0BBh
	b db 0C3h, 97h, 82h, 31h, 97h, 81h, 24h, 78h, 9Dh, 29h,  78h, 0C3h,  67h, 82h, 0B4h
	r db 15 dup(?)
.code
start: 
	mov eax, dword ptr a[0]
	sub eax, dword ptr b[0]
	mov dword ptr r[0], eax

	mov eax, dword ptr a[4]
	sbb eax, dword ptr b[4]
	mov dword ptr r[4], eax

	mov eax, dword ptr a[8]
	sbb eax, dword ptr b[8]
	mov dword ptr r[8], eax

	mov ax, word ptr a[12]
	sbb ax, word ptr b[12]
	mov word ptr r[12], ax

	mov al, byte ptr a[14]
	sbb al, byte ptr b[14]
	mov byte ptr r[14], al

	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
