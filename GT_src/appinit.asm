; БИБЛИОТЕКА ПРЕРЫВНИЯ АППАРАТНОГО
;ИНИЦИАЛИЗАЦИИ CP/M И ОЧИСТОК ЭКРАНА
UP	EQU 80H
DOWN	EQU 20H
RIGHT	EQU 40H
LEFT	EQU 10H
FIRE	EQU 08H

PUSHA MACRO REG
	PUSH B
	PUSH D
	PUSH H
	IF NOT NUL REG
	PUSH PSW
	ENDIF
	ENDM
POPA MACRO REG
	IF NOT NUL REG
	POP PSW
	ENDIF
	POP H
	POP D
	POP B
	ENDM

RST07 MACRO MUSIC,NOKEY
;  ЗНАЧЕНИЯ:  MUSIC-ВСТАВИТЬ ПОДДЕРЖКУ МУЗЫКИ
;     NOKEY -  ВЫКЛЮЧИТЬ ПРЕОБРАЗОВАНИЕ КОДОВ GETKEY
APINIT:
	LOCAL INIT1,INIT2,INIT3,GETCODE
	LOCAL YKLAV,SETCOD,SETCO
	LOCAL RUSCON,@NAJ,@NONAJ
	PUSHA 1
	LHLD TIMER ;ТАЙМЕРА
	INX H	   ;ХВАТАЕТ НА 21 МИНУТУ
	SHLD TIMER ;(65536/50)
	LXI H,PEREP
	XRA A
	CMP M
	JZ INIT2
	DCR M
	LXI D,100FH
	LXI H,COLR15
INIT1:
	MOV A,E
	OUT 2
	MOV A,M
	OUT 0CH
	OUT 0CH
	NOP
	NOP
	DCX H
	OUT 0CH
	DCR E
	DCR D
	OUT 0CH
	JNZ INIT1
INIT2:
	MVI A,8AH
	OUT 0	
	LXI H,KEYS
	MVI A,0FEH
INIT3:
	MOV B,A
	OUT 3
	IN 2
	MOV M,A
	MOV A,B
	INX H
	RLC
	JC INIT3
	IF NUL NOKEY
	CALL GETCODE
	ENDIF
	MVI A,88H
	OUT 0
	LDA SCROLL
	OUT 3
	LDA BORDER
	OUT 2
	IN 7
	STA JOYPU  ; БЕРЕМ КОД ОТ ДЖОЯ *ПУ*
	IF NUL NOKEY
	LXI H,RUSCON
	IN 1
	RLC
	JC @NONAJ
	XRA A
	ORA M
	JZ @NAJ
	DCR M
	LDA KEYPAD
	XRI 2
	STA KEYPAD
	JMP @NAJ
@NONAJ:	MVI M,1
@NAJ:
	LDA KEYPAD
	ANI 2
	RLC
	RLC
	OUT 1
	ENDIF

	IF NOT NUL MUSIC
	LDA YCHAN1
	ORA A
	CNZ PLAY1CHAN
	LDA YCHAN2
	ORA A
	CNZ PLAY2CHAN
	LDA YCHAN3
	ORA A
	CNZ PLAY3CHAN
	ENDIF
	POPA 1
	EI 
	RET
KEYS:	DS 8
SCROLL:	DB 255
BORDER:	DB 0
OLD39H:	DW 0
COLR0:	DB 0,0,7,7,38H,38H,2BH,2BH,0C0H,0C0H
	DB 0C6H,0C6H,0E8H,0E8H,0ADH
COLR15:	DB 0ADH
PEREP:	DB 200
TIMER:	DS 2

	IF NUL NOKEY
GETCODE:
	XRA A
	STA KEY
	MVI C,0
SETCOD:	MVI B,8
	LXI H,KEYS
SETCO:	MOV A,M
	CPI 0FFH
	JNZ YKLAV
	MOV A,C
	ADI 8
	MOV C,A
	DCR B
	INX H
	JNZ SETCO
	RET
YKLAV:	RAR
	INR C
	JC YKLAV
	MOV A,C
	STA KEY
	RET
	ENDIF
	ENDM
; КОНЕЦ RST07 МАКРО
LPAUSE MACRO
;/// небольшая пауза (1/10 с) |||
	REPT 5
	HLT
	ENDM
	ENDM


TURBOCLS MACRO
	LOCAL TC1,TCEND
	JMP TCEND
@TC:
	DI
	LXI H,0
	DAD SP
	LXI SP,0E000H
	LXI D,0
	LXI B,0CFFH
	XRA A
TC1:	REPT 4
	PUSH D
	ENDM
	DCX B
	CMP B
	JNZ TC1
	SPHL
	EI
	RET
TCEND:
TURBOCLS MACRO
	CALL @TC
	ENDM
	TURBOCLS
	ENDM