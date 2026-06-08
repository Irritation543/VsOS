@echo off
echo Installing GCC toolchain via MSYS2...
set CHERE_INVOKING=yes
set MSYSTEM=UCRT64
C:\msys64\usr\bin\pacman.exe -S --noconfirm mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-nasm
echo.
echo Done! You can now run build.bat
pause
