all: clean example

example: %: %.asm
	@nasm -f elf $<
	@ld -m elf_i386 -s -o $@ *.o
	@./$@ ||:

clean:
	@rm -f *.o example
