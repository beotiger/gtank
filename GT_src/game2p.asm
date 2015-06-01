;//////////  GAME2P.LIB \\\\\\\\\\\\\
;*****   ИГРОВАЯ БИБЛИОТЕКА     *****
;
;MAKROS:	KEYS2P,CHAR16 (BY 26JAN2000)gDw

;> ОБСЛУЖИВАНИЕ ВСЕЙ КЛВИАТУРЫ
;> БЫСТРЫЙ ВЫВОД СИМВОЛА  НА ЭКРАН
;> ПОДПРОГРАММЫ ЗАДАНИЯ КЛАВИШ
;
;
;

;
;ОТСЮДА ВИДНО, ЧТО ДЛЯ РАБОТЫ ЭТОЙ БИБЛИОТЕКИ
;СЛЕДУЕТ ПОДКЛЮЧАТЬ APINIT.LIB+GARPH.LIB

TABL2SYM EQU TABLSYM+800H ;ТАБЛИЦА СИМВOЛОВ 16х16

; !!!!!!!!!!! KEYS2P !!!!!!!!!!!!
KEYS2P	MACRO PLAYER2,xtKEY
	LOCAL GETKEY,GETK0,GETK1
;УСТАНОВИТЕ PLAYER2(ЛЮБОЕ ЗНАЧЕНИЕ)DЛЯ 2-Х ИГРОКОВ
;УСТАНОВИТЕ xtKEY ДЛЯ ИСПОЛЬЗОВАНИЯ 6-КЛАВИШ ВМЕСТО 5

;ВЫБОР ВНУТР.КОДА НАЖАТИЯ
;ЖДЕТ ПОКА НЕ НАЖАТА
GETKEY:
	PUSHA
GETK0:	MVI B,7
	LXI H,KEYS+7;МАССИВ КЛАВИШ, УСТ.RST07
GETK1:	MOV A,M
	CPI 255 ;ЕСТЬ НАЖАТИЕ?
	JNZ GETK2;ДА!
	DCX H
	DCR B
	JP GETK1
	LPAUSE ;ВЫДОХНЕМ
	JMP GETK0 ; ПО НОВОЙ
GETK2:	MVI C,255
	INR C
	RAL
	JC $-2
	MOV A,C
	RRC
	RRC
	RRC
	ORA B
	MOV B,A
	MVI A,255
	CMP M  ;КЛАВИША ОТПУЩЕНА?
	JNZ $-1 ;НЕТ-ВЕЧНЫЙ ЦИКЛ
	LPAUSE
	MOV A,B ;ВЕРНЕМ КОД B <A>
	POPA
	RET ;ВЫХОД С КОДОМ НАЖАТИЯ В <A>
INITKEYS:
;ПЕРЕОПРЕДЕЛЕНИЕ КЛАВИШ
;ВХОД: A=0 ДЛЯ ПЕРВОГО ИГРОКА
;      А=1 ДЛЯ ВТОРОГО (ЕСЛИ ЗАДАН PLAYER2)
;      L-КУРСОР ПО  Y(0-30)ГДЕ ВЫВОДИТЬ СТРОКИ
	LXI D,sNUMPL1
	IF NUL PLAYER2
	ELSE
	ORA A
	JZ $+6
	LXI D,sNUMPL2
	MOV B,A
	ENDIF
	MVI H,11 ;КООРД.Х ДЛЯ  ВЫВОДА СТРОКИ
	MVI A,7
	CALL CHARCOLOR ;ЦВЕТ
	CALL PUTSTRING
	INR L
	MVI H,5
	LXI D,sPRKEY
	MVI A,5
	CALL CHARCOLOR
	CALL PUTSTRING
	MVI H,15H
	MOV A,H
	CALL CHARCOLOR ;INVERSE ON
	LXI D,sKEYNAMES ;НАЗВАНИЯ ЕБАННЫХ КЛАВИШ, МАТЬ ИХ
	IF NOT NUL PLAYER2
	XRA A
	ORA B
	LXI B,PL1KEYS ;КОДЫ КЛАВИШ 1-ГО ИГРОКА
	JZ $+6
	LXI B,PL2KEYS ;КОДЫ КЛАВИШ 2-ГО ИГРОКА
	ELSE
	LXI B,PL1KEYS
	ENDIF
	IF NUL xtKEY
	MVI A,5
	ELSE
	MVI A,6
	ENDIF
	LOCAL INK1
INK1:	PUSH PSW
	CALL PUTSTRING ;ВЫВЕДЕМ СТРОКУ С НАЗВАНИЕМ КЛВИШИ
	CALL GETKEY ;ЖДЕМ НАЖАТИЯ
	STAX B	   ;ЗАПИШЕМ КОД В ПАМЯТЬ
	INX B
	POP PSW
	DCR A
	JNZ INK1
	RET ;{INITKEYS}

PL1KEYS:  ;КОДЫ ПРОГРАММНЫЕ КЛАВИШ ДЛЯ 1-ГО ИГРОКА
	DB 40H,20H,0,60H,080H,0A0H
sNUMPL1:
	DB '1-',217,202,32,201,199,210,207,203,0
	IF NOT NUL PLAYER2
PL2KEYS:
	DB 46H,0C4H,6,0C7H,24H,0A5H
sNUMPL2:
	DB '2-',207,202,32,201,199,210,207,203,0
;НАДПИСЬ '2-ой игрок' в КОИ-8, МАТЬ ЕЕ ЗА НОГУ
	ENDIF	
;ДАЛЕЕ НАДПИСЬ:'Нажмите клавишу '
sPRKEY:	DB 238,193,214,205,201,212,197,32
	DB 203,204,193,215,201,219,213,32,0
sKEYNAMES:
	DB 247,247,229,242,232,32,0 ;ВВЕРХ
	DB 247,240,242,225,247,239,0;ВПРАВО
	DB 247,238,233,250,32,32,0  ;ВНИЗ
	DB 247,236,229,247,239,32,0 ;ВЛЕВО
	DB 239,231,239,238,248,32,0 ;ОГОНЬ
	DB 247,249,226,239,242,32,0 ;ВЫБОР

;ЯЧЕЙКИ СО ФЛАГАМИ НАЖАТЫХ КЛАВИШ
;
KEY1P:	DB 0
	IF NOT NUL PLAYER2
KEY2P:	DB 0
	ENDIF
KEYBOARD:
;ОСНОВНА САБА УСТАНОВКИ ФЛАГОВ НАЖАТЫХ КЛАВИШ
;ФЛАГИ УСТАНАВЛИВАЮТСЯ СПРАВА НАЛЕВО В ТОМ ПО-
;РЯДКЕ,В КОТОРОМ ПЕРЕЧИСЛЕНЫ НАЗВАНИЯ КЛАВИШ ВВЕРХУ:
;БИТЫ KEY1P,KEY2P:
;d7- UP, d5- DOWN, d6- RIGHT, d4- LEFT
;d3- FIRE, d2- FIRE2 (CHOICE, JUMP etc.)
;ЕСЛИ 1, ТО СООТВЕТСТВУЮЩАЯ КЛАВИША НАЖАТА
;В ДАННЫЙ МОМЕНТ, ИНАЧЕ БИТ РАВЕН 0
;ВСЕ КАК У ЛЮДЕЙ, ВСЕ ПО-РУССКИ
;ТОЛЬКО КЛАВИАТУРА У ВЕКТОРА  КРИВАЯ
;КНОПКИ  НАЖИМАЮТСЯ ЧЕРЕЗ ЖОПУ,ОЙ ЧЕРЕЗ РАЗ
;СЕЙЧАС 11:30 НОЧИ 26 января 2000 года от р.Х.

; Я СЕЙЧАС (19ФЕВ2000РХ) СДЕЛАЛ СОВМЕСТИМОСТЬ
; ОПРОСА КЛАВЫ С ОПРОСОМ ДЖОЯ ПУ

	LXI D,PL1KEYS+4 ;ТОЛЬКО 5 КЛАВ(ДЛЯ Г-ТАНК)
	MVI C,0
	REPT 5
	LDAX D
	ANI 7
	LXI H,KEYS ;СКАН-КОДЫ ИЗ RST07(APINIT.LIB)
	XLAT B
	LDAX D
	RLC
	RLC
	RLC
	ANI 7
	LXI H,NUMBIT ;А ЭТО МАСИВ ИЗ POINT(GRAPH.LIB)
	XLAT ; new i8080 instruction: MOV A,[HL]+A
	ANA B
	JNZ $+4 ;БИТ ЕСТЬ, НАЖАТИЯ НЕТ.НЕ  ПО-РУСКИ КАК-ТО
	STC
	ROR C
	DCX D
	ENDM
	STA KEY1P ;C STORE IN MEMORY

	IF NOT NUL PLAYER2
;ДЛЯ ВТОРОГО ИГРОКА ПРОДЕЛЫВЕМ АНАЛОГИЧНУЮ ПРОЦЕДУРУ
	LXI D,PL2KEYS+4
	MVI C,0
	REPT 5
	LDAX D
	LXI H,KEYS
	ANI 7
	XLAT B
	LDAX D
	RLC
	RLC
	RLC
	ANI 7
	LXI H,NUMBIT
	XLAT
	ANA B
	JNZ  $+4
	STC
	ROR C
	DCX D ;НА СЛЕД.КОД
	ENDM
	STA KEY2P
	ENDIF
	RET ;ВСЕ?{KEYBOARD}

	ENDM
;ЗДЕСЬ КОНЕЦ МАКРА KEYS2P PLAYER2,xtKEY



CHAR16	MACRO
;
; БЫСТРЫЙ ВЫВОД СИМВОЛА 16x16 
;СИМВОЛ ДОЛЖЕН СОСТОЯТЬ ИЗ 4 МАЛЫХ(8х8)
;ВЫВОДЯТСЯ: 1 2
;	    3 4
;СИМВОЛЫ МОЖНО НАРИСОВАТЬ В SISE
;ИЛИ В БУДУЩЕМ ISE(IMAGE SYMBOL EDITOR)
WHPL:	DB 0A0H
;ВХОД:HL-CURSOR X,Y(0..1FH),B - KOD 1-ГО СИМВОЛА ИЗ ТАБЛИЦЫ
PUT16x16:
	PUSHA
	XCHG
	MVI H,0
	MOV L,B
	DAD H
	DAD H
	DAD H
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
	POPA
	RET

;ТЕПЕРЬ ВЫВОДИМ СИМВОЛ 8х8.
;ВХОД: B - KOD СИМВОЛА, C - СДВИГ ВНИЗ СИМВОЛА(0/4)
;	HL - CURSOR  X, Y (0..1FH) RESP.
PUT8x8:	PUSHA
	MVI D,0
	MOV E,B
	LDA WHPL
	ORA H
	MOV B,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	SUB C
	MOV C,A
	XCHG
	DAD H
	DAD H
	DAD H
	LXI D,TABL2SYM
	DAD D
	REPT 8
	MOV A,M
	STAX B
	INX H
	DCR C
	ENDM
	POPA
	RET
;ВЫВОД СО СДВИГОМ ВПРАВО НА 4 ТОЧКИ:
;ВХОД - HL-CURSOR X,Y  ; B -CODE, C -SHIFT DOWN
PUT8x8X:
	PUSHA
	MVI D,0
	MOV E,B
	LDA WHPL
 	ORA H
	MOV B,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	SUB C
	MOV C,A
	XCHG
	DAD H
	DAD H
	DAD H
	LXI D,TABL2SYM
	DAD D
	XCHG
	REPT 8
	LDAX D
	MVI H,0
	MOV L,A
	DAD H
	DAD H
	DAD H ; СДВИНУЛИ ВЛЕВО НА 4 ТОЧКИ
	DAD H ;
	MOV A,L
	INR B
	STAX B ; ПИШЕМ В ВОЗУ
	MOV A,H
	DCR B
	STAX B
	INX D
	DCR C  ;СЛЕД.СТРОКА
	ENDM
	POPA
	RET ;ВСЕ???
;СТИРАЕМ СИМВОЛЫ 8х8
DEL8x8:
	PUSHA
	LDA WHPL
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	SUB C
	MOV L,A
	XRA A
	MOV M,A
	REPT 7
	DCR L
	MOV M,A
	ENDM
	POPA
	RET
DEL8x8X:
	PUSHA
	LDA WHPL
	ORA  H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	SUB C
	MOV L,A
	XRA A
	MOV M,A
	INR H
	MOV M,A
	REPT 7
	DCR H
	DCR L
	MOV M,A
	INR H
	MOV M,A
	ENDM
	POPA
	RET
;ВЫВОД ВЕРXНЕЙ ЧАСТИ СИМВОЛА 16х16
PUT16x16U:
	LOCAL PT16U
	PUSHA
PT16U:	XCHG
	MVI H,0
	MOV L,B
	DAD H
	DAD H
	DAD H
	LXI B,TABL2SYM
	DAD B
	XCHG
	LDA WHPL ;ПЛОСК.
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A
	LDAX D
	MOV M,A
	REPT 7
	INX D
	DCR L
	LDAX D
	MOV M,A
	ENDM
;ВЫВОДИМ ВТОРОЙ СИМВОЛ И ВСЕ?
	MVI A,8
	ADD L
	MOV L,A
	INR H ;	X = X + 1
	REPT 8
	INX D
	DCR L
	LDAX D
	MOV M,A ;MOVSB
	ENDM
	POPA
	RET ; {PUT16x16U}
PUT16x16D:
;ВЫВОДИМ НИЖНЮЮ  ЧАСТЬ ЗАДАННОГО СИМВОЛА 16х16
	PUSHA
	INR B
	INR B ;КОД НИЖНИХ 2-x СИМВОЛОВ
	INR L ; Y = Y + 1
	JMP PT16U ;ОСТАЛЬНОЕ ВСЕ КАК ПРИ
		  ;ВЫВОДЕ ВЕРХА СИМВОЛА

DEL16x16:
;	УДАЛЕНИЕ СИМВОЛА 16х16 ТОЧЕК
;	В ОДНОЙ ПЛОСКОСТИ
;	ВХОД:  HL  - CURSOR
;////////////////ВНИМАНИЕ!!!!//////////////////////////////
;	DEL16x16(U/D) ВЫЗЫВАТЬ ТОЛЬКО ПРИ ЗАПРЕЩЕННЫХ
;	ПРЕРЫВАНИЯХ, ТАК КАК ИДЕТ РАБОТА СО СТЕКОМ!

	PUSHA
	LDA WHPL
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A
	XCHG
	LXI H,0
	MOV B,H
	MOV C,L  ;  BCHL - I8082 INSTRUCTION
	DAD SP
	XCHG ;	STORE SP IN DE
	INR L
	SPHL
	REPT 8
	PUSH B
	ENDM
	INR H
	SPHL
	REPT 8
	PUSH B
	ENDM
	XCHG
	SPHL ;ВЕPНЕМ SP	
	POPA
	RET
;СТИРАНИЕ НИЖНЕЙ И ВЕРХНЕЙ ЧАСТИ СИМВОЛОВ 16x16
DEL16x16D:
	INR L  ; X = X + 1
DEL16x16U:
	PUSHA
	LDA WHPL ;АДРЕС ПЛОСК.
	ORA H
	MOV H,A
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A
	XCHG
	LXI B,0
	LXI H,0
	DAD SP
	XCHG
	INR L
	SPHL
	REPT 4
	PUSH B
	ENDM
	INR H
	SPHL
	REPT 4
	PUSH B
	ENDM
	XCHG
	SPHL ; ВЕРТНЕМ УКАЗ.СТЕКА, ТАК ЕГО И СЯК
	POPA
	RET

;ЗАВЕРШИЛИ ВЫВОД СИМВОЛА(26ЯНВ2000рХ,12:07АМ(НОЧИ))
	ENDM
