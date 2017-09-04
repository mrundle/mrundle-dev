Table of Contents
=================

   * [Source](#source)
   * [Table of Contents (TOC) Generator](#table-of-contents-toc-generator)
   * [Overview](#overview)
   * [Syntax](#syntax)
   * [Hello World](#hello-world)
   * [Memory Segments](#memory-segments)
   * [Registers](#registers)
      * [Processor Registers](#processor-registers)
      * [Data Registers](#data-registers)
      * [Pointer Registers](#pointer-registers)
      * [Index Registers](#index-registers)
      * [Control Registers](#control-registers)
      * [Segment Registers](#segment-registers)
      * [Example](#example)
   * [Linux System Calls](#linux-system-calls)
      * [Example](#example-1)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Source

Transcribed from https://www.tutorialspoint.com/assembly_programming

# Table of Contents (TOC) Generator

```
# From https://github.com/ekalinin/github-markdown-toc
wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
chmod a+x gh-md-toc
./gh-md-toc README.md
```

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
```
    [label]  mnemonic  [operands]  [;comment]
```

The fields in square brackets are optional. A basic instruction has two parts, the first one ins the name of the instruction (or the mnemonic) to be executed, and the second are the operands or parameters of the command.

Examples of some typical assembly language statements:

```
INC COUNT       ; Increment the memory variable COUNT
MOV TOTAL, 48   ; Transfer the value 48 in the memory TOTAL
ADD AH, BH      ; Add the content of the BH register into the AH register
AND MASK1, 128  ; Perform AND operation on the variable MASK1 and 128
ADD MARKS, 10   ; Add 10 to the variable MARKS
MOV AL, 10      ; Transfer the value 10 into the AL register
```

# Hello World

The following assembly language code displays the string 'Hello World' on
the screen.

```
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
```

To compile and run, write that to hw.asm and execute:

```
nasm -f elf hello.asm
ld -m elf_i386 -s -o hello hello.o
```

Output:

```
Hello, world!
```

# Memory Segments

We have already covered the three sections of an assembly program. These sections represent various memory segments as well. Interestingly, you can replace the "section" keyword with "segment" and get the same result. I.e.:

```
segment .text
    global _start        
```

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

```
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
```

Some of these data registers have specific use in arithmetical operations.

**AX** is the **primary accumulator**. It is used in input/output and most arithmetic instructions. For example, in multiplication operation, one operand is stored in EAX, AH, or AL register according to the size of the operand

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
    | ESP           | SP            |  Stack Pointer (SP)
     --------------------------------
    | EBP           | BP            |  Base Pointer (BP)
     --------------------------------
```

## Index Registers

The 32-bit index registers, ESI and EDI, and their 16-bit rightmost portions, SI and DI, are used for indexed addressing and sometimes used in addition and subtraction. There are two sets of index pointers:

* **Source Index (SI)** - Used as source index for string operations
* **Destination Index (DI)** - Used as destination index for string operations

```
    31             16               0
     --------------------------------
    | ESI           | SI            |  Source Index (SI)
     --------------------------------
    | EDI           | DI            |  Destination Index (DI)
     --------------------------------
```

## Control Registers

The 32-bit instruction pointer register and the 32-bit flags register combined are considered the control registers. 

Many instructions involve comparisons and mathematical calculations and change the status of the flags and some other conditional instructions test the value of these status flags to take the control flow to another location.

The common flag bits are:

* **Overflow Flag (OF)**, indicates the overflow of a high-order (leftmost) bit of data after a signed arithmetic operation.
* **Direction Flag (DF)**, determines the left or right direction for moving or comparing string data. When the DF value is 0, the string operation proceeds left-to-right, and when the value is set to 1, right-to-left.
* **Interrupt Flag (IF)**, determines whether the external interrupts like keyboard entry, etc., are to be ignored or processed. It disables the external interrupt when the value is 0 and enables interrupts when set to 1.
* **Trap Flag (TF)**, allows setting the operation of the processor in single-step mode. The DEBUG program we used sets the trap flag, so we could step through the execution one instruction at a time.
* **Sign Flag (SF)**, shows the sign of the result of an arithmetic operation. This flag is set according to the sign of a data item following the arithmetic operation. The sign is indicated by the high-order of leftmost bit. A positive result clears the value of SF to 0 and a negative result sets it to 1.
* **Zero Flag (ZF)**, indicates the result of an arithmetic or comparison operation. A nonzero result clears the zero flag to 0, and a zero result sets it to 1.
* **Auxiliary Carry Flag (AF)**, contains the carry from bit 3 to bit 4 following an arithmetic operation; used for specialized arithmetic. The AF is set when a 1-byte arithmetic operation causes a carry from bit 3 into bit 4.
* **Parity Flag (PF)**, indicates the total number of 1-bits in the result obtained from an arithmetic operation. An even number of 1-bits clears the parity flag to 0 and an odd number of 1-bits sets the parity flag to 1.
* **Carry Flag (CF)**, contains the carry of 0 or 1 from a high-order (leftmost) bit after an arithmetic operation. It also stores the contents of last bit of a *shift* or *rotate* operation.

The following table indicates the position of flag bits in the 16-bit Flags register:

```
            -----------------------------------------------------------------------
    Flag  : |    |    |    |    | OF | DF |IF |TF |SF |ZF |   |AF |   |PF |   |CF |
            -----------------------------------------------------------------------
    Bit no: | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
            -----------------------------------------------------------------------
```

## Segment Registers

Segments are specific areas defined in a program for containing data, code, and stack. There are three main segments:

* **Code Segment**, contains all instructions to be executed. A 16-bit Code Segment (CS) register stores the starting address of the code segment.
* **Data Segment**, contains data, constants, and work areas. A 16-bit Data Segment register (DS) stores the starting address of the data segment.
* **Stack Segment**, contains data and return addresses of procedures or subroutines. It is implemented as a 'stack' data structure. The Stack Segment (SS) register stores the starting address of the stack.

Apart from the DS, CS, and SS registers, there are other extra segment registers - **ES (extra segment)**, **FS**, and **GS**, which provide additional segments for storing data.

All memory locations within a segment are relative to the starting address of the segment. A segment begins in an address evenly divisible by 16 (or hex 10). So, the rightmost hex digit in all such memory addresses is 0, which is not generally stored in the segment registers.

Because the segment registers store the segments start address, the exact location of data or instruction within the segment needs an *offset value* (or displacement). To reference an in-segment memory location, the processor combines the basse segment address (in the segment register) with the offset value of the location.

## Example

The following simple program illustrates the use of registers in assembly programming. This program displays nine stars on the screen along with a simple message.

```
section	.text
   global _start	 ;must be declared for linker (gcc)
    
_start:	         ;tell linker entry point
   mov	edx,len  ;message length
   mov	ecx,msg  ;message to write
   mov	ebx,1    ;file descriptor (stdout)
   mov	eax,4    ;system call number (sys_write)
   int	0x80     ;call kernel
    
   mov	edx,9    ;message length
   mov	ecx,s2   ;message to write
   mov	ebx,1    ;file descriptor (stdout)
   mov	eax,4    ;system call number (sys_write)
   int	0x80     ;call kernel
    
   mov	eax,1    ;system call number (sys_exit)
   int	0x80     ;call kernel
    
section	.data
msg db 'Displaying 9 stars',0xa ;a message
len equ $ - msg  ;length of message
s2 times 9 db '*'
```

Compile and execute the code:

```
nasm -f elf ex.asm
ld -m elf_i386 -s -o example ex.o
```

Which should output:

```
Displaying 9 stars
*********
```

# Linux System Calls

System calls are APIs for the interface between the user space and the kernel space. We have already used system calls, sys_write and sys_exit, for writing to the screen and exiting from the program, respectively.

To make use of Linux system calls in your assemblky programs, you need to take the following steps:

1. Put the system call number into the EAX register
2. Store the arguments to the system call in the registers EBX, ECX, etc.
3. Call the relevant interrupt (80h).
4. The result is usually returned in the EAX register.

There are six registers that store the arguments of the system call used. These are the EBX, ECX, EDX, ESI, EDI, and EBP registers. They take consecutive arguments, starting with EBX. If there are more than six arguments, then the memory location of the first argumetn is stored in the EBX register.

The following code snippet shows the use of the system call sys_exit:

```
mov     eax,1       ; system call number (sys_exit)
int     0x80        ; call kernel
```

The following code snippet shows the use of the system call sys_write:

```
mov     edx,4       ; message length
mov     ecx,msg     ; message to write
mov     ebx,1       ; file descriptor (stdout)
mov     eax,4       ; system call number (sys_write)
int     0x80        ; call kernel
```

All the syscalls are listed in **/usr/include/asm/unistd.h**, together with their numbers (the value to store in EAX before calling ```int 0x80```).

The following table shows some of the system calls used in this tutorial:

```
%eax    Name        %ebx        %ecx    %edx    %esx    %edi
1       sys_exit    int         -       -       -       -
2       sys_fork    struct      -       -       -       -
                    pt_regs
3       sys_read    unsigned    char *  size_t  -       -
                    int
4       sys_write   unsigned    const   size_t  -       -
                    int         char *  
5       sys_open    const       int     int     -       -
                    char *
6       sys_close   unsigned    -       -       -       -
                    int
```

## Example

The following example reads a number from the keyboard and displays it on the screen:

```
section .data                           ;Data segment
   userMsg db 'Please enter a number: ' ;Ask the user to enter a number
   lenUserMsg equ $-userMsg             ;The length of the message
   dispMsg db 'You have entered: '
   lenDispMsg equ $-dispMsg                 

section .bss           ;Uninitialized data
   num resb 5
	
section .text          ;Code Segment
   global _start
	
_start:                ;User prompt
   mov eax, 4
   mov ebx, 1
   mov ecx, userMsg
   mov edx, lenUserMsg
   int 80h

   ;Read and store the user input
   mov eax, 3
   mov ebx, 2
   mov ecx, num  
   mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
   int 80h
	
   ;Output the message 'The entered number is: '
   mov eax, 4
   mov ebx, 1
   mov ecx, dispMsg
   mov edx, lenDispMsg
   int 80h  

   ;Output the number entered
   mov eax, 4
   mov ebx, 1
   mov ecx, num
   mov edx, 5
   int 80h  
    
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 80h
```

Compile and run:

```
$ nasm -f elf ex.asm
$ ld -m elf_i386 -s -o example ex.o
$ ./example
Please enter a number: 23
You have entered: 23
```
