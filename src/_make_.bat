@echo off

set ROM=GameOfLife

..\bin\ASM68K.EXE /m /p ..\md\md.asm, %ROM%.md, , listings.lst
echo.
..\bin\ROMPAD.EXE %ROM%.md 255 0
..\bin\FIXHEADR.EXE %ROM%.md
echo.

pause