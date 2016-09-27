@ Desenvolvido por Tomas Silva Queiroga, RA 137748, Unicamp, Ciencia da Computacao, CC012, em 2014
@ Formatado com \t = '    ' (um tab igual a 4 espacos)
@ Para MC404, T02 parte 3 (final), Simulador de IAS
@ para evitar erros, conforme sugerido no grupo de discussao, o codigo da parte um e dois utilizado aqui foi colocado antes do .data deste arquivo

.text
	.align 		4
	.global		get_command
	.global 	run_command
	.global		new_line
	.global 	write
	.global		writeln
	.global		arm_strtou
	.global		arm_utostr
	.global		arm_strcmp
	.global		arm_strlen
	.global		arm_memcpy

	.global		execute

@ Tabela com opCode em hexa, e sua representacao simbolica, e descricao
@ 	opCode 	|	Representacao		| descricao
@-----------+-----------------------+-------------------------------------
@	  0A	|	LOAD	MQ			| AC := MQ
@	  09	|	LOAD	MQ, M(X)	| MQ := Mem[X]
@	  21	|	STOR	M(X)		| Mem[X] := AC
@	  01	|	LOAD	M(X)		| AC := Mem[X]
@	  02	|	LOAD	-M(X)		| AC := -Mem[X]
@	  03	|	LOAD	|M(X)|		| AC := |Mem[X]|
@-----------+-----------------------+-------------------------------------
@	  0D	|	JUMP	M(X, 0:19)	| Salta para a inscrucao a esquerda da palavra contida no endereco X da memoria
@	  0E	|	JUMP	M(X, 20:39)	| Salta para a inscrucao a direita da palavra contida no endereco X da memoria
@	  0F	|	JUMP	+M(X, 0:19) | Se AC >= 0 entao salta para a instrucao a esquerda em X
@	  10	|	JUMP	+M(X, 20:39)| Se AC >= 0 entao salta para a instrucao a direita em X
@-----------+-----------------------+-------------------------------------
@	  05	|	ADD		M(X)		| AC := AC + Mem[X]
@	  07	|	ADD		|M(X)|		| AC := AC + |Mem[X]|
@	  06	|	SUB		M(X)		| AC := AC - Mem[X]
@	  08	|	SUB		|M(X)|		| AC := AC - |Mem[X]|
@	  14	|	LSH					| AC := AC << 1
@	  15	| 	RSH					| AC := AC >> 1
@-----------+-----------------------+-------------------------------------
@	  12	|	STOR	M(X, 8:19)	| Move os 12 bits a direita de AC para o campo endereco da instrucao a esquerda de X na memoria
@	  13	|	STOR	M(X, 28:39)	| Move os 12 bits a direita de AC para o campo endereco da instrucao a direita de X na memoria

execute:
	push	{r4, r8, lr}

	mov		r8, #0							@ r8 sera o registrador que guardara o retorno do execute, por enquanto, retorna 0

	bl		load_instruction
	mov		r3, r1

	mov		r4, #5
	mul		r3, r4							@ calcula offset do endereco, cada endereco sao 5 bytes
	ldr		r2, =IAS_MEM_MAP
	add		r2, r3, r2						@ r2 = &Mem[r1] Endereco "fisico" da memoria

	cmp		r0, #0x0A
	beq		execute_LOAD_MQ
	cmp		r0, #0x09
	beq		execute_LOAD_MQ_MX
	cmp		r0, #0x21
	beq		execute_STOR_MX
	cmp		r0, #0x01
	beq		execute_LOAD_MX
	cmp		r0, #0x02
	beq		execute_LOAD_NMX
	cmp		r0, #0x03
	beq		execute_LOAD_ABS_MX

	cmp		r0, #0x0D
	beq		execute_JUMP_MX_LEFT
	cmp		r0, #0x0E
	beq		execute_JUMP_MX_RIGHT
	cmp		r0, #0x0F
	beq		execute_JUMP_MX_LEFT_HS
	cmp		r0, #0x10
	beq		execute_JUMP_MX_RIGHT_HS

	cmp		r0, #0x05
	beq		execute_ADD_MX
	cmp		r0, #0x07
	beq		execute_ABS_ADD_MX
	cmp		r0, #0x06
	beq		execute_SUB_MX
	cmp		r0, #0x08
	beq		execute_ABS_SUB_MX
	cmp		r0, #0x14
	beq		execute_LSH
	cmp		r0, #0x15
	beq		execute_RSH

	cmp		r0, #0x12
	beq		execute_STOR_MX_LEFT
	cmp		r0, #0x13
	beq		execute_STOR_MX_RIGHT

	mov		r8, #3							@ instrucao invalida, retorna 3
	b		execute_end

execute_LOAD_MQ:
	ldr		r1, =MQ
	ldr		r2, =AC
	ldrb	r3, [r1]						@ carrega primeiro byte de MQ
	strb	r3, [r2]						@ guarda em AC
	ldr		r3, [r1, #1]					@ carrega ultimos bits de MQ
	str		r3, [r2, #1]					@ guarda em AC

	b		execute_update_PC

execute_LOAD_MQ_MX:
	ldr		r0, =MQ
	ldrb	r3, [r2], #1					@ carrega primeiro byte de Mem[r2]
	strb	r3, [r0]						@ guarda em MQ
	ldr		r3, [r2]						@ carrega ultimos bits de Mem[r2]
	str		r3, [r0, #1]					@ guarda em MQ

	b		execute_update_PC

execute_STOR_MX:
	ldr		r0, =AC
	ldrb	r3, [r0]						@ carrega primeiro byte de AC
	strb	r3, [r2], #1					@ guarda em Mem[r2]
	ldr		r3, [r0, #1]					@ carrega ultimos bits de AC
	str		r3, [r2]						@ guarda em Mem[r2]

	b		execute_update_PC

execute_LOAD_MX:
	ldr		r0, =AC
	ldrb	r3, [r2], #1					@ carrega primeiro byte de Mem[r2]
	strb	r3, [r0]						@ guarda em AC
	ldr		r3, [r2]						@ carrega ultimos bits de Mem[r2]
	str		r3, [r0, #1]					@ guarda em AC

	b		execute_update_PC

execute_LOAD_NMX:
	ldrb	r1, [r2], #1					@ carrega primeiro byte de Mem[r2]
	ldr		r0, [r2]						@ carrega ultimos bits de Mem[r2]

	bl		negative						@ inverte sinal

	ldr		r2, =AC
	strb	r1, [r2]						@ guarda em AC
	str		r0, [r2, #1]					@ guarda em AC

	b		execute_update_PC

execute_LOAD_ABS_MX:
	ldrb	r1, [r2], #1
	ldr		r0, [r2]

	bl		absolute_value

	ldr		r2, =AC
	strb	r1, [r2]
	str		r0, [r2, #1]

	b		execute_update_PC

execute_JUMP_MX_LEFT:
	mov		r0, #0
	bl		execute_JUMP
	mov		r8, r0
	b		execute_end
execute_JUMP_MX_RIGHT:
	mov		r0, #1
	bl		execute_JUMP
	mov		r8, r0
	b		execute_end
execute_JUMP_MX_LEFT_HS:
	ldr		r3, =AC
	ldrb	r3, [r3]						@ r3 = primeiro byte de AC

	ldr		r4, =MAX_BYTE
	ldrb	r4, [r4]
	cmp		r3, r4
	bhi		execute_update_PC				@ se AC < 0, nao realiza o salto

	mov		r0, #0
	bl		execute_JUMP
	mov		r8, r0
	b		execute_end
execute_JUMP_MX_RIGHT_HS:
	ldr		r3, =AC
	ldrb	r3, [r3]						@ r3 = primeiro byte de AC

	ldr		r4, =MAX_BYTE
	ldrb	r4, [r4]
	cmp		r3, r4
	bhi		execute_update_PC				@ se AC < 0, nao realiza o salto

	mov		r0, #1
	bl		execute_JUMP
	mov		r8, r0
	b		execute_end

execute_ADD_MX:
	mov		r0, #0
	mov		r1, #0
	bl		execute_arithmetic_operation
	b		execute_update_PC
execute_ABS_ADD_MX:
	mov		r0, #0
	mov		r1, #1
	bl		execute_arithmetic_operation
	b		execute_update_PC
execute_SUB_MX:
	mov		r0, #1
	mov		r1, #0
	bl		execute_arithmetic_operation
	b		execute_update_PC
execute_ABS_SUB_MX:
	mov		r0, #1
	mov		r1, #1
	bl		execute_arithmetic_operation
	b		execute_update_PC
execute_LSH:
	ldr		r3, =AC
	ldr		r0, [r3, #1]
	ldrb	r1, [r3]						@ r1:r0 = AC

	mov		r1, r1, lsl #1					@ r1 = r1 << 1
	mov		r2, r0, lsl #1					@ r2  = r0 << 1

	cmp		r2, r0
	addlo	r1, r1, #1						@ se r2 < r0, houve overflow, adicionamos 1 a r1

	mov		r0, r2

	strb	r1, [r3], #1
	str		r0, [r3]						@ AC = r1:r0

	b		execute_update_PC
execute_RSH:
	ldr		r3, =AC
	ldr		r0, [r3, #1]
	ldrb	r1, [r3]						@ r1:r0 = AC

	mov		r2, r1, lsr #1					@ r0 = r1 << 1
	mov		r0, r0, lsr #1					@ r0  = r0 << 1

	mov		r4, #1
	and		r1, r1, #1						@ r1 = primeiro bit de r1 == 1
	cmp		r1, #1
	eoreq	r0, r0, r4, lsl #31				@ se r2 < r1, houve overflow, setamos o primeiro bit (mais significativo) de r0

	mov		r1, r2

	strb	r1, [r3], #1
	str		r0, [r3]						@ AC = r1:r0

	b		execute_update_PC

execute_STOR_MX_LEFT:
	ldr		r3, =AC
	ldr		r0, [r3, #1]
	mov		r0, r0, lsl #20					@ r0 = (12 a direita de AC) << 20, como vamos simular STOR M(X, 8:19), 8:19 sao os 12 bits a esquerda de X, pulado o primeiro byte

	ldr		r1, [r2, #1]!					@ r1 = Mem[X, 8:39]
	mov		r1, r1, lsl #12
	mov		r1, r1, lsr #12					@ zera 12 bits a esquerda de r1
	eor		r1, r1, r0						@ adicionamos os 12 bits de AC

	str		r1, [r2]

	b		execute_update_PC

execute_STOR_MX_RIGHT:
	ldr		r3, =AC
	ldr		r0, [r3, #1]
	mov		r0, r0, lsl #20					@ r0 = (12 a direita de AC), como vamos simular STOR M(X, 28:39), 28:39 sao os 12 bits a direita de X, pulado o primeiro byte
	mov		r0, r0, lsr #20					@ r0 tem apenas os 12 bits a direita de AC que serao setados em X, justamente nesta posicao

	ldr		r1, [r2, #1]!					@ r1 = Mem[X, 8:39]
	mov		r1, r1, lsr #12
	mov		r1, r1, lsl #12					@ zera 12 bits a direita de r1
	eor		r1, r1, r0						@ adicionamos os 12 bits de AC

	str		r1, [r2]

	b		execute_update_PC

execute_update_PC:
	bl		update_PC						@ atualiza pc, e retorna o retorno do metodo
	mov		r8, r0

execute_end:
	cmp		r8, #0							@ se nao houve erros
	moveq	r0, #0							@ retorna 0
	movne	r0, r8							@ se nao, retorna o codigo de erro guardado em r8
	pop		{r4, r8, pc}

@ se r0 = 0, soma, se nao, subtrai
@ se r1 = 0, valor normal, se nao, valor absoluto
@ r2 = endereco contento valor a ser somado com AC
execute_arithmetic_operation:
	push	{r5, r6, lr}

	mov		r5, r0
	mov		r6, r1

	ldrb	r1, [r2], #1
	ldr		r0, [r2]						@ r1:r0 = Mem[X]
	cmp		r6, #1							@ se r6 for 1, inverte r1:r0
	bleq	absolute_value

	ldr		r4, =AC
	ldr		r3, [r4, #1]
	ldrb	r4, [r4]						@ r4:r3 = AC

	cmp		r5, #0							@ se r5 == 0
	bne		execute_arithmetic_operation_sub
execute_arithmetic_operation_add:
	adds	r3, r3, r0						@ AC += r1:r0
	adc		r4, r4, r1
	b		execute_arithmetic_operation_str
execute_arithmetic_operation_sub:
	subs	r3, r3, r0						@ se nao, AC -= r1:r0
	sbc		r4, r4, r1

execute_arithmetic_operation_str:
	ldr		r2, =AC
	strb	r4, [r2], #1
	str		r3, [r2]

execute_arithmetic_operation_end:
	pop		{r5, r6, pc}


@ recebe em r0 se devemos pular para a esquerda (0) ou direita (1), em r1 o novo valor de pc
@ retorna 0 se 0 <= r1 <= 1023 e 1 caso contrario
execute_JUMP:
	push	{lr}

	mov		r2, #1
	mov		r2, r2, lsl #10					@ r2 = 1024

	cmp		r1, r2							@ se novo endereco de pc >= 1024, retorna 1, se nao, continua
	movhs	r0, #1
	bhs		execute_JUMP_end

	ldr		r2, =PC

	strb	r0, [r2], #1					@ PC->esquerda/direita = r0, PC = r1
	str		r1, [r2]

	mov		r0, #0							@ retorna sucesso
execute_JUMP_end:
	pop		{pc}

@ retorna |r1:r0| (8bits:32bits), sem alterar demais registradores
absolute_value:
	push	{r2, lr}

	ldr		r2, =MAX_BYTE
	ldrb	r2, [r2]
	cmp		r1, r2							@ se o byte mais significativo for maior que 0111 1111 (128), o numero sera negativo, entao invertemos o sinal
	blhi	negative

absolute_value_end:
	pop		{r2, pc}

@ inverte o sinal do numero contido em r1:r0 (8bits:32bits) e retorna em r1:r0
negative:
	push	{lr}
	mov		r2, #0
	sub		r2, #1							@ r4 = 1111 1111 1111 1111 1111 1111 1111 1111

	eor		r0, r2							@ inverte bits (para fazer complemento de 2)
	adds	r0, #1							@ soma 1

	mov		r2, #1
	mov		r2, r2, lsl #8
	sub		r2, r2, #1						@ r4 = 1111 1111

	eor		r1, r2							@ inverte os bits
	adc		r1, #0							@ soma com o carry ,

negative_end:
	pop		{pc}


@ retorna em r0 o opCode do comando (byte), e em r1 os 12 bits de argumento (20 zeros e os 12 bits)
load_instruction:
	push	{r4, lr}

	ldr		r1, =PC
	ldrb	r2, [r1]						@ r2 = instrucao a esquerda ou direita
	ldr		r1, [r1, #1]					@ r1 = PC
	mov		r3, #5
	mul		r1, r3							@ r1 = offset gerado por PC (PC * 5)

	ldr		r3, =IAS_MEM_MAP

	cmp		r2, #0
	beq		load_instruction_left
	b		load_instruction_right

load_instruction_left:
	ldrb	r0, [r3, r1]					@ r0 = byte(mem[PC])
	add		r1, r1, #1
	ldr		r1, [r3, r1]
	mov		r1, r1, lsr #20					@ r1 = word(mem[PC + sizeof(byte)]) >> 20
	b		load_instruction_end

load_instruction_right:
	mov		r4, #1
	mov		r4, r4, lsl #20
	sub		r4, r4, #1						@ r4 = 0xFFFFF

	add		r1, r1, #1
	ldr		r1, [r3, r1]
	and		r1, r1, r4						@ r1 = 20 ultimos bits
	mov		r0, r1, lsr #12					@ r0 = r1 >> 12 (primeiro byte dos 20 bits)
	mov		r1, r1, lsl #20
	mov		r1, r1, lsr #20					@ r1 = (r1 << 20) >> 20 (primeiro byte, dos 20 bits)

load_instruction_end:
	pop		{r4, pc}

@ atualiza o PC, e a flag que indica esquerda e direita
@ retorna em r0 0 se tudo der certo, 2 caso o fim do mapa de memoria foi atingido
update_PC:
	push	{lr}

	ldr		r0, =PC
	ldrb	r1, [r0]						@ r1 = se pc esta na esquerda ou direita
	eor		r1, r1, #1						@ se estava na esquerda, vai para direita e vice versa
	strb	r1, [r0]						@ guarda posicao no byte mais significativo de PC

	ldr		r2, [r0, #1]					@ se apos o xor, r1 eh zero, entao estavamos na direita, e agora esquerda, entao incrementamos pc
	cmp		r1, #0
	addeq	r2, r2, #1
	streq	r2, [r0, #1]					@ PC = PC + (r1 == 0 ? 1 : 0)

	mov		r1, #1
	mov		r1, r1, lsl #10					@ r1 = 1024

	cmp		r2, r1							@ se PC >= 1024, retorna 2, se nao, 0
	movlo	r0, #0
	movhs	r0, #2

update_PC_end:
	pop		{pc}

@ parte dois

@ Modulo com a implementacao de captacao de comandos para auxiliar a utilizacao do simulador IAS
@ Segue uma tabela com as descricoes de cada comando.
@   Codigo   |
@ de retorno |	Comando		| Descricao
@ 	  0		 |	quit		| Finaliza execucao do programa sendo simulado e do simulador.
@	 #1		 |	step [#1]	| Executa #1 instrucoes e para. Se nenhum #1 for passado, executa apenas a
@			 | 				| instrucao atual. Retorna o numero de instrucoes executadas com exito.
@	 -1		 |	continue	| Continua a executar o programa ate encontrar uma instrucao nao identificada.
@	 -2		 |	write #1 #2	| Armazena o valor #2 no endereço de memoria #1.
@	 -3		 |	print #1	| Imprime na tela o valor atualmente armazenado no endereço de memoria #1.
@	 -4		 |	registers	| Imprime o conteudo atual dos registradores AC, MQ e PC.
@	 -5		 |  qualquer	| Caso a entrada for nenhuma das descritas, retorna -5, codigo de erro


@ Le da entrada padrao (via syscall read) uma cadeia de caracteres e identifica qual comando o usuario deseja executar.
@ Retorna em r0 o codigo de retorno conforme apresentando na Tabela acima.
@ Alem disso, os operandos #1 e #2 (caso hajam) serao salvos como cadeias de caracteres nas posicoes de memoria
@ indicadas por r0 e r1, respectivamente.
@ Caso receba um comando inexistente, retorna o valor -5, conforme já dito anteriormente.
get_command:
	push	{r4, r5, lr}

	mov		r4, r0							@ guardamos os enderecos passados por parametro
	mov		r5, r1

	bl		default_reader

	ldr		r0, =buffer_read				@ remove espacos iniciais
	bl		find_first_letter				@ r0 apontara para a primeira letra do comando

	ldrb	r1, [r0]						@ se *r0 for 0, entao o comando eh invalido
	cmp		r1, #0

	bl		replace_next_space_to_end_of_string
	@ agora temos a cadeia terminada com zero relativa ao comando

	push	{r0, r1}						@ em r1 temos a posicao seguinte da ultima posicao valida do comando
	bl		arm_strlen						@ r2 = strlen(r0)
	mov		r2, r0
	pop		{r0, r1}

	cmp		r2, #1							@ se r2 for diferente de um, usaremos strcmp, se nao, comparamos *r0 com q, s, c, w, p, r
	bne		get_command_cmp
	ldrb	r3, [r0]						@ r3 = *r0
	cmp		r3, #113						@ se r3 == 'q'
	beq		get_command_return_quit
	cmp		r3, #99							@ se r3 == 'c'
	beq		get_command_return_continue
	cmp		r3, #114						@ se r3 == 'r'
	beq		get_command_return_registers

	cmp		r3, #115						@ se r3 == 's'
	beq		get_command_return_step
	cmp		r3, #112						@ se r3 == 'p'
	beq		get_command_return_print

	cmp		r3, #119						@ se r3 == 'w'
	beq		get_command_return_write

	b		get_command_return_error		@ se nao for nenhuma das letras acima

get_command_cmp:
	push	{r0-r3}						@ comando == 'quit'
	ldr		r1, =quit_lbl
	bl		arm_strcmp
	cmp		r0, #0						@ lembrando que se r0 == 0 depois de arm_strcmp, entao as cadeias que estavam em r0 e r1 sao iguais
	pop		{r0-r3}
	beq		get_command_return_quit

	push	{r0-r3}						@ comando == 'continue'
	ldr		r1, =continue_lbl
	bl		arm_strcmp
	cmp		r0, #0
	pop		{r0-r3}
	beq		get_command_return_continue

	push	{r0-r3}						@ comando == 'registers'
	ldr		r1, =registers_lbl
	bl		arm_strcmp
	cmp		r0, #0
	pop		{r0-r3}
	beq		get_command_return_registers

	push	{r0-r3}						@ comando == 'step'
	ldr		r1, =step_lbl
	bl		arm_strcmp
	cmp		r0, #0
	pop		{r0-r3}
	beq		get_command_return_step

	push	{r0-r3}						@ comando == 'print'
	ldr		r1, =print_lbl
	bl		arm_strcmp
	cmp		r0, #0
	pop		{r0-r3}
	beq		get_command_return_print

	push	{r0-r3}						@ comando == 'write'
	ldr		r1, =write_lbl
	bl		arm_strcmp
	cmp		r0, #0
	pop		{r0-r3}
	beq		get_command_return_write

	b		get_command_return_error		@ se nao for nenhuma das palavras acima
get_command_cmp_end:

get_command_return_error:
	mov		r0, #0
	sub		r0, #5
	b		get_command_end

get_command_return_quit:
	mov		r0, #0
	b		get_command_end

get_command_return_continue:
	mov		r0, #0							@r0 = 0 - 1
	sub		r0, #1
	b		get_command_end

get_command_return_registers:
	mov		r0, #0
	sub		r0, #4
	b		get_command_end

get_command_return_step:
	bl		get_parameter

	mov		r0, #1
	b		get_command_end

get_command_return_print:
	bl		get_parameter

	mov		r0, r4
	bl		arm_strlen						@ print tem parametro obrigatorio, retorna erro caso o tamanho da str guardada em r4 por 0
	cmp		r0, #0
	beq		get_command_return_error

	mov		r0, #0
	sub		r0, #3
	b		get_command_end

get_command_return_write:
	bl		get_parameter					@ obtem primeiro parametro
	mov		r4, r5
	sub		r1, r1, #1
	bl		get_parameter					@ obtem segundo parametro

	mov		r0, r4
	bl		arm_strlen						@ write tem dois parametros obrigatorios
	cmp		r0, #0
	beq		get_command_return_error

	mov		r0, r5
	bl		arm_strlen
	cmp		r0, #0
	beq		get_command_return_error

	mov		r0, #0
	sub		r0, #2
	b		get_command_end

get_command_end:
	pop		{r4, r5, pc}

@ encontra o proximo parametro, dado que em r1 temos o endereco do ultimo caracter da ultima palavra processada
@ grava em r4
get_parameter:
	push	{lr}

	add		r1, r1, #1						@ pula caracter \0
	mov		r0, r1
	bl		find_first_letter				@ r0 apontara para a primeira letra do parametro
	bl		replace_next_space_to_end_of_string
	push	{r0}
	bl		arm_strlen
	mov		r2, r0
	add		r2, r2, #1						@ assim copia o \0 também para o endereco do parametro
	pop		{r0}
	mov		r1, r0
	mov		r0, r4
	bl		arm_memcpy
get_parameter_end:
	pop		{pc}

@ Executa a funcao em r0 (1 - -4), conforme get_command, parametro 1 em r1, e parametro 2 em r2
@ retornar em r0:
@	0 em caso de exito,
@	-1 caso haja um salto para endereco invalido por parte do codigo simulado,
@	-2 caso a simulacao atinja o fim do mapa de memoria
@	-3 em qualquer outro caso.
run_command:
	push	{r4, lr}

	mov		r3, #1
	cmp		r0, r3
	beq		run_command_step				@  1
	sub		r3, #1
	cmp		r0, r3
	beq		run_command_quit				@  0
	sub		r3, #1
	cmp		r0, r3
	beq		run_command_continue			@ -1
	sub		r3, #1
	cmp		r0, r3
	beq		run_command_write				@ -2
	sub		r3, #1
	cmp		r0, r3
	beq		run_command_print				@ -3
	sub		r3, #1
	cmp		r0, r3
	beq		run_command_registers			@ -4

	b		run_command_return_generic_error

run_command_step:							@ nao implementado na parte 2
	mov		r0, r1							@ r1 = parseInt(r1)
	bl		arm_strtou
	mov		r1, r0

run_command_step_while:						@ executa 1 ou r1 vezes comandos
	push	{r1}
	bl		execute
	pop		{r1}
	cmp		r1, #1							@ r1 sera 1 ou menos depois de executar as instrucoes desejadas
	bls		run_command_step_while_end
	sub		r1, r1, #1
	cmp		r0, #0
	beq		run_command_step_while			@ se o execute retornou sucesso, continua executando, se nao para
run_command_step_while_end:
	b		run_command_return_execute_code

run_command_quit:
	mov		r0, #0
	mov		r7, #1							@ syscall que sai do programa
	svc		0

run_command_continue:						@ nao implementada na parte 2
	bl		execute
	cmp		r0, #0
	beq		run_command_continue			@ se o execute retornou sucesso, continua executando, se nao para
run_command_continue_end:
	b		run_command_return_execute_code

run_command_write:
	mov		r0, r1							@ r1 = parseInt(r1)
	push	{r2}
	bl		arm_strtou
	pop		{r2}
	mov		r1, r0
	mov		r4, #1
	mov		r4, r4, lsl #10					@ r4 = 1024
	cmp		r1, r4
	movhs	r0, #0
	subhs	r0, r0, #3
	bhs		run_command_end					@ se r0 for maior que o ultimo endereco de memoria valido, retorna

	mov		r0, r2							@ r2 = parseInt(r2)
	push	{r1}
	bl		arm_strtou_40
	mov		r4, r1
	pop		{r1}
	mov		r2, r0

	mov		r3, #5
	mul		r1, r3							@ o enderecamento eh de 5 em 5 bytes					
	ldr		r3, =IAS_MEM_MAP
	add		r3, r3, r1						@ r3 = endereco onde devera ser armazenado r2
	strb	r4, [r3]
	str		r2, [r3, #1]

	mov		r0, #0
	b		run_command_end

run_command_print:
	mov		r0, r1							@ r0 = parseInt(r1)
	bl		arm_strtou
	mov		r4, #1
	mov		r4, r4, lsl #10					@ r4 = 1024
	cmp		r0, r4
	movhs	r0, #0
	subhs	r0, r0, #3
	bhs		run_command_end					@ se r0 for maior que o ultimo endereco de memoria valido, retorna

	mov		r3, #5
	mul		r0, r3							@ o enderecamento eh de 5 em 5 bytes
	ldr		r3, =IAS_MEM_MAP
	add		r3, r3, r0
	ldrb	r1, [r3]						@ r1 = byte mais significativo
	ldr		r0, [r3, #1]					@ r0 = 4 bytes menos

	ldr		r2, =buffer_read				@ r1 = utostr(r3[r0])
	bl		arm_utostrhex
	ldr		r1, =buffer_read
	bl		writeln							@ printf("%s\n", r1)

	mov		r0, #0
	b		run_command_end

run_command_registers:
run_command_registers_AC:
	ldr		r1, =AC_lbl						@ AC: valor
	bl		write
	ldr		r2, =AC
	ldrb	r1, [r2]						@ r1 = byte mais significativo
	ldr		r0, [r2, #1]					@ r0 = 4 bytes menos
	ldr		r2, =buffer_read
	bl		arm_utostrhex
	ldr		r1, =buffer_read
	bl		writeln

run_command_registers_MQ:
	ldr		r1, =MQ_lbl						@ MQ: valor
	bl		write
	ldr		r2, =MQ
	ldrb	r1, [r2]						@ r1 = byte mais significativo
	ldr		r0, [r2, #1]					@ r0 = 4 bytes menos
	ldr		r2, =buffer_read
	bl		arm_utostrhex
	ldr		r1, =buffer_read
	bl		writeln

run_command_registers_PC:
	ldr		r1, =PC_lbl						@ PC: 0x000 - {E|D}
	bl		write
	ldr		r0, =PC
	ldr		r0, [r0, #1]
	ldr		r1, =buffer_read
	mov		r2, #3
	mov		r3, #0
	bl		arm_utostrhex_32
	bl		write

	ldr		r1, =PC_lr_lbl
	bl		write

	ldr		r0, =PC
	ldrb	r0, [r0]
	cmp		r0, #0
	ldreq	r1, =PC_l_lbl
	ldrne	r1, =PC_r_lbl
	bl		writeln

	mov		r0, #0
	b		run_command_end

run_command_return_generic_error:
	mov		r0, #0
	sub		r0, r0, #3
	b		run_command_end

run_command_return_execute_code:
	cmp		r0, #0
	beq		run_command_end
	cmp		r0, #1
	subeq	r0, #2
	beq		run_command_end
	cmp		r0, #2
	subeq	r0, #4
	beq		run_command_end
	sub		r0, #6
	b		run_command_end

run_command_end:
	pop		{r4, pc}

@ Converte um inteiro sem sinal de 40 bits (4 bytes menos significativos em r0, e o mais em r1, r1:r0)
@ para uma cadeia de caracteres com digitos hexadecimais representando o inteiro.
@ A cadeia comeca a partir do endereco fornecido em r2 e termina com \0.
arm_utostrhex:
	push	{lr}

	push	{r0-r3}							@ colocamos em r2 a conversao do byte contido em r1
	mov		r0, r1
	mov		r1, r2
	mov		r2, #2
	mov		r3, #0
	bl		arm_utostrhex_32				@ arm_utostrhex_32(r1, r2, 2)
	pop		{r0-r3}

	push	{r0-r3}
	mov		r1, r2
	add		r1, #4							@ pulamos os 4 caracteres ja escritos (0x00)
	mov		r2, #8
	mov		r3, #1
	bl		arm_utostrhex_32				@ arm_utostrhex_32(r0, r2 + 4, #8)
	pop		{r0-r3}

arm_utostrhex_end:
	pop		{pc}

@ Converte um inteiro sem sinal de 32 bits em r0
@ para uma cadeia de caracteres com digitos hexadecimais representando, o inteiro com a mascara 0x{0}n (0x com r2 digitos pelo menos).
@ A cadeia comeca a partir do endereco fornecido em r1 e termina com \0.
@ caso r3 tenha valor diferente de 0, nao colocara 0x no inicio
arm_utostrhex_32:
	push	{r4, r5, lr}

	mov		r4, r2							@ guardamos quantos digitos em r4
	mov		r5, r3							@ guardamos se usaremos 0x em r5

	mov		r2, #0							@ contador de quantos digitos foram empilhados
arm_utostrhex_32_while:
	mov		r3, r0, lsr #4
	mov		r3, r3, lsl #4
	sub		r3, r0, r3						@ r3 = r0 - ((r0 >> 4) << 4) (primeiro digito em r0, em hexa)

	push	{r3}							@ empilhamos o digito para colocar em ordem na string
	add		r2, r2, #1

	mov		r0, r0, lsr #4					@ desloca um byte para a direta, pois ja guardamos o primeiro digito
	cmp		r0, #0							@ se ainda ha digitos, continua laco
	bne		arm_utostrhex_32_while
arm_utostrhex_32_while_end:

	cmp		r5, #0
	movne	r3, #0
	bne		arm_utostrhex_32_while_complete
	mov		r0, #48
	strb	r0, [r1]						@ r1[0] = '0'
	mov		r0, #120
	strb	r0, [r1, #1]					@ r1[1] = 'x'

	mov		r3, #2							@ indice na string r1

arm_utostrhex_32_while_complete:			@ desempilhamos os digitos e guardamos na string
	cmp		r4, r2							@ se a quantidade de digitos empilhados for menor do que a quantidade de digitos esperada
	beq		arm_utostrhex_32_while_complete_end
	mov		r0, #48							@ adicionamos zeros
	strb	r0, [r1, r3]					@ r1[r3] = '0'
	add		r3, r3, #1
	sub		r4, r4, #1
	b		arm_utostrhex_32_while_complete
arm_utostrhex_32_while_complete_end:

arm_utostrhex_32_while_pop:					@ desempilhamos os digitos e guardamos na string
	pop		{r0}
	cmp		r0, #10							@ se r0 < 10
	addlo	r0, #48							@ adicionamos '0' a r0
	addhs	r0, #55							@ se nao, 'A' - 10 a r0

	strb	r0, [r1, r3]					@ r1[r3] = r0
	add		r3, r3, #1						@ r3++
	sub		r2, r2, #1						@ r2--
	cmp		r2, #0							@ se ja desempilhamos todos os caracteres, saimos do while
	bne		arm_utostrhex_32_while_pop

	mov		r0, #0
	strb	r0, [r1, r3]					@ finaliza com '\0'

arm_utostrhex_32_end:
	pop		{r4, r5, pc}

@ Retorna em r1:r0 o valor representado pela string contida em r0 (decimal ou hex)
arm_strtou_40:
	push	{r4-r9, lr}

	ldrb	r3, [r0]
	cmp		r3, #0							@ se a str eh vazia (r0[0] == '\0'
	beq		arm_strtou_return_zero_40

	mov		r9, #0							@ r9 guardara se a string eh hex ou dec ( 0 == dec)

											@ se a str eh hex, comeca com 0x
	cmp		r3, #48							@ r1[0] == 48 == '0'
	bne		arm_strtou_end_if_40
	ldrb	r3, [r0, #1]
	cmp		r3, #120						@ r1[1] == 120 == 'x'
	bne		arm_strtou_end_if_40
	add		r0, r0, #2						@ r1 = r1 + 16 (r1[2]
	mov		r9, #1							@ r9 = true
arm_strtou_end_if_40:

	mov		r1, #0							@ guardaremos aqui os 20 bits menos significativos
	mov		r2, #0							@ e aqui os 20 bits mais

	mov		r3, #1
	mov		r3, r3, lsl #12
	sub		r3, r3, #1						@ r3 = 12 bits 1 (32 bits - 20 usados = 12)

	mov		r4, r3, lsl #20					@ r4 = 12 bits 1, 20 bits 0

	mov		r5, #1
	mov		r5, r5, lsl #20
	sub		r5, #1							@ r5 = 20 bits 1

	mov		r8, #10							@ r8 = 10, para multiplicar

arm_strtou_40_while:
	ldrb	r6, [r0], #1					@ enquanto r0[i] != -1
	cmp		r6, #0
	beq		arm_strtou_40_while_end

	cmp		r9, #1							@ se hex
	moveq	r1, r1, lsl #4					@ entao r1 = r1 << 4
	moveq	r2, r2, lsl #4					@ entao r2 = r2 << 4
											@ se nao, r1 = r1 * 10 e r2 = r2 * 10
	movne	r7, r1
	mulne	r1, r7, r8						@ r1 *= 10
	movne	r7, r2
	mulne	r2, r7, r8						@ r2 *= 10

	cmp		r6, #48							@ se r0[i] >= '0' (se nao, verifica se eh um digito hex)
	blo		arm_strtou_hex_digit_40
	cmp		r6, #57							@  e r0[1] <= '9' (se nao, verifica se eh um digito hex)
	bhi		arm_strtou_hex_digit_40
	addls	r1, r1, r6						@ r1 += r0[i]
	subls	r1, r1, #48						@ r1 -= 48, traslada 48 unidades, pois '0' == '48'
	b		arm_strou_40_end_if				@ continua loop
arm_strtou_hex_digit_40:
	cmp		r9, #1							@ se nao for hex (se nao comecava com 0x, mas encontrou caracter diferente de 0-9), str nao eh numero valido
	bne		arm_strtou_return_zero_40

	cmp 	r6, #65							@ se r0[i] >= 'A' (se nao, verifica se eh um digito hex minusculo)
	blo		arm_strtou_hex_digit_min_40
	cmp		r6, #70							@ e r0[i] <= 'F' (se nao, verifica se eh um digito hex minusculo)
	bhi		arm_strtou_hex_digit_min_40
	add		r1, r1, r6						@ entao r1 += r0[i]
	sub		r1, r1, #55						@ r1 -= 55 ('A' == 65, e A = 10, então 65 - 10 = 55)
	b		arm_strou_40_end_if
arm_strtou_hex_digit_min_40:
	cmp 	r6, #97							@ se r1[i] >= 'a' (se nao, eh caracter invalido)
	blo		arm_strtou_return_zero_40
	cmp		r6, #102						@ e r1[i] <= 'f'  (se nao, eh caracter invalido)
	bhi		arm_strtou_return_zero_40
	add		r1, r1, r6						@ entao r1 += r0[i]
	sub		r1, r1, #87						@ r1 -= 87 ('a' == 97, e a = 10, entao 97 - 10)
	b		arm_strou_40_end_if

arm_strou_40_end_if:

	and		r7, r1, r4
	mov		r7, r7, lsr #20					@ r7 = 12 ultimos bits de r1
	add		r2, r2, r7						@ r2 recebe ultimos bits de r1

	and		r1, r1, r5						@ zeramos os 12 ultimos bits de r1

	b		arm_strtou_40_while
arm_strtou_40_while_end:


	and		r7, r2, r3						@ r7 = 12 primeiros bits de r2
	mov		r7, r7, lsl #20					@ r7 = r7 << 20 para somar este valor em r1, completando os 32 bits de r1, que "volta" a ser um registrador de 32 bits
	add		r1, r1, r7

	mov		r2, r2, lsr #12					@ como os 12 primeiros bits de r2 agora estao em r1, entao deslocamos os ultimos 8 para serem os primeiros.

	mov		r0, r1							@ r1 = byte mais significativo, r0 os 4 menos.
	mov		r1, r2
	b		arm_strtou_40_end

arm_strtou_return_zero_40:
	mov		r0, #0
	mov		r1, #0

arm_strtou_40_end:
	pop		{r4-r9, pc}

@ Dada uma cadeia de caracteres que comeca no endereco apontado por r0,
@ coloca 0 na primeira ocorrencia de espaco
@ retorna em r0 o endereco original da cadeia
@ e em r1 o endereco da ultima posicao
replace_next_space_to_end_of_string:
	push	{r0, lr}

replace_next_space_to_end_of_string_while:	@ enquanto r1 > ' '
	ldrb	r1, [r0]						@ r1 = *r0
	cmp		r1, #32							@ r1 > ' '
	addhi	r0, r0, #1						@ r0++
	bhi		replace_next_space_to_end_of_string_while

	mov		r1, #0							@ *r0 = 0
	strb	r1, [r0]

	mov		r1, r0

replace_next_space_to_end_of_string_end:
	pop		{r0, pc}

@ Dada uma cadeia de caracteres que comeca no endereco apontado por r0,
@ retorna em r0 o endereco do primeiro endereco diferente de espaco da cadeia original (ltrim(r0))
find_first_letter:
	push	{lr}

find_first_letter_while:					@ enquanto r1 <= ' '
		ldrb	r1, [r0]					@ r1 = *r0
		cmp		r1, #32						@ se r1 > ' ', retorna
		bhi		find_first_letter_end
		cmp		r1, #0						@ se r1 == 0, retorna
		beq		find_first_letter_end
		add		r0, r0, #1					@ r0++
		b		find_first_letter_while

find_first_letter_end:
	pop		{pc}

@ Limpa (preenche com 0) o buffer
default_reader_clear_buffer:
	push	{lr}

	ldr		r1, =buffer_read
	mov		r2, #0
default_reader_clear_buffer_while:
	ldrb	r0, [r1]
	cmp		r2, #255
	beq 	default_reader_clear_buffer_end
	add		r2, r2, #1
	mov		r0, #0
	strb	r0, [r1], #1
	b		default_reader_clear_buffer_while

default_reader_clear_buffer_end:
	pop		{pc}

@ Grava em buffer_read o valor vindo da entrada padrao (via syscall read)
@ sem alterar nenhum registrador
default_reader:
	push	{r0, r1, r2, r7, lr}

	bl		default_reader_clear_buffer

	mov		r0, #0							@ read(0, buffer_read, 255)
	ldr		r1, =buffer_read
	mov		r2, #255
	mov		r7, #3
	svc		0

default_reader_end:
	pop		{r0, r1, r2, r7, pc}

@ escreve uma quebra de linha, sem alterar qualquer registrador
new_line:
	push	{r0-r7, lr}

	mov		r0, #1
	ldr		r1, =newLine
	mov		r2, #1
	mov		r7, #4
	svc		0
new_line_end:
	pop		{r0-r7, pc}

@ escreve a sequencia de caracteres contida em r1, sem alterar qualquer registrador
write:
	push	{r0-r7, lr}

	mov		r0, r1
	push	{r1, r3}
	bl		arm_strlen
	mov		r2, r0
	pop		{r1, r3}

	mov		r0, #1
	mov		r7, #4
	svc		0
write_end:
	pop		{r0-r7, pc}

@ escreve a sequencia de caracteres contida em r1, sem alterar qualquer registrador, e pula de linha em seguida
writeln:
	push	{r0-r7, lr}

	bl		write
	bl		new_line
writeln_end:
	pop		{r0-r7, pc}

@ codigo parte 1
@ Converte uma cadeia de caracteres em r0 com digitos decimais ou hexadecimais
@ terminada em NULL (\0) para um inteiro sem sinal de 32 bits.
@ retorna em r0
arm_strtou:
	push	{r4, r5, lr}

	ldrb	r3, [r0]
	cmp		r3, #0							@ se a str eh vazia (r0[0] == '\0'
	beq		arm_strtou_return_zero

	mov		r1, r0							@ como o retorno eh em r0, vamos tratar r1 como a str (r0)
	mov		r0, #0							@ retorno
	mov		r2, #0							@ booleana se str eh hex
	mov		r4, #10

											@ se a str eh hex, comeca com 0x
	cmp		r3, #48							@ r1[0] == 48 == '0'
	bne		arm_strtou_end_if
	ldrb	r3, [r1, #1]
	cmp		r3, #120						@ r1[1] == 120 == 'x'
	bne		arm_strtou_end_if
	add		r1, r1, #2						@ r1 = r1 + 16 (r1[2]
	mov		r2, #1							@ r2 = true
arm_strtou_end_if:

arm_strtou_while:
		ldrb	r3, [r1], #1				@ r3 = r1[i]
		cmp		r3, #0						@ se acabou a str
		beq		arm_strtou_end				@ entao retorna r0

		cmp		r2, #1						@ se hex
		moveq	r0, r0, lsl #4				@ entao r0 = r0 << 4
		movne	r5, r0
		mulne	r0, r5, r4					@ se nao, r0 = r0 * 10

		cmp		r3, #48						@ se r1[i] >= '0' (se nao, verifica se eh um digito hex)
		blo		arm_strtou_hex_digit
		cmp		r3, #57						@  e r1[1] <= '9' (se nao, verifica se eh um digito hex)
		bhi		arm_strtou_hex_digit
		addls	r0, r0, r3					@ r0 += r[i]
		subls	r0, r0, #48					@ r0 -= 48, traslada 48 unidades, pois '0' == '48'
		b		arm_strtou_while			@ continua loop
arm_strtou_hex_digit:
		cmp		r2, #1						@ se nao for hex (se nao comecava com 0x, mas encontrou caracter diferente de 0-9), str nao eh numero valido
		bne		arm_strtou_return_zero

		cmp 	r3, #65						@ se r1[i] >= 'A' (se nao, verifica se eh um digito hex minusculo)
		blo		arm_strtou_hex_digit_min
		cmp		r3, #70						@ e r1[i] <= 'F' (se nao, verifica se eh um digito hex minusculo)
		bhi		arm_strtou_hex_digit_min
		add		r0, r0, r3					@ entao r0 += r[i]
		sub		r0, r0, #55					@ r0 -= 55 ('A' == 65, e A = 10, então 65 - 10 = 55)
		b		arm_strtou_while			@ continua loop
arm_strtou_hex_digit_min:
		cmp 	r3, #97						@ se r1[i] >= 'a' (se nao, eh caracter invalido)
		blo		arm_strtou_return_zero
		cmp		r3, #102					@ e r1[i] <= 'f'  (se nao, eh caracter invalido)
		bhi		arm_strtou_return_zero
		add		r0, r0, r3					@ entao r0 += r[i]
		sub		r0, r0, #87					@ r0 -= 87 ('a' == 97, e a = 10, entao 97 - 10)
		b		arm_strtou_while			@ continua loop

arm_strtou_return_zero:
	mov		r0, #0

arm_strtou_end:
	pop		{r4, r5, pc}

@ Divide um inteiro em r0 sem sinal por 10,
@ retorna o resultado em r0, e o resto em r1
udiv10:
	push 	{lr}

	mov		r1, r0							@ o resto
	mov		r0, #0							@ o quociente

udiv10_do_while:							@ enquanto r1 >= 10, pois se for menor, ja eh o resto da divisao
		cmp		r1, #10
		blo		udiv10_do_while_end
		sub		r1, r1, #10					@ r1 -= 10
		add		r0, r0, #1					@ como foi feita uma subtracao, r0 ++
		b		udiv10_do_while
udiv10_do_while_end:

	pop {pc}


@ Converte um inteiro sem sinal para uma cadeia de caracteres com dígitos decimais representando o inteiro.
@ A cadeia deve ser preenchida na memória a partir do endereço fornecido em buf e deve ser terminada com NULL.
arm_utostr:
	push 	{lr}

	mov		r2, #0							@ quantos digitos tem o numero r0
	mov		r3, r0							@ para nao estragar r0 na verificacao, copiamos seu valor para r3

arm_utostr_digit_count_while:				@ descobre quantos digitos tem o numero dividindo-o por 10 multiplas vezes
		cmp 	r3, #0						@ se ainda tiver digitos, entao r3 != 0
		beq		arm_utostr_digit_count_while_end
		add		r2, r2, #1					@ quantos digitos++

		push	{r0, r1}					@ r3 = r3 / 10
		mov		r0, r3
		bl		udiv10
		mov		r3, r0
		pop		{r0, r1}

		b		arm_utostr_digit_count_while
arm_utostr_digit_count_while_end:

	mov		r3, #0							@ r1[r2--] = '\0'
	strb	r3, [r1, r2]
	sub		r2, r2, #1

arm_utostr_while:
		cmp		r0, #0						@ enquanto nao acabaram os digitos de r0
		beq		arm_utostr_end

		push 	{r1}
		bl		udiv10						@ r0 = r0 / 10
		mov		r3, r1						@ r3 = r0 % 10
		pop		{r1}
		add		r3, #48						@ r3 += 48, pois '0' == 48
		strb	r3, [r1, r2]				@ r1[r2--] = r3
		sub		r2, r2, #1
		b		arm_utostr_while

arm_utostr_end:
	pop		{pc}

@ Compara as duas cadeias de caracteres apontadas por r0 e r1.
@ Retorna em r0
@	 0 se ambas forem iguais, ou
@	-1 se a primeira for lexicograficamente menor que a segunda, ou
@	 1 se a segunda for lexicograficamente menor que a primeira.
arm_strcmp:
	push	{r4, r5, lr}

	cmp		r0, r1							@ se os apontadores apontam para o mesmo lugar
	moveq	r0, #0							@ ambas sao iguais
	beq		arm_strcmp_end
	mov		r5, #1							@ se for 0, acabou r0 e/ou r1

arm_strcmp_while:							@ enquanto r0[i] != '\0' ou r1[i] != '\0'
		ldrb	r3, [r0], #1				@ r3 = r0[i] (e r0++)
		cmp		r3, #0						@ se acabou r0
		moveq	r5, #0
		ldrb	r4, [r1], #1				@ r4 = r1[i] (e r1++)
		cmp		r4, #0						@ se acabou r1
		moveq	r5, #0
		cmp		r5, #1
		bne		arm_strcmp_while_end

		cmp		r3, r4
		beq		arm_strcmp_while			@ se r0[i] == r1[i], continua laco
		mov		r0, #0
		sublo	r0, r0, #1					@ se r0[i] < r1[i], retorna -1
		addhi	r0, #1						@ se nao, retorna 1
		b		arm_strcmp_end

arm_strcmp_while_end:

	cmp		r3, r4
	mov		r0, #0							@ se r0[i] == r1[i], retorna 0
	sublo	r0, r0, #1						@ se r0[i] < r1[i], retorna -1
	addhi	r0, #1							@ se nao, retorna 1

arm_strcmp_end:
	pop		{r4, r5, pc}

@ Retorna em r0 o tamanho em bytes da cadeia de caracteres apontada por r0.
@ Note que a cadeia deve ser terminada com NULL e o caractere NULL nao eh contabilizado no tamanho calculado pela funcao.
arm_strlen:
	push	{lr}

	mov		r1, #0							@ tamanho da cadeia

arm_strlen_while:							@ enquanto r0[r1] != '\0'
		ldrb	r2, [r0, r1]				@ r2 = r0[r1]
		cmp		r2, #0
		beq		arm_strlen_while_end

		add		r1, r1, #1
		b		arm_strlen_while
arm_strlen_while_end:

	mov		r0, r1
arm_strlen_end:
	pop		{pc}

@ Copia r3 bytes a partir do endereço de memoria apontado por r1 para a regiao da memoria com inicio em r0.
@ As regioes de memoria apontadas por r0 e r1 nao devem se sobrepor.
arm_memcpy:
	push	{r4, lr}

	cmp		r0, r1							@ se for o mesmo endereco de memoria
	beq		arm_memcpy_end					@ nada deve ser feito

	cmp		r0, r1							@ se r0 < r1, com overlap ou nao, nao tem problema
	movhi	r3, r1							@ se nao, se r0 > r1
	addhi	r3, r3, r2						@ e r1 + r2 > r0
	cmphi	r3, r0
	bhs		arm_memcpy_copy_backwards		@ entao o destino vem depois da origem, tem overlap, devemos copiar de tras para frente

	mov 	r3, #0
arm_memcpy_while:
		cmp		r3, r2						@ enquanto nao copiou todos os bytes desejados
		bhs		arm_memcpy_end
		ldrb	r4, [r1], #1				@ r0[i] = r1[i], e incrementa i
		strb	r4, [r0], #1
		add		r3, r3, #1
		b		arm_memcpy_while

arm_memcpy_copy_backwards:
	mov 	r3, r2							@ comecamos do fim
	add		r0, r0, r3						@ r0 = r0 + r2 - 1
	sub		r0, r0, #1
	add		r1, r1, r3						@ r1 = r1 + r2 - 1
	sub		r1, r1, #1
arm_memcpy_copy_backwards_while:
		cmp		r3, #0						@ enquanto nao copiou todos os bytes desejados
		bls		arm_memcpy_end
		ldrb	r4, [r1] 					@ r0[i] = r1[i], e decrementa i
		strb	r4, [r0]
		sub		r3, r3, #1
		sub		r0, r0, #1
		sub		r1, r1, #1
		b		arm_memcpy_copy_backwards_while

arm_memcpy_end:
	pop {r4, pc}

.data
	quit_lbl:		.asciz	"quit\0"
	step_lbl:		.asciz	"step\0"
	continue_lbl:	.asciz	"continue\0"
	write_lbl:		.asciz	"write\0"
	print_lbl:		.asciz	"print\0"
	registers_lbl:	.asciz	"registers\0"

	AC_lbl:			.asciz	"AC: \0"
	MQ_lbl:			.asciz	"MQ: \0"
	PC_lbl:			.asciz	"PC: \0"
	PC_lr_lbl:		.asciz	" - \0"
	PC_l_lbl:		.asciz	"E\0"
	PC_r_lbl:		.asciz	"D\0"

	newLine:		.asciz "\n\0"
	buffer_read:	.space	255
	MAX_BYTE:		.byte 127				@ 0111 1111 e o maior inteiro na representacao com sinal de um byte
