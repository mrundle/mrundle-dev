# Source

Transcribed from https://www.tutorialspoint.com/assembly_programming

# Overview

An assembly program can be divided into three sections.
1) **section.data** - used for declaring initialized data or constants. This data does not change at runtime. You can declare various constant values, file names, buffer sizes, etc. in this section.
2) **section.bss**  - used for declaring variables
3) **section.text** - used for keeping the actual code; must begin with the declaration "global _start", which tells the kernel where the program execution begins

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

1) **Data segment**. Represented by .data section and the .bss. The .data section is used to declare the memory region where data elements are stored for the program. This section cannot be expanded after the data elements are declared, and it remains static throughout the program. The .bss section is also a sstatic memory section that contains buffers for data to be declared later in the program. This buffer memory is zero-filled.

2) **Code segment**. Represented by the .text section. This defines an area in memory that stores the instruction codes. This is also a fixed area.

3) **Stack**. This segment contains data values passed to functions and procedures within the program.

# Registers

Processor operations mostly; involve processing data. This data can be stored in memory and accessed from thereon. However, reading data from and storing data into memory slows down the processor, ass it involves complicated processes of sending the data request across the control bus and into the memory storage unit and getting the data through the same channel.

To speed up the processor operations, thet processor includes some internal memory storage locations called *registers*. 

The registers store data elements for processing without having to access the memory. A limited number of registers are build into the processor chip.

## Processor Registers

There are ten 32-bit and six 16-bit processor registers in IA-32 architecture. The registers are grouped into three categories:

1) General registers
2) Control registers
3) Segment registers

The general registers are further divided into the following groups:

1) Data registers
2) Pointer registers
3) Index registers

## Data Registers

Four 32-bit data registers are used for arithmetic, logical, and other operations. These 32-bit registers can be used in three ways:

* As complete 32-bit data registers: EAX, EBX, ECX, EDX
* Lower halves of the 32-bit registers can be used as four 16-bit data registers: AX, BX, CX, DX
* Lower and higher halves of the above-mentioned four 16-bit registers can be used as eight 8-bit data registers: AH, AL, BH, BL, CH, CL, DH, and DL

    31             16        8      0
     --------------------------------
    | EAX           |  AH    |  AL  |  AX  Accumulator
    |--------------------------------
    | EBX           |  BH    |  BL  |  BX  Base
    |--------------------------------
    | ECX           |  CH    |  CL  |  CX  Counter
    |--------------------------------
    | EDX           |  DH    |  DL  |  DX  Data
    |--------------------------------

Some of these data registers have specific use in arithmetical operations.

**AX** is the **primary accumulator**. It is used in input/output and most arithmetic instructions. For example, in multiplication operation, one operand is stored in AX or AX or AL register according to the size of the operand

**BX** is known as the **base register**, as it could be used in indexed addressing.

**CX** is known as the **count register**, as the ECX, CX registers store the loop count in iterative operation.

**DX** is known as the **data register**. It is also used in input/output operations. It is also used with the AX register along with DX for multiplication and division operations involving large values

## Pointer Registers

The pointer registers are 32-bit EIP, ESP, and EBP registers and corresponding 16-bit right portions IP, SP, and BP. There are three categories of pointer registers. There are three categories of pointer registers:

* **Instruction Pointer (IP)** - The 16-bit IP register stores the offset address of the next instruction to be executed. IP in association with the CS register (as CS:IP) gives the complete address of the current instruction in the code segment.

* **Stack Pointer (SP)** - The 16-bit SP register provides the offset value within the program stack. SP in association with the SS register (SS:SP) refers to the current position of data or address within the program stack.

* **Base Pointer (BP)** - The 16-bit BP register mainly helps in referencing the parameter variables passed to a subroutine. The address in SS register is combined with the offset in BP to get the location of the parameter. BP can also be combined with DI and SI as a base register for special addressing.

```
    31             16               0
     --------------------------------
    | ESP           | SP            |  Stack Pointer
     --------------------------------
    | EBP           | BP            |  Base Pointer
     --------------------------------
```

## Index Registers
