@Authors: Paulo Queiroz de Carvalho, Rita Kassiane Santos dos Santos e Rodrigo Damasceno Sampaio
@Curricular component: MI-Sistemas Digitais (TEC499) 
@Concluded in: 04/04/2022
@We declare that this code has been prepared by us individually and does not contain any
@Code snippet from another colleague or author, such as from books and
@Handouts, and electronic pages or documents from the Internet. Any code snippet
@By someone other than ours is highlighted with a citation to the author and source
@Of the code, and I am aware that these snippets will not be considered for evaluation purposes.

@---------------------------------------------------------------------------------------------------------------------

@ Macro for printing a given value into a register sent to it
.macro	print	valor
	mov	r6, \valor
	ldr	r3, =num
	mov 	r5, #32

lp:	lsls	r6, #1
	bcs	if
	mov	r4, #0x30
	b	end

if:	mov	r4, #0x31

end:	str	r4, [r3]

	@ Print num
	mov     r0, #1
	ldr	r1, =num
	mov	r2, #1
	mov	r7, #4
	svc	0
    	
	@ Test loop
	subs	r5, #1
	bne	lp
    
	mov	r0, #1
	ldr	r1, =enter
	mov     r2, #1
    	mov	r7, #4  
    	svc	0
.endm

.data
	num:	.word 0x0
	enter:	.ascii "\n"

@---------------------------------------------------------------------------------------------------------------------
@ r0, r1, r2 Dados para o print
@ r3 endereço de num (variavel)
@ r4 Recebe o valor a imprimir para avaliar o proximo bit a ser impresso
@ r5 contador for
@ r6 Numero impresso
@ r7 syscall
@---------------------------------------------------------------------------------------------------------------------
