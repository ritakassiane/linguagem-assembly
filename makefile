all: UartDateL.o
	ld -o UartDateL UartDateL.o

UartDateL.o: UartDateL.s
	as -o UartDateL.o UartDateL.s
	

# a receita manda excluir todos os arquivos com extensรฃo .o, os de backup *~ e o arquivo binรกrio printy no diretรณrio atual.

clean:
	rm -rf *.o *~ UartDateL
