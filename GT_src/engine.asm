;////////////////// G - T A N K \\\\\\\\\\\\\\\\\\\\\\
;БИБЛИОТЕКА	**ENGINE**
;МАКАР __ENGINE__ ВКЛЮЧАЕТ ДВЕ ОСНОВНЫЕ САБЫ
;	AIOBJ : ARTIFICIAL INTELLECT OF OBJCTS
;		ALSO OF PLAYERS!
;	CONTROLOBJ : САМ МОТОР ИГРЫ
ENGINE	MACRO
AIOBJ:	LXI H,FIRSTOBJ
	CALL AI1PL ;СНАЧАЛА 1-ЫЙ ИГРОК ИДЕТ
	LXI H,FIRSTOBJ+10H ;+SIZEOFOBJ
	CALL AI2PL ;ТЕПЕРЬ ВТОРОЙ ИГРОК
	LXI H,FIRSTOBJ+20H
	MVI A,MAXOBJ-2  ;СЧЕТЧИК ОБ_ЕКТОВ
AIOBJ1:	PUSH PSW
	PUSH H
	CALL AIi80 ;НА ЧТО СПОСОБЕН i80?
	POP H
	LXI D,10H ;SIZEOFOBJ
	DAD D
	POP PSW
	DCR A
	JNZ AIOBJ1
	RET  ;ВСЕ??{AIOBJ}
AI1PL:	;ОБСЛУЖИВАЕМ 1-ГО ИГРОКА
	MOV A,M
	ORA A
	RZ
	CPI 3
	RNC   ;DON'T MIX RNC WITH RLC
	LXI H,FIRSTOBJ+6 ;OBJ0.DIR
	LDA YDEMO
	ORA A
	CALL CTRL1P ;КОНТРОЛЬ 1-ГО ИГРОКА
AI0:	JNZ AIO1  ;НА ДЕМОНСТРАЦИЮ
	PUSH PSW
	MOV B,M  ; B = OLDDIR
	MVI M,0  ;DIR=NORTH
	RLC
	JC AI00
	INR M    ;DIR=EAST
	RLC
	JC AI00
	MVI M,3
	RLC
	JC AI00
	DCR M
	RLC
	JC AI00
	MVI A,8
	ORA B ;СОХРАНЕННОЕ НАПРАВЛЕНИЕ + d3
	MOV M,A
AI00:	POP PSW ;ВООСТ.КОД НАЖАТИЯ (КЛАВИШИ/ДЖОЯ *ПУ*)
	ANI 8  ;FIRE1?
	RZ     ;NOPE
AIOF:	
	LXI B,6
	DAD B  ;HL TO OBJ[A].CSH (СОСТОЯНИЕ СТРЕЛЬБЫ)
	MVI A,80H
	ORA M
	MOV M,A ; SET d7 IN CSH
	RET
AIO1:
;ДЕМОНСТРАЦИЯ
	ANI 0F8H  ; ВСЕ ЖЕ ЕСТЬ НАЖАТИЕ?
	JNZ AIO10 ; YES - STOP PLAY_DEMO
	XCHG
	LHLD DEMON ;
	MOV A,M   ; БЕРЕМ КОД ДЕМО
	INX H
	SHLD DEMON
	XCHG
	CPI 255    ;КОНЕЦ ДЕМО?
	JNZ AIO11  ; NICHT - AIO11
AIO10:	LXI H,DEMOBEG ;АДРЕС НАЧАЛА ДЕМО
	SHLD DEMON
	MVI A,255
	STA YDEMO ;FLAG OF ENDING OF DEMO!?
	RET
AIO11:	MOV B,A ;STORE CODE IN <B>
	ANI 0FH
	MOV M,A  ; NEW DIR
	MOV A,B
	ANI 80H ; IF FIRE??
	RZ	; NOPE
	JMP AIOF; SET FLAG OF FIRE
AI2PL:
;	ОБСЛУЖИВАЕМ 2-ГО ИГРОКА
;	АНАЛОГИНО ПЕРВОМУ, ТОЛЬКО УПРАВЛЕНИЕ ВЫБИРАЕМ ДРУГОЕ
	MOV A,M ;CONDITION
	ORA A
	RZ
	CPI 3
	RNC
	LXI H,FIRSTOBJ+10H+6  ;УКАЖЕМ НА  DIR
	LDA YDEMO
	ORA A
	CALL CTRL2P  ;УПРАВЛЕНИЕ ВТОРОГ ИГРОКА
	JMP AI0		;ОСТАЛЬНОЕ ВСЕ КАК У 1-ГО БРАТА

;ТЕПЕРЬ КОМП (i80) ИГРАЕТ САМ
AIi80:
	MOV A,M
	ORA A
	RZ      ;IF EMPTY - RET
	CPI 3   ;IF BROKEN OR FROZEN
	RNC	; RET, TOO
	LXI B,9
	DAD B
	MOV A,M   ; OBJ.TYPE
	CPI 2
	RNC	;NOR TANK, NEITHER MAN - RET
	DCX H
	DCX H
	DCX H
	DCR A  ;IF MAN
	JZ AIMAN  ; GOTO AIMAN
	MVI A,8
	ANA M
	JNZ AIi81  ; NO MOVING
	RND
	CPI 19H
	JNC AIiFIRE  ;MOVE, IF FIRE?
AIi81:
	RND
	; NEW SUPER Z88 INSTRUCTION (2BYTES, 6 TACTS)
	CPI 15H
	JNC AIi82
	MVI A,8
	ORA M
	MOV M,A ;STOP VEHICLE
	RET
AIi82:	PUSH H  ;ЗАПОМНИМ УКАЗ. НА OBJ.DIR
	LDA LEVGOAL  ;ЦЕЛЬ МИССИИ ДЛЯ ИГРОКА
	DCR A        ;ЗАЩИТА БАЗЫ?
	JNZ AIi83    ;NOPE, MISS
	LDA BASEX
	STA PLX      ;ИНАЧЕ ПИШЕМ КООРДИНАТЫ БАЗЫ
	LDA BASEY    ; В КООРДИНАТЫ ИСКОМОГО ОБ_ЕКТА
	STA PLY   
	JMP AIi85
AIi83:	
; ИНАЧЕ ЦЕЛЬ МИССИИ ДЛЯ ИГРОКОВ - АТАКА БАЗЫ,
; ЛИБО УНИЧТОЖЕНИЕ ВРАГА.
;ПОДСТАВЛЯЕМ В PLX,PLY КООРДИНАТЫ БЛИЖАЙШЕГО ИГРОКА
	LDA FIRSTOBJ+4  ;PL1.CURX
	MOV B,A
	STA PLX
	LDA FIRSTOBJ+5  ;PL1.CURY
	MOV C,A
	STA PLY
	LDA FIRSTOBJ+10H  ;СОСТОЯНИЕ 2-ГО ИГРОКА
	ORA A
	JZ AIi85  ; ПУСТО - ИДЕМ К ПЕРВОМУ
	DCX H	; HL TO OBJ.CURY
	MOV A,M
	SUB C 
	JNC $+5
	NEG
	MOV E,A  ; E = ABS(PL1X-TANKX)
	DCX H
	MOV A,M  ;A=CURX
	SUB B
	JNC $+5
	NEG
	ADD E
	MOV E,A  ; E = DISTANCE TO PLAYER1
	LDA FIRSTOBJ+10H+4  ;PL2.CURX
	MOV B,A
	LDA FIRSTOBJ+10H+5  ;PL2.CURY
	MOV C,A
	MOV A,M  ;TANK.CURX
	SUB B    ; - PL2.CURX
	JNC $+5
	NEG
	MOV D,A  ; D = ABS(TANK.X - PL2.X)
	INX H
	MOV A,M
	SUB C
	JNC $+5
	NEG
	ADD D   ; A = DISTANCE TO PLAYER2
	CMP E	; COMPARE WITH DIST TO PL1
	JNC AIi85  ; JGE AIi85 (ИДЕМ НА 1-ГО,IF >= )
	MOV A,B
	STA PLX
	MOV A,C
	STA PLY
AIi85:	POP H	; ВОССТ.УКАЗ. НА OBJ.DIR
	DCX H
	RND
	CPI 0B0H
	JC AIi86 ;ИДЕМ ПО ОСИ  Y
; ИНАЧЕ ДВИГАЕМСЯ ПО ОСИ  X
	DCX H
	MOV C,M  ; C = CURX
	LDA PLX
	CMP C    ; PLx<CURX?
	INX H
	INX H
	MVI M,2  ; DIR = WEST
	JC AIiFIRE  ;OK.- GO WEST
	DCR M	; DIR = EAST IN ANOTHER CASE
	JMP AIiFIRE
AIi86:	MOV C,M  ; C = CURY
	LDA PLY
	INX H
	MVI M,0   ; DIR = NORTH
	CMP C
	JC AIiFIRE
	MVI M,3   ; ELSE DIR = SOUTH
AIiFIRE:
; ПРОБУЕМ ОТКРЫТЬ ОГОНЬ
; ПРИ ВХОДЕ СЮДА HL ДОЛЖЕН УКАЗЫВАТЬ НА  OBJ.DIR
	RND
	CPI 0E7H
	JNC AIiF5
	CPI 20H
	RNC
AIiF5:	LXI B,6
	DAD B    ; HL ONTO OBJ.CSH
	MVI A,80H
	ORA M	; CSH = CSH OR 80H
	MOV M,A ; 
; ON Z80 INSTRUCTIONS:
;	LXI H,CSH
;	SET 7,M
	RET
AIMAN:
; ЧЕЛОВЕКА ДВИГАЕМ СЛУЧАЙНО, ЧТОБЫ НЕ ЗАПОЛЗ ПОД ТАНК
	MVI A,8
	ANA M	 ;ЕСТЬ ДВИЖЕНИЕ?
	JNZ AIM3 ;НЕТ
	RND
	CPI 10H
	JNC AIiFIRE  ;ОТКРЫВАЕМ МОЖЕТ БЫТЬ ОГОНЬ
AIM3:	RND
	RRC
	RRC
	ANI 3
	MOV M,A   ; SET NEW DIRECION (0-3)
	JMP AIiFIRE  ; CONTINUE OF FIRE_CASE

;КОНЕЦ САБЫ  _AIOBJ_
; НО МАКАР ENGINE ЕЩЕ ПРОДОЛЖАЕТСЯ

;УПРАВЛЕНИЕ ИГРОКОВ МОЖЕТ МЕНЯТЬСЯ В ЛУЧШУЮ/ХУДШУЮ СТОРОНЫ
;ПОЭТОМУ ОНИ ВЫНЕСЕНЫ В ОТДЕЛЬНЫЕ САБЫ
;ВОЗМОЖЕН КОД В _МЕНЮ_ :
;	LXI H,JOYPU
;	SHLD CTRL1P+1
; ИЛИ:
;	LXI H,KEY1P
;	SHLD CTRL2P+1  ;МЕНЯЕМ УПРАВЛЕНИЕ 2-ГО ИГРОКА
CTRL1P:
	LDA KEY1P   ;БЕРЕМ КЛАВУ1
	RET
CTRL2P:
	LDA KEY2P
	RET

; ТЕПЕРЬ ПОШЕЛ САМ МОТОР ИГРЫ
;
CONTROLOBJ:
	MVI A,QBANK
	OUT 10H
	LXI H,FIRSTOBJ
	XRA A
CTROB0:	STA NUMOBJ  ;ТЕК.НОМЕР ОБ_ЕКТА
	MOV A,M  ;CONDITION
	ORA A	 ;<>EMPTY?
	PUSH H	 ;
	CNZ CTROB1  ; ДА - ОБСЛУЖИВЕМ ОБ_ЕКТ
	POP H
	LXI D,10H
	DAD D
	LDA NUMOBJ  ;СЧЕТСЧИК ОБ_КТОВ
	INR A		;УВЕЛИЧИМ
	CPI MAXOBJ  ;ДОСТИГЛИ МАКСИМАЛЬНОГО?
	JC CTROB0   ; NET - CTROB0
	XRA A
	OUT 10H	;QUASI-DISK OFF
	RET	; ВСЕ?! {CONTROLOBJ}
CTROB1:
	SHLD ADDROBJ  ;ЗАПОМНИМ АДРЕС ОБ_ЕКТА
	LXI D,DESOBJ  ;ПЕРЕПИШЕМ ИЗ
	XCHG	;СОСТОЯНИЯ ОБ_ЕКТА В OПИСАНИЕ ОНОГО
	REPT 9
	MOVSB
	ENDM
	LDAX D    ; 10 ЯЧЕЕК ПАМЯТИ
	MOV M,A
	LXI H,CTROB2
	PUSH H   ;УСТ.АДРЕС ВОЗВРАТА ПО !RET
	LDA TYPE  ; TИП ОБ_ЕКТА:
	ORA A
	JZ CTRTANK  ; ТАНК
	DCR A
	JZ CTRMAN   ; MAN
	DCR A
	JZ CTRBULL  ; BULLET (ПУЛЯ/СНАРЯД/РАКЕТА)
	JMP CTREXPL ; EXPLOSION (ВЗРЫВ БОЛЬШOЙ МОЩНОСТИ)
CTROB2:
	LXI D,DESOBJ ;DE - ОПИСАНИЕ ОБ_ЕКТА
	LHLD ADDROBJ ;HL - АДРЕС ТЕК.ОБ_ЕКТА
	REPT 9
	MOVSB
	ENDM
	LDAX D
	MOV M,A
	RET   ;ЧАСТЬ КОНТРОЛЯ ОКОНЧЕНА

;КОНТРОЛЬ ВЗРЫВА
CTREXPL:
	LDA OLDX
	MOV C,A
	LDA OLDY
	CALL GETMAPXY ;ОПРЕДЕЛИМ АДРЕС МАР
	LDA TIMEROBJ
	ORA A
	JZ CTEX5 ;ВЗРЫВ КОНЧИЛСЯ
	DCR A
	STA TIMEROBJ  ;ВРЕМЯ ВЗРЫВА
	CPI 4
	MVI A,224  ;EXPL1
	JNC $+5
	MVI A,228  ;EXPL2
	STA VID
	JMP PUTINMAP1
CTEX5:	MVI A,255
	STA CONDITION  ; OBJECT = DEAD
	JMP DELFRMAP1

;/////// Т А Н К ! ! ! \\\\\\\\\\\\
CTRTANK:
	LXI H,CONDITION
	MOV A,M
	DCR A
	JZ CTRTA5  ; NORMAL
	PUSH H
	LXI D,0FH
	DAD D
	DCR M  ; DEC(TIMEROBJ)
	POP H
	JNZ CTRTA4
	MVI M,1  ;CONDITION = NORMAL
	DCR A
	JZ CTRTA5 ; БЕССЕРТЕН БЫЛ - ПРОДОЛЖИМ
	DCR A
	RZ	; БЫЛ ЗАМОРОЖЕН - ПОКА ВЫЙДЕМ
	MVI M,0  ; ОСВОБОДИМ ОБ_ЕКТ
	LDA CURX
	MOV C,A
	LDA CURY
	CALL GETMAPXY
	CALL MOVEMAP1MAP ;ПОМЕСТИМ КОДЫ ТАНКА ИЗ MAP1->MAP
	JMP DELFRMAP1	;УДАЛИМ ЕГO ИЗ МАР1 И ВСЕ?
CTRTA4:	DCR A
	RNZ
CTRTA5:
	; OБРАБОТАЕМ ТАНК В НОРМАЛЬНОМ
	; И БЕССМЕРТНОМ СОСТОЯНИ
	CALL STOREOLD ;СОХРАНИМ КООРДИНАТЫ
	CZ MOVETANK   ;ДВИГАЕМ ТАНК В НАПР. DIR
	LDA CSH
	MOV B,A
	ANI 80H
	RZ	; НЕ СТРЕЛЯЛ
	MVI A,7FH
	ANA B
	STA CSH
	LXI H,SHTM  ;СКОРОСТРЕЛЬНОСТЬ
	CMP M
	RZ	;
; ИНАЧЕ ПРОБУЕМ ВЫСТРЕЛИТЬ
	CALL CHECKEDGE ;ПРОВЕРКА СТОИТ ЛИ НА КРАЮ ОБ_ЕКТ
	RC  ; DA - RET
	LDA DIR
	ANI 3
	ADD A
	LXI H,SHIFTS
	ADDHL
	MOV C,M  ;DSHIFT
	INX H
	MOV B,M
	LXI D,INCCOOR16  ;ПРИРАЩЕНИЯ К КООРДИНТАМ ВЫСТРЕЛА
; СОЗДАЕМ НОВЫЙ ВЫСТРЕЛ
; ВХОД - BC-SHIFTS, DE - POINTER TO TABL OF INC_COORS
CREATEBULL:
	PUSH B
	PUSH D
	CALL FINDFREEOBJ
	POP D
	POP B
	RC  ; НЕ НAЙДЕН СВОБОДНЫЙ ОБ_ЕКТ
	MVI M,1  ;CONDITION
	MVI A,6
	ADDHL
	LDA DIR
	ANI 3
	STOSB    ;DIR
	STOSB B  ;XSHIFT
	STOSB C  ;DSHIFT
	MVI M,2  ;TYPE
	INX H
	LDA WTYPE  ;ВИД ОРУЖИЯ
	LXI B,POWERS ;МОЩНОСТИ ЗАРЯДОВ
	ADD C
	MOV C,A ; NOT COUNTING CY
	LDAX B
	STOSB	 ;POWER
	INX H
	INX H
	LDA WTYPE
	LXI B,SPEEDS  ;	СКОРОСТЯ СНАРЯДОВ
	ADD C
	MOV C,A
	LDAX B
	STOSB	 ;SPEED
	LDA NUMOBJ
	STOSB	 ;MOTHERNUMBER
	LXI B,DISTANCE
	LDA WTYPE
	ADD C
	MOV C,A
	LDAX B
	MOV M,A
	LXI B,-14
	DAD B  ;НАСТРОИМ HL НА ВИД OБ'ЕКТА
	LDA WTYPE
	ADD A
	ADD A
	MOV B,A
	LDA DIR
	ANI 3
	ADD B   ; A = WTYPE*4+DIR
	LXI B,VIDS
	ADD C
	MOV C,A
	LDAX B
	STOSB  ; VID
	LDA DIR
	ANI 3
	ADD A
	ADDDE  ;ПРИРАЩЕНИЯ
	XCHG
	LDA CURX
	ADD M
	MOV B,A
	INX H
	LDA CURY
	ADD M
	XCHG
	STOSB B	 ;OLDX
	STOSB	 ;OLDY
	STOSB B	 ;CURX
	STOSB	 ;CURY
	LXI H,CSH
	INR M  ; КОЛ-ВО ВЫСTРЕЛОВ УВЕЛИЧИМ
	RET
STOREOLD:
;СОХРАНЕНИЯ КООРИНАТ И ПРОВЕРКА ДВИЖЕНИЯ
	LDA CURX
	STA OLDX
	LDA CURY
	STA OLDY
	LDA DIR  ; BIT 3,DIR
	ANI 8	 ;(ЕСЛИ 1, ТО НЕТ ДВИЖЕНИЯ)
	RET
STORESHIFTS:
; СОХРАНИМ СДВИГИ
	LXI H,XSHIFT
	MOV A,M
	RLC
	RLC
	RLC
	RLC
	ANI 0F0H
	ORA M
	MOV M,A
	INX H
	MOV A,M
	RLC
	RLC
	RLC
	RLC
	ANI 0F0H
	ORA M
	MOV M,A  ;OLD_DSHIFT
	RET

CHECKEDGE:
;ПРОВЕРКА УПИРАНИЯ ОБ'ЕКТА В КРАЙ КАРТЫ
	LOCAL CHED1,CHECKN,CHECKE,CHECKW
	LDA CURX
	MOV B,A
	LDA CURY
	MOV C,A
	MVI D,1FH  ;МAXX
	LDA LMAXY
	MOV E,A    ;MAXY
	LDA TYPE
	ORA A
	JNZ CHED1
	DCR D
	DCR E  ;ДЛЯ ТАНКОВ КОНЕЧНЫЕ КООРДИНАТЫ МЕНЬШЕ	
CHED1:	LDA DIR
	ANI 3
	JZ CHECKN ;СЕВЕР
	DCR A
	JZ CHECKE ;ВОСТОК
	DCR A
	JZ CHECKW ;ЗАПАД
; ИНАЧЕ НАПРАВЛЕНИЕ - ЮГ
	MOV A,E ;MAXY COMP CURY
	CMP C
	RNZ ;ВЫХОД С CY = 0
	STC
	RET
CHECKN:
	ORA C
	RNZ
	STC
	RET
CHECKE:
	MOV A,D
	CMP B
	RNZ
	STC
	RET
CHECKW:
	ORA B
	RNZ  ;IF CURX=0 THEN CY=1
	STC
	RET

;////////// M A N \\\\\\\\\\\\\
CTRMAN:
	LXI H,CONDITION
	MOV A,M
	DCR A
	JZ CTRMA5 ;NORMAL
	PUSH H
	LXI D,0FH
	DAD D
	DCR M
	POP H
	JNZ CTRMA4
	MVI M,1  ;CONDITION=NORMAL
	DCR A
	JZ CTRMA5
	MVI M,0FFH  ; CONDITION = DEAD
	RET  ;ВСЕ
CTRMA4:	DCR А  ;ПРОДОЛЖИМ ТОЛЬКО ДЛЯ БЕССМЕРТНОГО
	RNZ	; (CONDITION=2)
CTRMA5:
	CALL STORESHIFTS ;СОХРАНИМ СДВИГИ ОБ'ЕКТА
	CALL STOREOLD   ;СОХРАНИМ КООРДИНАТЫ
	CZ MOVEMAN  ;ПРОБУЕМ ДВИНУТЬ ЧЕЛОВЕКА
	LDA CSH
	MOV B,A
	ANI 80H
	RZ   ; НЕ СТРЕЛЯТЬ!
	MVI A,7FH
	ANA B
	STA CSH ;КОЛ-ВО ВЫСТРЕЛОВ
	LXI H,SHTM  ;СКОРОСТРЕЛЬНОСТЬ
	CMP M
	RZ
	CALL CHECKEDGE
	RC ; НА КРАЮ - ВСЕ
	LDA XSHIFT
	ANI 0FH
	MOV B,A    ; В <BC> - СДВИГИ MAN'A
	LDA SHIFT
	ANI 0FH
	MOV C,A  
	LXI D,INCCOORMAN ;ПРИРАЩЕНИЯ ДЛЯ МАН'А
	JMP CREATEBULL   ;СОЗДАЕМ ПУЛЮ И ВСЕ

;СОБСТВЕННОЕ ДВИЖЕНИЕ И ОБРАБОТКА ТАНКА
;ВЗАИМОДЕЙСТВИЕ ТАНКА С ДРУГИМИ ПОДВИЖНЫМИ И НЕ
;ПОДВИЖНЫМИ ОБ'ЕКТАМИ
MOVETANK:
	CALL CHECKEDGE
	RC
	LDA NUMOFDSP
	STA xDSP ;СОХРАНИМ НАЧАЛЬНОЕ КОЛ-ВО ДЯ ВОССТАНОВЛЕНИЯ
;В СЛУЧАЕ ЕСЛИ ТАНК ОСТАНОВИТСЯ
	LDA DIR
	ANI 3
	ADD A
	ADD A
	LXI H,INCTANK ;ТАБЛИЦА ПРИРАЩЕНИЙ
			;ДЛЯ ПРОВЕРКИ MAPS
	ADDHL
	LDA CURX
	ADD M
	STA NCURX  ;НОВЫЙ X
	MOV B,A
	LDA CURY
	INX H
	ADD M
	MOV C,A
	STA NCURY  ;НОВЫЙ Y
	PUSH H
	CALL CHECKMAP  ; ПРОВЕРИМ КАРТУ
	POP H
	JC STOPTANK ; ТАНК НЕ ЕДЕТ
	INX H
	LDA CURX  ;ПРИРАЩЕНИЯ ДЛЯ
	ADD M     ;ВТОРОЙ ПОЛОВИНЫ КАPTЫ
	MOV B,A
	INX H
	LDA CURY
	ADD M
	MOV C,A
	CALL CHECKMAP ;ПРОВЕРИМ КАРТУ ДЛЯ ПРАВОЙ ЧАСТИ ТАНКА
	JC STOPTANK ;ОСТАНАВЛИВАЕМСЯ

;////// ИНАЧЕ ТОЧНО ДВИГАЕМ ТАНК \\\\\\\\\\\
	LXI D,STWALLXY
RMT0:	LXI H,CWALL
	MOV A,M
	DCR A     ;НЕТ УДАЛЕННЫХ СТЕН
	JM RMT1
	MOV M,A
	PUSH D
	LDAX D
	MOV C,A
	INX D
	LDAX D  ;STWALL.Y
	CALL GETMAPXY
	MVI A,255
	STAX D  ; ЧИСТИМ КАРТУ ОТ СТЕНЫ
	POP D
	CALL SAVEDSTCOOR ;CОХРАНИМ КООРД.КИРП.СТЕНЫ
	JMP RMT0
RMT1:	LXI D,FLAGXY ;КООРДИНАТЫ ФЛАЖКА
	LXI H,CFLAG
	MOV A,M
	DCR A
	JM RMT3
	MVI M,0
	PUSH D  ;УДАЛИМ ФЛАГ С МАР1
	LDAX D
	MOV C,A ; C=FLAGX
	INX D
	LDAX D  ; A=FLAGY
	CALL GETMAPXY
	CALL DELFRMAP
	POP D
	REPT 4
	CALL SAVEDSTCOOR
	ENDM
	LDA ARMOR
	STA HP  ;ВОССТАНОВИМ HP ДО МАКСИМУМА
	LXI H,NUMMEL
	MVI A,2
	ORA M
	MOV M,A
RMT3:	LXI D,STARXY
	LXI H,CSTAR  ;ВЗЯЛИ ЗВЕЗДУ?
	MOV A,M
	ORA A
	JZ RMT4
	MVI M,0
	PUSH D
	LDAI
	MOV C,A
	LDAX D
	CALL GETMAPXY
	CALL DELFRMAP  ;УДАЛИМ ЗВЕЗДУ ИЗ КАРТЫ
	POP D
	REPT 4
	CALL SAVEDSTCOOR
	ENDM
	LXI H,NUMMEL ;НОМЕР МЕЛОДИИ
	MVI A,4
	ORA M
	MOV M,A
; ПРОВЕДЕМ РАЗДАЧУ БОНУСА
	LXI H,BONUS
	INR M
	LXI H,BONOBJ
	LDA NUMOBJ ;НОМЕР ТЕКУЩЕГО ОБ'ЕКТА
	INR A ;ДОЛЖНО БЫТЬ ЛИБО 1, ЛИБО 2
	ORA M
	MOV M,A
RMT4:	LXI D,MINEXY
	LXI H,CMINE  ;ПОДОРВАЛИСЬ НА МИНЕ?
	MOV A,M
	DCR A
	JM RMT6  ; НЕТ - RMT6
	MOV M,A
	PUSH D
	LDAI
	MOV C,A
	LDAX D
	CALL GETMAPXY ;ПОУЧИМ АДРЕС МИНЫ
	CALL DELFRMAP ;УДАЛИМ ЕЕ С КАРТЫ
	POP D
	PUSH D
	REPT 4
	CALL SAVEDSPCOOR;УДАЛИМ ОБ'ЕКТ С ЭКРАНА
	ENDM
	LDA CONDITION
	CPI 2
	JZ RMT50  ;ЕСЛИ БЕССМЕРТНЫ, ТО ВСЕ
	LDA HP
	SUI 5
	STA HP
	JC EXPLTANK ; ТАНК ВЗОРВАН
	JZ EXPLTANK ; TO ЖЕ	
RMT50:	POP H
	MOV B,M  ;MINEX
	INX H
	MOV C,M  ;MINEY
	CALL CREATEEXPL  ;СOЗДАДИМ ВЗРЫВ
	JMP RMT4
RMT6:	LXI D,CMAN
	LDAX D
	DCR A
	JM RMT7  ;НЕТ РАЗДАВЛЕННОГО МАНА
	STAI
	XCHG
	MOV A,M ;ПОЛУЧИМ НОМЕР РАЗДАВЛЕННОГО МАНА
	CALL GETADOBJ ;ПОЛУЧИМ АДРЕС ЕГО ОБ'ЕКТА
	MVI M,4 ; CONDITION = CRUSHED
	INX H
	MVI M,245  ; VID
	INX H
	INX H
	INX H
	MOV C,M  ; C=CURX
	INX H
	MOV A,M  ; A=CURY
	INX H
	INX H
	CALL GETMAPXY
	MOV A,M
	ANI 0FH
	MOV B,A  ; B=NEWXSHIFT
	INX H
	MOV A,M
	ANI 0FH
	MOV C,A  ; C=NEWDSHIFT
	CALL DEL8FRMAP1  ;УДАЛИМ ОБ'ЕКТ С КАPТЫ
	LXI H,MAXMEN
	DCR M  ;УМЕНЬШИМ СЧЕТЧИК ЛЮДЕЙ
	LXI H,NUMMEL
	MVI A,8
	ORA M
	MOV M,A
RMT7:
;	ТЕПЕРЬ НАКОНЕЦ ДВИГАЕМ САМ ТАНК
;	В КАРТЕ УРОВНЯ И КООРДИНАТЫ
	LDA CURX
	MOV C,A
	LDA CURY
	CALL GETMAPXY
	CALL DELFRMAP1  ;УДАЛИМ ТАНК ИЗ КАРТЫ
;ПО СТАРЫМ КООРДИНАТАМ
	LDA NCURX
	STA CURX
	MOV C,A
	LDA NCURY ;NEW COORDS X,Y
	STA CURY
	MOV D,A
	LDA DIR
	ANI 3
	ADD A
	ADD A
	LXI H,MOTHEROBJ
	ADD M
	STA VID
	MOV A,D ;ВОСТ. CURY
	CALL GETMAPXY
	LDA VID
	JMP PUTINMAP1 ;ПОМЕСТИМ КОДЫ В КАРТУ-1 И ВСЕ
EXPLTANK:
; ТАНЕ ПОДОРВАЛСЯ НА МИНЕ
	MVI A,255
	STA CONDITION
	POP PSW  ;ЧИСТИМ СТЕК
	XRA A
	STA CSH	; БОЛЬШЕ НЕ СТРЕЛЯЕТ
	LDA NUMOBJ
	CPI 2
	RC  ;ДЛЯ ИГРОКА ПРОСТО ВЫХОДИМ
;ИНАЧЕ НАХОДИМ НОМЕР ТАНКА ПО ЕГО MOTHERNUMBER
	LDA MOTHERNUMBER
; ДЕЛИМ ЕГО НА 16
	REPT 4
	ORA A
	RAR
	ENDM	
	LXI H,MAXMEN
	ADDHL
	DCR M  ; УМЕНЬШИМ ЧИСЛО TАНКОВ
	RET  ; ВЫХОДИМ В CTRTANK	
SAVEDSTCOOR:
; СОХРАНЕНИЕ ПАРЫ КООРДИНАТ (Х,У) ДЛЯ
; ПОСЛЕДУЮЩЕГО УДАЛЕНИЯ С ЭКРАНА В САБЕ DELSTOBJ
; (ЕСЛИ ОНИ ПОПАДАЮТ В ВИДИМУЮ ЧАСТ КАРТЫ)
;	ВХОД:	DE- УКАЗАТЕЛЬ НА ПАРУ КООРДИНАТ
	LXI H,NUMOFDST
	MOV A,M
	CPI MAXDST
	RZ ; БОЛЬШЕ НЕ СОХРАНЯЕМ
	INR M
	LXI H,DSTXY
	ADD A
	ADDHL ; ПРОВЕДЕМ ИНДЕКСАЦИЮ
	MOVSB  ; [DE]->[HL] С ИНКРЕМЕНТОМ
	MOVSB
	RET  ;ВСЕ
CREATEEXPL:
;СОЗДАЕМ ВЗРЫВ ПО КООРДИНАТАМ <BC> НА ВХОДЕ
	PUSH B
	CALL FINDFREEOBJ
	POP B
	RC
	MVI M,1  ;CONITION=NORMAL
	INX H
	MVI M,224 ;VID
	INX H
	STOSB B ;OLDX
	STOSB C ;OLDY
	STOSB B ;CURX
	STOSB C ;CURY
	INX H
	INX H
	INX H
	MVI M,3 ;TYPE
	LXI B,6
	DAD B
	MVI M,9 ;TIMEROBJ (RANGE FOR BULLETS)
	RET
;КОНТРОЛЬ КАРТЫ ДЛЯ ТАНКА - ОСНОВНАЯ
;BXOD - BC- COORDS
CHECKMAP:
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY ;ПОЛУЧИМ АДРЕС МАР В DE
	POP B
	LDAX D
	CPI 252  ;SPACE ZONE
	JNC CHM5 ;ПРОХОДИМ ДАЛЕЕ
	CPI 200
	RC
	CPI 204
	JC BREAKSTWALL ;СЛOМАЕМ СТЕНУ
	CPI 212
	JC CHM5
	CPI 216 ;ЭТО CROSS?
	RC	;DA - RET
	CPI 220
	JC CATCHSTAR ;ХВАТАЙ ЗВЕЗДУ!
	CPI 224
	JC CATCHFLAG ;СХВАТИМ ФЛАГ
	CPI 236  ;ПЕСОК
	JC CHM5  ;ПРОХОДИМ ДАЛЕЕ
	CPI 240
	JC EXPLMINE ;ВЗОРВЕМСЯ
CHM5:	;ПРОВЕРИМ ТЕПЕРЬ _MAP1_
	LXI H,2000H
	DAD D
	MOV A,M
	CPI MAN1
	RC ;НЕ ИДЕМ
	CPI 244
	JC CRUSHAMAN ;ДАВИМ НЕГОДЯЯ
	RET ;ИНАЕ ВЫХОД С CY=0
BREAKSTWALL:
	LXI H,CWALL
	MOV A,M
	INR M
	ADD A
	LXI H,STWALLXY
	ADDHL
	STOSB B
	MOV M,C
	ORA A
	RET ;ВЫХОДИМ ИЗ CHECKMAP С СУ=0
CATCHSTAR:
	CALL GETTOPLEFT ;НАХОДИМ ИСТИННЫЕ КООРД. В BC
	LXI H,CSTAR
	JMP CATFL4
CATCHFLAG:
	CALL GETTOPLEFT
	LXI H,CFLAG
CATFL4:	INR M
CATFL5:	INX H
; ЗАПОМНИМ 4 КООРДИНАТЫ ИЗ <BC> B [HL]
	STOSB B ;X,Y
	STOSB C
	INR B  ;X+1,Y
	STOSB B
	STOSB C
	INR C  ;X+1,Y+1
	STOSB B
	STOSB C
	DCR B  ;X,Y+1
	STOSB B
	MOV M,C
	ORA A
	RET
EXPLMINE:
	CALL GETTOPLEFT
	LXI H,CMINE
	MOV A,M
	INR M
	ADD A
	LXI H,MINEXY
	ADDHL
	JMP CATFL5+1 ;ЗАПОМНИМ 4 КООРДИНАТЫ МИНЫ ДЛЯ СТИРАНИЯ
GETTOPLEFT:
;ПОЛУЧИТ ИСТИННЫЕ X,Y ОБ('ЕКТА 16x16
;ВХОД: A - CODE, BC-COORDS
	ANI 3
	RZ
	DCR B
	DCR A
	RZ
	DCR C
	DCR A
	RNZ
	INR B
	RET
CRUSHAMAN:
	LDA DIR
	ANI 3
	CPI 1
	JZ CAM5
	CPI 3
	JZ CAM5
	ORA A
	JNZ CAM2
	CALL FINDOBJ ; ИЩЕМ ОБ'ЕКТ ПО КООРДИНАТАМ <BC>
	JNC CAM6  ; НАЙДЕН, ЕСЛИ CY=0
	DCR C
	JMP CAM5
CAM2:	;ТАНК СМОТРИТ НА ЗАПАД
	CALL FINOBJ
	JNC CAM6 ;НАЙДЕН
	DCR B
CAM5:	CALL FINDOBJ
	RC
CAM6:	LXI H,CMAN
	MVI M,1
	INX H
	MOV M,A
	RET
MOVEMAN:
	CALL CHECKEDGE
	RC
	LDA CURX
	MOV B,A
	LDA CURY
	MOV C,A
	LDA DIR
	ANI 3
	JZ MANN
	DCR A
	JZ MANE
	DCR A
	JZ MANW ;ДВИГАТЬ НА ЗАПАД
;ИНАЧЕ ДВИГАЕМ НА ЮГ
	LDA DSHIFT
	MOV D,A
	ANI 0FH
	JZ MANS2
	MOV A,D
	ANI 0F0H
	STA DSHIFT
	INR C
	JMP RMOVEM ;ДВИГАЕМ МАНА
MANS2:	PUSH B
	INR C
	CALL CHECKMAN
	POP B
	JC STOPMAN
	LDA XSHIFT
	ANI 0FH
	JZ MANS3
	PUSH B
	INR B
	INR C
	CALL CHECKMAN
	POP B
	JC STOPMAN
MANS3:	LDA DSHIFT
	ANI 0F0H
	ORI 4
	STA DSHIFT
	JMP RMOVEM
MANN:	LDA DSHIFT
	MOV D,A
	ANI 0FH
	JZ MANN2
	MOV A,D
	ANI 0F0H
	STA DSHIFT
	JMP RMOVEM
MANN2:	DCR C
	PUSH B
	CALL CHECKMAN
	POP B
	JC STOPMAN
	LDA XSHIFT
	ANI 0FH
	JZ MANS3 ;КАК НА ЮГ
	PUSH B
	INR B
	CALL CHECKMAN
	POP B
	JC STOPMAN ; НЕТ ДВИЖЕНИЯ
	JNC MANS3
MANE:	;ДВИГАЕМСЯ НА ВОСТОК
	LDA XSHIFT
	ANI 0FH
	JZ MANE2
	INR B
	LDA XSHIFT
	ANI 0F0H
	STA XSHIFT
	JMP RMOVEM
MANE2:	PUSH B
	INR B
	CALL CHECKMAN
	POP B
	JC STOPMAN
	LDA DSHIFT ;ЕСТЬ СДВИГ ВНИЗ?
	ANI 0FH
	JZ MANE5 ; НЕТ - ВСЕ
	PUSH B
	INR B
	INR C
	CALL CHECKMAN
	POP B
	JC STOPMAN
MANE5:	LXI H,XSHIFT
	MOV A,M
	ANI F0H
	ORI 4
	MOV M,A
	JMP RMOVEM
MANW:	LDA XSHIFT
	MOV D,A
	ANI 0FH
	JZ MANW2
	MOV A,D
	ANI 0F0H
	STA XSHIFT
	JMP RMOVEM
MANW2:	DCR B
	PUSH B
	CALL CHECKMAN
	POP B
	JC STOPMAN
	LDA DSHIFT
	ANI 0FH
	JZ MANW5
	PUSH B
	INR C
	CALL CHECKMAN
	POP B
	JC STOPMAN
MANW5:	LXI H,XSHIFT
	MOV A,M
	ANI 0F0H
	ORI 4
	MOV M,A
RMOVEM:	;РЕАЛЬНОЕ ДВИЖЕНИЕ ЧЕЛОВЕКА
	PUSH B ; ЭТО НОВЫЕ КООРДИГАТЫ МЭНА
	LDA XSHIFT
	ANI 0F0H
	RRC
	RRC
	RRC
	RRC
	MOV B,A ; B=OLDSHIFT
	LDA DSHIFT
	ANI 0F0H
	REPT 4
	RRC
	ENDM
	MOV C,A
	PUSH B
	LDA CURX
	MOV C,A
	LDA CURY
	CALL GETMAPXY
	POP B
	CALL DEL8FRMAP1 ;УДАЛИМ ЕГО
	POP B ;ВОССТ.КООРДИНАТЫ
	LXI H,CURX
	STOSB B
	MOV M,C
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	LDA XSHIFT
	ANI 15
	MOV B,A
	LDA DSHIFT
	ANI 15
	MOV C,A
	LDA CYCLES
	ANI 3
	ADI MAN1
	STA VID ;ЗАДАЕМ НОВЫЙ ВИД МЭНА
	JMP PUT8INMAP1 ;ПИШЕМ ЕГО В КАРТУ-1 И ВСЕ?
STOPMAN:
	LDA DIR
	ORI 8
	STA DIR
	RET
SOPTANK:
	LDA XDSP
	STA NUMOFDSP
	XRA A
	STA CWALL
	STA CFLAG
	STA CSTAR
	STA CMINE
	STA CMAN
	JMP STOPMAN
CHECKMAN:
;ПРОВЕРКА КАРТЫ ДЛЯ МАНА!
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	POP B
	LDAX D ;БЕРЕМ КОД ИЗ МАР
	CPI 252
	JNC CHMAN5
	CPI 128
	JC SITINTANK ;САДИТCЯ В ТАНК!
	CPI 172
	RC
	CPI 176   ;ЕЖ?
	JC CHMAN5
	CPI 204
	RC
	CPI 216 ;ТREE,FIR-TREE,CROSS
	JC CHMAN5 ;ПРОХОДИМ
	CPI 224
	RC
CHMAN5:	MVI A,20H
	ADD D
	MOV D,A
	LDAX D
	CPI 252
	RET
SITINTANK:
;СЕСТЬ В ТАНК
;ВХОД:	BC- КООРДИНАТЫ ТАНКА, A - KOD ЧАСТИ ТАНКА
	PUSH PSW
	CALL GETTOPLEFT
	POP PSW
	ANI 0FCH
	STA VID
	RAR
	RAR
	RAR
	ORA A
	RAR
	PUSH PSW
	LXI H,MAXMEN
	DCR M
	MOV E,A
	LDA NUMOBJ
	CPI 2
	JC SITIT3
	MOV A,E
	ADDHL
	INR M ;УВЕЛИЧИМ КОЛ-ВО ТАНКОВ
SITIT3:	POP PSW
	ADD A
	ADD A
	LXI H,TABTANK
	ADDHL
	MOV A,B
	STA OLDX
	STA CURX
	MOV A,C
	STA OLDY
	STA CURY
	LDA VID
	SUB M ; - MOTHERNUMBER
	RAR
	ORA A
	RAR
	ORI 8
	STA DIR
	MOV A,M
	STA MOTHERNUMBER
	INX H
	MOV A,M
	STA ARMOR
	STA HP
	INX H
	MOV A,M
	STA SHTM
	XRA A
	STA CSH
	STA TYPE
	INX H
	MOV A,M
	STA WTYPE
	LDA MOTHERNUMBER
	CPI 96
	MVI A,0
	JC $+4
	INR A
	STA SPEED
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	CALL DELFRMAP ;СТИРАЕМ С КАРТЫ
	LDA VID  ;ВИД ТАНКА
	CALL PUTINMAP1  ;ПИШЕМ В _МАР1_
	POP H ;ЧИСТИМ СТЕК ОТ АДРЕСА CHECKMAN
	STC ;ДВИЖЕНИЯ НЕТ
	RET
;ВСЕ? {CTRMAN}
; ПАМЯТЬ КОНЧАЕТСЯ И Я ВЫНУЖДЕН РАЗБИТЬ МОТОР НА ДВЕ ЧАСТИ
; ПРОДОЛЖЕНИЕ СМТРИТЕ В ФАЙЛЕ __ENGINE2.LIB__
;  ИМЯ МАКАРА: __ENGINE2__
	ENDM
;КОНЕЦ МАКАРА __ENGINE__
