nasm -f win64 test.asm -o test.o
ld test.o -o test.exe -l kernel32 -l user32
test.exe