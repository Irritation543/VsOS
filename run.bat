@echo off
set "PATH=C:\msys64\ucrt64\bin;%PATH%"
if not exist vsos.bin (
    echo vsos.bin not found! Run build.bat first.
    pause
    exit /b 1
)
echo Starting VsOS in QEMU...
qemu-system-i386 -display sdl -vga std -audiodev dsound,id=audio0 -machine pc,pcspk-audiodev=audio0 -device AC97,audiodev=audio0 -kernel vsos.bin
pause
