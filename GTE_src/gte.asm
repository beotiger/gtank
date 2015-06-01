;///////// G - T A N K   EDITOR\\\\\\\\\\\\\\\\\
; 	ОСНОВНОЙ ФАЙЛ ПРOЕКТА G-TANK EDITOR
; GTE.ASM - СБОРЩИК ВСЕХ МОДУЛЕЙ,  НАЧАЛО,ПРОВЕРКА
;	DISPATCHER  OF  <HIS HIGHNESS EDITOR>
; ПОДАВИМ ВЫДАЧУ ЛИСТИНГА (.PRN)
	.XLIST

;	ПОДКЛЮЧАЕМ БИБЛИОТЕКИ
INCLUDE MATH.ASM
INCLUDE INPUT.ASM

	LXI SP,100H
	CALL CLEARMEM ;ОЧТСТИМ ПАМЯТЬ КОДАМИ 252 (EMPTY)

@CONT:	LDA 80H
	DCR A   ; НЕТ ПАРАМЕТРОВ - 
	JM @NOFILE ;HЕТ ФАЙЛА ОШИБКА
	LXI SP,08000H
	LXI D,5CH
	MVI C,15
	CALL 5     ; ОТКРЫВАЕМ ФАЙЛ
	CPI 255
	JZ @CREATEIT ; ОШИБКА- СОЗДАЕМ ФАЙЛ
	LXI D,NUMLEV
	
@READIT:
; ЧИТАЕМ УРОВНИ ФАЙЛА
	PUSH D
	LXI D,5CH
	MVI C,14H
	CALL 5
	POP D
	ORA A
	JNZ @BEGIN ; ВСЕ ПРОЧИТАЛИ
	LDIR 80H,,80H ; ПЕРЕПИШЕМ ИЗ БУФЕРА В ПАМЯТЬ УРОВНЕЙ
	JMP @READIT
	
@CREATEIT:
	XRA A
	STA NUMLEV
	LXI D,5CH
	MVI C,16H ; CREATE FUNCTION
	CALL 5
	CPI 255
	JNZ @BEG1 ; НА НАЧАЛО
	CALL @CRIT
	DB 'COULDN',39,'T CREATE FILE.$'
@CRIT:	POP D
	MVI C,9
	CALL 5
	RST 0
@NOFILE:
	CALL @CRIT
	DB 'GIVE ME FILE NAME, PLEASE.$'
@BEGIN:
	LXI D,5CH
	MVI C,10H
	CALL 5 ; CLOSE FILE CPM
@BEG1:	 
	DI
	XRA A
	OUT 10H
	OUT 7
	OUT 0
	LHLD 39H
	SHLD OLD39H
	LXI H,APINIT
	SHLD 39H
	JMP DISP00 ; НА ДИСПЕТЧЕР

; ПРОВЕДЕМ ЗДЕСЬ ОСHОВНЫЕ МАКАРЫ
INCLUDE APINIT.ASM
INCLUDE GRAPH.ASM

DISP00:
	EI
	MVI A,3
	CALL CHARCOLOR
	TURBOCLS
	LXI H,3
	MVI A,NIZ
	MVI  C,32
	CALL PUTUCHAR
	INR H
	DCR C
	JNZ $-5
	MVI A,1
	CALL CHARCOLOR
	MVI A,2
	STA HEIGHT
; ВЫВОДИМ ИМЯ ФАЙЛА, ЗАДАННОЕ В КОМАНДНОЙ СТРОКЕ
	LXI H,0E00H
	LXI D,5DH
	LDA 65H
	PUSH PSW
	XRA A
	STA 65H
	CALL PUTSTRING
	MVI A,'.'
	LXI H,1600H
	CALL PUTUCHAR
	INR H
	POP PSW
	LXI D,65H
	STAX D
	XRA A
	STA 68H
	CALL PUTSTRING ; ВЫВЕДЕМ РАСШИРЕНИЕ
	LXI H,0100H
	LXI D,VYBOR
	MVI A,2
	CALL CHARCOLOR
	CALL PUTSTRING
	MVI A,1
	STA HEIGHT ;ВЫCОТА СИМВОЛОВ - 0
	LDA NUMLEV
	ORA A
	JZ NEWLEVEL ;ЕСЛИ СОЗДАЛИ ФАЙЛ, ТО НОВЫЙ УРОВЕНЬ
BEGED:	; НАЧАЛО РЕДАКТИРОВАНИЯ
	LDA CURLEV
	STA iCURLEV
	CALL FINDLEVEL ; НАХОДИМ УРОВЕНЬ
	CALL OUTINFO
	DB 7,3,1,2,2,'Поле:',4 ;OUT TWO-CIFERED BYTE
iCURLEV:
	DB 0,0
	XRA A
	STA CURX
	STA CURY
	STA ELEVY ; КУРСОРЫ И ВЕРХНЯЯ СТРОКА
DISP1:	LXI SP,100H
	CALL PUTLEVEL
DISP2:	LDA CURCODE
	MOV B,A
	LXI H,700H
	CALL PUTOBJ
DISPATCHER:
;	МИГАЕМ КУРСОРМ В ПОЗИЦИИ CURX,CURY

	LDA CURX
	STA iCURX ;ДЛЯ ВЫВОДА НА ЭКРАН СОХРАНИМ
	MOV H,A
	LDA ELEVY
	MOV B,A
	LDA CURY
	STA iCURY ;ДЛЯ ВЫВОДА НА ДИСПЛЕЙ
	SUB B
	ADI 4
	MOV L,A
	MVI A,CROSS
	CALL PUTBIG
; ВЫВЕДЕМ НА ЭКРАН ТЕКУЩЕЕ ПОЛОЖЕНИЕ КУРСОРА
	CALL OUTINFO
	DB 7,7,1,2,14H,'X=',3 ;HEX OUTPUT
iCURX:	DB 0,'h Y=',3
iCURY:	DB 0,'h',0
	MVI B,10
	CALL PAUSE   ; ЗАДЕРЖКА
	CALL PRINTCODE  ; ОТПЕЧАТАЕМ КОД
	CALL PRINTPL  ; ИГРОКОВ ВЫВЕДЕМ
	MVI B,16
	CALL PAUSE
	JZ DISPATCHER ; ВЕЧНЫЙ ЦИКЛ ДО НАЖАТИЯ
	PUSH PSW
	IN 1
	ANI 40H ; УС НАЖАТА?
	MVI A,0
	JNZ $+4 ; НЕТ - 
	INR A
	STA MODE ; MODE-(0/1)
	LPAUSE
	POP PSW
	LXI H,TABKEYS
	MVI C,17 ; КОЛ-ВО КЛАВИШ УПРАВЛЯЮЩИХ РЕДАКТОРОМ
	LXI D,DISPATCHER
	PUSH D ; ПЕРЕХОД ПО !RET
DISP3:	CMP M
	INX H
	JZ DISP4 ; СОВПАЛ КОД НАЖАТИЯ
	INX H
	INX H
	DCR C
	JNZ DISP3
	BELL ; ПОДАДИМ ЗВУКОВОЙСИГНАЛ
	RET

DISP4:	MOV E,M
	INX H
	MOV D,M ; АДРЕС - В <DE>
	XCHG
	PCHL ; ИЛИ PCDE
TABKEYS:
	DB LEFT
	DW MLEFT ; ДВИЖЕНЕ ВЛЕВО
	DB RIGHT
	DW MRIGHT
	DB UP
	DW MUP
	DB DOWN
	DW MDOWN
	DB VK
	DW SETCODE ; ВК- ПОСТАВИТЬ ВЫБРАННЫЙ КОД
	DB AR2
	DW QUIT ; ВЫЙТИ
	DB TAB
	DW GETCURCODE ; ПОЛУЧИМ НОВЫЙ КОДИК
	DB STR
	DW CLEARLEV ; ОЧИТСКА УРОВНЯ
	DB PS
	DW PREVLEV ;ПРЕДЫДУЩИЙ
	DB ZB
	DW NEXTLEV
	DB 12H
	DW SET1PL ; ПОСТАВИТЬ ИГРОКОВ
	DB 13H
	DW SET2PL
	DB 14H
	DW SETLEVY ; УСТАНОВИТЬ LEVY
	DB F1
	DW SETHEADER
	DB F2
	DW SAVEFILE ; ЗАПИСЬ ФАЙЛА
	DB F3
	DW NEWLEVEL ; СОЗДАТЬ НОВЫЙ УРОВЕНЬ
	DB DOM
	DW GOHOME
PAUSE:	;ВХОD - <B>-COUNTER OF HLT
	CALL GETLINK ;УСТ.СВЯЗЬ С ПОЛЬЗОВАТЕЛЕМ
	RNZ
	HLT
	DCR B
	JNZ PAUSE
	RET
GETLINK:LDA KEY
	ORA A
	RNZ ; КЛАВА НАЖАТА - ВСЕ
	LDA JOYPU
	ANI 0F8H
	RZ ; НЕТ СИГНАЛА ОТ ДЖОЯ ПУ- ВСЕ
	RRC
	RRC
	RRC
	LXI H,JOY2KEYS
	ADDHL
	MOV A,M
	ORA A
	RET
JOY2KEYS:
	DB 0,VK,LEFT,VK,DOWN,0,0,0
	DB RIGHT,0,0,0,0,0,0,0,UP
SETCODE:
;УСТАНОВИТЬ КОД В ПМЯТЬ УРОВНЯ
	LDA MODE
	ORA A
	JZ SET1CODE
	MVI A,3
	PUSH PSW
	CALL SET1CODE
	POP PSW
	DCR A
	JNZ $-6
SET1CODE:
	LDA CURX
	MOV B,A
	LDA CURY
	MOV C,A
	CALL GETAD ; В <HL> - АДРЕС
	LDA CURCODE
	MOV M,A
	CALL PRINTCODE
	LXI H,CURX
	MOV A,M
	CPI 1EH
	JZ SET1C1
	INR M
	INR M ; CURX=CURX+2
	RET
SET1C1:	LDA ELEVY
	ADI 1AH  ; ЕСЛИ НА КРАЮ ОКНА,
	LXI H,CURY
	CMP M
	RZ      ; ТО ВСЕ
	INR M
	INR M
	XRA A
	STA CURX
	RET		
GETAD:	;ПОЛУЧИТЬ В HL АДРЕС ЯЧЕЙКИ ПАМЯТИ ТЕК.УРОВНЯ 
	;ПО КОРДИНАТАМ <B,C> (X,Y RESP.)
	MOV A,C
	ANA A
	RAR    ; A = CURY / 2
	MOV L,A
	MVI H,0
	REPT 4
	DAD H
	ENDM
	MOV A,B ; A=CURX
	ANA A   ; CLC
	RAR
	MOV E,A
	MVI D,0
	DAD D
	LXI D,30
	DAD D ;+РАЗМЕР ЗАГОЛОВКА УРОВНЯ (30 БАЙТ)
	XCHG
	LHLD LEVPTR
	DAD D
	RET
PRINTCODE:
	LDA CURX
	MOV B,A
	LDA CURY
	MOV C,A
	CALL GETAD
	XCHG
	MOV H,B  ; H=CURX
	LDA ELEVY
	MOV B,A   ; B=ELEVY
	MOV A,C
	SUB B
	ADI 4
	MOV L,A ;L=CURY-ELEVY+4
	LDAX D
	MOV B,A ;B- НУЖНЫЙ КОД
	JMP PUTOBJ

MLEFT:	LXI H,CURX
	LDA MODE
	ORA A
	JZ $+6
	MVI M,0
	RET
	MOV A,M
	ORA A
	JZ BELL1
	DCR A
	DCR A
	MOV M,A
	RET

BELL1:	BELL  ;ПОДАЧА ЗВУКОВОГО СИГНАЛА
	RET

MRIGHT:	;ДВИЖЕНИЕ ВПРАВО
	LXI H,CURX
	LDA MODE
	ORA A
	JZ $+6
	MVI M,1EH
	RET
	MOV A,M
	CPI 1EH
	JZ BELL1 ;НА КРАЮ ЭКРАНА- ВСЕ
	INR M
	INR M
	RET
MUP:	;ВВЕРX И ВНИЗ СЛОЖНЕЕ ДВИЖЕНИЕ,
	;ИБО УРОВЕНЬ МОЖЕТ ЗАНИМАТЬ НЕ ДОН ЭКРН,
	; А НЕСКОЛЬКО (ДО 9)
	LXI H,CURY
	MOV A,M
	ORA A
	JZ BELL1 ;ЕСЛИ НА ВЕРХУ УРОВНЯ - ТО ВСЕ
	LDA MODE
	ORA A
	JNZ MUP5
	LDA ELEVY
	CMP M     ;CURY=ELEVY?
	JZ MUP1   ;ДА -> MUP1
MUP0:	DCR M
	DCR M
	RET
MUP1:	SUI 6
	JNC $+4
	XRA A
	STA ELEVY ;ВЕРХНЯЯ ВИДИМАЯ СТРОКА СМЕЩАЕТСЯ
	JMP DISP1
MUP5:	LDA ELEVY
	CMP M
	JZ MUP6 ;НАХОДМСЯ ВВЕРХУ?
	MOV M,A
	RET
MUP6:	SUI 1CH ;FULL PAGE UP
	JNC $+4
	XRA A
	STA ELEVY
	MOV M,A ;ELEVY=-14, CURY=ELEVY
	JMP DISP1

MDOWN:	;СМЕЩАЕМСЯ ВНИЗ
	LXI H,CURY
	LDA MODE
	ORA A
	JNZ MD5
	LDA LMAXY
	DCR A
	CMP M  ;ЕСЛИ НАХОДИМСЯ НА КРАЮ УРОВНЯ,
	JZ  BELL1 ;ТО ОШИБКА
	INR M
	INR M  ; CURY = CURY + 2
	LDA ELEVY
	ADI 1AH
	CMP M
	RNZ  ; НЕ ДОСТИГЛИ КРАЯ ОКНА - ВЫХОД В ДИСПЕТЧЕР
	LDA ELEVY
	ADI 6
	MOV E,A ;E= ELEVY+6
	LDA LMAXY
	SUI 1BH
	CMP E
	LXI H,ELEVY
	JC MD2
	MOV M,E
	JMP DISP1
MD2:	MOV M,A ;ELEVY=LMAXY-1BH
	JMP DISP1
MD5:	;НАЖАТА УС+DOWN
	LDA ELEVY
	ADI 1CH
	MOV E,A ; E = ELEVY + 1CH
	ADI 1BH
	LXI H,LMAXY
	JC MD6 ;СРАЗУ ПЕРЕШЛИ ГРАНИЦУ
	CMP M
	JNC MD6
	MOV A,E
MD50:	STA ELEVY ;ELEVY = ELEVY + 1CH (PAGE DOWN)
	STA CURY  ;CURY =  ELEVY
	JMP DISP1 ;ВЫХОД НА ДИСПЕТЧЕР
MD6:	MOV A,M
	DCR A
	STA CURY ; CURY = LMAXY - 1
	SUI 1AH
	STA ELEVY ; ELEVY = LMAXY - 1BH
	JMP DISP1 ;
QUIT:	;ВЫХОД
	LDA MODE
	ORA A
	JNZ QUIT5
	LXI D,QUITSTR
	LXI H,0B02H
	MVI A,3
	CALL CHARCOLOR
	CALL PUTSTRING
	LPAUSE
	WAITKEY
	CPI 25H ;'D' PRESSED?
	JZ QUIT5
	CPI VK
	JZ QUIT5
	LXI H,0B02H
	LXI D,NNAME
	LPAUSE
	JMP PUTSTRING ;СОТРЕМ НАДПИСЬ 'ВЫЙТИ?' И ВСЕ?
DELSTRING:
; ИНАЧЕ ЧИСТИМ СТРОКУ И С РАДОСТЬЮ ВОЗВРАЩАЕМСЯ 
; В НАШ ЛЮБИМЫЙ ПРОФЕССИОНАЛЬНЫЙ РЕДАКТОР
	LXI H,2
	MVI C,32
	MOV A,C
	CALL PUTUCHAR
	INR H
	DCR C
	JNZ $-5
	LPAUSE ;НЕБОЛЬШАЯ ЗАДЕРЖКА
	RET
QUIT5:	LPAUSE
	DI
	LHLD OLD39H
	SHLD 39H
	MVI A,23H
	OUT 10H
	EI
	HLT
	CALL QUIT6
	DB 'SEE YOU LATER, PAL!?$'
QUIT6:	POP D
	MVI C,9
	CALL 5 ; ВЫВЕДЕМ ПРОЩАЛЬНУЮ НАДПИСЬ
	RST 0 ; И ВЫЙДЕМ В CP/M

CLEARLEV:
;	ОЧИСТИМ УРОВЕНЬ КОДАМИ ИЗ ТAБЛИЦЫ-2
	CALL TABLE
	LDA MODE
	ORA A
	RM
	JNZ CLRL2
CLRLX:	LXI B,0
	CALL GETAD
	LDA CURCODE
	MOV B,A
	LDA LMAXY
	INR A
	ANA A
	RAR ;
CLR0:	MVI C,16
	MOV M,B
	INX H
	DCR C
	JNZ CLR0+2
	DCR A  ; УМЕНЬШМ СЧЕТЧИК СТРОК
	JNZ CLR0
	JMP PUTLEVEL
CLRL2:	MVI B,0
	LDA ELEVY
	MOV C,A
	CALL GETAD
	LDA CURCODE
	MOV B,A
	MVI A,14
	JMP CLR0

TABLE:
; СОЗДАНИЕ ТАБЛИЦЫ ДЛЯ ВЫБОРА НОВОГО СИМВОЛА
	LXI B,307H
	LXI D,1C14H
	CALL RAMKA
	LXI B,0C12H
	LXI D,1B13H
	CALL RAMKA
	CALL OUTINFO
	DB 7,7,1,13H,0DH
	DB 'gDw:GT-graphics',0
	LXI H,1C3CH
	LXI D,0E4A4H
	CALL RECT ;ВЫВЕDЕМ РАМКУ
	INR H
	INR H
	INR L
	DCR D
	DCR D
	DCR E
	DCR E
	CALL RECT ;ЕЩЕ ДОНУ ДЛЯ КРАСОТЫ
	MVI B,63
	CALL TABPRINT
	DCR B
	JP $-4
	LDA CURCODE
	ANA A
	RAR
	ANA A
	RAR ; ДЕЛИМ НА 4 ЕГО
TAB0:	ANI 63
	MOV B,A ; B = CURCODE/4
TAB01:	
	PUSH B
	CALL PUTCROSS ;ВЫВЕДЕМ КРЕСТ НА МЕСТЕ КУРСОРА
	MVI B,8
	CALL PAUSE
	POP B
	PUSH B
	CALL TABPRINT ;ВЫВЕЕМ САМ КОД
	MVI  B,16
	CALL PAUSE
	POP B
	LPAUSE
	JZ TAB01 ;ЕСЛИ НЕТ НАЖАТИЯ, ВСЕ
	CPI AR2
	JZ TAB8 ;ОТКАЗ
	CPI VK
	JZ TAB9 ;ПОДТВЕРЖДЕНИЕ
	CPI UP
	JNZ TAB1
	MOV A,B
	SUI 12
	JMP TAB0
TAB1:	CPI DOWN
	JNZ TAB2
	MOV A,B
	ADI 12
	JMP TAB0
TAB2:	CPI LEFT
	JNZ TAB3
	MOV A,B
	DCR A
	JMP TAB0
TAB3:	CPI RIGHT
	JNZ TAB4
	MOV A,B
	INR A
	JMP TAB0
TAB4:	BELL
	MOV A,B
	JMP TAB0
TAB8:	MVI A,-1
	STA MODE
	JMP PUTLEVEL ;СОТРЕМ РАМКУ И ТАБЛИЦУ
TAB9:	MOV A,B
	ADD A
	ADD A
	STA CURCODE ; НОВЫЙ ЯКОБЫ CURCODE
	JMP PUTLEVEL	
GETCURCODE:
	CALL TABLE
	POP PSW ;ЧИСТИМ СТЕК
	JMP DISP2
TABPRINT:
;	ВЫВЕСТИ НА ЭКРАН КОД 16*16 ИЗ ТАБЛИЦЫ
;	СИМВОЛОВ - 2
	PUSH B
	MOV A,B
	CALL DIV12
	MOV A,C ;ОСТАТОК
	ADD A
	ADI 4
	MOV H,A  ; X = CODE MOD 12 * 2 + 4
	MOV A,B
	CALL DIV12
	ADD A
	ADI 8
	MOV L,A  ;Y = CODE DIV 12 * 2 + 8
	MOV A,B
	ADD A
	ADD A
	MOV B,A
	CALL PUTOBJ
	POP B
	RET
DIV12:	;ДЕЛЕНИЕ <А> НА 12, ОСТАТОК В <C>
	MVI E,255
	INR E
	SUI 12
	JNC DIV12+2
	ADI 12
	MOV C,A ;<С> - ОСТАТОК   (MOD)
	MOV A,E ;<А> - РЕЗУЛЬТАТ (DIV)
	RET
PUTCROSS:	;ВЫВОД КРЕСТИКА НА МЕСТЕ <B>
	MOV A,B
	CALL DIV12
	MOV A,C
	ADD A
	ADI 4
	MOV H,A
	MOV A,B
	CALL DIV12
	ADD A
	ADI 8
	MOV L,A
	MVI A,CROSS
	JMP PUTBIG
PREVLEV:
	LDA MODE
	ORA A
	JNZ PREVL0
	LXI H,CURLEV ;ТЕК.УРОВЕНЬ
	MOV A,M
	DCR A
	JZ BELL1
	MOV M,A
	JMP BEGED ;НА НЧАЛО РЕДАКТИРОВАНИЯ
PREVL0:	LXI H,CURLEV
	MVI M,1
	JMP BEGED

NEXTLEV:
	LXI H,CURLEV
	LDA MODE
	ORA A ;УС НАЖАТА?
	LDA NUMLEV ;ЧИСЛО УРОВНЕЙ
	JNZ NEXTL0
	CMP M
	JZ BELL1
	INR M
	JMP BEGED
NEXTL0:	MOV M,A
	JMP BEGED
GOHOME:	LXI H,CURX
	MVI M,0
	LXI H,CURY
	LDA MODE
	ORA A
	JNZ GHOM1
	LDA ELEVY
	MOV M,A ; CURY=ELEVY
	RET
GHOM1:	 ;CURY = 0
	XRA A
	MOV M,A
	STA ELEVY
	JMP PUTLEVEL ;ВЫВЕДЕМ УРОВЕНЬ  ВСЕ?

SET1PL:	;УСТАНОВИМ ИГРОКОВ 1 И 2-ГО СООТВ.
	LHLD LEVPTR
	LXI D,26
	DAD D
	LDA CURX
	MOV M,A
	LDA CURY
	INX H
	MOV M,A
	CALL MRIGHT
	JMP PUTLEVEL
SET2PL:	LHLD  LEVPTR
	LXI D,28
	DAD D
	LDA CURX
	MOV M,A  ; PL2.CURX = CURX
	INX H
	LDA CURY
	MOV M,A ;PL2.CURY = CURY
	CALL MRIGHT ;ПЕРЕДВИНЕМ КУРСР ВПРАВО
	JMP PUTLEVEL ;ВЫВЕДЕМ УРОВЕНЬ И ВСЕ?
NEWLEVEL:	
	LDA NUMLEV
	INR A
	CALL FINDLEVEL
	XCHG ;DE=HL
	LDIR NNAME,,14 ;ИМЯ ПЕРЕПИШЕМ
	XCHG
	MVI M,1BH ;LMAXY
	INX H
	MVI M,1   ;LEVGOAL
	MVI A,9
	INX H
	MVI M,0
	DCR A
	JNZ $-4
	INX H
	MVI M,12 ;BASE.HP
	INX H
	MVI M,10H ;PL1.CURX
	INX H
	MVI M,1AH ;PL1.CURY
	INX H
	MVI M,0CH ;PL2.CURX
	INX H
	MVI M,1AH ;PL2.CURY
	LDA NUMLEV
	INR A
	CALL FINDLEVEL
	CALL CHECKLSIZE
	JNC MEMERROR ;НЕ ХВАТИЛО ПАМЯТИ
	LXI H,NUMLEV
	INR M
	MOV A,M
	STA CURLEV
	MVI A,252
	STA CURCODE  ;КОД = ПУСТО
	CALL CLRLX ;ОЧИСТИМ УРОВЕНЬ
	JMP BEGED ; НАЧНЕМ РЕДАКТИРОВАНИЕ		
MEMERROR:
	LXI H,02H
	MVI A,3
	CALL CHARCOLOR
	LXI D,MEMERR
	CALL PUTSTRING
	BELL
	MVI B,50*3 ;3 СЕКУНДЫ
	CALL PAUSE
	CALL DELSTRING
	JMP BEGED
CHECKLSIZE:
; ИЗМЕРИТЬ РАЗМЕР УРОВНЯ
; И ПРОВЕРИТЬ ВЫХОД ЗА ПРЕДЕЛЫ ДОСТУПНОЙ ПАМЯТИ	
	LDA LMAXY
CHSZ2:	INR A
	ANA A
	RAR
	MOV L,A
	MVI H,0
	REPT 4
	DAD H
	ENDM
	LXI D,30
	DAD D
	XCHG
	LHLD LEVPTR
	DAD D
	LXI D,7E00H ;FIRSTOBJ
	CMPHD  ;РАВНИМ HL C DE
	RET
SAVEFILE:
; ЗАПИСЬ ФАЙЛА НА ДИСК
	MVI A,23H
	OUT 10H
	HLT
	XRA A
	STA 68H ; EXTENT = 0
	STA 7CH ; CURRENT REC = 0
	STA 6AH ; S2 = 0 ( FOR OPENING OF FILE)
	LXI D,5CH
	MVI C,15
	CALL 5 ;OPEN FILE
	CPI 0FFH
	JZ @WERR ;ОШИБКА ПРИ ОТКРЫТИИ
	LDA NUMLEV
	CALL FINDLEVEL
	CALL CHECKLSIZE ;В HL - АДРЕС КОНЦА УРОВНЯ
	LXI D,NUMLEV
SF31:	PUSH H
	PUSH D
	MVI C,1AH
	CALL 5   ; SET NEW DMA-ADDRESS
	LXI D,5CH
	MVI C,15H
	CALL 5 ; SAVE FILE
	POP D
	ORA A
	JNZ @WERR ;ОШИБКА ЗАПИСИ
	LXI H,80H
	DAD D
	XCHG  ; DE = DE + 128 (РАЗМЕР DMA)
	POP H
	CMPHD
	JNC SF31
	LXI D,5CH
	MVI C,10H
	CALL 5 ;CLOSE FILE
	HLT
	XRA A
	OUT 10H
	JMP BEGED ;НАЧНЕМ РЕДАКТИРОВАНИЕ
@WERR:	LXI D,5CH
	MVI C,10H
	CALL 5
	HLT
	XRA A
	OUT 10H
	MVI A,6
	CALL CHARCOLOR ;ЦВЕТ СООБЩЕНИЯ ОБ ОШИБКЕ
	LXI D,WERROR
	LXI H,02H
	CALL PUTSTRING
	BELL ;ЗВУКОВОЙ СИГНАЛ
	MVI B,50*3  ;3 СЕКУНДЫ
	CALL PAUSE
	POP PSW
	CALL DELSTRING ;УДАЛИМ СТРОКУ ОШИБКИ
	JMP BEGED ;ПРОДОЛЖИМ/НАЧНЕМ РЕДАКТИРОВАНИЕ
SETLEVY:
	LHLD LEVPTR
	LXI D,16
	DAD D ; НА LEVEL[X].LEVY
	LDA ELEVY
	MOV M,A
	RET ;И ВСЕ?
SETHEADER:
;	УСТАНОВИТЬ ЗАГОЛОВОК УРОВНЯ
	CALL PUTSTAT ;ВЫВЕДЕМ СНАЧАЛА ЗАГОЛОВОК
SETH1:	LDA UKAZ
	ADD A
	LXI H,UKADDR
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	XCHG
	SHLD SETH2+1
	LXI D,BUFFER
	MVI A,32
	STAX D ;ОЧИСТИМ БУФЕР
	INX D
	STAX D
	INX D
	STAX D
	DCX D
	DCX D
	XRA A
	MVI B,3
	MVI C,7
SETH2:	CALL SETLNAME ;ВЫЗОВ П/П УСТАНОВКИ
	LPAUSE
	LXI H,UKAZ
	CPI UP
	JZ SETH3
	CPI DOWN
	JZ SETH4
	CPI VK
	JNZ PUTLEVEL ;ВЫВОД УРОВНЯ И ВСЕ?
;ДВИГАЕМ УКАЗАТЕЛЬ ПО ЗАГОЛОВКУ ВВЕРХ/ВНИЗ
SETH4:	MOV A,M
	CPI 11
	JZ SETH5
	INR M
	JMP SETH1
SETH5:	MVI M,0
	JMP SETH1
SETH3:	MOV A,M
	ORA A
	JZ SETH6
	DCR M
	JMP SETH1
SETH6:	MVI M,11
	JMP SETH1
UKADDR:	DW SETLNAME,SETLGOAL,SETBASEHP
	DW SETMENEMY,SETMTIG,SETMTANK
	DW SETMAT,SETMPAN,SETMKILL
	DW SETMTR,SETMBMP,SETLMAXY
SETLNAME:
	LHLD LEVPTR
	XCHG
	LXI H,090AH
	MVI B,14
	JMP INPUT ;ВВЕДЕМ НОВОЕ ИМЯ УРОВНЯ И ВСЕ
SETLGOAL:
	LHLD LEVPTR
	LXI D,15
	DAD D
	MOV A,M
SETLG0:	PUSH H
	CALL PRINTGOAL ;ВЫВЕДЕМ НАЗВАНИЕ МИССИИ
	LPAUSE
	WAITKEY
	POP H
	CPI LEFT
	JZ SETLG1
	CPI RIGHT
	JZ SETLG2
	RET
SETLG1:	MOV A,M
	DCR  A
	ANI 3
	MOV M,A
	JMP SETLG0
SETLG2:	MOV A,M
	INR A
	ANI 3
	MOV M,A
	JMP SETLG0
SETBASEHP:
;УСТАНОВИМ НОВОЕ ЗНАЧЕНИЕ ХИТ-ПОИНТОВ ДЛЯ БАЗЫ
	LXI H,110EH
	CALL INPUT
	LXI B,25
SETIT:	PUSH B
	PUSH PSW
	DECI ;ПРЕОБРАЗУЕМ СТРОКУ ИЗ *DE В ЧИСЛО <DE>
	POP PSW
	POP B
	LHLD LEVPTR
	DAD B
	MOV M,E
	RET ;ВЫХОД С <А>- КОД ПОСЛЕДНЕГО НАЖАТИЯ

;УСТАНОВКА МАКСИМАЛЬНОГО КОЛ-ВА ВРАГОВ НА УРОВНЕ
; 1-ОЕ ЗНАЧЕНИЕ: ВСЕГО ВРАГА ОДНОВРЕМЕННО МОЖЕТ БЫТЬ
; ОСТАЛЬНЫЕ - ВСЕГО ВРАГА РОЖДАЕТСЯ В  BPOINTS
SETMENEMY:
	LXI H,0D0FH
	CALL INPUT
	LXI B,17
	JMP SETIT
SETMTIG:
	LXI H,0D11H
	CALL INPUT
	LXI B,18
	JMP SETIT
SETMTANK:
	LXI H,0D13H
	CALL INPUT
	LXI B,19
	JMP SETIT
SETMAT:	LXI H,0D15H
	CALL INPUT
	LXI B,20
	JMP SETIT
SETMPAN:
	LXI  H,140FH ;КУРСОР
	CALL INPUT
	LXI B,21
	JMP SETIT
SETMKILL:
	LXI H,1411H
	CALL INPUT
	LXI B,22
	JMP SETIT
SETMTR:	LXI H,1413H
	CALL INPUT
	LXI B,23
	JMP SETIT
SETMBMP:
	LXI H,1415H
	CALL INPUT
	LXI  B,24  ;СМЕЩЕНИE ДЛЯ MAXBMP
	JMP SETIT
SETLMAXY: ;УСТАНОВИМ КОЛ-ВО СТРОК В УРОВНЕ
	LDA NUMLEV
	LXI H,CURLEV ;ЕСЛИ РЕДАКТИРУЕМ НЕ
	CMP M  ; ПОСЛЕДНИЙ УРОВЕНЬ
	JNZ NOSET ;ТО НЕ УСТАНАВЛИВАЕМ
	LXI H,1117H
	XRA A
	MVI B,2
	CALL INPUT
	PUSH PSW ;СОХРАНИМ КОД НАЖАТИЯ В INPUT'E
	HEXI ;ПРЕОБРАЗУЕМ В 16-ЧНОМ  ФОРМАТЕ
	MOV A,E
	ORI 1
	STA LMAXY
	CALL CHECKLSIZE ;ПРОВЕРИМ ПАМЯТЬ
	JNC MEMERROR ;НЕТ ПАМЯТИ - ОШИБКА
	LXI D,14
	LHLD LEVPTR
	DAD D
	LDA  LMAXY
	MOV M,A ;ПОСТАВИМ В ЗАГOЛОВОК  LMAXY
	POP PSW
	RET ;ВЕРНЕМСЯ В  SETHEADER
NOSET:	MVI A,DOWN ;ПОДСТАВИМ КОД НАЖАТИЯ
	RET	; ВНИЗ СТРЕЛКА

INPUT:	mINPUT
CLEARMEM:
;	ОЧИСТКА ПАМЯТИ FIRSTLEV-FIRSTOBJ 
	LXI H,FIRSTLEVEL
	LXI B,0FC7EH
CLRM0:	MOV M,B
	INX H
	MOV A,H
	CMP C
	JC CLRM0
	RNC
INCLUDE HEADER.ASM ; ПЕРЕМЕННЫЕ  ПРОГИ GTE.COM
METKA:	DB 0 	;МЕТКА НЕ ДОЛЖНА ПЕРЕХОДИТЬ ЗА
		;ПАМЯТЬ АДРЕСОМ 1000H-103H(В ЛИСТЕ)
	ORG 2000H ;РЕАЛЬНЫЙ АДРЕС ЛИНКОВЩИКА - 2103H
INCLUDE SCREEN.ASM ; ЭКРАННЫЕ ОПЕРАЦИИ
	END
