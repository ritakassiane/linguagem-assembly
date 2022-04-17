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
	<a href="#executar"> Como executar </a>
</div>

<div id="diagrama">
	Imagem do diagrama aqui
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
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
				<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
</div>

<div id="enviando">
	<h1> Enviando Dado </h1>
			<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
</div>

<div id="executar">
	<h1>Como executar</h1>
		<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
		<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
		<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
		<p>
		Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
	</p>
</div>
