set app_name=%~n0
set masm32_path=C:\masm32

%masm32_path%\bin\ml /c /coff /I "%masm32_path%\include" %app_name%.asm
%masm32_path%\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:%app_name%.def /LIBPATH:%masm32_path%\lib %app_name%.obj