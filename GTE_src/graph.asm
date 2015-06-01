; GRAPH.INC
; 2 MACROS BY 15 JANUARY OF 2000:
;  __POINT__,__CHAR__
; 3 MACRO AT 20JAN2000:__BOLDCHAR__
; USING MATH.LIB,APINIT.LIB

TABLSYM	EQU 1000H  ; АДРЕС ТАБЛИЦЫ СИМВОЛОВ (2KB)

PLOT:
	PUSHA 1
	MVI A,7
	ANA H
	LXI D,NumBit
	ADD E
	MOV E,A
	MOV A,H
	RRC
	RRC
	RRC
	ANI 1FH
	ORI 80H
	MOV H,A
	MOV A,L
	CMA
	MOV L,A
	LXI B,2000H
	LDAX D
	MOV D,A
	NOP
	ORA M
	MOV M,A
;	REPT 2	- ДЛЯ ПОДДЕРЖКИ 4-ЕХ ПЛОСКОСТЕЙ УБРАТЬ ';'
	DAD B
	MOV A,D
	NOP
	ORA M
        MOV M,A
;	ENDM	- СМ. КОММЕНТАРИЙ ВЫШЕ И НИЖЕ ПО ЛиСТУ
	DAD B
	MOV A,D
	NOP
WHCOL:	ORA M
	MOV M,A
	POPA 1
	RET

; СЛЕДУЮЩИЙ МАКР ПРИМЕНЕН ДЛЯ ТОГО,
; ЧТОБЫ ТАБЛИЦА NUMBIT НЕ ПЕРЕCЕКАЛАСЬ
; С ОБЛАСТЬЮ 0FFH-100H
; ИНАЧЕ САБЫ POINT & GETCOLOR НЕВЕРНО БУДУТ РАБОТАТЬ

NumBit:	DB 80H,40H,20H,10H,8,4,2,1
SETCOLOR:
 ;УСТАНОВКА ЦВЕТА ДЛЯ СAБЫ PLOT
	PUSH H
	ANI 0FH
	LXI H,xCOLOR ;ТЕКУЩИЙ ЦВЕТ = УСТАНАВЛИВАЕМОМУ?
	CMP M
	JZ SETC3
	MOV M,A ;ТЕК.ЦВЕТ=УСТ.
	PUSH D
	PUSH PSW
	MVI D,2  ; или MVI D,3 ДЛЯ ВКЛЮЧЕНИЯ I-ОЙ ПЛОЦК.
	LXI H,WHCOL
SETC0:
	RRC
	JNC SETC1
	MVI M,0B6H
	DCX H
	MVI M,0
	JMP SETC2
SETC1:	MVI M,0A6H
	DCX H
	MVI M,2FH  ; 'CMA'
SETC2:  
	REPT 4
	DCX H
	ENDM
	DCR D
	JP SETC0
	POP PSW
	POP D
SETC3:
	POP H
	RET
xCOLOR:	DB 5AH ;ТЕКУЩИЙ ЦВЕТ
; VERTICAL/HORIZONTAL LINE
;ЦВЕТ ЛИНИИ ЗДАЕТСЯ С ПОМОЩЬЮ SETCOLOR (КАК И ДЛЯ ТОЧКИ)
;НЕОБХОДИМО СЛЕДИТЬ, ЧТОБЫ ЛИБО X1=X2, ЛИБО Y1=Y2
;			ИЛИ X2-X1=Y2-Y1
;ИНАЧЕ ЛИНИЯ НЕ ПОЛУЧИТСЯ
VHLINE:
	PUSHA
	LXI B,0
	MOV A,H
	CMP D
	JZ $+10
	MVI B,1
	JC $+5
	MVI B,-1
	MOV A,L
	CMP E
	JZ  $+10
	MVI C,1
	JC $+5
	MVI C,-1
VHL0:	CMPHD   ;HL=DE?
	JZ VHL1 ;ДА- ВЫХОД
	CALL PLOT
	MOV A,H
	ADD B
	MOV H,A
	MOV A,L
	ADD C
	MOV L,A
	JMP VHL0
VHL1:	POPA
	RET
RECT:
;	чертим прямоугольник
;ВХОД:	HL-X1,Y1 ,  DE-X2,Y2
	PUSHA
	PUSH D
	MOV E,L
	CALL VHLINE
	POP D
	PUSH H
	MOV H,D
	CALL VHLINE
	POP H
	PUSH H
	MOV L,E
	CALL VHLINE
	POP H
	MOV D,H
	CALL VHLINE
	POPA
	RET

; находим цвет точки HL в A


;///// ВЫВОД СИМВОЛА НА ЭКРАН В 3-Х ПЛОСКОСТЯХ //////
PUTUCHAR:
	PUSHA 1
	PUSH PSW
	XCHG
	MOV L,A
	MVI H,0
	DAD H
	DAD H
	DAD H
	LXI B,TABLSYM ;СЛОЖИМ С АДРЕСОМ НАЧАЛА
	DAD B 	; ТАБЛИЦЫ СИМВОЛОВ	
	XCHG
	MVI A,80H
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A
	MVI B,8	
	;
PUC1:	LDA HEIGHT
	MOV C,A  ;//////высота символа//////
PUC2:
	REPT 2  ; ИЛИ REPT 3 ДЛЯ ПОДДЕРЖКИ 4-ЕХ ПЛОСКOСТЕЙ
	  LDAX D
	  NOP
	  MOV M,A
	  MVI A,20H
	  ADD H
	  MOV H,A
	  ENDM
	LDAX D
PCOL1:	NOP ; ОБРАБОТКА (nop,xra a,cma)
	mov m,a
	MVI A,0C0H
	ADD H
	MOV H,A
	DCR L
	DCR C
	JNZ PUC2
	INX D
	DCR B
	JNZ PUC1
	POP PSW
	POPA 1
	RET
HEIGHT:	DB 1

;/////// установка цвета для символов,выводимых PUTUCHAR ///
;
CHARCOLOR:
	PUSH B
	PUSH H
	MOV B,A
	MVI C,0
	ANI 10H
	JZ $+5
	MVI C,2FH   ;'CMA'
	MOV A,B
	MVI B,2  ;ДЛЯ ВКЛЮЧЕНИЯ I-ОЙ ПЛОСКОСТИ- MVI B,3
	LXI H,PCOL1
CHC1:	RRC
	MOV M,C
	JC $+5
	MVI M,0AFH
	REPT 7
	DCX H
	ENDM
	DCR B
	JP CHC1
	POP H
	POP B
	RET

;////// ВЫВОД ИНФО НА ДИСПЛЕЙ //////////////
OUTINFO:
	POP H
	MOV A,M
	INX H
	ORA A 
	JZ INFEND
	CPI 1
	JZ SETCURS
	CPI 2
	JZ PUTBYTE
	CPI 3
	JZ HEXOUT ;ВЫВОД HEX-ЧИСЛА
	CPI 4
	JZ TWOCIFR ;ВЫВОД ЛИШЬ 2 ЗНАЧ.ЦИФР
	CPI 5
	JZ PUTWORD
	CPI 6
	JZ chHEIGHT ; меняем высоту выводимых символов
	CPI 7
	JZ chCOLOR  ;меняем цвет выводимыхсимволов
	CPI 13
	JZ CRLF
	CPI 12
	JZ TABX
;////// ИНАЧЕ ПРОСТО ВЫВОДИМ СИМВОЛ /////////
	PUSH H
	LHLD CURSOR
	CALL PUTUCHAR
	LXI H,CURSOR+1
	INR M
	POP H
	JMP OUTINFO+1
INFEND:	PCHL
CURSOR:	DW 0
SETCURS:
	MOV A,M
	STA CURSOR
	INX H
	MOV A,M
	STA CURSOR+1
	INX H
	JMP OUTINFO+1
HEXOUT:
	MOV A,M
	INX H
	PUSH H
	CALL $+7
	POP H
	JMP OUTINFO+1
	PUSH PSW
	RRC
	RRC
	RRC
	RRC
	CALL $+4
	POP PSW
	ANI 0FH
	ADI 90H
	DAA
	ACI 40H
	DAA
	LHLD CURSOR
	CALL PUTUCHAR
	INR H
	SHLD CURSOR
	RET
TWOCIFR:
	MOV A,M
	PUSH H
	MOV L,A
	MVI H,0
	CALL tBYTE
	POP H
	INX H
	JMP OUTINFO+1
TABX:	LDA CURSOR+1
	ADD M
	STA CURSOR+1
	INX H
	JMP OUTINFO+1

chHEIGHT:
	MOV A,M
	STA HEIGHT
	INX H
	JMP OUTINFO+1
chCOLOR:
	MOV A,M
	CALL CHARCOLOR
	INX H
	JMP OUTINFO+1
CRLF:	PUSH H
	LHLD CURSOR
	MVI H,0
	INR L
	SHLD CURSOR
	POP H
	JMP OUTINFO+1
;//////// вывод слова в 10-тичной системе /////////
PUTWORD:
	MOV E,M
	INX H
	MOV D,M
	INX H
	PUSH H
	XCHG
	CALL SETCIF
	POP H
	JMP OUTINFO+1
SETCIF:	LXI B,-10000
	CALL PUTCIF
	LXI B,-1000
	CALL PUTCIF
sBYTE:
	LXI B,-100
	CALL PUTCIF
tBYTE:	LXI B,-10
	CALL PUTCIF
	MOV A,L
	JMP OUTC2
PUTCIF:	MVI E,255
	INR E
	DAD B
	JC $-2
	MOV A,L
	SUB C
	MOV L,A
	MOV A,H
	SBB B
	MOV H,A
	MOV A,E
OUTC2:	ADI 30H
	PUSH H
	LHLD CURSOR
	CALL PUTUCHAR
	LXI H,CURSOR+1
	INR M
	POP H
	RET
PUTBYTE:
	MOV A,M
	INX H
	PUSH H
	MOV L,A
	MVI H,0
	CALL sBYTE
	POP H
	JMP OUTINFO+1

PUTSTRING:
;ВЫВОД СТРОКИ ASCIIZ,  DE - ADDRR, HL-CURSOR
	PUSH H
	PUSH PSW
PUTST0:
	LDAX D
	ORA A
	INX D
	JZ PUTST1 ;FIN OF STRING
	CALL PUTUCHAR ;CHAR OUT
	INR H
	MVI A,1FH
	ANA H
	JNZ PUTST0
	MOV H,A ; H=0
	INR L   ; NEXT STRING
	JMP PUTST0
PUTST1:	POP PSW
	POP H
	RET
