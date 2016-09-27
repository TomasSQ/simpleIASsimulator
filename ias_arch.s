@A macro abaixo eh usada para que possamos declarar um mapa de memoria
@de modo simplificado, sem ter que colocar a diretiva .byte manualmente
@a cada byte.

.macro	dec_bytes	byte1 byte2 byte3 byte4 byte5
	.byte 0x\byte1
	.byte 0x\byte5
	.byte 0x\byte4
	.byte 0x\byte3
	.byte 0x\byte2
.endm


.data
	.align 4
	.globl IAS_MEM_MAP
	.globl PC
	.globl AC
	.globl MQ

PC:
	.space 5
AC:
	.space 5
MQ:
	.space 5

IAS_MEM_MAP:
	dec_bytes 09 3F C0 A0 00	@	0x000	LOAD MQ, M(0x3FC)		LOAD MQ
	dec_bytes 21 30 00 13 FF	@	0x001	STOR M(0x300)			LOAD M(0x3FF)
	dec_bytes 02 3F F0 33 FB	@	0x002	LOAD -M(0x3FF)			LOAD |M(0x3FB|
	dec_bytes 0D 00 41 00 04	@	0x003	JUMP M(0x004, 0:19)		JUMP +M(0x004, 20:39)
	dec_bytes 0E 00 30 F0 05 	@	0x004	JUMP M(0x003, 20:39)	JUMP +M(0x005, 0:19)
	dec_bytes 02 3F F1 00 04	@	0x005	LOAD -M(0x3FF)			JUMP +M(0x004, 20:39
	dec_bytes 0F 00 50 D0 07	@	0x006	JUMP +M(0x005, 0:19)	JUMP M(0x007, 0:19)
	dec_bytes 05 3F F0 83 FF	@	0x007	ADD M(0x3FF)			SUB |M(0x3FF)|
	dec_bytes 01 3F 60 53 F7	@	0x008	LOAD M(0x3F6)			ADD M(0x3F7)
	dec_bytes 01 3F 60 73 FB	@	0x009	LOAD M(0x3F6)			ADD |M(0x3FB)|
	dec_bytes 01 3F 60 53 FB	@	0x00A	LOAD M(0x3F6)			ADD M(0x3FB)
	dec_bytes 01 3F 80 63 F9	@	0x00B	LOAD M(0x3F8)			SUB M(0x3F9)
	dec_bytes 01 3F 80 63 FC	@	0x00C	LOAD M(0x3F6)			SUB M(0x3FC)
	dec_bytes 01 3F 80 83 FB	@	0x00D	LOAD M(0x3F6)			SUB |M(0x3FC)|
	dec_bytes 01 3F 80 63 FB	@	0x00E	LOAD M(0x3F6)			SUB M(0x3FC)
	dec_bytes 01 3F 61 40 00	@	0x00F	LOAD M(0x3F6)			LSH
	dec_bytes 01 3F C1 40 00	@	0x010	LOAD M(0x3FC)			LSH
	dec_bytes 01 3F 61 50 00	@	0x011	LOAD M(0x3F6)			RSH
	dec_bytes 01 3F 51 20 13	@	0x012	LOAD M(0x3F5)			STOR M(X, 8:19)
	dec_bytes 01 00 00 D0 14	@	0x013	nada
	dec_bytes 01 3F 51 30 15	@	0x014	LOAD M(0x3F5)			STOR M(X, 28:39)
	dec_bytes 01 00 00 D0 14	@	0x015	nada

	.fill	991, 5, 0		 @preenche 999 linhas com 5 bytes nulos cada

	dec_bytes FF FF FF F3 FE @0x3F5 - lixo + 3FE
	dec_bytes 01 00 00 00 02 @0x3F6
	dec_bytes 02 00 00 00 01 @0x3F7
	dec_bytes FF 00 00 00 01 @0x3F8
	dec_bytes FF 00 00 00 00 @0x3F9
	dec_bytes FF FF FF FF FB @0x3FA -5
	dec_bytes FF FF FF FF FC @0x3FB -4
	dec_bytes 12 34 56 78 9A @0x3FC aux
	dec_bytes 00 00 00 00 10 @0x3FD pos do vetor 1
	dec_bytes 00 00 00 00 13 @0x3FE pos do vetor 2
	dec_bytes 00 00 00 00 03 @0x3FF tamanho dos vetores

@note que o total de linhas eh 1024
