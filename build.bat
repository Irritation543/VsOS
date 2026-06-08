@echo off
setlocal

set "PATH=C:\msys64\ucrt64\bin;C:\msys64\usr\bin;%PATH%"

where gcc >nul 2>&1
if %ERRORLEVEL% NEQ 0 ( echo GCC not found! & exit /b 1 )

echo Building VsOS GUI...
echo.

if not exist obj mkdir obj

echo [GEN] kernel\font.h
python tools\fontgen.py

echo [GEN] kernel\wallpaper.h
python wally.py

echo [GEN] kernel\start_logo.h
python tools\logo2c.py

echo [GEN] sounds
python sounds\gen_sounds.py

echo [ASM] boot\boot.asm
nasm -f win32 boot\boot.asm -o obj\boot.o || exit /b

echo [ASM] arch\i386\io.asm
nasm -f win32 arch\i386\io.asm -o obj\io.o || exit /b

for %%f in (kernel\*.c commands\*.c) do (
    echo [CC] %%f
    gcc -m32 -ffreestanding -fno-builtin -fno-stack-protector -fno-common -Wall -Wextra -Ikernel -Iarch\i386 -I. -c %%f -o obj\%%~nf.o || exit /b
)

for %%f in (kernel\*.cpp commands\*.cpp) do (
    echo [CXX] %%f
    g++ -m32 -ffreestanding -fno-builtin -fno-stack-protector -fno-exceptions -fno-rtti -fno-common -Wall -Wextra -Ikernel -Iarch\i386 -I. -c %%f -o obj\%%~nf.o || exit /b
)

echo [LD] vsos.pe
g++ -m32 -T linker.ld -nostdlib "-Wl,--image-base=0" -o vsos.pe obj\*.o || exit /b

echo [OBJCOPY] vsos.bin
objcopy -O elf32-i386 vsos.pe vsos.bin || exit /b

del vsos.pe
echo.
echo Build successful: vsos.bin
endlocal
