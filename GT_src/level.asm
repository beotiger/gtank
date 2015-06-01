;/////////////  G - T A N K  \\\\\\\\\\\\\
;/// LIBRARY:	**LEVEL**
;   by gDw , Volgograd FEB 18 2000aD.
; БИБЛИОТЕКА ОБСЛУЖИВАНИЯ УРОВНЕЙ

;	МАКАР:	__LEVEL__
; САБЫ: INITLEVEL, PUTLEVEL

;	MAKAR:	__OBJECT__
; САБЫ:	FINDFREEOBJ, CLEAROBJ, COUNTOBJ, PUTOBJ, PUTALLOBJ
;	FINDOBJ, GETADOBJ, PUTSOBJ

;	МАКАР:	__МАР__
; САБЫ:	PUT(8)INMAP(1), DEL(8)FRMAP(1)
;	MOVEMAP1MAP	

LEVEL	MACRO
INITLEVEL:
	DI
	MVI A,QBANK
	OUT 10H
	LXI H,0
	DAD SP ;ЧИСТИМ КАРТЫ УРОВНЕЙ MAP, MAP1
	LXI SP,0E000H
	LXI D,0FFFFH
	LXI B,4FFH
	XRA A
	STA YBASE    ;  БАЗА - НЕ РАЗБИТА
	STA NOENEMY  ;  ВРАГ - ДОЛЖЕН БЫТЬ

	LOCAL INIL0,INIL1,INIL2,INIL3,INIL4
	LOCAL FILLBEARPOINT,FILLTURRETPOINT
	LOCAL FILLBASECOOR,INIL01,INIL02
INIL0:	REPT 8
	PUSH D
	ENDM
	DCX B
	CMP B
	JNZ INIL0
	SPHL
	CALL CLEAROBJ ;ОЧИСТИМ ОБ_ЕКТЫ И НЕКТОРЫЕ ЯЧ.
	LHLD LEVPTR ;УКАЗ.УРОВНЯ ТЕК.
	LDIR ,LEVNAME,14 ;ИМЯ УРОВНЯ
	MOV A,M
	STA LMAXY
	INX H
	STA LEVGOAL ;ЦЕЛЬ МИССИИ
	INX H
	MOV A,M
	STA LCURY ;ТЕК.Y УРОВНЯ
	INX H
	LDIR ,MAXMEN,8 ;ЧИСЛО ПРОТИВНИКА
	MOV A,M
	STA BASEHP ; ХИТ-ПОИHТЫ БАЗЫ
	INX H
	LDA FIRSTOBJECT+5   ; PL1.CURY
	CPI 255   ; ЕСЛИ ИГРОКА НЕТ
	INX H     ; ТО НЕ ЗАПОЛНЯЕМ ЕГО НОВЫЕ КООРДИНАТЫ
	JZ  INIL02
	DCX H
	LXI D,FIRSTOBJECT+2 ; OBJ0.OLDX
	MOV A,M
	STAX D
	INX D
	INX D
	STAX D
	DCX D
	INX H
	MOV A,M
	STAX D
	INX D
	INX D
	STAX D ;OBJ0.CURY = LEVEL[X].TANK1.Y
INIL02:	LXI D,FIRSTOBJECT+10H+2 ;УКАЗАТ НА TANK2
	INX H
	LDA FIRSTOBJ+15H ;БЕРЕМ PL2.CURY
	CPI 255
	INX H  ; ПРОПУСТИМ LEVEL[X].TANK2.Y
	JZ INIL01
	DCX H	
	MOV A,M
	STAX D
	INX D
	INX D
	STAX D
	INX H
	MOV A,M ;A=LEV[X].TANK2.Y
	DCX D
	STAX D
	INX D
	INX D
	STAX D
INIL01:	INX H
	MOV B,H
	MOV C,L  ; BCHL
	XRA A
	STA CURY
	LDA LMAXY
	INR A
	RAR
	LXI D,MAP ;УКАЗ.НА НАЧАЛО КАРТЫ (A000H)
INIL1:
	PUSH PSW ;СЧЕТЧИК СТРОК
	XRA A
	STA CURX ;ТЕК.X
	MVI A,16  ;ЧИСЛО КОЛОНОК В УРОВНЕ
INIL2:	PUSH PSW
	PUSH D
	LDAX B  ;КОД УРОВНЯ БЕРЕМ В <А>
	CPI 128 ;ТАНК?
	JC INIL3 ;ДА ->
	CPI 160   ;ПУШКА?
	CC FILLTURRETPOINT ;ЗАПОЛНИМ ЕЕ КООРДИНАТЫ
	CPI 168	;БАЗА?
	CZ FILLBASECOOR ;ЗАПОМНИМ КОРД.БАЗЫ
	CPI 176
	CZ FILLBEARPOINT ;ЗАПОЛНИМ ТОЧКУ ПОЯВЛЕНИЯ ТАНКОВ
	CPI MAN1
	JC INIL3
	CPI MAN1+4
	CC SETMAN ;УСТАНОВИМ ЧЕЛОВЕКА В УРОВНЕ
	JMP INIL4
INIL3:	;ЗАПОЛНИМ КАРТУ  МАР ОБ_ЕКТОМ 16х16
	CALL PUTINMAP
INIL4:	POP D
	INX B
	INX D
	INX D
	LXI H,CURX
	INR M
	INR M
	POP PSW
	DCR A
	JNZ INIL2
	LXI H,32
	DAD D  ; ПРОПУСТИМ СТРОКУ  В МАР
	XCHG   ; ТАК КАК РАБОТАЕМ С КАРТИНКАМИ 16х16
	LXI H,CURY
	INR M
	INR M ;ПРОПУСТИМ СТРОКУ  ПО ТОЙ ЖЕ ПРИЧИНЕ
	POP PSW ;ВОССТ.СЧЕТЧИК СТРОК
	DCR A
	JNZ INIL1
	MOV H,B
	MOV L,C  ;HLBC
	SHLD LEVPTR ;СОХРАНИМ УКАЗ.НА СЛЕД.УРОВЕНЬ
;	CОЗДАДИМ РЕЗЕРВНУЮ КОПИЮ КОЛ-ВА ТАНКОВ
	LDIR MAXMEN,TANKS,8
	XRA A
	OUT 10H
	EI
	RET ;ВСЕ?{INITLEVEL}
FILLBASECOOR:
;ЗАПOЛНЕНИЕ КООРДИНАТ БАЗЫ
;ЧТОБЫ ТАНКИ ПРОТИВНИКА СМОГЛИ НАХОДИТЬ ЕЕ
	PUSH PSW
	LDA CURY
	STA BASEY ;КООРД Y БАЗЫ
	LDA CURX
	STA BASEX ;КООРД X БАЗЫ
	POP PSW
	RET
FILLBEARPOINT:
;ЗАПОЛНЕНИЕ ТОЧЕК ПОЯВЛЕНИЯ ТАНКОВ
	LOCAL FBP1
	PUSH PSW
	LXI H,NUMOFBP
	MOV A,M
	CPI MAXBP ;ДОСТИГЛИ  МАКСИМУМА?
	JZ FBP1   ;ДА - ПРОПУСКАЕМ  ТОЧКУ 
	INR M
	LXI H,BPXY ;УКАЗ.НА МАССИВ ТОЧЕК
	ADD A
	ADDHL
	LDA CURX
	MOV M,A
	INX H
	LDA CURY
	MOV M,A
FBP1:	POP PSW
	RET
FILLTURRETPOINT:
;ЗАПОЛНИМ ИНФО О ПУШКЕ, ЧТОБЫ ОНА СТРЕЛЯЛА
	LOCAL FTP1,FTP3
	PUSH PSW
	LXI H,NUMOFTP
	MOV A,M
	CPI MAXTP ;ДОСТИГЛИ МАКИМАЛЬНОГО ЗНАЧЕНИЯ?
	JZ FTP3   ;ДА-ПРОПУСКАЕМ ЭТУ ПУШКУ
	INR M
	LXI H,TPXY
	ADD A
	ADD A
	ADDHL
	LDA CURX
	MOV M,A
	INX H
	LDA CURY
	MOV M,A
	INX H
	POP PSW
	PUSH PSW ;ВОССТ. КОД ПУШКИ
	SUI 144
	JC FTP1
	RAR
	RAR ;/4
	MVI M,12 ; TP.HP = 12
	INX H
	ORI 80H
	MOV M,A ; TP.DIR = <A>
	JMP FTP3
FTP1:	ADI 16
	ORA A
	RAR
	RAR
	MVI M,9  ; TP.TYPE = TURRET
	INX H
	MOV M,A
FTP3:	POP PSW
	RET  ;

SETMAN:
; УСТАНОВКА  ЧЕЛОВЕКА В УРОВНЕ
; МОЖЕТ ПРИМЕНЯТЬСЯ ВО ВРЕМЯ ИГРЫ, НАПРИМЕР, КОГДА
; ЧЕЛОВЕК ВЫПРЫГИВАЕТ ИЗ ГОРЯЩЕГО ТАНКА ИЛИ БМП
;ВХОД - DE:AДРЕС MAP (НЕ МАР1!),CURX,CURY-КООРДИНАТЫ
;		ЧЕЛОВЕКА В УРОВНЕ
	PUSH B
	PUSH D
	CALL FINDFREEOBJ ;ИЩЕМ СВОБОДНЫЙ ОБ_ЕКТ
	POP D
	POP B
	RC ;НЕТ СВОБОДНОГО, ЕСЛИ CY=1
STM1:	PUSH H ;УКАЗ.НА ОBJ[X]
	LXI H,MAXMEN
	INR M ;ЧИСЛО ЛЮДЕЙ УВЕЛИЧИМ
	MVI A,MAN1 ;КОД ЧЕЛОВЕКА
	LXI H,2000H ;ПЕРЕЙДЕМ
	DAD D	    ;NA MAP1
	MOV M,A
	POP H
STMPL1:	;СЮДА ПЕРЕХОД ДЛЯ ЗАПОЛНЕНИЯ ЧЕЛОВЕКА ИГРОКОВ
	MVI M,1 ;CONDITION =NORMAL
	INX H
	MOV M,A  ;КОД ЧЕЛОВЕКА
	INX H
	LDA CURX
	MOV M,A
	INX H
	INX H
	MOV M,A
	DCX H
	LDA CURY ;КООРД Y
	MOV M,A
	INX H
	INX H
	MOV M,A
	INX H
	MVI M,8  ; OBJ.DIR НАПРАВЛЕНИЕ
	INX H
	MVI M,0  ;OBJ.XSHIFT =0
	INX H
	MVI M,0  ;OBJ.DSHIFT =0
	INX H
	MVI M,1  ;OBJ.TYPE = MAN
	INX H
	MVI M,1  ;OBJ.WTYPE = BULLET
	INX H
	MVI M,2  ;OBJ.SHTM =2  (СКОРОСТРЕЛЬНОСТЬ)
	INX H
	MVI M,0  ;OBJ.CHS =0   (СОСТОЯНИЕ СТРЕЛЬБЫ)
	INX H
	MVI M,1  ;OBJ.SPEED =1
	RET  ; ВСЕ {SETMAN}

; ВЫВОД УРОВНЯ НА ЭКРАН 
PUTLEVEL:
	LOCAL PUTL2,PUTL3
	DI
;
	LDA LEVY ;ТЕКУЩИЙ Y
	MVI C,0  ; X = 0
	CALL GETMAPXY ;В DE - ADDRES MAP
	MVI L,4
PUTL2:	MVI H,0
PUTL3:	MVI A,QBANK ;QBANK = 20H
	OUT 10H
	LDAX D
	MOV B,A ;КОД УРОВНЯ
	XRA A
	OUT 10H
	CALL PUTSCHAR
	INR H
	INX D
	MOV A,H
	CPI 20H
	JC PUTL3
	INR L
	MOV A,L
	CPI 20H
	JC PUTL2
	EI
	RET ;ВCE {PUTLEVEL}??

	ENDM
;КОНЕЦ МАКАРА LEVEL


OBJECT	MACRO
PUTSCHAR:
;ВЫВОД ЦВЕТНОГО ОБ_ЕКТА 8х8 ТОЧЕК
;В ТРЕХ ПЛОСКОСТЯХ
;ВХОД - HL - CURSOR(0..1FH BOTH)
;	B  - КОД ВЫВОДИМОГО СИМВОЛА
	PUSHA 1
	XCHG
	MOV L,B
	MVI H,0
	PUSH H
	LXI B,TABLCOLSYM ;ТАБЛИЦА ЦВЕТОВ СИМВОЛОВ
	DAD B
	MOV A,M
	STA COLSYM ;ЦВЕТ СИМВОЛА (0-7)
	POP H
	DAD H
	DAD H
	DAD H ;HL*8
	LXI B,TABL2SYM ; ТАБЛИЦА ОБ_ЕКТОВ
	DAD B
	XCHG  ;В DE - АДРЕС КОДОВ СИМВОЛА
	MVI A,0E0H
	ORA H
	MOV H,A  ;HI BYTE OF VRAM
	MOV A,L
	ADD A
	ADD A
	ADD A
	CMA
	MOV L,A ; LOW BYTE OF VRAM
	CALL PUTSO0
	CALL PUTSO0
	CALL PUTSO0
	POPA 1
	RET
PUTSO0:
;ВЫВОД СИМВОЛА В ОДНОЙ ПЛОСКОСТИ
	MVI A,-20H
	ADD H
	MOV H,A ;ПЕРЕХОДИМ К СЛЕД.ПЛОСК.
	LDA COLSYM  ;ЦВЕТ
	RRC
	STA COLSYM
	JNC PUTSO1 ;СТИРАЕМ С ПЛОСК.
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
PUSO1:
;		СТИРАНИЕ ОБ_ЕКТА 8х8
	PUSH H
	XRA A
	MOV M,A
	REPT 7
	DCR L
	MOV M,A
	ENDM
	POP H
	RET



FINDFREEOBJ:
;ИЩЕМ СВОБОДНЫЙ ОБ_ЕКТ
;ВЫХОД: CY=0,HL-ADDRESS OF FRST  FREE OBJ
;	CY=1 - ОБ_ЕКТ НЕ НАЙДЕН, К СОЖАЛЕНИЮ

	LXI H,FIRSTOBJ+20H
	LXI D,10H ;РАЗМЕР ОБ_ЕКТА
	MVI C,MAXOBJ-2 ;ЧИСЛО ОБ_ЕКТОВ
	MOV A,M  ;БЕРЕМ CONDITION OF OBJECT
	ORA A
	RZ  ;ОБ_ЕКТ НАЙДЕН
	DAD  D
	DCR C
	JNZ $-5
	STC ;ОБ_ЕКТ НЕ НАЙДЕН
	RET
CLEAROBJ:
;ОЧИСТКА  ВСЕХ  ОБ_ЕКТОВ
;(КРОМЕ  ПРИНАДЛЕЖАЩИХ ИГРОКАМ)
	LXI H,FIRSTOBJ+20H
	LXI B,MAXOBJ*10H-20H ;СЧЕТЧИК
	XRA A
	LOCAL CLRO1
CLRO1:
	MOV M,A
	INX H
	LOOP CLRO1 ;ЭТОТ МАКАР ИЗ MATH.LIB
	
	RET
COUNTOBJ:
;ПОДСЧЕТ ЗАНЯТЫХ ОБ_ЕКТОВ В ИГРЕ
;ВЫХОД: <A>-ЧИСЛО ОБ_ЕКТОВ
	LXI H,FIRSTOBJ+20H
	LXI D,10H ;SIZE OF OBJ
	LXI B,MAXOBJ-2
COB0:	XRA A
	ORA M
	JZ $+4
	INR B ;ОБ_ЕКТ ЕСТЬ!
	DAD D
	DCR  C
	JNZ COB0
	MOV A,B
	RET
GETMAPXY:
;ПОЛУЧИТЬ АДРЕС MAP ПО ЗАДАННЫМ КООРДИНАТАМ
;	ВХОД: <A> - Y, <C> - X
;	ВЫХОД: DE - MAP[X,Y]
	PUSH H
	PUSH B
	MVI H,0
	MOV B,H ;B = 0
	MOV L,A ;HL=Y
	REPT 5
	DAD H ;HL=HL*20H
	ENDM
	DAD B ;HL=HL+X
	LXI D,MAP
	DAD D
	XCHG ;В DE-АДРЕС  МAP
	POP B
	POP H
	RET
PUTOBJ:
;ВЫВОД ОБ_ЕКТА НА ЭКРАН В  3-Ь ПЛОЦКОСТЯХ
;	ВХОД: <B>-КОД ОБ_ЕКТА(ЛЕВЫЙ ВЕРЬНИЙ УГОЛ)
;		HL - КУРСОР(0..31) XY СООТВЕТСТВЕННО
	PUSHA
	MVI A,0C0H ;СТ.АДРЕС НАЧАЛА 2-ОЙ ПЛОСК.
	STA WHPL
	MOV A,B  ;В <А> - КOД СИМВОЛА
	LXI D,TABLCOLSYM ;АДРЕС ТАБЛ.ЦВЕТОВ ОБ_ЕКТОВ
	ADD E
	MOV E,A
	LDAX D ;ЦВЕТ СИМВОЛОВ
PUTO1:	RAR
	MOV C,A	
	CC PUT16x16 ;ВЫВОДИМ ВО 2-ОЙ  ПЛОСК.
	MVI A,0A0H ;СТ.БАЙТ АДРЕСА
	STA WHPL   ;НАЧАЛА 3-ЕЙ  ПЛОСК.
	ROR C
	CC PUT16x16
	MVI A,80H ;СТ.БАЙТ АДРЕСА
	STA  WHPL ;НАЧАЛА 4-ОЙ ПЛОСК.
	ROR C
	CC PUT16x16
	POPA
	RET  ;ВСЕ? {PUTOBJ}

; УДАЛЕНИЕ СТАТИЧЕСКИХ ОБ'ЕКТОВ С ЭКРАНА
DELSTOBJ:
	LXI H, NUOFDSP ;ЧИСЛО СТАТИЧЕСКИХ ОБ'ЕКТОВ
	MOV A,M
	DCR A
	RM
	DCR M
	ADD A
	LXI H,DSPXY ;КООРД.СТАТИЧЕКИХ ОБ'КТОВ
;		ПОДЛЕЖАЩИХ УДАЛЕНИЮ С ЭКРАНА
	ADDHL
	MOV D,M
	INX H
	LDA LEVY
	MOV E,A
	MOV A,M ; Y
	SUB E
	ADI 4
	MOV E,A ; ЭКРАННЫЙ Y
	XCHG
	MVI B,255 ; КОД = SPACE
	CPI 4
	JC DELSTOBJ ; НЕ ВХОДИТ В ЭКРАН (ВИДИМУЮ ЧАСТЬ)
	CPI 20H
	CC PUTSCHAR ; СТИРАЕМ ОБ'ЕКТ
	JMP DELSTOBJ	

; ВЫВОДИМ СТАТИЧЕСКИЕ ОБ'ЕКТЫ
PUTSTOBJ:
	LXI H,NUMOFSTO
	MOV A,M
	DCR A
	RM
	DCR M ; УМЕНЬШИМ ЧИСЛО СТАТ.Б'ЕКОВ
	ADD A
	ADD A
	LXI H,STOBJXY
	ADDHL
	MOV D,M
	INX H
	LDA LEVY
	MOV E,A
	MOV A,M
	SUB E
	ADI 4
	MOV E,A ; E - ЭКРАННЫЙ Y
	INX H
	MOV B,M  ; КОД ВЫВОДИМОГО ОБ'ЕКТА 8х8
	XCHG ; HL = DE = CURSOR
	CPI 4
	JC PUTSTOBJ ; НЕ ВХОДИТ В ЭКРАН - СЛЕД.ОБ.
	CPI 20H
	CC PUTSCHAR ; ВЫВОДИМ СИМВОЛ
	JMP PUTSTOBJ ;ПЕРЕХОДИМ К СЛЕД. ОБ'ЕКТУ

PUTALLOBJ:
;ВЫВОД ВСЕХ ДВИЖУЩИХСЯ ОБ_ЕКТОВ 
;В УРОВНЕ
	MVI A,0C9H
	STA 38H  ;ЖДЕМ ОЮРАТНОГО
	HLT	;ХОДА  ЛУЧА
	DI
	MVI A,MAXOBJ
	LXI H,FIRSTOBJ
PALO1:	PUSH PSW
	PUSH H
	MOV A,M ;СОСТОЯНИЕ
	ORA A
	JZ PALO4 ;ПУСТ - СЛЕД.ОБ_ЕКТ
	JM PALO5 ;МЕРТВ-СТИРАЕМ ОБ_ЕКТ
PALO0:	INX H
	MOV A,M  ; OBJ.VID
	PUSH PSW
	MOV B,A
	LXI D,TABLCOLSYM ;ТАБЛИА ЦВЕТОВ
	ADD E
	MOV E,A
	LDAX D
	DCR A
	MVI A,0C0H ; 2-AЯ ПЛОСК.
	JZ $+5
	MVI A,0A0H ; 3-ЬЯ ПЛОСК.
	STA WHPL
	INX H
	MOV D,M ; OBJ.OLDX
	INX H
	LDA LEVY
	MOV C,A
	MOV A,M
	SUB C
	ADI 4
	MOV E,A  ; <E> = OBJ.OLDY - LEVY + 4
	INX H
	PUSH H  ;СОХР.УКАЗ. НА OBJ.CURX
	MOV  A,B ;ВЕРНЕМ OBJ.VID
PALO:	LXI B,PALO2
	PUSH B   ;АДРЕС ПО !RET
	CPI MAN1
	JNC PALO10 ;ЭТ ОБ_ЕКТ 8х8 ТОЧЕК
	MOV A,E ;КООРД.Y
	XCHG  ; HL = DE
	CPI  3
	JZ DEL16x16D
	RC
	CPI 1FH
	JZ DEL16x16U ;УДАЛИМ ВЕРХ ОБ_ЕКТА
	JC DEL16x16 ;ЕСЛИ ОБ_ЕКТ ПОНЛОСТЬЮ ВЛАЗАЕТ В ЭКРАН,
		; ТО УДАЛЯЕМ ЕГО ПОЛНОСТЬЮ
	RET ; ИНАЧЕ - JMP PALO2
PALO10:	MOV A,E
	CPI 4
	RC
	CPI 20H
	RNC ;ОБ_ЕКТ  8х8 НЕ В ЭКРАНЕ
	MVI A,4
	ADD L
	MOV L,A
	MOV A,M
	RRC
	RRC
	RRC
	RRC
	ANI 15
	MOV C,A ; OBJ.DSHIFT(OLD)
	DCX H
	MVI A,0F0H  ; OBJ.XSHIFT(OLD)
	ANA M  ; = 0?
	XCHG
	JZ DEL8x8 ; ДА - УДАЛЯЕМ СО СДВИГОМ
	JMP DEL8x8X ;УДАЛЕНИЕ СО СДВИГОМ

PALO2:	POP H
	MOV D,M
	INX H
	LDA LEVY
	MOV  C,A
	MOV A,M
	SUB C
	ADI 4
	MOV E,A ;СМ. КОММЕНТАРИЙ ВВЕРХУ
	POP PSW ;  OBJ.VID
	LXI B,PALO4
	PUSH B
	MOV B,A ;ВИД ОБ.В <B>
	CPI MAN1
	JNC PALO3 ;ВЫВОДИМ ОБ_ЕКТ 8х8!
	XCHG
	MOV A,L
	CPI 3
	JZ PUT16x16D ; НИЖНЮЮ ЧАСТЬ
	CPI 1FH
	JZ PUT16x16U;ВЕРХ.ОБ_ЕКТА
	JC PUT16x16 ;ВЕСЬ ОБ_ЕКТ
	RET ; JMP PALO4
PALO3:	MOV A,E  ; <A> = Y
	CPI 4
	RC
	CPI 20H
	RNC ;ОБ_ЕКТ НЕ ВМЕЩАЕТСЯ В ЭКРАН
	INX H
	INX H
	INX H
	MOV C,M ; OBJ.DSHIFT
	DCX H
	XRA A
	ORA M  ; OBJ.XSHIFT
	XCHG
	JZ PUT8x8 ; ВЕСЬ ОBJ
	JMP PUT8x8X ; СО СДВИГОМ В 4 TOЧКИ
PALO4:
;ПЕРЕХОДИМ К СЛЕД. ОБ_ЕКТУ
	POP H
	LXI D,10H
	DAD D
	POP PSW
	DCR A  ;ДЕКРМЕНТИРУЕМ СЧЕТСЧИК ОБ_ЕКТОВ В  ИГРЕ
	JNZ PALO1
	MVI A,0C3H  ;КОД  !JMP
	STA 38H
	EI
	RET  ;ИЛИ RETI
PALO5:	;УДАЛЯЕМ МЕРТВЫЙ ОБ__ЕКТ
	INR M ;CONDITION=0
	PUSH H
	LXI H,PALO6 ;ПЕРЕУСТАНОВИМ АДРЕС
	SHLD PALO+1 ;ВОЗВРАТА  ПО !RET
	POP H
	JMP PALO0
PALO6:	POP H
	POP H ;ЧИСТИМ  СТЕК ОТ КОДА И АДРЕСА OBJ.CURX
	LXI H,PALO2 ;ВЕРНЕМ ОРИГИНАЛЬНЫЙ  АДРЕС
	SHLD PALO+1 ;ВОЗВРАТА ПО !RET
	JMP PALO4 ;СЛЕД.ОБ_ЕКТ
;ВСЕ??{PUTALLOBJ}

GETADOBJ:
;ПОЛУЧИТЬ АДРЕС ОБ_ЕКТА ПО НОМЕРУ В <А>
;ВХОД:	A(0..MAXOBJ-1)-НОМЕР ОБ_ЕКТА
;ВЫХОД:	HL - АДРЕС ОБ_ЕКТА
	LXI H,FIRSTOBJ
	LXI D,10H ;SIZEOFOBJ
	DCR A
	RM
	DAD D
	JMP $-3
FINDOBJ:
;НАЙТИ НОМЕР И АДРЕС ОБЖ ПО ЕГО КООРДИНАТАМ
;ВХОД:	BC- X,Y COORDS OF OBJ
;ВЫХОД:	A - NUMBER OF OBJ, HL - ADDRESS OF OBJ
	LOCAL FOB1,FOB5
	XRA A
	LXI H,FIRSTOBJ+4 ; НА OBJ.CURX
	LXI D,10H ;SIZEOFOBJ
FOB1:	PUSH PSW
	MOV A,M  ;A=CURX
	CMP B    ;=X?
	JNZ FOB5 ;NO- NEXTOBJ
	INX H
	MOV A,M  ;A=CURY
	CMP C    ;=Y?
	DCX H
	JNZ FOB5 ;NO - NEXT OBJ
	POP PSW  ;CURRENT NUMBER
	DCX H
	DCX H
	DCX H  ;HL НА НАЧАЛО ОБ_ЕКТА
	DCX H
	ORA A  ; CLC
	RET
FOB5:	DAD D  ;NEXTOBJ
	POP PSW
	INR A       ;УВЕЛИЧ.СЧЕТЧИК ОБ_ЕКТОВ
	CPI MAXOBJ ;ДОСТИГЛИ КОНЕЧНОГО?
	JC FOB1
	STC   ; CY = 1
	RET   ;NOT FOUND
;КОНЕЦ МАКАРА OBJECT
	ENDM


MAP	MACRO
;ОБСЛУЖИВНИЕ КАРТЫ MAP,MAP1
PUTINMAP1:
;ПОМЕСТИТЬ ОБ_ЕКТ 16х16 В MAP1
;ВХОД: DE - ADDRESS OF _MAP_, A-VID OF OBJECT
	PUSH H
	PUSH D
	LXI H,2000H
	DAD D
	MOV M,A
	INX H
	INR A
	MOV M,A
	INR A
	LXI D,31
	DAD D
	MOV M,A
	INX H
	INR A
	MOV M,A
	POP D
	POP H
	RET
DELFRMAP1:
;	УДАЛЕНИЕ ОБ.16х16 ИЗ  MAP1
;ВХОД:	DE - АДРЕС _MAP_
	PUSH H
	PUSH D
	LXI H,2000H
	DAD D
	MVI M,255
	INX H
	MVI M,255
	LXI D,31  ; MaxX - 1
	DAD D
	MVI M,255
	INX H
	MVI M,255
	POP D
	POP H
	RET
PUT8INMAP1:
;ПОМЕСТИТЬ ОБ_ЕКТ 8х8 В КАРТУ 1
;ВХОД:	DE - ADDR.OF _MAP_, BC-XSHIFT,DSHIFT RESP.
;	A - CODE OF THE OBJECT
	PUSH H
	PUSH D
	LXI H,2000H
	DAD D
	MOV M,A
	MOV D,A
	XRA A
	ORA B ;XSHIFT = 0?
	INX H
	JZ $+4
	MOV M,D ; MAP(X+1,Y)=A
	MOV A,D
	LXI D,31
	DAD D  ;СПУСТИМСЯ НА СТРОКУ
	MOV D,A
	XRA A
	CMP C ;DSHIFT =0?
	LOCAL PUT8IN0
	JZ PUT8IN0 ; ДА - ВЫХОДИМ
	MOV M,D
	INX H
	CMP B  ; XSHIFT = 0?
	JZ $+4
	MOV M,D ;MAP1(X+1,Y+1)=CODE
PUT8IN0:
	POP D
	POP H
	RET
DEL8FRMAP1:
;	УДАЛЯЕМ ОБ.8х8 ИЗ MAP1
; ВХОД:	DE-ADR.OF _MAP_, BC - XSHIFT,DSHIFT
	PUSH H
	PUSH D
	LXI H,2000H
	DAD D
	MVI M,255
	INX H
	XRA A
	CMP B
	JZ $+5
	MVI M,255
	LXI D,31
	DAD D
	CMP C
	JZ PUT8IN0
	MVI M,255
	INX H
	CMP B
	JZ $+5
	MVI M,255
	POP D
	POP H
	RET
MOVEMAP1MAP:
;	ПЕРЕПИСЬ КОДОВ ОБ.16х16
;	ИЗ МАР1 В МАР
; ВХОД:	DE - ADDR.OF MAP
	PUSH D
	PUSH H
	LXI H,2000H
	DAD D   ;[HL] TO MAP1
	MOV A,M ;CODE FROM MAP1
	STAX D  ;INTO  MAP!
	INX H
	INX D
	MOV A,M ;ONCE MORE
	STAX D  ;TIME
	MVI A,31  ;СПУСТИМСЯ НА СТРОКУ
	ADDHL     ; В МАР1
	MVI A,31  ;И
	ADDDE     ;В МАР
	MOV A,M
	STAX D
	INX H
	INX D
	MOV A,M  ; ПОСЛЕДНИЙ (4-ЫЙ) КОД
	STAX D   ;ИЗ MAP1 В MAP
	POP H
	POP D
	RET ;ВСЕ??
PUTINMAP:
;ПОМЕСТИТЬ ОБ.16х16 В МАР
;ВХОД:	DE- ADDR.MAP, A-VID
	PUSH H
	PUSH D
	STAX D
	INX D
	INR A
	STAX D
	INR A
	LXI H,31
	DAD D  ;НА СТРОКУ НИЖЕ
	MOV M,A
	INR A
	INX H
	MOV M,A ; 4CODE= A+3
	POP D
	POP H
	RET
DELFRMAP:
;УДАЯЕМ ИЗ  МАР ОБ., ВХОД:	DE-ADDR.OF MAP
	PUSH H
	PUSH D
	MVI A,255 ;КОД ИНИЦИАЛИЗАЦИИ КАРТ
	STAX D
	INX D
	STAX D
	LXI H,31
	DAD D ;НА СТРОКУ НИЖЕ
	MOV M,A
	INX H
	MOV M,A
	POP D
	POP H
	RET
;ПОКА КОНЕЦ МАКАРА  __MAP__
	ENDM
