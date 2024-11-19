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
	q dd 15.0
	num_pow dd 2.0
	print_step db "S = %.6f, n = %.6f", 13, 10, 0
	print_fmt db "%.6f", 13, 10, 0
.code

; Осторожно! В стеке для FPU должно быть свободно 4 элемента для вычислений.
; pow (float x, float y)
pow proc
	pushad

	fld dword ptr [esp + 8 + 8 * 4] ; y получаем из параметров. S(0) = y
	fabs ; y = |y|
	fld dword ptr [esp + 4 + 8 * 4] ; x получаем из параметров. S(0) = x, S(1) = y
	fabs ; x = |x|

	; Вычислим t = ylog_2(x)
	fyl2x ; S(0) = ylog_2(x)
	fxam
	fstsw ax
	sahf
	jz  pow_ok  
	jpe pow_C2is1    ; Если C2 = 1
	jc  pow_is_nan   ; Если получили isNan, то x и y = 0, а значит нужно вернуть 1.
	jmp pow_ok

	pow_C2is1:
	jc    pow_infinity
	jmp pow_ok

	pow_is_nan:
	; У нас infinity может случиться только если у нас x = 0. В этом случае надо бы возвращать 0.
	ffree ST(0)
	fincstp
	fld1
	popad
	ret 8

	pow_infinity:
	; У нас infinity может случиться только если у нас x = 0. В этом случае надо бы возвращать 0.
	ffree ST(0)
	fincstp
	fldz
	popad
	ret 8

pow_ok:
	
	fld1 ; S(0) = 1; S(1) = ylog_2(x)
	fscale ; S(0) = S(0) * 2 ^ S(1); S(1) = ylog_2(x)

	fld1 ; S(0) = 1; S(1) = 2 ^ a; S(2) = ylog_2(x)
	fld ST(2) ; S(0) = ylog_2(x); S(1) = 1; S(2) = 2 ^ a; S(3) = ylog_2(x)
	fprem ; S(0) = ylog_2(x) % 1 = b; S(1) = 1; S(2) = 2 ^ a; S(3) = ylog_2(x)
	f2xm1 ; S(0) = 2 ^ b - 1; S(1) = 1; S(2) = 2 ^ a; S(3) = ylog_2(x)
	faddp ST(1), ST(0) ; S(0) = 2 ^ b; S(1) = 2 ^ a; S(2) = ylog_2(x)
	fmulp ST(1), ST(0) ; S(0) = 2 ^ a * 2 ^ b; S(1) = ylog_2(x)

	fldz                            ; ST(0) = 0; S(1) = 2 ^ a * 2 ^ b; S(2) = ylog_2(x)
	fld dword ptr [esp + 4 + 8 * 4] ; ST(0) = x, ST(1) = 0; S(2) = 2 ^ a * 2 ^ b; S(3) = ylog_2(x)
	fcompp   ; Сравнение x с 0 и выталкивание переменных из стека
	fstsw ax ; Загрузка swr в ax
	sahf     ; Загрузка ah в eflags. Теперь можем сравнивать.
	fld1     ; S(0) = sign_x
	jb pow_x_less_zero
	jmp pow_x_end
pow_x_less_zero:
	fchs   ; S(0) = -S(0) = sign_x
pow_x_end:

	; ST(0) = sign_x; S(1) = 2 ^ a * 2 ^ b; S(2) = ylog_2(x)

	fmulp ST(1), ST(0) ; S(0) = sign_x * 2 ^ a * 2 ^ b; S(1) = ylog_2x
	fxch               ; S(0) = ylog_2x; S(1) = sign_x * 2 ^ a * 2 ^ b
	ffree ST(0)        
	fincstp            ; S(0) = sign_x * 2 ^ a * 2 ^ b
	fldz                            ; S(0) = 0; S(1) = sign_x * 2 ^ a * 2 ^ b
	fld dword ptr [esp + 8 + 8 * 4] ; S(0) = y; S(1) = 0; S(2) = sign_x * 2 ^ a * 2 ^ b
	fcompp ; S(0) = sign_x * 2 ^ a * 2 ^ b
	fstsw ax ; Загрузка swr в ax
	sahf     ; Загрузка ah в eflags. Теперь можем сравнивать.
	jb pow_y_less_zero
	jmp pow_y_end
pow_y_less_zero:
	fld1                 ; S(0) = 1; S(1) = x ^ |y|
	fdivrp ST(1), ST(0)  ; S(0) = 1 / x ^ |y| = x ^ y.
pow_y_end:

	popad
	ret 8
pow endp

start: 
	finit ; Инициализация сопроцессора
	fld1 ; S(1) = n = 1
	fldz ; S(0) = 0 = S (1)

	mov ecx, 50

	cycle:
		sub esp, 16
		fst qword ptr [esp]
		fxch
		fst qword ptr [esp + 8]
		fxch
		mov esi, ecx
		push offset print_step
		call crt_printf
		add esp, 20
		mov ecx, esi

		fld1                 ; ST(0) = 1, ST(1) = S, ST(2) = n
		fld ST(2)            ; ST(0) = n, ST(1) = 1, ST(2) = S, ST(3) = n
		fpatan               ; ST(0) = atan(1 / n), ST(1) = S, ST(2) = n
		faddp ST(1), ST(0)   ; ST(0) = S + atan(1 / n) = S, ST(1) = n
		fld ST(1)            ; ST(0) = n, ST(1) = S + atan(1 / n) = S, ST(2) = n

		sub esp, 44
		fst dword ptr [esp]
		fstp tbyte ptr [esp + 4]
		fstp tbyte ptr [esp + 14]
		fstp tbyte ptr [esp + 24]
		
		sub esp, 8
		mov eax, dword ptr num_pow
		mov ebx, dword ptr q
		mov ebp, dword ptr [esp + 8]
		mov dword ptr [esp], ebp
		mov dword ptr [esp + 4], eax

		call pow             ; ST(0) = n ^ 2, ST(1) = S + atan(1 / n) = S, ST(2) = n

		fstp tbyte ptr [esp + 34]

		fld tbyte ptr [esp + 24]
		fld tbyte ptr [esp + 14]
		fld tbyte ptr [esp + 4]
		fld tbyte ptr [esp + 34]
		add esp, 36

		mov dword ptr [esp], ebx
		fstp dword ptr [esp + 4]
		call pow             ; ST(0) = q^2, ST(1) = n ^ 2, ST(2) = S + atan(1 / n) = S, ST(3) = n
		faddp ST(1), ST(0)   ; ST(0) = n ^ 2 + q ^ 2, ST(1) = S + atan(1 / n) = S, ST(2) = n
		
		fld1                 ; ST(0) = 1, ST(1) = n ^ 2 + q ^ 2, ST(2) = S + atan(1 / n) = S, ST(3) = n
		fld ST(3)            ; ST(0) = n, ST(1) = 1, ST(2) = n ^ 2 + q ^ 2, ST(3) = S + atan(1 / n) = S, ST(4) = n
		fsubrp ST(1), ST(0)  ; ST(0) = n - 1, ST(1) = n ^ 2 + q ^ 2, ST(2) = S + atan(1 / n) = S, ST(3) = n
		fdivrp ST(1), ST(0)  ; ST(0) = (n - 1) / (n ^ 2 + q ^ 2), ST(1) = S + atan(1 / n) = s, ST(2) = n
		faddp ST(1), ST(0)   ; ST(0) = S + atan(1 / n) + (n - 1) / (n ^ 2 + q ^ 2), ST(1) = n
		fxch                 ; ST(0) = n, ST(1) = S + atan(1 / n) + (n - 1) / (n ^ 2 + q ^ 2)
		fld1                 ; ST(0) = 1, ST(1) = n, ST(2) = S + atan(1 / n) + (n - 1) / (n ^ 2 + q ^ 2)
		faddp ST(1), ST(0)   ; ST(0) = n + 1, ST(1) = S + atan(1 / n) + (n - 1) / (n ^ 2 + q ^ 2)
		fxch                 ; ST(0) = S, ST(1) = n + 1
	dec ecx
	jne cycle

	fxch
	ffree ST(0)
	fincstp

	sub esp, 8
	fstp qword ptr [esp]
	push offset print_fmt
	call crt_printf
	add esp, 8

	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start