nasm -f elf64 -o donut.o donut.asm
ld -o donut donut.o -lm -dynamic-linker /lib64/ld-linux-x86-64.so.2