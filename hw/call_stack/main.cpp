#include <windows.h>
#include <DbgHelp.h>
#include <stdio.h>
#include <locale.h>

#pragma comment(lib, "dbghelp.lib")

// Пример в интернете:
// https://stackoverflow.com/questions/22465253/symgetlinefromaddr-not-working-properly

void print_trace(LPVOID instructionAddress)
{
	printf("Определение имени функции и модуля, которому принадлежит инструкция с адресом 0x%p\n", instructionAddress);
	DWORD flags = GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT;
	
	HMODULE hModule; // Дескриптор модуля

	// Получение начального адреса модуля по адресу инструкции instructionAddress
	if (GetModuleHandleExA(flags, (LPCSTR)instructionAddress, &hModule))
	{
		char module_name[MAX_PATH + 1];

		// Получение имени библиотеки
		GetModuleFileNameA(hModule, module_name, MAX_PATH);
		printf("Начальный адрес модуля: 0x%p\nИмя модуля: %s\n", hModule, module_name);

		DWORD disp = 0; // Смещение относительно начала подпрограммы
		// Поскольку функция SymFromAddr записывает имя найденной процедуры в конце структуры SYMBOL_INFO, нужно
		// сразу после неё расположить буфер для сохранения имени
		struct
		{
			IMAGEHLP_SYMBOL symbolInfo = { };
			char name_buffer[1024];

		} SYMBOL_DATA;
		
		SYMBOL_DATA.symbolInfo.SizeOfStruct = sizeof(IMAGEHLP_SYMBOL); // Размер структуры
		SYMBOL_DATA.symbolInfo.MaxNameLength = 1024;	// Длина буфера для сохранения символьного имени

		//decltype(SymGetSymFromAddr64)* pSymGetSymFromAddr64 = (decltype(SymGetSymFromAddr64)*)(GetProcAddress(LoadLibraryA("dbghelp.dll"), "SymGetSymFromAddr64"));

		// Получение имени функции, которая содержит инструкцию с адресом instructionAddress
		if (SymGetSymFromAddr(GetCurrentProcess(), (DWORD)instructionAddress, &disp,
			&SYMBOL_DATA.symbolInfo))
			 //PUSH offset SD
			 //PUSH offset disp
			 //PUSH 0
			 //PUSH instructionAddress
			 //PUSH hProcess
			 //CALL pSymFromAddr
		{
			printf("Имя подпрограммы: %s, Смещение инструкции в байтах от начала функции: %u\n", SYMBOL_DATA.symbolInfo.Name, disp);

			// Получение номера строки в исходном тексте программы
			// Чтобы можно было получить номер строки, необходимо задать ключ компиляции /LTCG:incremental в параметрах проекта:
			// Компоновщик -> Оптимизация -> Создание кода во время компоновки -> Использовать создание кода во время компоновки (/LTCG)
			IMAGEHLP_LINE line;
			line.SizeOfStruct = sizeof(IMAGEHLP_LINE);
			DWORD displacement;
			if (SymGetLineFromAddr(GetCurrentProcess(), (DWORD)instructionAddress, &displacement, &line))
			{
				printf("Подпрограмма \"%s\" находится в файле \"%s\"\nАдрес: 0x%p\nСмещение инструкции в байтах от начала строки: %d\nСтрока: %d\n", 
					SYMBOL_DATA.symbolInfo.Name, 
					line.FileName, 
					(DWORD_PTR)SYMBOL_DATA.symbolInfo.Address, 
					displacement, 
					line.LineNumber);
			}
			else
			{
				printf("SymGetLineFromAddr64 возвратила код ошибки: %d\n", GetLastError());
			}
		}
		else
		{
			printf("SymGetSymFromAddr64 возвратила код ошибки: %d\n", GetLastError());
		}
	}
}

void main(void)
{
	struct
	{
		IMAGEHLP_SYMBOL symbolInfo = { };
		char name_buffer[1024];

	} SYMBOL_DATA;

	IMAGEHLP_LINE line;
	line.SizeOfStruct = sizeof(IMAGEHLP_LINE);

	printf(R"(
sizeof SYMBOL DATA: %d
SYMBOL DATA ptr: %d 
SizeOfStruct ptr: %d 
MaxNameLength ptr: %d 
symbolInfo ptr: %d 
name_buffer ptr: %d
symbolInfoName: %d

IMAGEHLP_LINE: %d
IMAGEHLP_LINE SizeOfStruct: %d
)", 
		sizeof(SYMBOL_DATA), 
		&SYMBOL_DATA, 
		&SYMBOL_DATA.symbolInfo.SizeOfStruct, 
		&SYMBOL_DATA.symbolInfo.MaxNameLength,
		&SYMBOL_DATA.symbolInfo,
		&SYMBOL_DATA.name_buffer,
		&SYMBOL_DATA.symbolInfo.Address,
		&line,
		&line.LineNumber);

	//SymSetOptions(SymGetOptions() | SYMOPT_LOAD_LINES);

	SymInitialize(GetCurrentProcess(), NULL, TRUE);

	//LPVOID some_instruction = (LPVOID)((DWORD_PTR)&GetTickCount + __rdtsc() % 10000); // Инструкция со случайным адресом

	//print_trace(some_instruction); // Вызов со случайным адресом

	typedef USHORT(WINAPI* CaptureStackBackTraceType)(__in ULONG, __in ULONG, __out PVOID*, __out_opt PULONG);

	CaptureStackBackTraceType pCaptureStackBackTraceType = (CaptureStackBackTraceType)(GetProcAddress(LoadLibraryA("kernel32.dll"), "RtlCaptureStackBackTrace"));

	if (pCaptureStackBackTraceType == NULL)
		return;

	void* callers[1024];
	int count = pCaptureStackBackTraceType(0, _countof(callers), callers, NULL);
	for (int i = 0; i < count; i++) // Перебрать все адреса возврата в стеке
	{
		printf("------- Уровень %d, адрес 0x%p ------- \n", i + 1, callers[i]);
		print_trace(callers[i]);
		puts("\n");
	}
}