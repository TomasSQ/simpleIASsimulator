@ Desenvolvido por Tomas Silva Queiroga, RA 137748, Unicamp, Ciencia da Computacao, CC012, em 2014
@ Formatado com \t = '    ' (um tab igual a 4 espacos)
@ Para MC404, T02 parte 1, Simulador de IAS

.text
	.align 	4
	.globl main
	.globl execute

main:
	push {r7, r10, ip, lr}
	mov r10, #1

@1
test_strtou_hex:
	bl write_test_n_begin

	ldr r0, =t_1
	bl arm_strtou

	mov r1, #0xF
	mov r1, r1, lsl #4
	add r1, #0xF
	mov r1, r1, lsl #4
	add r1, #3
	cmp r0, r1

	@se retorno de strtou for 4083
	ldreq r1, =sucesso
	@se nao
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@2
teste_strtou_dec:
	bl write_test_n_begin
	ldr r0, =t_2
	bl arm_strtou

	mov r1, #0xF
	mov r1, r1, lsl #4
	add r1, #0xD
	mov r1, r1, lsl #4
	add r1, #8
	mov r1, r1, lsl #4
	add r1, #4
	mov r1, r1, lsl #4
	add r1, #0xC
	push {r1}
	cmp r0, r1

	@se retorno de strtou for 1038412 (FD84C)
	ldreq r1, =sucesso
	@se nao
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@3
test_arm_utostr:
	bl write_test_n_begin
	pop	{r0}
	ldr r1, =aux
	bl arm_utostr
	bl write

	bl new_line
	bl write_test_n_end

@4
test_arm_strlen:
	bl write_test_n_begin
	ldr r0, =aux
	bl arm_strlen
	cmp r0, #7
	ldreq r1, =sucesso
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@5
test_arm_strcmp_1:
	bl write_test_n_begin
	ldr r0, =str1
	ldr r1, =str2
	bl arm_strcmp
	cmp r0, #0
	ldreq r1, =sucesso
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@6
test_arm_strcmp_2:
	bl write_test_n_begin
	ldr r0, =str1
	ldr r1, =str3
	bl arm_strcmp
	cmp r0, #1
	ldreq r1, =sucesso
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@7
test_arm_strcmp_3:
	bl write_test_n_begin
	ldr r0, =str3
	ldr r1, =str2
	bl arm_strcmp
	mov r3, #0
	sub r3, #1
	cmp r0, r3
	ldreq r1, =sucesso
	ldrne r1, =fracasso
	bl write

	bl write_test_n_end

@8
test_arm_memcpy_1:
	bl write_test_n_begin

	ldr r0, =aux2
	ldr r1, =aux
	mov	r2, #7
	bl arm_memcpy

	ldr r1, =aux2
	bl write

	bl new_line
	bl write_test_n_end

@9
test_arm_memcpy_2:
	bl write_test_n_begin
	ldr r0, =aux2
	ldr r1, =aux3
	mov	r2, #7
	bl arm_memcpy
	ldr r1, =aux2
	bl write

	bl new_line
	bl write_test_n_end

@10-?
test_get_command:
		ldr		r0, =param_1
		ldr		r1, =param_2
		bl		get_command

		mov		r1, #1
		cmp		r0, r1
		beq		test_get_command_step		@1
		sub		r1, #1
		cmp		r0, r1
		beq		test_get_command_quit		@0
		sub		r1, #1
		cmp		r0, r1
		beq		test_get_command_continue	@-1
		sub		r1, #1
		cmp		r0, r1
		beq		test_get_command_write		@-2
		sub		r1, #1
		cmp		r0, r1
		beq		test_get_command_print		@-3
		sub		r1, #1
		cmp		r0, r1
		beq		test_get_command_registers	@-4
		ldr		r1, =error_lbl
		bl		write

		b		test_get_command

	test_get_command_quit:
		ldr		r1, =quit_lbl
		bl		write

		b		test_get_command_end

	test_get_command_continue:
		ldr		r1, =continue_lbl
		bl		write

		b		test_get_command

	test_get_command_print:
		ldr		r1, =print_lbl
		bl		write

		ldr		r1, =param_1
		bl		write
		bl		new_line

		b		test_get_command

	test_get_command_registers:
		ldr		r1, =registers_lbl
		bl		write

		b		test_get_command

	test_get_command_step:
		ldr		r1, =step_lbl
		bl		write

		ldr		r1, =param_1
		bl		write
		bl		new_line

		b		test_get_command

	test_get_command_write:
		ldr		r1, =write_lbl
		bl		write

		ldr		r1, =param_1
		bleq	write
		bleq	new_line
		ldr		r1, =param_2
		bleq	write
		bleq	new_line

		b		test_get_command

test_get_command_end:

test_run_command:
		ldr		r0, =param_1
		ldr		r1, =param_2
		bl		get_command
		mov		r2, #0
		sub		r2, r2, #5
		cmp		r0, r2
		ldreq	r1, =error_lbl
		bleq	write
		beq		test_run_command
		ldr		r1, =param_1
		ldr		r2, =param_2
		bl		run_command

		mov		r1, #0
		cmp		r0, r1
		beq		test_run_command

		sub		r1, #1
		cmp		r0, r1
		ldreq	r1, =invalid_jmp_lbl
		bleq	write
		beq		test_run_command

		sub		r1, #1
		cmp		r0, r1
		ldreq	r1, =end_of_map_lbl
		bleq	write
		beq		test_run_command

		sub		r1, #1
		cmp		r0, r1
		ldreq	r1, =error_lbl
		bleq	write

		b		test_run_command

test_run_command_end:

end_tests:
	mov		r0, #1
	ldr		r1, =end
	mov		r2, #5
	mov		r7, #4
	svc		0

	pop		{r7, r10, ip, pc}

	mov		r7, #1
	svc		0

write_test_n_begin:
	push	{r0-r9, lr}
	ldr		r1, =test
	bl		write

	ldr		r1, =test_n
	mov		r0, r10
	bl		arm_utostr
	bl		write

	ldr		r1, =started
	bl		write

	pop		{r0-r9, pc}

write_test_n_end:
	push	{r0-r9, lr}
	ldr		r1, =test
	bl		write

	ldr		r1, =test_n
	mov		r0, r10
	bl		arm_utostr
	bl		write

	ldr		r1, =ended
	bl		write

	add		r10, r10, #1
	pop		{r0-r9, pc}

.data
	aux: 			.asciz "1111111\0"
	aux2: 			.asciz "Teste beeem grande, mais de 10 caracteres\0"
	aux3: 			.asciz "Teste isso aqui agora!\0"
	str1:			.asciz "tomas\0"
	str2:			.asciz "tomas\0"
	str3:			.asciz "bla\0"
	sucesso:		.asciz "Sucessoo\n\0"
	fracasso:		.asciz "fracasso\n\0"
	end:			.asciz "fim\n\0"
	test:			.asciz "Test "
	test_n:			.space 4
	started:		.asciz " started\n\0"
	ended:			.asciz " ended\n\0"

	t_1:	.asciz "0xFF3\0"

	t_2: 	.asciz "1038412\0"

	param_1:		.space 15
	param_2:		.space 15

	teste:			.space 10
	quit_lbl:		.asciz	"\nquit\n\0"
	step_lbl:		.asciz	"\nstep\n\0"
	continue_lbl:	.asciz	"\ncontinue\n\0"
	write_lbl:		.asciz	"\nwrite\n\0"
	print_lbl:		.asciz	"\nprint\n\0"
	registers_lbl:	.asciz	"\nregisters\n\0"
	execute_lbl:	.asciz	"\nexecute\0"
	error_lbl:		.asciz	"\nerror\n\0"
	invalid_jmp_lbl:.asciz	"\nsalto para endereco invalido\n\0"
	end_of_map_lbl:	.asciz	"\nfim do mapa de memoria\n\0"

