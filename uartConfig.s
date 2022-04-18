@Authors: Paulo Queiroz de Carvalho, Rita Kassiane Santos dos Santos e Rodrigo Damasceno Sampaio
@Curricular component: MI-Sistemas Digitais (TEC499) 
@Concluded in: 04/04/2022
@We declare that this code has been prepared by us individually and does not contain any
@Code snippet from another colleague or author, such as from books and
@Handouts, and electronic pages or documents from the Internet. Any code snippet
@By someone other than ours is highlighted with a citation to the author and source
@Of the code, and I am aware that these snippets will not be considered for evaluation purposes.

.include "macros.s"

@---------------------------------------------------------------------------------------------------------------------
.equ pagelen, 	4096				@ Memory page size				
.equ PROT_READ,	1			@ Read mode for mapping
.equ PROT_WRITE,2				@ Write mode for mapping
.equ MAP_SHARED,1				@ Lets you share the mapping with other parties
.equ S_RDWR, 	0666				@ RW acess rights
.equ O_RDWR, 	0				@ read mode for devmen
.equ sys_open, 	5 			@ Open and possibly create a file
.equ sys_mmap2,	192 			@ Map files or devices into memory
.equ UART_DR, 	0x0				@ Data Register
.equ UART_FR, 	0x18				@ Flag Register
.equ UART_IBRD, 0x24				@ Integer Baud Rate Divisor
.equ UART_FBRD, 0X28				@ Fractional Baud Rate Divisor
.equ UART_LCRH, 0X2c				@ Line Control Register
.equ UART_CR, 	0X30				@ Control Register
.equ UART_TXFF, (1<<5)				@ Transmit FIFO is Full
@---------------------------------------------------------------------------------------------------------------------
	.align  2
device:
      .asciz  "/dev/mem"

.global _start

.align  2
_start:
@---------------------------------------------------------------------------------------------------------------------
	@ Memory mapping process
	@ Dev/mem opening process, setting register parameters (r0, r1, r2) for linux call
	ldr 	r0, devmem			@ Name of the file we want to open, make a load register for r0
	ldr 	r1, flag			@ File open mode
	ldr 	r2, openMode			@ Access mode and rights, for the user
	mov 	r7, #sys_open			@ Linux open system call
	svc 	0				@ Call Linux to read
	mov 	r4, r0		 		@ The result of the call is put in register 0, we move its result to register 4
	
	@ Mem mmap
	ldr 	r5, addr 			@ Address we want (physical memory ) / 4096
	mov 	r1, #pagelen 			@ Size of mem we want

	mov 	r2, #(PROT_READ + PROT_WRITE)	@ Opening mode both read and write
	mov 	r3, #MAP_SHARED 		@ Mem share options
	mov 	r0, #0 			@ Let linux choose a virtual address
	mov 	r7, #sys_mmap2			@ Linux mmap2 service system call
	svc 	0				@ Call Linux to mapping
	mov 	r8, r0 			@ Keep the returned virt addr
	
@--------------------------------------------------------------------------------------------------------------------

	@ UART configuration and data submission process
	
UART:	@ Disabling the UART
	mov 	r1, #0				@ Moves the value 0 to register 1, so that it is possible to disable all uart
	str	r1, [r8, #UART_CR]		@ Store Register from the value stored in register 1, to the UART Control Register >>
						@>> Using the virtual memory address we have in r8 plus the UART_CR offset

	@ Loop to wait for uart to finish the current transmission, if exist
loop:	ldr 	r1, [r8, #UART_FR]		@ Load the data from the Flag Register
	and 	r1, #0b1000			@ Resets all bits except the one in the given position (which refers to Buzzy)
	cmp	r1, #0				@ Compares whether or not the result is 0
	bne	loop				@ Returns to loop if result is not 0
		
	@ Disabling the FIFO (FEN in Line Control Register, LCRH)
	mov	r0, #1				@ Move the value 1 to register 0, so that you can later disable FIFO
	lsl	r0, #4				@ It does a 4-bit shift in register 0 where we previously stored the value 1, because it is in the 4th bit of the UART_LCRH that we want to change
	ldr	r1, [r8, #UART_LCRH]		@ Load data from Line Control Register
	bic	r1, r0				@ Bit clear data from register 0 to register 1
	str	r1, [r8, #UART_LCRH]		@ Write the new value of register 1 to the respective address of the Line Control Register
	
	@ Configuring the UART, passing the number of data bits, number of stop bits and parity
	ldr	r1, [r8, #UART_LCRH]		@ Load data from Line Control Register
	mov 	r0, #0b1101110			@ Moves a sequence of bits to register 0, where positions with bits 1 will be the positions that will change in the UART_LCRH
	bic 	r1, r0				@ Bit clear data from register 0 to register 1
	mov	r0, #0b1001010			@ 7 Bts | 2 StopBt | Par. impar | Par. Abilitda 
	add	r1, r0				@ Add values from register 0 to register 1
	str 	r1, [r8, #UART_LCRH]		@ Write the value of register 1 in the respective address of the Line Contrl Register
	
	@ Configuring the Baud Rate
	@(3Mhz/ (14400*16)) = 212,63		@ Calculate to find the BAUDDIV ( UARTCLK/ (16 x BaudRate)>> 
						@ >>Value referring to the BAUDDIV in binary, whose entire part will be saved in the IBRD and the fractional part in the FBRD
	mov	r0, #212			@ Move the value referring to the integer part to register 0
	str	r0, [r8, #UART_IBRD]		@ Write the value of register 0 to the Integer Baud Rate Divider
	mov	r0, #63			@ Moves the value referring to the fractional part to register 0
	str	r0, [r8, #UART_FBRD]		@ Write the value of register 0 to Fractional Baud Rate Divider
	
	@ Enabling the UART and streaming
	mov 	r1, #0b11			@ Moves the 2-bit string with value 1
	lsl 	r1, #8				@ Does an 8-bit shift
	add	r1, #1				@ Add immediate value 1 to register 1
	str	r1, [r8, #UART_CR]		@ Write the value of register 1 to the UART Control Register
	
	@ Enabling FIFO
	mov	r0, #1				@ Move o valor 1 para o registrador 0
	lsl	r0, #4				@ It does a 4-bit shift in register 0 where we previously stored the value 1, because it is in the 4th bit of the UART_LCRH that we want to change
	ldr	r1, [r8, #UART_LCRH]		@ Load data from Line Control Register
	orr	r1, r0				@ Do an "or" operation with registers 0 and 1
	str	r1, [r8, #UART_LCRH]		@ Write the new value of register 1 to the respective address of the Line Control Register

	@ Exit and termination of processes
exit:	
	mov 	r0, #0				@ Move value 0 to register 0
	mov 	r7, #1				@ Linux Exit system call
	svc	0				@ Call Linux to exit

@--------------------------------------------------------------------------------------------------------------------

	@ Variables used in the code, their meaning is described in the lines where they were used.
.align  2
devmem: 
	.word device				
addr: 
	.word 0x20201				
openMode:
	.word 0					
flag:
	.word 0666


