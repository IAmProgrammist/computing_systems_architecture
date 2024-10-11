.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
includelib	kernel32.lib
includelib	msvcrt.lib
 
.data
	x dw -10
	y dw 7
	z dw -14
	output_str db "x = %hd, y = %hd, z = %hd, res = %d, edx = %d.", 0


.code
start: 
	movsx ecx, x ; Расширяем x до двойного слова
	add ecx, 10  ; edx = edx + 10
	mov eax, ecx ; ecx = edx = (x + 10)
	
	movsx ecx, y ; Расширяем y до двойного слова
	sub ecx, 5   ; edx = edx - 5
	imul ecx     ; edx:eax = ecx * edx = (x + 10) * (y - 5)

	mov ebx, 3   ; ebx = 3
	mov ecx, eax ; ecx = eax
	movsx eax, z ; Расширяем z до двойного слова
	cdq          ; eax -> edx:eax. edx:eax = r.
	idiv ebx     ; edx:eax / ebx = z / 3. eax = r / 3, edx = r % 3.
	movsx ebx, z ; ebx = z
	sub ebx, eax ; ebx = ebx - eax = z - z / 3
	imul ecx, ebx; ecx = ecx * ebx = (x + 10) * (y - 5) * (z - z / 3)
	mov eax, ecx ; eax = ecx

	mov ebx, 7   ; eax = 7
	imul ebx, ebx; ebx = ebx * ebx = 7^2
	imul ebx, ebx; ebx = ebx * ebx = 7^4

	sub eax, ebx ; eax = eax - ebx = (x + 10) * (y - 5) * (z - z / 3) - 7^4
	; Конец!
	
	push edx
	push eax
	push dword ptr x
	push dword ptr y
	push dword ptr z
	push offset output_str
	call crt_printf
	add esp, 4*6

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
