
PUTBIG:	; ВЫВОД КАРТЫ 16*16
	CALL PUTUCHAR
	INR H
	INR A
	CALL PUTUCHAR
	INR A
	INR L
	INR A
	CALL PUTUCHAR
	DCR A
	DCR H
	JMP PUTUCHAR

PUTOBJ:	;ВЫВОД ОБ'ЕКТА 16*16 
	PUSH B
	PUSH H
	CALL PUTSCHAR
	INR H
	INR B
	CALL PUTSCHAR
	INR L
	INR B
	INR B
	CALL PUTSCHAR
	DCR H
	DCR B
	CALL PUTSCHAR
	POP H
	POP B ;ВОССТ.РЕГ
	RET   ; И ВСЕ?

PUTSCHAR:
	PUSHA 1
	XCHG
	MOV L,B
	MVI H,0
	PUSH H
	LXI B,TABLCOLSYM ;АДРЕС ТАБЛИЦЫ ЦВЕТОВ
	DAD B
	MOV A,M
	STA COLSYM ;ОПРЕДЕЛИМ ЦВЕТ СИМВОЛА
	POP H
	DAD H
	DAD H
	DAD H
	LXI B,TABL2SYM
	DAD B
	XCHG
	MVI A,0E0H
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A
	CALL PUTSO0
	CALL PUTSO0
	CALL PUTSO0
	POPA 1
	RET  ;{PUTSCHAR}
PUTSO0:	MVI A,-20H
	ADD H
	MOV H,A
	LDA COLSYM
	RRC
	STA COLSYM
	JNC PUTSO1 ;СТИРАЕМ ПЛОСКОСТЬ
	PUSH H
	PUSH D
	LDAX D
	MOV M,A
	REPT 7
	INX D
	DCR L
	LDAX D
	MOV M,A
	ENDM
	POP D
	POP H
	RET
PUTSO1:	PUSH H
	XRA A
	MOV M,A
	REPT 7
	DCR L
	MOV M,A
	ENDM
	POP H
	RET


RAMKA:	; ВЫВОД РАМКИ
;ВХОД:	BC - X1,Y1 ; DE- X2,Y2
	MOV H,B
RAMA1:	MOV L,C
	MVI A,32
	CALL PUTUCHAR ; ВЫВЕДЕМ ПРОБЕЛ
	MOV L,E
	CALL PUTUCHAR
	INR H
	MOV A,H
	CMP D
	JC RAMA1
	JZ RAMA1
	MOV L,C
RAMA2:	MOV H,B
	MVI A,32
	CALL PUTUCHAR
	MOV H,D
	CALL PUTUCHAR
	INR L
	MOV A,L
	CMP E
	JC RAMA2
	JZ RAMA2
	RET  ;  {RAMKA}
PUTSTCHAR:
;ВЫВОД СИМВОЛА 8*8 НА ЭКРАН В 3-Х ПЛОСКОСТЯХ,
;ИСПОЛЬЗУЯ ТАБЛИЦУ СИМВОЛОВ 2
	
;  ВЫВОД ТЕКУЩЕЙ СТАТИСТИКИ УРОВНЯ
PUTSTAT:
	LXI B,0F11H
	LXI D,1012H
PTS0:	CALL RAMKA ; СОТРЕМ  РАМКОЙ ЧАСТЬ ЭКРАНА
	DCR B
	DCR C ;X1-1,Y1-1
	INR D
	INR E
	HLT
	HLT
	MOV A,B
	CPI 7
	JNC PTS0
	MVI A,7
	CALL SETCOLOR
	LXI H,3848H
	LXI D,0C7D7H
	CALL RECT  ; ОБВОДЯЩУЮ РАМКУ ВЫВЕДЕМ БЕЛЫМ ЦВЕТОМ
	MVI A,3
	CALL SETCOLOR
	LXI H,4454H
	LXI D,44B4H
	CALL VHLINE
	LXI H,5CCCH
	CALL VHLINE
	LXI D,0A4CCH
	CALL VHLINE
	LXI H,0BCB4H
	CALL VHLINE
	LXI D,0BC54H
	CALL VHLINE
	
PTS01:	MVI C,7
	LHLD LEVPTR ;ИМЯ УРОВНЯ В САМОМ НАЧАЛЕ ЗАГОЛОВКА
	XCHG	;В *DE
	LXI H,090AH
	MVI B,14
	CALL PRINTIT
	LDA CURLEV
	STA i0 ;НОМЕР ТЕК.УРОВНЯ
	CALL OUTINFO
	DB 7,4,1,19H,0CH,'ПОЛЕ: ',4
i0:	DB 0,1,0CH,9,6,2,'ЦЕЛЬ:',6,1,0
	LHLD LEVPTR
	LXI D,15
	DAD D
	MOV A,M ;ПОЛУЧИМ ЦЕЛЬ МИССИИ
	JMP DALEE
PRINTGOAL:
	ANI 3
	ADD A
	LXI H,ADDRGOALS
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	LXI H,0E0CH
	CALL PUTSTRING ; ВЫВОДИМ ЦЕЛЬ МИССИИ
	INR L
	JMP PUTSTRING ; ВТОРАЯ ЧАСТЬ ЦЕЛИ
DALEE:	CALL PRINTGOAL
	CALL OUTINFO16
;------------------------------------
;           Y , X, CODE	  ;NAME
;------------------------------------ 
	DB 11H,10,16      ;TIGER
	DB 13H,10,32      ;TANKETTE
	DB 15H,10,48  	  ;ATANK
	DB 0FH,11H,64 	  ;PANTHER
	DB 11H,11H,80 	  ;KILLER
	DB 13H,11H,96 	  ;TRIKE
	DB 15H,11H,112	  ;BMP
	DB 255 ;КОНЕЦ INFO16

; ТЕПЕРЬ ПЕРЕУСТАНОВИМ 8 ЯЧЕЕК ДЛЯ ВЫВОДА
	LHLD LEVPTR ; ЧИСЛО НЕ УБИТОГО ЕЩЕ ПРОТИВНИКА
	PUSH H
	LXI D,14
	DAD D  ;ВОЗЬМЕМ ИЗ ЗАГОЛОВКА УРОВНЯ 
	MOV A,M
	STA iLMAXY ;LMAXY
	INX H
	INX H
	MOV A,M
	STA iLEVY ;LEVY
	POP H
	LXI D,25
	DAD D
	MOV A,M
	STA iBASEHP ;ХТ-ПОИНТЫ БАЗЫ ДЛЯ ВЫВОДА НА ЭКРАН
	LXI D,-8
	DAD D
	XCHG
	LDAI
	STA i1
	LDAI
	STA i2
	LDAI
	STA i3
	LDAI
	STA i4
	LDAI
	STA i5
	LDAI
	STA i6
	LDAI
	STA i7
	LDAI
	STA i8
	CALL OUTINFO
	DB 6,1,7,7 ; ВЫСОТА СИМВОЛОВ- 1, ЦВЕТ- БЕЛЫЙ
	DB 1,15,13,4
i1:	DB 0,1,11H,13,4
i2:	DB 0,1,13H,13,4
i3:	DB 0,1,15H,13,4
i4:	DB 0,1,15,14H,4
i5:	DB 0,1,11H,14H,4
i6:	DB 0,1,13H,14H,4
i7:	DB 0,1,15H,14H,4
i8:	DB 0,6,1,1,14,10,7,2,'BASEHP:',7,7,4
iBASEHP:
	DB 0,7,1,1,17H,11,'LMAXY:',7,7,3 ; HEXOUT OF BYTE
iLMAXY:	DB 0,7,1,'h',7,2,1,18H,12,'LEVY:',7,7,3
iLEVY:	DB 0,'h',0
	LPAUSE
	RET ; ВСЕ?

OUTINFO16:
; ВЫВОД РИСУНКОВ 16х16
	POP H
	MOV A,M
	INX H
	CPI 255
	JZ OIF16E ;КОНЕЦ
	MOV E,A
	MOV D,M
	INX H
	MOV B,M
	INX H
	XCHG
	CALL PUTOBJ  ; ВЫВОДИМ ОБ'ЕКТ 16х16
	XCHG ; ВЕРНЕМ АДРЕС В HL
	JMP OUTINFO16+1
OIF16E:	PCHL

;АДРЕСА НАДПИСЕЙ И САМИ НАДПИСИ
ADDRGOALS:
	DW GOAL1,GOAL2,GOAL3,GOAL4
GOAL1:	DB 'ТЕСТ     ',0,'УРОВНЯ   ',0
GOAL2:	DB 'ЗАЩИТА   ',0,'БАЗЫ     ',0
GOAL3:	DB 'АТАКА    ',0,'БАЗЫ     ',0
GOAL4:	DB 'УНИЧТОЖЕ-',0,'НИЕ ВРАГА',0
AUTHOR:	DB 'А.В. Плешаков',0,'Вектор-06Ц',0

RUSE:	DB 0  ; КОНЕЦ НАДПИСЕЙ (2KOI8 НЕ ЗАБУДЬ ИХ ПРОГНАТЬ)

FINDLEVEL:
;	ПОИСК УРОВНЯ ПО НОМЕРУ В <А>
;	ЗАПИСЬ АДРЕСА НАЧАЛА УРОВНЯ В LEVPTR
	LXI H,FIRSTLEVEL ;АДРЕС НАЧАЛА ПЕРВОГО УРОВНЯ
FINDL1:	SHLD LEVPTR
	DCR A
	JZ FINDL3 ; НАШЛИ УРОВЕНЬ ТРЕБУЕМЫЙ
	PUSH PSW
	PUSH H
	LXI D,14
	DAD D
	MOV A,M ; A=  LMAXY
	INR A
	RAR
	MOV E,A
	XCHG  ; HL = 0 [ LMAXY+1 / 2]
	DAD H
	DAD H
	DAD H
	DAD H
	LXI D,30
	DAD D ;+ HEADER
	POP D
	DAD D ;+ AДРЕС НAЧАЛА УРОВНЯ
	POP PSW
	JMP FINDL1
FINDL3:	; ТЕПЕРЬ ЛИШЬ ЗАПОЛНИМ ЯЧЕЙКУ  LMAXY
	LXI D,14
	DAD D
	MOV A,M
	STA LMAXY
	LXI D,-14
	DAD D 
	RET ; И ВСЕ?

; БЫСТРЫЙ ВЫВОД СИМВОЛА 16x16 
;СИМВОЛ ДОЛЖЕН СОСТОЯТЬ ИЗ 4 МАЛЫХ(8х8)
;ВЫВОДЯТСЯ: 1 2
;	    3 4
;СИМВОЛЫ МОЖНО НАРИСОВАТЬ В SISE
;ИЛИ В БУДУЩЕМ ISE(IMAGE SYMBOL EDITOR)
WHPL:	DB 0C0H  ; СТ.БАЙТ АДРЕСА  НАЧАЛА ПЛОСКОСТИ

;ВХОД:HL-CURSOR X,Y(0..1FH),B - KOD 1-ГО СИМВОЛА ИЗ ТАБЛИЦЫ
PUT16x16:
	PUSHA 1
	XCHG
	MVI H,0
	MOV L,B
	DAD H
	DAD H
	DAD H
ACHAR16:	; ПОДСТАВЛЕНИЕ АДРЕСА НУЖНОЙ ТАБЛИЦЫ
	LXI B,TABL2SYM;АДРЕС НАЧАЛА ТАБЛ.СИМВОЛОВ
	DAD B
	XCHG
	LDA WHPL ;ГЛОБИДЕН СОДЕРЖ.СТ.БАЙТ ПЛОСК.
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A ;*8
	CMA
	MOV L,A
;ИТАК,ТЕПЕРЬ В HL-АБСОЛЮТНЫЙ АДРЕС  VRAM
;	A В DE-АДРЕС БАЙТ ВЫВОДИМОГО  СИМВОЛА
	LDAX D
	MOV M,A
	REPT 7
	INX D
	DCR L
	LDAX D
	MOV M,A
	ENDM
;ВЫВЕЛИ ПЕРВЫЙ СИМВОЛ.TЕПЕРЬ ВЫВОДИМ ВТОРОЙ!!!
	MVI A,8 ;ПРИБАВИМ НА 1 БОЛЬШЕ
	ADD L   ;ДЛЯ CОЗДАНЯ ПРОСТОГО МАКРА
	MOV L,A
	INR H
	REPT 8
	INX D
	DCR L
	LDAX D
	MOV M,A
	ENDM

	DCR L  ;НЕ ЗАБУДЬ ПРО ЭТУ КОМАНДУ
	DCR H
	INX D
	LDAX D ;ВЫВОДИМ 3-ИЙ СИМВОЛ
	MOV M,A
	REPT 7
	INX D
	DCR L
	LDAX D
	MOV M,A
	ENDM

	MVI A,8
	ADD L
	MOV L,A ;ВЕРНЕМ СТРОКУ
	INR H   ;СДВИНЕМ СТОЛБЕЦ
	REPT 8
	INX D ;ВЫВОДИМ 4-ЫЙ, ПОСЛЕДНИЙ,СИМВОЛ
	DCR L
	LDAX D
	MOV M,A
	ENDM
	POPA 1
	RET

PUTLEVEL:
; ВЫВОД УРОВНЯ НА ЭКРАН С ПОЗИЦИИ ELEVY
	LDA ELEVY
	MOV C,A
	MVI B,0
	CALL GETAD
	XCHG
	MVI L,4 ;НАЧАЛЬ.СТРОКА
PTL0:	MVI H,0
	MVI C,16 ;ЧИСЛО СИМВОЛОВ В СТРОКЕ
PTL1:	LDAX D
	INX D
	MOV B,A
	CALL PUTOBJ
	INR H
	INR H
	DCR C
	JNZ PTL1
	INR L
	INR L
	MOV A,L
	CPI 20H
	JC PTL0
PRINTPL: ;ТЕПЕРЬ ВЫВЕДЕМ ПОЛОЖЕНИЕ ИГРОКОВ, ЕСЛИ ОНИ ВХОДЯТ
	; ВИДИМУЮ ОБЛАСТЬ ЭКРАНА
	LDA ELEVY
	MOV C,A
	LHLD LEVPTR
	LXI D,26
	DAD D
	MOV B,M
	INX H
	PUSH H
	MOV A,M
	MOV H,B ;УХИЩРЕНИЯ, САМ ЧЕРТ НОГУ СЛОМИТ
	SUB C
	ADI 4
	CPI 4
	JC PRPL2
	CPI 20H
	MOV L,A
	MVI B,0 ;КОД ВЫВИМОЙ КАРТИНКИ (ТАНК)
	CC PUT16x16
PRPL2:	POP H
	INX H
	MOV B,M
	INX H
	MOV A,M ; A= PL2.CURY
	SUB C	; - ELEVY
	ADI 4
	CPI 4
	RC
	MOV H,B
	MOV L,A
	MVI B,0
	CPI 20H
	JC PUT16x16 ; ВЫВОДИМ ТОЛЬКО ЕСЛИ ПОПАЛ В ВИДИМУЮ
	RET  ; ОБЛАСТЬ ЭКРАНА
