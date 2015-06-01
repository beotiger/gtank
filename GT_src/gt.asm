;///////// G - T A N K \\\\\\\\\\\\\\\\\
; 	ОСНОВНОЙ ФАЙЛ ПРOЕКТА G-TANK
; GT.ASM - СБОРЩИК ВСЕХ МОДУЛЕЙ,  НАЧАЛО,ПРОВЕРКА
;	DISPATCHER  OF  <HER MAJESTY GAME>
;	CREATED BY  gDw
; ПОДАВИМ ВЫДАЧУ ЛИСТИНГА (.PRN)
	.XLIST

;	ПОДКЛЮЧАЕМ БИБЛИОТЕКИ
INCLUDE MATH.ASM

	LXI SP,100H
	DI
	IN 1
	RLC
	RLC
	JNC @CONT ; ЕСЛИ УС НАЖТА, НЕ ПРИЗВОДИТЬ ПРОВЕРКИ
	XRA A
	OUT 10H
	STA 0A000H
	STA 0C333H
	STA 0D8ABH
; ПРОВЕРЕМ, ВКЛЮЧИТСЯ ЛИ КВАЗИ ДИСК
	MVI A,23H
	OUT 10H
	LDA 0A000H
	ORA A
	JNZ @OK ; ВЛЮЧИЛСЯ
	LDA 0C333H
	ORA A
	JNZ @OK
	LDA 0D8ABH
	ORA A
	JNZ @OK
; ЕСЛИ КВАЗИ-ДИСКА НЕТ,
; ТО ВЫХОДИМ В ОСЬ С ПРЕДУПРЕЖДАЮЩЕЙ НАДИСЕЙ
	EI
	CALL @NOQD
	DB 'SORRY, BUT YOUR SYSTEM DOES NOT HAVE QUASI-DISK$'
@NOQD:	POP D
	MVI C,9
	CALL 5
	RST 0
@OK:	; ТЕПЕРЬ ПРОВЕРИМ 20Н БАНК КВАЗИ НА ВШИВОСТЬ
	LXI D,80H
	MOV C,E
	LXI H,0A000H
	MVI A,QBANK
	OUT 10H
	MVI A,0E5H
@IFFREE:
	CMP M  ; КОД 0E5H
	JNZ @NOFREE ; НЕ СВОБОДЕН -> @NOFREE
	DAD D
	DCR C
	JNZ @IFFREE
@CONT:	LDA 80H
	DCR A   ; НЕТ ПАРАМЕТРОВ - 
	JM @RECONT ; ИСТИННОЕ НАЧАЛО
	MVI A,23H
	OUT 10H
	LXI SP,0E000H
	EI
	LXI D,5CH
	MVI C,15
	CALL 5     ; ОТКРЫВАЕМ ФАЙЛ
	CPI 255
	JZ @RECONT ; ОШИБКА - ВСЕ
	LXI D,NUMLEV
	
@READIT:
; ЧИТАЕМ УРОВНИ ФАЙЛА
	PUSH D
	LXI D,5CH
	MVI C,14H
	CALL 5
	POP D
	ORA A
	JNZ @RECONT ; ВСЕ ПРОЧИТАЛИ
	LDIR 80H,,80H ; ПЕРЕПИШЕМ ИЗ БУФЕРА В ПАМЯТЬ УРОВНЕЙ
	JMP @READIT
@RECONT:
	DI
	XRA A
	OUT 10H
	OUT 7
	OUT 0
	LHLD 39H
	SHLD OLD39H
	LHLD 1
	SHLD OLD1 	;СОХР. АДРЕС ОСЬ-ОБРАБОТЧИКА RST 0
	LXI H,APINIT
	SHLD 39H
	LXI H,GAMES
	SHLD 1		; ПЕРЕХОД ПО СБРОСУ
	JMP DISPATCHER ; НА ДИСПЕТЧЕР
@NOFREE:
	MVI A,23H
	OUT 10H
	EI
	CALL @NOF0
	DB 'WARNING: THERE IS DATA ON YOUR QUASI-DISK, WHICH'
	DB 13,10,'CAN BE REMOVED. CONTINUE ANYWAY?(Y/N)$'
@NOF0:	POP D
	MVI C,9
	CALL 5 ; ВЫдАДИМ СТРОКУ НА ЭКРАН
	MVI C,1
	CALL 5 ; РЕАДКЕЫ
	CPI 'Y'
	JZ @CONT
	RST 0 ; ИНАЧЕ - ВЫХОД В ДОСЬ

; ПРОВЕДЕМ ЗДЕСЬ ОСHОВНЫЕ МАКАРЫ
INCLUDE APINIT.ASM
INCLUDE	MUSIC.ASM
INCLUDE GAME2P.ASM
INCLUDE GRAPH.ASM

DISPATCHER:
	EI
	LDA NUMLEV ;ЧИСЛО УРОВНЕЙ
	CPI 3 ;<3?
	JNC $+6
	STA DEMLEV ;УРОВЕНЬ ДЛЯ ДЕМОНА = КОНЕЧНОМУ УРОВНЮ

	IN 1
	RLC
	JC GAMES  ; РУC НЕ НАЖАТА
	MVI A,1
	STA HAMODE ; HAMODE ON
	LDA NUMLEV
	STA MAXLEV

GAMES:	LXI SP,100H
	MVI A,0C3H	; КОД КОМАНДЫ !JMP
	STA 38H		; ОБРАБОТЧИК RST 7
	EI
	CALL BOARD ; ЗАСТАВКА
	CALL MENU  ; МЕНЮ

GAME:	CALL INITLEVEL ; ИНИЦИАЛИЗИРУЕМ УРОВЕНЬ
	CALL PUTLEVEL  ; ВЫВД УРОВНЯ НА ЭКРАН
	CALL PUTGDW    ; ОЧИСТКА ПОЛЯ
	CALL PUT2ARMOR ; ВЫВОД ИНФО ОБ ИГРОКАХ
	CALL PUTSTAT   ; ВЫВОД СТАТИСТИКИ

GAMEP:	CALL KEYBOARD  ; КЛАВИАТУРА
	CALL AIOBJ	; AI
	CALL CONTROLOBJ ; КОНТРОЛЬ - МОТОР ИГРЫ
	CALL BEARTANKS  ; ПОЯВЛЕНИЕ ТАНКОВ
	CALL SERVETURRET ; СТРЕЛЬБА ПУШЕК
	CALL SCROLLLEVEL ; СДВИГ УРОВНЯ
	CALL DELSTOBJ	; УДАЛЕНИЕ СТАТ.ОБ'КТОВ
	CALL PUTALLOBJ ;  ВЫВОД ДИНАМИЧЕСКИХ ОБ'ЕКТОВ
	CALL PUTSTOBJ   ; ВЫВОД  СТАТИЧ.ОБ'ЕКТОВ
	CALL PLMUSIC	; ЗВУКОВЫЕ ЭФФЕКТЫ
	CALL GIVBONUS	; РАЗДАЧА БОНУСОВ
	CALL PUT2ARMOR
	CALL ANALYSER	; АНАЛИЗАТОР
	JMP GAMEP	; ЕЕ ВЕЛИЧЕСТВО  *ИГРА*

OLD1:	DW 0

	ORG 2000H
	RND
INCLUDE HEADER.ASM
INCLUDE LEVEL.ASM
INCLUDE ENGINE.ASM
INCLUDE ENGINE2.ASM
INCLUDE SCREEN.ASM
INCLUDE SYSTEM.ASM

INCLUDE GTMUS.INC	; ПОДКЛЮЧЕНИЕ ФАЙЛА С МУЗЫКОЙ

NUMLEV:	DB 0 ; КОНЕЦ ИГРЫ ЕСТЬ НАЧАЛО УРОВНЕЙ
	END
