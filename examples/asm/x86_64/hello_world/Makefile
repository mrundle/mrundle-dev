all: clean hello_world

hello_world: %: %.asm
	@nasm -f elf $<
	@ld -m elf_i386 -s -o $@ *.o
	@./$@ ||:

clean:
	@rm -f *.o hello_world
