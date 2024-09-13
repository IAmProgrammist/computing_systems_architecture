.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include msvcrt.inc
include user32.inc
includelib	kernel32.lib
includelib	msvcrt.lib
includelib	user32.lib
 
.data
	a DD 30201, 30201h ; Массив a из 4-байтовых чисел 30201 и 30201h
	b DB 43h, 0F3h, 0F3h, 0E5h ; Массив b из однобайтных шестнадцатеричных чисел 
	DF 1500 ; Неименованная зона с 6-байтовым числом
	DD 1.5, 1.6, 1.9, -1.9 ; Неименованный массив из 4-байтовых вещественных чисел
	t DQ 0E7D32A1h ; t содержащее 8-байтовое шестнадцатеричное число
	stra DB 16 dup(1) ; Строка stra с 16 1-байтовыми символами 1	
        out_buffer DB 128 dup(0) ; Строка out_buffer
        a_name db "a", 0
        b_name db "b", 0
        unknown1_name db "U_1", 0
        unknown2_name db "U_2", 0
        t_name db "t", 0
        stra_name db "stra", 0        
	caption DB "Variables introduced:", 0
	str_fmt   DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10 
        str_fmt_2 DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10
        str_fmt_3 DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10
        str_fmt_4 DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10 
        str_fmt_5 DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10
	str_fmt_6 DB "%s", 9, "%p", 9, "%p", 9, "%d", 13, 10, 0

.code
start:
	; Аргументы передаются в стек в обратном порядке
	; Шестая
	push 16				; Размер stra
	push offset stra + 16		; Конечный адрес stra
	push offset stra	        ; Начальный адрес stra
	push offset stra_name		; Указатель на stra

	; Пятая
	push 8	; Размер t
	push offset t + 8		; Конечный адрес t
	push offset t			; Начальный адрес t
	push offset t_name		; Имя t

	; Четвёртая
	push 16	                        ; Размер unknown2_name
	push offset t - 1		; Конечный адрес unknown2_name
	push offset t - 17		; Начальный адрес unknown2_name
	push offset unknown2_name	; Имя unknown2_name

	; Третья
	push 6	                        ; Размер unknown1_name
	push offset b + 7		; Конечный адрес unknown1_name
	push offset b + 1		; Начальный адрес unknown1_name
	push offset unknown1_name	; Имя unknown1_name

	; Вторая
	push 4	                        ; Размер b
	push offset b + 4		; Конечный адрес b
	push offset b    		; Начальный адрес b
	push offset b_name      	; Имя b

	; Вторая
	push 8	                        ; Размер a
	push offset a + 8		; Конечный адрес a
	push offset a    		; Начальный адрес a
	push offset a_name      	; Имя a

	push offset str_fmt		; Адрес строки формата

	push offset out_buffer ; Буфер, в который будет печататься строка
	call crt_sprintf
	add esp, 4*26

	push offset out_buffer 	
        call crt_puts	; puts(out_buffer)	
        add esp, 4*1


;После вызова функций с приставкой «crt» нужно обязательно очищать стек!
;Для печати в окно использовать функцию MessageBoxA:

	push 0			; Тип окна
	push offset caption	; Заголовок окна
	push offset out_buffer	; Сообщение
	push 0			; Дескриптор окна
	call MessageBoxA	


	call crt__getch 	; Задержка ввода, getch()
	; Вызов функции ExitProcess(0)
	push 0		; Поместить аргумент функции в стек
	call ExitProcess 	; Выход из программы
end start
