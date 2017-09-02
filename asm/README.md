# Source

Transcribed from https://www.tutorialspoint.com/assembly_programming

# Overview

An assembly program can be divided into three sections.
1) section.data - used for declaring initialized data or constants. This data does not change at runtime. You can declare various constant values, file names, buffer sizes, etc. in this section.
2) section.bss  - used for declaring variables
3) section.text - used for keeping the actual code; must begin with the declaration "global _start", which tells the kernel where the program execution begins

Comments begin with a semicolon.

Assembly language programs consist of three types of statements.
1) Executable instructions or instructions. Tell the processor what to do. Each consists of an operation code ("opcode"), which generates one machine language instruction.
2) Assembler directives or pseudo-ops. Tell the assembler about various aspects of the assembly process. These are non-executable and do not generate machine language instructions
3) Macros. Essentially a text substitution mechanism.

# Syntax
Statements are entered on statement per line following this format:

   [label]  mnemonic  [operands]  [;comment]

The fields in square brackets are optional. A basic instruction has two parts, the first one ins the name of the instruction (or the mnemonic) to be executed, and the second are the operands or parameters of the command.

Examples of some typical assembly language statements:

    INC COUNT       ; Increment the memory variable COUNT
    MOV TOTAL, 48   ; Transfer the value 48 in the memory TOTAL
    ADD AH, BH      ; Add the content of the BH register into the AH register
    AND MASK1, 128  ; Perform AND operation on the variable MASK1 and 128
    ADD MARKS, 10   ; Add 10 to the variable MARKS
    MOV AL, 10      ; Transfer the value 10 into the AL register

# Hello World

The following assembly language code displays the string 'Hello World' on
the screen.

    section	.text
       global _start     ;must be declared for linker (ld)
        
    _start:	            ;tells linker entry point
       mov	edx,len     ;message length
       mov	ecx,msg     ;message to write
       mov	ebx,1       ;file descriptor (stdout)
       mov	eax,4       ;system call number (sys_write)
       int	0x80        ;call kernel
        
       mov	eax,1       ;system call number (sys_exit)
       int	0x80        ;call kernel

    section	.data
    msg db 'Hello, world!', 0xa  ;string to be printed
    len equ $ - msg     ;length of the string

To compile and run, write that to hw.asm and execute:

	nasm -f elf hello.asm
	ld -m elf_i386 -s -o hello hello.o

Output:

    Hello, world!


# Memory Segments

We have already covered the three sections of an assembly program. These sections represent various memory segments as well. Interestingly, you can replace the "section" keyword with "segment" and get the same result. I.e.:

    segment .text
        global _start        

A segmented memory model divides the system memory into groups of independent segments referenced by pointers located in the segment registers. Each segment is used to contain a specific type of data. One segment is used to contain instruction codes, another segment stores data elements, and a third segment keeps track of the program stack. 

In light of the above section, we can specify various memory segments as:

1) Data segment. Represented by .data section and the .bss. The .data section is used to declare the memory region where data elements are stored for the program. This section cannot be expanded after the data elements are declared, and it remains static throughout the program. The .bss section is also a sstatic memory section that contains buffers for data to be declared later in the program. This buffer memory is zero-filled.

2) Code segment. Represented by the .text section. This defines an area in memory that stores the instruction codes. This is also a fixed area.

3) Stack. This segment contains data values passed to functions and procedures within the program.


