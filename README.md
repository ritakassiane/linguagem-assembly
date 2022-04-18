# 📌Sitemas Digitias
Entender a ligação entre o hardware e o software é essencial para o desenvolvimento sólido na carreira de um Engenheiro da Computação. Nesse contexto, a linguagem Assembly protagoniza um papel essencial para projetar sistemas digitais ou desenvolver softwares mais eficientes, visto que através desta, é possível  ter controle absoluto sob o hardware. 

A fim de adentrar ao universo do IoT, uma equipe de graduandos em Engenharia da Computação aceitou o contrato para desenvolvimento de um protótipo de sistema digital baseado em um processador ARM, que receberá informações de sensores via UART. Para isso, foi utilizado uma Raspberry Pi Zero e programação em linguagem Assembly.

## 👥Equipe: <br>
* Paulo Queiroz de Carvalho <br>
* Rita Kassiane Santos  <br>
* Rodrigo Damasceno Sampaio <br>

<h1 align="center"> Sumário </h1>
<div id="sumario" style="display: inline_block" align="center">
	<a href="#diagrama"> Diagrama  </a> |
	<a href="#mapeamento"> Mapeamento de memória </a> |
	<a href="#configuracao"> Configurando a UART</a> |
	<a href="#enviando"> Enviando dado</a> |
	<a href="#teste"> Teste </a> |
	<a href="#executar"> Como executar </a> |
	<a href="#conclusao"> Conclusão </a>
</div>

<div id="diagrama">
	<h1> Diagrama </h1>
		<div id="image01" style="display: inline_block" align="center">
		<img src="/diagrama-do-sis.png"/>
		<p>
			Diagrama do sistema desenvolvido
			</p>
		</div>
	
</div>

<div id="mapeamento">
	<h1> Mapeamento de Memória </h1>
			<p>
		A fim de obter o endereço de memória virtual que permitirá acessar os periféricos da raspberry - nesse contexto a UART - , é realizado o mapeamento de memória. Sabendo que no linux tudo é considerado um arquivo, primeiramente realiza-se uma chamada ao sistema (syscall), solicitando que o sistema operacional utilize o caminho "/dev/mem" para abrir o arquivo que fornece o acesso à memória. Posteriormente o retorno do processo contendo as páginas e endereçamentos é salvo no registrador r0 e movido para r4.
Em seguida, carregamos a razão entre o endereço de memória física da GPIO e o número de páginas [Coloca a operação e o valor aqui] no registrador r5 e movemos para r1 o valor equivalente ao tamanho da memória que será usado (nesse contexto, 4096). Subsequentemente, realiza-se as operações para configurar as opções de proteção da memória.
	</p>
	<p> Para isso, configuramos, respectivamente:</p>
	<ul>
				<li>A permissão para os modos de leitura e escrita,</li>
				<li>Compartilhar o mapeamento com outras partes,</li>
<li>Permite-se que o sistema operacional escolha o endereço virtual </li>
<li>Faz uma chamada ao sistema requisitando o serviço mmap2 do Linux, para realizar as configurações implementadas</li>
				<li>Move-se para r8 o endereço de memória virtual retornado</li>
	</ul>
</div>


<div id="configuracao">
	<h1> Configuração </h1>
			<p>
Agora que já obteve-se o endereço da memória é necessário acessar a localização da UART, as quais serão necessárias para configurar e enviar dados. Consultando a documentação do BCM2835 temos a  informação que as linhas de transmissão e recepção podem ser roteadas através dos pinos 14 e 15 da GPIO, respectivamente. Além disso, indica-se que a UART tem 18 registradores, começando em seu endereço base de 2E2010016. No entanto, para a solução desse protótipo, utilizaremos apenas 6 registradores, sendo esses:
	</p>
	<ul>
		<li>UART DATA REGISTER(offset: #0)</li>
		<p>
		Usado para enviar e receber dados serialmente, ou seja, um byte de cada vez. Escrever neste registrador é adicionar um byte ao FIFO de transmissão. 
Outro fato acerca deste registrador é que, embora ele seja seja de 32 bits, apenas os 8 bits menos significativos são usados na transmissão, e 12 bits menos significativos são usados para recepção. Se o FIFO estiver vazio, a UART começará a transmitir o byte imediatamente. Se ele estiver cheio, o último byte no O FIFO será substituído pelo novo byte que é gravado no Data Register. 
Quando esse registrador é lido, ele retorna o byte no topo do FIFO de recebimento, junto com quatro bits de status adicionais para indicar se algum erro foi encontrado. 
Foi utilizado os bits entre 7-0 para acessar o último dado enviado e o dado do byte recebido.
	</ul>
	<ul>
		<li>UART_FR (offset: #18)</li>
		<p>
	O UART Flag Register pode ser lido para determinar o status da UART. Quando vários bytes precisam ser enviados, o sinalizador TXFF deve ser verificado para garantir que o FIFO de transmissão não está cheio antes de cada byte ser escrito no registrador de dados. Ao receber dados, o bit RXFE pode ser usado para determinar se há ou não mais dados a serem lidos do FIFO. 
		</p>
	</ul>
	<ul>
		<li>UART_IBRD e UART_FRD (offset: #24 e #28)</li>
		<p>
	UART_FBRD é a parte fracionária do valor do Baud Rate Divisor e UART_IBRD é a parte inteira. 
		</p>
	</ul>
	<ul>
		<li>UART_LCRH (offset: #2c)</li>
		<p>
É o registrador Line Control. É usado para configurar parâmetros de comunicação e não deve ser alterado até que a UART seja desabilitada escrevendo zero no bit 0 de UART_CR, e o sinalizador BUSY em UART_FR deve estar limpo para indicar que não enta oculpado.
		</p>
	</ul>
	<ul>
		<li>UART_CR (offset: #30)
</li>
		<p>
		A UART Control Register é usada para configurar, habilitar e desabilitar o UART. Para habilitar a transmissão, o bit TXE e o bit UARTEN devem ser configurados para 1. Para habilitar a recepção, o bit RXE e o bit UARTEN devem ser configurados para 1. 
		</p>
	</ul>
	<p>
Em geral, os seguintes passos devem ser usados para configurar ou reconfigurar o UART: <br>
	<ul>
		<li>Desativar o UART</li>
		<p>
Move-se o valor 0 para o registrador 1. Posteriormente realiza um Store Register (str) para arrastar o valor armazenado em R1 para a localização da UART Control register para que seja possível desabilitar toda UART.
	</ul>
	<ul>
		<li>Aguardar o final da transmissão ou recepção do caractere atual</li>
		<p>
Um loop é criado para aguardar a UART finalizar a transmissão de dados atual, caso exista.
		</p>
	</ul>
	<ul>
		<li>Esvaziar o FIFO de transmissão definindo o bit FEN como 0 no Line Control Register.</li>
	</ul>
	<ul>
		<li>Configurar novamente o Control Register.</li>
		<ul>
			<li>
				Número de bits do dado, stop bits e paridade
			</li>
			<p>
				Carrega-se em R1 os dados do Line Control Register. Posteriormente, move-se uma sequência de bits para o registrador 0, onde as posições com bits 1 serão as posições as quais serão alteradas nesse registrador. 
O mnemônico bic(Bit Clear) é utilizado para realizar uma operação AND nos bits de R1 com os complementos dos bits correspondentes no valor R0. Com isso configura-se que o dado enviado deverá ter 7 bits, 2 Stop Bits, será um dado com paridade a qual deve ser ímpar. 
			</p>
		</ul>
		<ul>
			<li>
				Baudrate
			</li>
			<p>
Encontra-se o valor do BAUDDIV (Divisor de Baud Rate) através da expressão:
Frequência de Clock da UART/(16*Baud Rate desejado). Posteriormente, armazena-se o valor inteiro desse resultado no UART_IBRD e a parte fracionária em UART_FBRD. Nesse projeto esse cálculo é aplicado da seguinte maneira:
BAUDDIV = (3Mhz/ (1200*16)) = 156,25 	
			</p>
		</ul>
	</ul>
	<ul>
		<li> Ativar o UART e FIFO</li>
		<p>
Para ativar a UART, é adicionado 1 nos bits UARTEN (bit 0) - responsável por ativar a UART - e TXE (bit 8) - responsável por ativar a transmissão de dados - pertencentes ao registrador UART Control Register.
Posteriormente, deve-se ativar o FIFO. Para isso, deve-se adicionar o valor lógico 1 no bit denominado FEN do registrador Line Control Register. 
		</p>
	</ul>
</div>

<div id="enviando">
	<h1> Enviando e Recebendo dados </h1>

</div>

<div id="teste">
	<h1>Testes</h1>
	<div id="image01" style="display: inline_block" align="center">
			<img src="/MAP001.jpg"/><br>
		<p>
		Dado: 11001010
		8 Bts
		2 SB
		Paridade: Par
		</p>
	</div>
	<div id="image02" style="display: inline_block" align="center">
		<img src="/MAP002_1.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		2 SB
		Paridade: Par;
		Parity Disable;
		</p>
	</div>
	<div id="image03" style="display: inline_block" align="center">
		<img src="/MAP003.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		2 SB;
		Paridade: Impar		
		</p>
	</div>
	<div id="image04" style="display: inline_block" align="center">
		<img src="/MAP004.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		1 SB;
		Paridade: Par		
		</p>
	</div>
	<div id="image05" style="display: inline_block" align="center">
			<img src="/MAP005.jpg"/><br>
		<p>
		Dado: 11001010;
		7 bts;
		1 SB;
		Paridade: Par
		</p>
	</div>
		<div id="image06" style="display: inline_block" align="center">
			<img src="/MAP006.jpg"/><br>
		<p>
		Dado: 11001010;
		6 bts;
		1 SB;
		Paridade: Par	
		</p>
	</div>
		<div id="image08" style="display: inline_block" align="center">
			<img src="/MAP008.jpg"/><br>
		<p>
		Dado: 00110101
		8 bts;
		2 SB;
		Paridade: Par	
		</p>
	</div>
	<div id="image09" style="display: inline_block" align="center">
		<img src="/MAP009.jpg"/><br>
		<p>
		Dado: 01110101
		8 bts;
		2 SB;
		Paridade: Par	
		</p>
	</div>
	<div id="image10" style="display: inline_block" align="center">
		<img src="/MAP010.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 14400 Hz
		I = 212
		F = 63
		Paridade: Par	
		</p>
	</div>
	<div id="image11" style="display: inline_block" align="center">
		<img src="/MAP011.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 76800 Hz
		I = 40
		F = 0
		Paridade: Par	
		</p>
	</div>
	<div id="image11" style="display: inline_block" align="center">
		<img src="/MAP012.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 38400 Hz
		I = 79
		F = 63
		Paridade: Par	
		</p>
	</div>
</div>

<div id="executar">
	<h1>Como executar</h1>
		<p>
		Os arquivos base do códgio assembly encontra-se no caminho raíz desse diretório (/pbl-sistemas-digitais/) e são denominados:
		</p>
		<ul>
			<li>uartConfig.s</li>
			<p>Arquivo principal o qual é usado para a configuração da UART</p>
		</ul>
		<ul>
			<li>uartDateL.s</li>
			<p>Arquivo de envio de dado e teste de loopback</p>
		</ul>
		<ul>
			<li>uartDateO.s</li>
			<p>Arquivo que implementa um loop de envio de dados para serem visualizados via osciloscópio</p>
		</ul>
		<p>
			Para executar o produto desenvolvido, utiliza-se o arquivo makefile. 
			Para isso, dentro de um terminal linux, abra o diretório que contém os arquivos bases mencionados anteriormente e execute os seguinte comando:
		<ul>
			<li>make all</li>
			<p>Cria o executável</p>
		</ul>
		<ul>
			<li>sudo ./UartDateL</li>
			<p>Executa o programa</p>
		</ul>
		</p>
</div>
<div id="conclusao">
	<h1>Conclusão</h1>
	<p>
	Para atingir o objetivo solicitado neste problema foi necessário entender o conceito de mapemento de memória e o implementar, a fim de obter o endereço de memória virtual e consequentemente conseguir acessar a UART. Posteriormente a isso foi possível configura-la a partir das necessidades apontadas como requisitos dos sistema, e enviar um dado de acordo com o padrão RS232.
	</p>
	<p>
Além disso, o protótipo do sistema auxiliou os graduandos em Engenharia da Computação na solidificação do conhecimento acerca da arquitetura ARM e conceitos base da linguagem Assembly, como: principais mnemônicos, estruturas condicionais e estruturas de repetição.
	</p>
	<p>
O problema solucionado cumpre <strong>todos</strong> os requisitos solicitados, e foi desenvolvido utilizando Raspberry Pi Zero além de ter sido devidamente testado através da verificação do dado enviado utilizando o osciloscópio e teste de loopback.
	</p>
</div>
