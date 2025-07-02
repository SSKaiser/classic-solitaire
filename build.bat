@echo off
nasm -fwin64 .\src\main.asm -o sol.obj -F cv8
gcc -o sol.exe sol.obj -lkernel32 -g
del sol.obj