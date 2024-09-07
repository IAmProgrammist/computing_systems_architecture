.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib
 
.data
	a DD 30201, 30201h ; Массив a из 4-байтовых чисел 30201 и 30201h
	b DB 43h, 0F3h, 0F3h, 0E5h ; Массив b из однобайтных шестнадцатеричных чисел 
	DF 1500 ; Неименованная зона с 6-байтовым числом
	DD 1.5, 1.6, 1.9, -1.9 ; Неименованный массив из 4-байтовых вещественных чисел
	t DQ 0E7D32A1h ; t содержащее 8-байтовое шестнадцатеричное число
	stra DB 16 dup(1) ; Строка stra с 16 1-байтовыми символами 1

.code
start: 
	MOV ESI, 65737341h ; Записать в регистр ESI шестнадцатеричное число 65737341h
	AND ESI, dword ptr b ; Выполнить логическое AND над ESI и b, интерпретированным как dword. Результат записать в ESI
	MOV dword ptr stra, ESI ; Записать в stra из ESI
	MOV ECX, dword ptr t ; Записать в ECX из t
	IMUL ECX, 7 ; Умножить ECX на 7
	ADD ECX, 6 ; Добавить к ECX 6
	MOV dword ptr stra[4], ECX ; Записать в stra по 4 позиции ECX
	ADD stra[8], 'q' ; Добавить к stra по позиции 8 q. 1 + 'q' = 'r'.
	DEC stra[9] ; Уменьшить stra[9] на 1. Получим 0 - нуль-строку.
; И осталось даже 6 неиспользованных байт - какое расточительство!
	
	push offset stra
	call crt_puts	; puts(stra)
	ADD ESP, 4		; Очистка стека от аргумента

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
