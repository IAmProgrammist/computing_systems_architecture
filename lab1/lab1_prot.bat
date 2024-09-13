del lab1_prot.exe
set masm32_path=C:\masm32
%masm32_path%\bin\ml /c /coff /I "%masm32_path%\include" lab1_prot.asm
%masm32_path%\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:%masm32_path%\lib lab1_prot.obj
pause
lab1_prot.exe
pause
