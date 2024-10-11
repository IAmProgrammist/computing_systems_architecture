set app_name=%~n0
del %app_name%.exe
set masm32_path=C:\masm32
%masm32_path%\bin\ml /c /coff /I "%masm32_path%\include" %app_name%.asm
%masm32_path%\bin\link /SUBSYSTEM:CONSOLE /LIBPATH:%masm32_path%\lib %app_name%.obj
pause
%app_name%.exe
pause
