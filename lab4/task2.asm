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
	i dd 0
	j dd 0
	result dd 0
	k_tmp dd 0
	h dw 0
	x dw 512 dup(0)
	y dw 512 dup(0)
	m dw 0
	n dw 0
	str_fmt db "%u", 0
	str_output_fmt db "%u", 13, 10, 0
	input_str db "%hu %hu %hu", 0
	output_str db "%d", 13, 10, 0

.code

; void input (short* a, int n)
input proc
	pushad
	mov esi, [esp + 4 + 8 * 4]
	mov ecx, [esp + 8 + 8 * 4]
	xor ebx, ebx

input_j_loop:
	cmp ebx, ecx
	je input_j_exit
	lea edi, [esi + ebx * 2]

	pushad
	push edi
	push offset str_fmt
	call crt_scanf
	add esp, 8
	popad

	inc ebx
	jmp input_j_loop
input_j_exit:
	popad
	ret 8
input endp

; void output (int* a, int n)
output proc
	pushad
	mov esi, [esp + 4 + 8 * 4]
	mov ecx, [esp + 8 + 8 * 4]
	xor ebx, ebx

output_j_loop:
	cmp ebx, ecx
	je output_j_exit
	lea edi, [esi + ebx * 2]

	pushad
	mov ax, [edi + 0]
	movsx eax, ax
	push eax
	push offset str_output_fmt
	call crt_printf
	add esp, 8
	popad

	inc ebx
	jmp output_j_loop
output_j_exit:
	popad
	ret 8
output endp

; Внимание! Функцию поменял, бикос в оригинальной может случиться деление на 0, что довольно грустно. 
; i/3 + 1 и 5 * (i + j) / (i + 1) + 1
k proc
	pushad
	mov ebp, [esp + 4 + 8 * 4] ; ebp = i
	mov esi, [esp + 8 + 8 * 4] ; esi = j
	mov eax, ebp ; eax = i
	cdq          ; Расширяем eax
	mov ebx, 3
	idiv ebx     ; eax = i / 3, edx = i % 3
	cmp edx, 0
	je k_i_divides_three
	jmp k_i_not_divides_three
k_i_divides_three:
	add eax, 1
	mov k_tmp, eax ; k_tmp = eax = i / 3
	jmp k_i_end
k_i_not_divides_three:
	mov ebx, ebp ; ebx = i
	add ebx, 1   ; ebx = i + 1
	mov eax, ebp ; eax = i
	add eax, esi ; eax = i + j
	cdq          ; Расширение eax
	idiv ebx     ; eax = eax / ebx = (i + j) / (i + 1)
	mov ebx, 5   ; ebx = 5
	imul ebx     ; eax = eax * ebx = 5 * (i + j) / (i + 1)
	add eax, 1   ; eax = eax + 1 = 5 * (i + j) / (i + 1) + 1
	mov k_tmp, eax ; k_tmp = eax = 5 * (i + j) / (i + 1) + 1

	jmp k_i_end
k_i_end:
	popad
	mov eax, k_tmp
	ret 8
k endp


start: 
    ; Вводим x, y, z
	push offset n
	push offset m
	push offset h
	push offset input_str
	call crt_scanf
	add esp, 4*4

	movsx eax, m
	push eax
	push offset x
	call input

	movsx eax, m
	push eax
	push offset y
	call input

cycle_i:
	mov eax, i
	movsx ebx, m
	cmp eax, ebx
	je cycle_i_end

	mov j, 0
cycle_j:
	mov eax, j
	movsx ebx, n
	cmp eax, ebx
	je cycle_j_end

	mov esi, i
	mov ax, x[esi * 2]
	cwde 
	mov ebp, eax ; Записываем в ebp = xi
	
	mov esi, i
	mov ax, y[esi * 2]
	cwde 
	mov esi, eax ; Записали в esi = yi

	push j
	push i
	call k
	mov ebx, eax ; ebx = k(i, j)
	mov eax, ebp ; eax = xi
	cdq
	idiv ebx     ; eax = eax / ebx = xi / k(i, j)
	mov ecx, eax  ; ecx = eax = xi / k(i, j)

	mov ebx, ebp  ; ebx = xi
	imul ebx, ebx ; ebx = ebx * ebx = xi ^ 2
	mov eax, esi  ; eax = esi = yi
	imul eax, esi ; eax = eax * yi = yi^2
	imul eax, esi ; eax = eax * yi = yi^3
	imul eax, ebp ; eax = eax * xi = yi^3 * xi
	imul eax, i   ; eax = eax * i  = yi^3 * xi * i
	add eax, 6    ; eax = eax + 6  = yi^3 * xi * i + 6
	cdq
	idiv ebx  ; eax = eax / ebx = (yi^3 * xi * i + 6) / (xi ^ 2)
	sub ecx, eax ; ecx = xi / k(i, j) - (yi^3 * xi * i + 6) / (xi ^ 2)
	add result, ecx ; Складываем наши вычисления в результат

	inc j ; j++
	jmp cycle_j ; Топаем к началу цикла
cycle_j_end:
	inc i
	jmp cycle_i
cycle_i_end:

	push result
	push offset output_str
	call crt_printf
	add esp, 8

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
