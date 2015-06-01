;/////////// G - T A N K \\\\\\\\\\\\\\\\\
; БИБЛИОТЕКА SCREEN.LIB
; ВКЛЮЧАЕТ МAКАР - __SCREEN__
; ВСЕ ОТНСЯЩИЕСЯ К ЭКРАНУ САБЫ:
;	PUTGDW - ОЧИСТКА/ИНИЦ.ПОЛЯ ВВЕРХУ
;	PUT2ARMOR - ВЫВОД КОЛ-ВА ЖИЗНЕЙ И БРОНИ
;	MENU   - ВЫВОД И ОРГАНЗАЦИЯ МЕНЮ
;	PUTSTAT - ВЫВОД СТАТИСТИКИ УРОВНЯ 
;		(СКОЛЬКО ВРАГОВ ОСТАЛОСЬ, НОМЕР УРОВНЯ)
;	BOARD  - НАЧАЛЬНАЯ ЗАСТАВКА

SCREEN	MACRO
PUTGDW:
	LXI H,0
	MVI C,3
	MVI B,255
PUTGD0:	CALL PUTSCHAR ;ВЫВОД ПРОБЕЛА
	INR H
	MVI A,1FH
	ANA H
	JNZ PUTGD0
	MOV H,A ; H=0
	INR L
	DCR C
	JNZ PUTGD0
	LDA YDEMO
	ORA A  ; ЕСЛИ НАЧАЛАСЬ ДЕМОНСТРАЦИЯ
	RNZ    ; ТО ВСЕ
	CALL OUTINFO
	DB 7,3,6,3,1,0,10H,STOLB  ; РАЗДЕЛИТЕЛЬ ЗОН
	DB 6,1,1,0,16H,7,13H,'*1 игрок*'
	DB 1,1,11H,7,1,'БРОНЯ',0
	LDA FIRSTOBJ+15H ; PL2.URY
	CPI 255
	JZ PUTGD5
	CALL OUTINFO
	DB 1,0,1,7,13H,'*2 игрок*'
	DB 1,1,0AH,7,1,'БРОНЯ',0
PUTGDE:	RET
PUTGD5:	;КОГДА НЕТ ВТОРОГО ИГРОКА
	;НА МЕСТЕ ЕГО ЗОНЫ ВЫВОДИМ ТОЧКИ
	MVI C,3
	LXI H,0
	MVI A,4
	CALL CHARCOLOR
	RND
PUTGD6:	RRC
	MOV E,A
	ANI 3
	ADI POINTS0
	CALL PUTUCHAR ;ВЫВODИМ  ТОЧКИ
	INR H
	MOV A,H
	CPI 10H
	MOV A,E
	JC PUTGD6
	MVI H,0
	INR L
	INR A
	DCR C  ; ЧИСЛО СТРОК -3
	JNZ PUTGD6
	RET

PUT2ARMOR:
	LDA YDEMO
	ORA A
	JNZ PUTDEMON  ;	ДЕМОНСТР.НАДПИСИ
	LDA FISTOB;+10H
	ORA A
	JZ PUTA3
	DCR A
	JZ PUT2LIV ; ВЫВОДИМ ЖИЗНИ
	MOV E,A ;EXTRA REG
	LDA FIRSTOBJ+1FH ;PL2.TIMEROBJ
	STA PUT2T1
	STA PUT2T2
	DCR E
	JZ PUT2INV ;НЕУЯЗВИМ
	CALL OUTINFO
	DB 7,4,1,1,0
	DB 'ЗАМОРОЖЕН',7,7,1,2,5,4
PUT2T1:	DB 0,0
	JMP PUTA5 ;ПРОДОЛЖИМ ДЛЯ 1-ГО
PUT2INV:
	CALL OUTINFO
	DB 7,4,1,1,0,'НЕУЯЗВИМ '
	DB 7,7,1,2,5,4
PUT2T2:	DB 0,0
	JMP PUTA5
PUT2LIV:
	LDA PL2LIV ; ЧИСЛО ЖИЗНЕЙ 2-ГО ИГРОКА
	STA PUT2T3
	CALL OUINFO
	DB 7,4,1,1,0
	DB ' ЖИЗНЕЙ  ',1,2,5,4
PUT2T3:	DB 0,0
PUTA5:	; ВЫВОДИМ БРОНЮ 2-ГО ИГРОКА  ПЕРЕХОДИМ К ПЕРВОМУ
	LXI H,0A02H
	LDA FIRSTOBJ+18H ; PL2.HP
	MVI C,10H  ; КОНЕЧ.СТОЛБЕЦ
	CALL PUTARMOR ; ВЫВОДИМ БРОНЮ ТАНКА
	JMP PUTA6 ;ОБСЛУЖИВАЕМ НАКОНЕЦ 1-ГО
PUTA3:	LDA FIRSTOBJ+15H
	CPI 255
	JZ PUTA4 ; НЕТ 2-ГО
	LDA PL2LIV
	ORA A
	JNZ PUT2LIV ; ВЫВОДИМ ЖИЗНИ
; ИНАЧЕ ВЫВОДИМ НАДПИСЬ ИГРА КОНЧЕНА
	CALL OUTINFO
	DB 6,2,7,7,1,1,0,'ИГРА ОКОНЧЕНА ',6,1,0
; ТЕПЕРЬ ТОЖЕ ПОЧТИ О ПЕРВОМ ИГРОКЕ
PUTA6:	LDA FIRSTOBJ
	ORA A
	JZ PUTA7 ; НЕТ ПОКА ЕГО?
	DCR A
	JZ PUT1LIV ;ЖИЗНИ
	MOV E,A
	LDA FIRSTOBJ+15
	STA PUT1T1
	STA PUT1T2
	DCR E
	JZ PUT1INV ; НЕУЯЗВИМ
; ИНАЧЕ - ЗАМОРОЖЕН
	CALL OUTINFO
	DB 7,4,1,1,17H,'ЗАМОРОЖЕН'
	DB 1,2,1CH,7,7,4
PUT1T1:	DB 0,0
	JMP PUTA8 ; ВЫВОДИМ БРОНЮ 1-ГО
PUT1INV:
	CALL OUTINFO
	DB 7,4,1,1,17H,' НЕУЯЗВИМ',1,2,1CH,7,7,4
PUT1T2:	DB 0,0
	JMP PUTA8
PUT1LIV:
	LDA PL1LIV  ; ЧИСЛО ЖИЗНЕЙ 1-ГО
	STA PUT1T3
	CALL OUINFO
	DB 7,4,1,1,17H,'  ЖИЗНЕЙ ',1,2,1CH,7,7,4
PUT1T3:	DB 0,0
PUTA8:	; ВЫВОДИМ КЛ-ВО БРОНИ 1-ГО ИГРОКА
	LXI H,1102H
	LDA FIRSTOBJ+8 ;PL1.HP
	MVI C,17H
PUTARMOR:
; НЕ ПУТАТЬ АДРЕС С PUT2ARMOR
	MOV B,A ;БРОНИ
	ANI 3
	MOV E,A ; Xr
	MOV A,B
	RAR
	ORA A
	RAR
	CPI 7
	JC $+5
	MVI A,6 ; NUM - ЧИСЛО ЦЕЛЬНЫХ ПОЛОСОК БРОНИ
	MOV B,A
	MVI A,7
	CALL CHARCOLOR ;УСТАНОВИМ, ПОЖАЛУЙ, ЦВЕТ
	XRA A
	CMP B
	JZ PUTARX ; НЕТ ЦЕЛЫХ ПОЛОСОК
	MVI A,ARM4 ;КОД СИМВОЛА 4 ПОЛОСКИ
	CALL PUTUCHAR
	INR H
	DCR B
	JNZ $-5
PUTARX:	DCR H
	MOV A,E ; Xr- ОСТАТОК БРОНИ?
	DCR H
	ORA A
	JZ PUTARX1
	INR H
	ADI ARM1-1 ; КОД СИМВОЛОВ ОСТАТКА БРОНИ
	CALL PUTUCHAR
	MVI B,255 ; CODE = EMPTY
PUTARX1:
	INR H
	MOV A,H
	CMP C
	RNC ; ДОСТИГЛ КОНЕЧНОЙ КОЛОНКИ - ВЫХОДИМ
	CALL PUTSCHAR ; ЗАТИРАЕМ ПОЛЕ
	JMP PUTARX1
PUTA7:	LDA PL1LIV ; ЖИЗНИ 1-ГО
	ORA A
	JNZ PL1LIV ; НЕ 0 - ВЫВОДИМ ИХ ЧИСЛО
	CALL OUTINFO
	DB 6,2,7,7,1,1,11H
	DB ' ИГРА ОКОНЧЕНА ',6,1,0
	RET ; ВЫХODИМ ИЗ PUT2ARMOR
PUTA4:	;ВЫВОДИМ ТОЧКИ НА МЕСТЕ 2-ГО
	MVI C,6 ;ЧИСЛО МОЖНО МЕНЯТЬ (КАК СКОРОСТЬ И КРАСОТА)
; ЭТО БЫЛО ЧИСЛО ТОЧЕК*8
	RND
	ANI 15
	MOV H,A ; X = [0..15]
	ANI 3
	SUI 1
	ACI 0
	MOV L,A ; Y = [0..2]
	RND
	ANI 3
	ADI POINTS0 ;КОД СИМВОЛА ТОЧЕК
	CALL PUTUCHAR
	DCR C
	JNZ PUTA4+2
	JMP PUTA6 ; ПЕРЕЙДЕМ К 1-ОМУ

; ПОКАЗ НАДПИСЕЙ - АВТОРА, ГОРОДА
PUTDEMON:
	LDA NUMDEMON
	ADD A
	LXI H,ADDEM ;АДРЕCА ДЕМО
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	XCHG
	PCHL
ADDEM:	DW PUTD0,PUTD1,PUTD2,PUTD3,PUTD4,PUTD5
	DW PUTD7,PUTGDW ; ПОСЛЕДНЯЯ - ОЧИСТКА ПОЛЯ
PUTD0:	CALL OUTINFO
	DB 6,3,7,7,1,0,0,'-gDw-',6,1,0
	RET
PUTD1:	CALL OUTINFO
	DB 7,3,1,0,0BH,'ИДЕЯ: ',0
PUTD10:	CALL OUTINFO
	DB 7,4,'Плешаков А.В.',0 ;  Я СКРОМЕН, Г-ДА?
	RET
PUTD2:	CALL OUTNFO
	DB 7,3,1,1,8,'КОД i-80: ',0
	JMP PUTD10
PUTD3:	CALL OUTINFO
	DB 7,3,1,2,8,'ГРАФИКА: ',0
	JMP PUTD10 ;ВЫВОД ПЛЕШАКОВА
PUTD4:	CALL OUTINFO
	DB 7,3,1,0,9,'ПОМОЩЬ: ',7,4,'Белянин В.Г.',0
	RET
PUTD5:	CALL OUTINFO
	DB 7,1,1,1,8,6,2
	DB 'Волгоград-2000 янв-апр',6,1,0
PUTD7:	RET
; НА PUTD7 ПОКА НИЧЕГО НЕ CТОИТ


;  ВЫВОД ТЕКУЩЕЙ СТАТИСТИКИ УРОВНЯ
PUTSTAT:
	LDA YDEMO
	ORA A
	RNZ ;ВО ВРЕМЯ ДЕМО НЕТ СТАТИСТИКИ
	LXI H,8090H
	XRA A
	CALL SETCOLOR ;УСТ. ЦВЕТ РИСОВАНИЯ
	CALL DELPIXEL ;УДАЛИМ ЦЕНТР.ТОЧКУ
	LXI D,8090H
PTS0:	DCR L
	DCR H ;X1-1,Y1-1
	INR D
	INR E
	CALL RECT
	MOV A,L
	CPI 48H
	JNC PTS0
	MVI A,7
	CALL SETCOLOR
	CALL RECT  ; ОБВОДЯЩУЮ РАМКУ ВЫВЕДЕМ БЕЛЫМ ЦВЕТОМ
	MVI A,3
	CALL SETCOLOR
	LXI H,4454H
	LXI D,44B4H
	CALL VHLINE
	LXI H,5CCCH
	CALL VHLINE
	LXID,0A4CCH
	CALL VHLINE
	LXI H,0BCB4H
	CALL VHLINE
	LXI D,0BC54H
	CALL VHLINE
	
; ЗДЕСЬ МОЖНО ВКЛЮЧИТЬ МУЗЫКУ
	LDA YSOUND
	ORA A
	JZ PTS01
; ИНАЧЕ ВКЛЮЧИМ МЕЛОДИЮ СТАТИСТИКИ
	STARTPLAY MPS1,MPS2,MPS3
PTS01:	MVI A,6
	CALL CHARCOLOR
	LXI D,LEVNAME ; ИМЯ УРОВНЯ
	LXI H,090AH
	CALL PUTSTR
	LDA CURLEV
	STA i0 ;НОМЕР ТЕК.УРОВНЯ
	CALL OUTINFO
	DB 7,4,1,19H,0CH,'ПОЛЕ: ',4
i0:	DB 0,1,0CH,9,6,2,'ЦЕЛЬ:',6,1,0
	LDA LEVGOAL ;ЦЕЛЬ МИССИИ
	ADD A
	LXI H,ADDRGOALS
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	LXI H,0E0CH
	CALL PUTSTR ; ВЫВОДИМ ЦЕЛЬ МИССИИ
	INR L
	CALL PUTSTR ; ВТОРАЯ ЧАСТЬ ЦЕЛИ
	LDA LEVGOAL
	DCR A
	JNZ PTS2
	; ВЫВЕДЕМ РИСУНОК БАЗЫ
PTS1:	LXI H,150CH
	MVI B,168 ;КОД БАЗЫ
	CALL PUTOBJ
	JMP PTS3
PTS2:	DCR A
	JZ PTS1
PTS3:	LXI H,0A0FH
	MVI B,MAN1
	MVI C,4
	MVI A,0A0H
	STA WHPL  ; ПЛОСКОСТЬ
	CALL PUT8x8X  ; ВЫВЕДЕМ ЧЕЛОВЕЧКА СО СДВИГОМ
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
	LXI H,MAXMEN ; ЧИСЛО НЕ УБИТОГО ЕЩЕ ПРОТИВНИКА
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
	DB 6,2,7,7 ; ВЫСОТА СИМВОЛОВ- 2, ЦВЕТ- БЕЛЫЙ
	DB 1,15,13,4
i1:	DB 0,1,11H,13,4
i2:	DB 0,1,13H,13,4
i3:	DB 0,1,15H,13,4
i4:	DB 0,1,15,14H,4
i5:	DB 0,1,11H,14H,4
i6:	DB 0,1,13H,14H,4
i7:	DB 0,1,15H,14H,4
i8:	DB 0,6,1,0

;  ТЕПЕРЬ ЖДЕМ СИГНАЛА ОТ ИГРОКА
PTS5:	LDA KEY1P
	ANI 0F8H
	JNZ PTS6
	LDA KEY2P
	ANI 0F8H
	JNZ PTS6
	LDA JOYPU
	ANI 0F8H
	JZ PTS5
; ИНАЧЕ ХОТЬ ЧТО-ТО НАЖАТО!!!!
	JMP PUTLEVEL ; ВЫВЕДЕМ УРОВЕНЬ И ВСЕ?
OUTINFO16:
; ВЫВОД РИСУНКОВ 1х16
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
GOAL1:	DB 'ТЕСТ',0,'УРОВНЯ',0
GOAL2:	DB 'ЗАЩИТА',0,'БАЗЫ',0
GOAL3:	DB 'АТАКА',0,'БАЗЫ',0
GOAL4:	DB 'УНИЧТОЖЕ-',0,'НИЕ ВРАГА'
MENUS1:	DB 'КОНЕЦ ИГРЫ',0
MENUS2:	DB 'ВЫХОД В ОСЬ',0
MENUS3:	DB 'ВОЗВРАТ В ИГРУ',0
MENUS4:	DB 'ВОЗВРАТ В ДЕМО',0
MENUS5:	DB 'КЛАВА 1',0
MENUS6:	DB 'КЛАВА 2',0
MENUS7:	DB 'ДЖОЙ ПУ',0
MENUS8:	DB 'ВЫКЛЮЧЕН',0
MENUS9:	DB 'ВКЛЮЧЕН',0

RUSE:	DB 0  ; КОНЕЦ НАДПИСЕЙ (2KOI8 НЕ ЗАБУДЬ ИХ ПРОГНАТЬ)
ADMENUS:
	DW MENUS5,MENUS6,MENUS7
GDEY:	DB 7,10,13,15,12H,15H,17H  ; ПОЛОЖЕНИЯ УКАЗАТЕЛЯ В МЕНЮ
MENU:	CALL TECLR ; ОЧИСТКА, ВЫВОД РАМОК
	CALL OUTINFO
	DB 7,3,6,1,1,5,15,'МЕНЮ:',6,2
	DB 7,1,1,7,9,'ИГРОКОВ:',1,10,9,'СТАРТ УРОВНЯ'
	DB 1,13,9,'ИГРОК 1:',1,15,9,'ИГРОК 2:',1,12H
	DB 9,'ЗВУК',0
	LXI H,915H
	LXI D,MENUS1
	LDA YDEMO
	ORA A
	JZ $+6
	LXI D,MENUS2
	CALL PUTSTRING
	LXI H,917H
	LXI D,MENUS3
	LDA YDEMO  ; ЕСЛИ ИДЕТ ДЕМОНСТРАЦИЯ
	ORA A
	JZ $+6
	LXI D,MENUS4  ; ИНАЧЕ ЭТА СТРОКА
	CALL PUTSTRING
; ТЕПЕРЬ ВЫВОДИМ ОПЦИИ МЕНЮ
MENU1:	MVI A,2
	CALL CHARCOLOR ; ЦВЕТ СИМОЛОВ
	LXI H,1207H
	LDA NUMOFPL
	DCR A
	MVI A,'1'
	JZ $+4
	INR A
	CALL PUTUCHAR ; ВЫBОДИМ ТЕК.ЧИСЛО ИГРОКОВ
	CALL OUTINFO
	DB 1,10,16H,4
CURLEV:	DB 1,0  ; ВЫЕЛИ ТЕКУЩИЙ УРОВЕНЬ
	LXI H,ADMENUS
	LDA PL1CTR
	ADD A
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	LXI H,110DH ; CURSOR
	CALL PUTSTRING
	LXI H,ADMENUS ; АДРЕС МЕНЮ СТРОК
	LDA PL2CTR
	ADD A
	XLAT E
	INX H
	MOV D,M
	LXI H,110FH ; CURSOR FOR 2ND STRING
	CALL PUTSTRING
	LXI H,0F12H
	LXI D,MENUS8
	LDA YSOUND
	ORA A
	JZ $+6
	LXI D,MENUS9
	CALL PUTSTRING ; ВЫВЕДЕ СОСТЯНИЕ ЗВУКА(ВЫКЛ/ВКЛ)
MENU2:	; ДИСПЕТЧЕР МЕНЮ
	LXI H,GDEY
	LDA UKAZ  ; УКАЗТЕЛЬ
	XLAT L
	MVI H,8
	MVI A,7
	CALL CHARCOLOR
	MVI A,CHEREP ; КОД СИМВОЛА-КУРСОРА
	CALL PUTUCHAR
	LXI D,0
	XCHG
	SHLD TIMER ; ТАЙМЕР ВКЛЮЧИМ
	CALL MENUKEY ; ЖДЕМ ОТВЕТА ОТ ИГРОКОВ
	PUSH PSW
	XCHG
	MVI A,' '
	CALL PUTUCHAR ;СОТРЕМ УКАЗАТЕЛЬ
	POP PSW
	LXI H,UKAZ ; УКАЗАТЕЛЬ НА УКАЗАТЕЛЬ
; СТОП! ЭТО ВАМ НЕ  С++ ? ЭТО АССЕМБЛЕР!
	CPI UP
	JNZ MENU3
	DCR M
	JP MENU2
	MVI M,6
	JMP MENU2
MENU3:	CPI DOWN
	JNZ MENU4
	INR M
	MOV A,M
	CPI 7
	JC MENU2
	MVI M,0
	JNC MENU2
MENU4:	MOV C,A
	MOV A,M ; A = UKAZ
	ADD A
	LXI H,ADMENU
	XLAT E
	IXN H
	MOV D,M
	XCHG
	PCHL
ADMENU:	DW MENU5,MENU6,MENU7,MENU8,MENU9,MENU10
	DW MENU11 ; ВОЗВРАТ В ДЕMO/ИГРУ

MENU5:	;СМЕНА ЧИСЛА ИГРОКОВ
	LDA YDEMO
	ORA A
	JZ MENU2 ; ЕСЛИ В ИГРЕ УЖЕ, ТО НЕ МЕНЯЕМ
	LXI H,NUMOFPL
	INR M
	MOV A,M
	CPI 3
	JC MENU1
	MVI M,1
	JMP MENU1
MENU6:	;НАЧАО ИГРЫ
	LDA MAXLEV
	INR A
	MOV B,A ; B = MAXLEV+1
	MOV A,C ; RESTORE KEYCODE
	CPI FIRE
	JZ STARTGAME ; НАЧНЕМ ИГРУ
	LXI H,CURLEV
	CPI LEFT
	JNZ $+5
	DCR M
	DCR M
	INR M
	MOV A,M
	ORA A
	JNZ $+5
	MVI M,5
	CMP B  ; CURLEV<=MAXLEV+1?
	JC MENU1
	DCR B
	MOV M,B  ; CURLEV = MAXLEV
	JMP MENU1
; СМЕНА УПРВЛЕНИЯ 1-ГО ИГРОКА
MENU7:	MOV A,C
	CPI FIRE
	JNZ MENU71
	LDA PL1CTR
	CPI 2
	JZ MENU2 ; ЕСЛИ ВКЛ.ДЖОЙ ПУ, ТО ВСЕ
	CALL TECLR
	XRA A
	MVI L,0BH
	CALL INITKEYS ; ПЕРЕОПРЕДЕЛИМ КЛАВИШИ
	JMP MENU
MENU71:	LXI H,PL1CTR
	CPI LEFT
	JNZ MENU72
	DCR M
	DCR M
MENU72:	INR M
; ЧИСЛО ДОЛЖНО БЫТЬ 0-2 (ЦИКЛИЧЕСКИ)
	MOV A,M
	CPI 3
	JC MENU1
	MVI M,0
	JZ MENU1
	MVI M,2
	JMP MENU1
MENU8:	LXI H,PL2CTR
	MOV A,C ;KEYCODE
	CPI FIRE
	JNZ MENU71+3
	MOV A,M
	CPI 2
	JZ MENU2
	CALL TECLR  ; ОЧИCТКА ОКНА, ВЫВОД РАМКИ
	MVI A,1
	MVI L,0BH
	CALL INITKEYS
	JMP MENU
MENU9:	LXI H,YSOUND ;ЗВУК
	MVI A,1
	XRA M
	MOV M,A
	JMP MENU1
MENU10:	MOV A,C
	CPI FIRE
	JNZ MENU2
	LDA YDEMO
	ORA A
	JZ GAMES ; НА ЗАСТАВКУ
; ИНAЧЕ ВЫХОДИМ В ОСЬ
	DI
	LHLD OLD39H
	SHLD 39H
	MVI A,23H
	OUT 10H
; ВЫВЕДЕМ ПРOЩАЛЬНУЮ НАДПИСЬ
	EI
	CALL MENU12
	DB 13,10,'THANK YOU FOR PLAYING G-TANK!',13,10
	DB 13,10,'I'LL BE GLAD TO GET YOU BACK!$'
MENU12:	POP D
	MVI C,9
	CALL 5
	RST 0
MENU11:
; ВОЗВРАТ В ДЕМО/ИГРУ
	JMP CHANGECTR ; ПОСЛЕ СМЕHЫ УПРАВЛЕНИЯ?
;
TECLR:	MVI B,255 ; CODE=EMPTY
	MVI L,5
	MVI A,21
TECLR1:	MVI H,7
	MVI C,18
	CALL PUTSCHAR
	INR H
	DCR C
	JNZ $-5
	INR L
	DCR A
	JNZ TECLR1
	LXI H,392CH
	LXI D,0CFCCH
	CALL RECT
	MVI B,MAN1 ; КОД ЧЕЛОВЕЧКА!
	MVI C,0
	LXI H,0705H
	CALL PUTSCHAR
	INR B
	LXI H,1805H
	CALL PUTSCHAR
	INR B
	LXI H,719H
	CALL PUTSCHAR
	INR B
	LXI H,1819H
	JMP PUTSCHAR ;ВЫВЕДЕМ ПОСЛЕДНЕГО И ВСЕ?
MENUKEY:
	LDA KEY1P
	ANI 0F8H
	JNZ MENUK3 ; ЕСТЬ НАЖАТИЕ!
	LDA KEY2P
	ANI 0F8H
	ANI 0F8H
	JNZ MENUK3
	LDA JOYPU
	ANI 0F8H
	JNZ MENUK3 ; ЕСТЬ СИГНАЛ ОТ ДЖОЯ!
	PUSH D
	LXI D,30*50 ; 1500
	LHLD TIMER ; ЧИСЛО АППАРАТНЫХ ПРЕРЫВАНИЙ
	CMPHD
	POP D
	JC MENUKEY
	LDA YDEMO
	ORA A
	JZ MENUKEY ; ЕСЛИ В ИГРЕ, ТО ОТМЕНА
	POP PSW    ; ЧИСТИМ СТЕК И ВЫХОДИМ ИЗ МЕНЮ
	RET
MENUK3:	LPAUSE  ; ПАУЗА В 1/10 С.
	RET
FINDLEVEL:
;	ПОИСК УРОВНЯ ПО НОМЕРУ В <А>
;	ЗАПИСЬ АДРЕСА НАЧАЛА УРОВНЯ В LEVPTR
	LXI H,FIRSTLEVEL ;АДРЕС НАЧАЛА ПЕРВОГО УРОВНЯ
FINDL1:	SHLD LEVPTR
	DCR A
	RZ
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
	DAD D ;+ AДРЕС НЧАЛА УРОВНЯ
	POP PSW
	JMP FINDL1
FILLPLSTR:
; ЗАПОЛНЕНИЕ СТРУКТУР ИГРОКОВ
;	ВХОД:	<А> - NUMOFPL (ЧИСЛО ИГРОКОВ)
	PUSH PSW
	LXI H,FIRSTOBJ
	CALL INITPLSTR
	POP PSW
	DCR A
	JZ DEL2PL ; 2-ГО ИГРОКА ВЫЧЕРКИВАЕМ
	LXI H,FIRSTOBJ+10H
	JMP INITPLSTR ; ИНИЦАЛИЗИРУЕМ СТРУКТУРУ 2-ГО ИГРОКА
DEL2PL:
	XRA A
	STA FIRSTOBJ+10H  ; PL2.COND = 0
	STA PL2LIV  ; ЖИЗНИ 2-ГО ОБНУЛИМ
	RET
INITPLSTR:
; ИНИЦИАЛИЗИРУЕМ НАЧАЛЬНУЮ СТРУКТУРУ ИГРОКА
;	ВХОД  - <HL> - АДРЕС НАЧАЛА  СТРУКТУРЫ
	MVI M,1 ;  CONDITION = NORMAL
	INX H
	XRA A
	MOV B,A
	STOSB    ; VID = T34
	REPT 4
	INX H
	ENDM
	MVI M,8  ; DIR =  NORTH+NO_MOVE
	INX H
	LDA HAMODE  ; MASTER MODE ON?
	ORA A
	MVI A,6
	JZ $+5  ; НЕТ - ПРОПУСК
	MVI A,200
	STOSB   ; ARMOR = 6/200
	STOSB   ;  HP   = ARMOR
	STOSB B   ; TYPE  = TANK
	MVI M,2   ; WTYPE = PROJECTS
	INX H
	LDA HAMODE
	ORA A
	MVI A,1
	JZ $+5
	MVI A,5
	STOSB     ; SHTM
	STOSB B   ; CSH
	MVI M,1   ; SPEED =  NORMAL (*)
	INX H
	STOSB B  ; MOTHERNUMBER=0
	STOSB B  ; TIMEROBJ = 0
	RET
STARTGAME:
;	САМОЕ НАЧАЛО ИГРЫ
;
	XRA A
	STA YDEMO
	STA PL1BON;
	STA PL2BON

	LDA NUMOFPL
	CALL FILLPLSTR ; ЗАПОЛНИМ СТРУКТУРЫ
	LDA CURLEV
	CALL FINDLEVEL ; НАЙДЕМ ТЕК.УРОВЕНЬ
	CALL CHANGECTR ; СМЕНИМ УПРАВЛЕНИЕ
	LDA HAMODE
	ORA A
	MVI A,3
	JZ $+5
	MVI A,99
	STA PL1LIV
	STA PL2LIV
	JMP GAME  ; ИГРА !!!!

ADDRCTR:
	DW KEY1P,KEY2P,JOYPU
CHANGECTR:
;	СMЕНА УПРАВЛЕНИЯ
	LDA PL1CTR ; НОМЕР УПРАВЛЕHИЯ
	ADD A
	LXI H,ADDRCTR
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	XCHG
	SHLD CTRL1P+1 ; МЕНЯЕМ УПРАВЛЕНИЕ
	LDA PL2CR
	ADD A
	LX H,ADDRCTR
	ADDHL
	MOV E,M
	INX H
	MOV D,M
	RET

BOARD:
;	НАЧАЛЬНАЯ ЗАСТАВКА
	TURBOCLS
	RND
	LXI H,4
	MVI A,1
	STA UKAZ   ; УКАЗАТЕЛЬ ТЕК.ПУНКТА МЕНЮ
	CALL CHARCOLOR
	MVI C,32
	MVI A,NIZ
	CALL PUTUCHAR
	INR H
	DCR C
	JNZ $-5
	LXI H,TABLSYM
	SHLD ACHAR16+1 ; ПЕРНАЗНАЧИМ ЕБАННЫЙ АДРЕС
	MVI A,80H
	STA WHPL ; ПЛСКОСТЬ УСТ. ДЛЯ ВЫВОДА ШАХМАТ
	MVI L,1AH
	MVI C,3
BRD1:	MVI H,0
	MVI B,16
BRD2:	MVI A,CHESS
	CALL PUT16x16
	INR H
	INR H
	DCR B
	JNZ BRD2
	INR L
	INR L
	DCR C
	JNZ BRD1
	CALL OUTINFO
	DB 6,1,1,15H,3,7,7,CPRT
	DB '2000 gDw VOLGOGRAD-2000',0
	LDA HAMODE
	ORA A
	JZ BRD0
	CALL OUTINFO
	DB 7,3,1,18H,2,'Master Mode  ON',0
	XRA A
	STA NUMMEL ; НЕТ МЕЛОДИИ
	STA GAMETIM ; НЕТ КОНЦА ИГРЫ
	LDA MAXLEV  ;
	STA CURLEV  ; CURLEV = MAXLEV
	CALL STARTDEMO ;ЗАПОЛНИМ НАЧАЛО ДЕМО
	MVI A,0A0H
	STA WHPL ; 3-Я ПЛОСК.
	XRA A
BRD3:	STA TCODE
	ADD A
	ADD A
	ADI 132
	STA BRDN4+1
	CALL BRDN ; ВЫВОД НАДПИСИ ТАНК
	RND
	CALL BRDKEY ; КЛАВИАТУРА/ТАЙМЕР
	LDA TKODE
	INR A
	ANI 7
	HLT  ; HALT!
	JMP BRD3 ; CIKLIMQ DO POSINENIQ/OB'QNENIQ/OB'EDENIQ
BRDN:	; ВЫВОДИМ НАДПИСЬ БЛОЬШУЮ ТАНК
	LXI D,TANKSTR ; УКАЗ.НА CТРУКТУРУ ТАНКА
	MVI L,8 ; НАЧ.СТРОКА
	MVI C,6  ; ЧИСЛО СТРОК
BRDN0:	MVI B,2
	MVI H,0 ; NАЧ.КОЛОНКА
BRDN1:	PUSH B
	MVI C,8
	LDAX D
BRDN2:	RLC
	MOV B,A
	MVI A,POINTS0
	JNC $+5
BRDN4:	MVI A,132
	CALL CHAR16x16 ; ВЫВОДИМ ЧТО-НИТЬ
	INR H
	INR H
	MOV A,B
	DCR C   ; ВСЕ БИТЫ ПРОВЕРИЛИ?
	JNZ BRDN2
	INX D
	POP B
	DCR B
	JNZ BRDN1
	INR L
	INR L
	DCR C
	JNZ BRDN0
	RET
; ЗАКОДИРОВАННАЯ НАДПИСЬ  "ТанК"
TANKSTR:
	DB 0F8H,9,24H,0EAH,2AH,0ACH,2AH,,0EAH
	DB 2EH,0A9H,2AH,0A9H
BRDKEY:	LXI H,KEYS
	MVI C,8
BRDK1:	MOV A,M  ; КЛАВИША...
	CPI 255
	JNZ BRDK3 ;..НАЖАТА -> BRDK3
	INX H
	DCR C
	JNZ BRDK1
	LDA JOYPU
	ANI 0F8H
	JNZ BRDK3 ; СИГНАЛ ОТ ДЖОЯ ПУ
	LXI D,62*50 ; 62 СЕКУНДЫ ЖДЕМ
	LHLD TIMER
	CMPHD
	RC
	LXI H,TABL2SYM
	SHLD ACHAR16+1 ; ВОССТАНОВИМ ОРИГ.АДРЕС ДЛЯ ВЫВОДА 
; ОБ'ЕКТОВ 16х16
	JMPGAMES ;НАЧНЕМ ДЕМО
BRDK3:	LPAUSE
	LXI H,TABL2SYM ; ТО ЖЕ
	SHLD ACHAR16+1
	POP H ; ЧИСТИМ СТЕК ОТ BRDKEY
	RET
STARTDEMO:
	MVI A,1
	STA YDEMO
	LXI H,DEMOBEG
	SHLD DEMON ; НАЧАЛА КОДОВ ДЕМО
	XRA A
	STA NUMDEMON ; ВВВОД НАДПИСЕЙ
	LXI H,0
	SHLD TIMER
	MVI A,2
	CALL FILLPLSTR ; В ДЕМО - 2 ИГРОКА
	LDA DEMLEV ; НОМЕР УРОВНЯ ДЕМО
	JMP FINDLEVEL ; НАЙДЕМ ЕГО И ВСЕ?

; ТУТ И КОНЕЦ МАКАРУ  __SCREEN__
	ENDM
