# x86_asm_exercises

These are a series of Linux exercises on x86 assembly.

## How to compile

### In a 32 bit system

	as source.c -o source.o
	ld source.o -o source

### In a 64 bit system

	as source.c -o source.o --32
	ld source.o -o source -m elf_i386
