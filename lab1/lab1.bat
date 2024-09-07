del lab1.exe
set masm32_path=C:\masm32
%masm32_path%\bin\ml /c /coff /I "%masm32_path%\include" lab1.asm
%masm32_path%\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:%masm32_path%\lib lab1.obj
pause
lab1.exe
pause
