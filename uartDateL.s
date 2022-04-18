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
.equ pagelen, 4096				@ Memory page size				
.equ PROT_READ, 1				@ Read mode for mapping
.equ PROT_WRITE, 2				@ Write mode for mapping
.equ MAP_SHARED, 1				@ Lets you share the mapping with other parties
.equ S_RDWR, 0666				@ RW acess rights
.equ O_RDWR, 0					@ read mode for devmen
.equ sys_open, 5 				@ Open and possibly create a file
.equ sys_mmap2, 192 				@ Map files or devices into memory

.equ UART_DR, 0x0				@ Data Register
.equ UART_FR, 0x18				@ Flag Register
.equ UART_IBRD, 0x24				@ Integer Baud Rate Divisor
.equ UART_FBRD, 0X28				@ Fractional Baud Rate Divisor
.equ UART_LCRH, 0X2c				@ Line Control Register
.equ UART_CR, 0X30				@ Control Register
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

	@ Mem protection options
	mov 	r2, #(PROT_READ + PROT_WRITE)	@ Opening mode both read and write
	mov 	r3, #MAP_SHARED 		@ Mem share options
	mov 	r0, #0 			@ Let linux choose a virtual address
	mov 	r7, #sys_mmap2			@ Linux mmap2 service system call
	svc 	0 				@ Call Linux to mapping
	mov 	r8, r0 			@ keep the returned virt addr
	
@--------------------------------------------------------------------------------------------------------------------

	@ Send data
	@ Loop enquanto o fifo estiver cheio
putlp:	
	ldr	r2, [r8, #UART_FR]		@ Load data from UART Flag Register into register 2
	tst	r2, #UART_TXFF			@ Test both operands to confirm that the FIFO is full ( Transmit FIFO is Full)
	bne	putlp				@ If the FIFO is, it returns to the beginning of the loop, if not, it goes to the next line of execution.
	
	mov	r0, #0b11111111		@ Moves the sequence of bits with value 1 to register 0
	bic	r1, r0				@ Bit clear data from register 0 to register 1
	mov	r0, #0b11001010		@ Moves the bit string (equivalent to the data we are sending in binary)
	add	r1, r0				@ Add values from register 0 to register 1
	str	r1, [r8, #UART_DR]		@ Write the value of register 1 to the memory address of the UART Data Register
	
	@ Wait for submission to finish
NTermi: ldr 	r1, [r8, #UART_FR]		@ Load data from UART Flag Register into register 1
	and 	r1, #0b1000			@ Performs and operation, to reset all bits except the position with bit 1 of the passed sequence
	cmp	r1, #0				@ Compares the value of register 1 with the value 0
	bne	NTermi				@ If the comparison result is different from 0, it means that the shipment has not finished yet.

@--------------------------------------------------------------------------------------------------------------------

	@ Receive data
	@ Checking receipt FIFO
	ldr	r1, [r8, #UART_FR]		@ Load data from UART Flag Register into register 2
	and	r1, #0b10000			@ Performs and operation, to reset all bits except the position with bit 1 of the passed sequence
	cmp	r1, #0				@ Compares the value of register 1 with the value 0
	bne	exit				@ If the result is different from 0, it means that there is a data and it will be printed on the screen, otherwise it is diverted to the output

	ldr 	r1, [r8, #UART_DR]		@ Load data from UART Data Register into register 2
	print	r1				@ We call the macro we created to print the data from register 1 to the screen

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


