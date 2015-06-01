;//////////// G - T A N K \\\\\\\\\\\\\\\\\
;
;_______ENGINE2.LIB______________
;
;ВХОДИТ ОДИН МАКАР:  __ENGINE2__
; САБЫ:		CTRBULL (КОНТРОЛЬ ПУЛЬ)
;		BEARTANKS (РОЖДЕНИЕ ТАНКОВ)
;		SERVETURRET (ОБСЛУЖИВАНИЕ ПУШЕК)
ENGINE2	MACRO
CTRBULL:
	CALL STOREOLD
	CALL STORESHIFTS
	LDA SPEED
CTRB0:	PUSH PSW
	CALL MOVEBULL ;ПУЛЯ ВСЕГДА ДОЛЖНА ЛЕТЕТЬ
	POP PSW
	DCR A
	JNZ CTRB0
	RET
MOVEBULL:
	CALL CHECKEDGE
	JC DELBULL ;НА КРАЮ СТОИТ - УДАЛЯЕМ ПУЛЮ
	LDA DIR
	ADD A
	LXI H,INCCOORMAN ; ПРИРАЩЕНИЯ ТАКИЕ ЖЕ КАК ДЛЯ МЭНА
	ADDHL
	LDA CURX
	ADD M ;+INCX
	MOV B,A
	STA CURX
	INX H
	LDA CURY
	ADD M ;+INCY
	MOV C,A
	STA CURY
	CALL CHECKBULL
	LDA XSHIFT
	ANI 15
	JZ MOVEB1
	INR B
	CALL CHECKBULL ;ПРОВЕРИМ КАРТУ
	DCR B  ; ВЕРНЕМ X
MOVEB1:	LDA DSHIFT
	ANI 15
	JZ MOVEB5 ;НЕТ CДВИГА ВНИЗ - ПРОВЕРКА КОНЧИЛАСЬ
	INR C
	CALL CHECKBULL ;ПРОВЕРИМ КАРТУ ЕЩЕ
	LDA XSHIFT
	ANI 15
	JZ MOVEB5
	INR B
	CALL CHECKBULL
MOVEB5:	LXI H,RANGE  ;ДИСТАНЦИЯ ПЛЕТА ПУЛИ
	MOV A,M
	ORA A
	JZ DELBULL ;0-ВСЕ, УДАЛЯЕМ ПУЛЮ
	DCR M
	RET ;ВСЕ?
CHECKBULL:
;	ПРОВЕРКА КАРТЫ 0,1 ДЛЯ ПУЛИ
;	ВХОД: 	BC-КООРДИНАТЫ ПРОВЕРКИ
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY ; В <DE> - АДРЕС МАР
	POP B
	LDAX D
	CPI 252
	JNC CHB5
	CPI 128	; ТРАНСПОРТ?
	JC STOPBULL ;ОСТАНОВИТЬ ПУЛЮ
	CPI 160
	JC HITTURRET ;ПОПАЛИ В ПУШКУ!
	CPI 164
	JC HITBUILDING ;ПОПАЛИ В ДОМ
	CPI 168
	JC HITBRWALL ;ПОПАЛИ В СТЕНУ
	CPI 172
	JC HITBАSE ;ПОПАЛИ В БАЗУ
	CPI 192
	JC STOPBULL ;ОСТАНОВИМ СНАРЯД
	CPI 196
	JC HITIRWALL ;ПОПАЛИ В ЖЕЛЕЗНУЮ СТЕНУ
	CPI 200
	JC HITBUILDING ; В СТOЛБ POPALI
	CPI 204
	JC HITBRWALL ;ПОПАЛИ В СТОНЕВОЛЛ
CHB5:	MVI A,20H
	ADD D
	MOV D,A ;ПЕРЕХОДИМ НА _МАР1_
	LDAX D
	CPI 252   ; ПУСТОТА?
	RNC	;ДА - ВЫХОДИМ
	CPI 128
	JC HITTANK ;ПОПАЛИ В ТАНК
	CPI 240
	RC
	CPI 244
	RNC
HITMAN:
; ПОПАЛИ В ЧЕЛОВЕКА?
	LDA DIR
	ANI 3
	JZ HITMN ;СЕВЕР
	DCR A
	JZ HITME
	DCR A
	JZ HITMW ; ЗАПАД, СООТВЕТСТВЕННО
HITME:	CALL FINDOBJ
	RC	; НЕ ДОЛЖНО БЫТЬ В ПРИНЦИПЕ ЗДЕСЬ CY=1
HITM3:	MVI M,3 ;MAN.CONDITION=KILLED
	INX H
	MVI M,244 ;MAN.VID
	LXI D,14
	DAD D
	RND
	ANI 0FH
	ADI 8
	MOV M,A
	CALL HITM5 ;СОТРЕМ С КАРТЫ-1
	LDA VID
	CPI 248
	RNC ;РАКЕТА ПРОДЛОЖАЕТ ЛЕТЕТЬ
STOPBULL:
	POP PSW	; ЧИСТИМ СТЕК ОТ АДРЕСА CHECKBULL
	JMP DELBULL ;УДАЛЯЕМ ПУЛЮ И ВЫХОДИМ В CONTROLOBJ
HITMN:	CALL FINDOBJ
	JNC HITM3
	DCR C
	CALL FINDOBJ
	INR C
	JMP HITM3-1
HITMW:	CALL FINDOBJ
	JNC HITM3 ;НАЙДЕН ЧЕЛОВЕК!
	DCR B  ; DEC(X)
	CALL FINDOBJ  ; ИЩЕМ ЕЩЕ РАЗ
	INR B
	JMP HITM3-1
HITM5:	;CТИРАЕМ МЭНА С КАРТЫ-1
	LXI D,-8
	DAD D  ; НАСТРАИВАЕМ HL НА XSHIFT
	PUSH B
	MOV A,M
	ANI 15
	MOV B,A  ; XSHIFT
	INX H
	MOV A,M
	ANI 15
	MOV C,A  ; DSHIFT
	PUSH B
	DCX H
	DCX H
	DCX H
	MOV A,M ; A=CURY
	DCX H
	MOV C,M ; C=CURX
	CALL GETMAPXY ; ПОЛУЧАЕМ АДРЕС
	POP B
	CALL DEL8FRMAP1 ;УДАЛЯЕМ СОБТВЕННО МЭНА
	POP B
	RET
DELBULL:
;УДАЛЯЕМ ПУЛЮ
	LDA MOTHERNUMBER ;МАТЬ ОБ'ЕКТА ПУЛИ
	CPI 255
	JZ DEBU1  ; ПУШКА!
	CALL GETADOBJ
	LXI D,0CH
	DAD D
	DCR M ; DEC(OBJ.CSH) - УМЕНЬШИМ КОЛ-ВО ВЫСТРЕЛОВ
	MVI A,255
DEBU1:	STA CONDITION ;CONDITION=DEAD
	POP H
	POP PSW ;ЧИСТИМ СТЕК ОТ АДРЕСА И АККУМУЛЯТОРА
	RET ;ВЫХОДИМ НА CTROB2
HITTURRET:
;	 ПОПАЛ В ПУШКУ!
	CALL GETTOPLEFT
	LDA NUMOFTP 
	MOV E,A  ; E=КОЛ-ВО ПУШЕК
	LXI H,TPXY
HITT1:	MOV A,M
	INX H
	CMP B
	JNZ HITT3 ;  НЕ СОВПАЛ X - HITT3
	MOV A,M
	CMP C
	JNZ HITT3 ;  НЕ СОВПАЛ Y - HITT3
	INX H
	LDA POWER
	MOV E,A
	MOV A,M
	SUB E
	MOV M,A
	JC EXPLOBJ
	JZ EXPLOBJ ;ВЗОРВЕМ ПУШКУ К ЧЕРТОВОЙ МАТЕРИ
	JMP STOPBULL
HITT3:	INX H
	INX H
	INX H
	DCR E
	JNZ HITT1
	RET ; ПУШКА НЕ НАЙДЕНА ( ПРОГРАММНАЯ ОШИБКА)
EXPLOBJ:
;	ВЗРЫВАЕМ ОБ'ЕКТ
;	ВХОД:	<BC> - КОРРЕКТНЫЕ КОНКРЕТНЫЕ КООРДИНАТЫ ОБ'ЕKТА
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	CALL DELFRMAP ;УДАЛЯЕМ ОБ'ЕКТ С КАРТЫ
	POP B
	LXI H,FLAGXY ;ИСПОЛЬЗУЕМ ЭНТУ ШТУКУ
	CALL CATFL5+1 ;ЗАПОЛНЯЕМ ЕЕ 4-МЯ КОРДИНАTАМИ
	LXI D,FLAGXY
	REPT 4
	CALL SAVEDSPCOOR
	ENDM
	CALL CREATEEXPL ; СОЗДАДИМ ВЗРЫВ НА МЕСТЕ ОБ'ЕКТА
	JMP STOPBULL ;  ИОСТАНАВЛИВАЕМ ПУЛЮ
HITBUILDING:
	CALL GETTOPLEFT
	LDA VID
	CPI 248
	JNC EPLOBJ ;ВЗРЫВАЕМ, ЕСЛИ РАКЕТА
	JMP STOPBULL ; ИНАЧЕ ПРОСТО ОСТНОВИМ ПУЛЮ
HITBRWALL:
	LDA VID
	CPI 246
	JZ STOPBULL ;ПРОСТЫЕ ПУЛИ НЕ ВЗРЫВАЮТ СТЕНУ
DELBRICK:
;	УДАЛИМ КИРПИЧЕК С КАРТЫ И С ПОЗЖЕ С ЭКРАНА
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY ;ПОЛУЧИМ АДРЕС КИРПИЧИКА
	MVI A,255 ; INIT CODE
	STAX D
	POP B
	LXI H,STWALLXY ;ИСПОЛЬЗУЕМ УЖЕ ГОТОВЫЕ ЯЧЕЙКИ
	MOV M,B ;ХРАНИМ Х СОБ'ЕКТА
	INX H
	MOV M,C ; И ЕГО У
	DCX H
	XCHG
	CALL SAVEDSPCOOR ;УДАЛЯЕМ С ЭКРАНА
	JMP STOPBULL ; И ОCТАНАВЛИВАЕМ ПОЛЕТ ПУЛИ?
HITIRWALL:
	LDA VID
	CPI 248  ; ЕСЛИ РАКЕТА,
	JNC DELBRICK ; ТО УДАЛЯЕМ КИРПИЧЕК
	JC STOPBULL
HITBASE:
;	ПОПАЛИ В БАЗУ
	CALL GETTOPLEFT
	LDA POWER ; МОЩНОСТЬ ЗАРЯДА
	MOV E,A
	LDA BASEHP
	SUB E
	STA BASEHP ;УМЕНЬШИМ HP БАЗЫ
	JNC STOPBULL ;НЕ ДОБИЛИ - ПРОСТО ОСТАНАВЛИВАЕMСЯ
	MVI A,1
	STA YBASE ;ФЛАГ: БАЗА ВЗОРВАНА!
	JMP EXPLOBJ ;ВЗОРВЕМ ОБ'ЕКТ БAЗУ
HITTANK:
; ПОПАДАНИЕ В ТАНК
; ПОСЛЕДНЯЯ ЧАСТЬ CHECKBULL
; НО И САМАЯ ДОЛГАЯ
	CALL GETTOPLEFT ;НАЙДЕМ КООРД.ЛЕВОГО ВЕРХНЕГО
			;УГЛА ТАНКА, В КОТОРЫЙ ПОПАЛИ ПО КОДУ ЕГО ЧАСТИ	

	CALL FINDOBJ ;НАЙДЕМ НОМЕР(<А>)И АДРЕС (<HL>)ОБ'ЕКТА
	RC  ;ЕСЛИ CY=1, ТО ОБ'ЕКТ НЕ НАЙДЕН

; В ПРИНЦИПЕ, CY ДОЛЖЕН ВЕГДА БЫТЬ 0 ЗДЕЦЬ, ИБО ОБ'ЕКТ-ТО ЕСТЬ
; НО ЭТО УЖЕ ПРОГРАММНАЯ ОШИБК БУДЕТ
; В ХАКЕРСОМ РЕЖИМЕ О НЕЙ БУДЕТ СООБЩАТЬЯ

	MOV E,A ; В <E> - НОМЕР ТАНКА
	LDA MOTHEROBJ ;КТО СТРЕЛЯЛ?
	CPI 2
	MOV A,E
	JC PLSHOT ;ИГРОК СТРЕЛЯЛ
	CPI 2
	JNC STOPBULL ;СВОЕГО НЕ УБИВАEМ
HITTA1:	PUSH H
	LXI D,8
	DAD D
	LDA POWER ;МОЩЬ ЗАРЯДА
	MOV E,A
	MOV A,M ; БЕРЕМ HP
	SUB E   ; УМЕНЬШАЕМ
	MOV M,A
	POP H
	JC DELTANK ;ТАНК УНИЧТОЖЕН
	JZ DELTANK
	DCR A
	JZ BREAKTANK ;ТАНК СЛОМАН - ЧЕЛОВЕКА ДАЙ
	JMP STOPBULL ;ИНАЧЕ ПРОСТО ОСТАНАВЛИВАЕМ ПУЛЮ
PLSHOT:	CPI 2  ; ПОПАЛИ В ЧУЖOГО?
	JNC HITTA1 ;ДА - УМЕНЬШИМ ЕГО HP
	MVI M,3 ;CONDITION=FROZEN
	LXI D,15
	DAD D
	RND
	ANI 0FH
	ADI 8
	MOV M,A  ; TIMEROBJ=RND
	JMP STOPBULL
DELTANK:
	CALL COUNTTANKS ;СЧИТАЕМ ТАНКИ, А ТО ИГРA БУДЕТ ВЕЧНОЙ
	MVI M,255  ; CONDITION = DEAD
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	CALL DELFRMAP1 ;УДАЛЯЕМ С КАРТЫ ТАНК
	POP B
	CALL CREATEEXPL ;НА ЕГО МЕСТЕ СОЗДДИМ ВЗРЫВ
	JMP STOPBULL    ;  И ОСТАНОВИМ ПУЛЮ
BREAKTANK:
; ЭТО СЛОЖНАЯ НО ИНТЕРЕСНАЯ ВОЗМОЖНОСТЬ МОТОРА
;  ** G-TANK **
; ЕСЛИ БРОНЯ ТАНКА = 1, ТО САМ ОН ОСТАНАВЛИВАЕТСЯ,
; А ИЗ НЕГО ВЫСКАКИВАЕТ ЧЕЛОВЕК
;	ЭТА ОСОБЕННОСТЬ РЕАЛИЗОВАНА НИЖЕ
	PUSH H
	PUSH B
	CALL FINDFREEOBJ ;ИЩЕМ СВОБОДНЫЙ ОБ'ЕКТ
	POP B
	POP D
	JC STOPBULL ; НЕ НАЙДЕН - ВСЕ
; В <DE> ТЕПЕРЬ АДРЕС СЛОМAННОГ ТАНКА
	PUSH D
	MVI A,4 ; CONDITION=BROKEN
	STAX D
; ТЕПЕРЬ ПЕРЕПИСЫВАЕМ ИЗ НАСТОЯЩЕГО ОБ'ЕКТА В НОВЫЙ
; ПОЗИЦИЮ И СОСТОЯНИЕ ТАНКА
	REPT 9
	MOVSB
	ENDM
	RND
	ANI 1FH
	ADI 1FH
	MOV M,A ; НАСТРОИМ СЛУЧАЙНО TIMEROBJ
	POP H ; АДРЕС СТАРОГО ОБ'ЕКТА
	CALL FINDBC ; ИЩЕМ МЕСТО ДЛЯ ЧЕЛОВЕКА
	MVI M,0
	JC STOPBULL ;НЕ НАЙДЕНО - ОБ'ЕКТ СВОБОДЕН
	MOV A,B
	STA CURX
	MOV A,C
	STA CURY
	CALL STM1 ;САБА ИЗ LEVEL.LIB (РОЖДЕНИЕ МЭНА!)
	JMP STOPBULL ;ВСЕ?
FINDBC:
; ИЩЕМ СВОБОДНОЕ МЕСТО РЯДОМ С ТАНКОМ ДЛЯ ЧЕЛОВЕКА
	XRA A
	CMP B
	JZ FINDBY ; X=0
; ИЩЕМ СЛЕВА ОТ ТАНКА
	DCR B
	CALL LASTCHM
	RNC  ; НАЙДЕНО - ВСЕ!
	INR C
	CALL LASTCHM
	RNC
	DCR C
	INR B
;ИЩЕМ НАД ТАНКОМ
FINDBY:	XRA A
	ORA C ; Y=0?
	JZ FINDCR ; DA - ИЩЕМ СПРАВА
	DCR C
	CALL LASTCHM
	RNC
	INR B
	CALL LASTCHM
	RNC
	DCR B
	INR C ;ВЕРНЕМ КООРДИНАТЫ ЛЕВОГО ВЕРХ.УГЛА ТАНКА
FINDCR:	
	MOV A,B
	CPI 1EH
	JNC FINDBD
; ИЩЕМ СПРАВА ОТ ТАНКА
	INR B
	INR B
	CALL LASTCHM
	RNC ; НАЙДЕН!?
	INR C
	CALL LASTCHM
	RNC
	DCR C
	DCR B
	DCR B
FINDBD:	LDA LMAXY
	DCR A
	MOV E,A
	MOV A,C ; 
	CMP E   ; Y < (LMAXY-1)
	CMC
	RC  ; НЕТ - ВЫХОДИМ С CY = 1
	INR C
	INR C ; Y=Y+2
	CALL LASTCHM ;
	RNC
	INR B
; ПОСЛЕДНЯЯ ПРОВЕРКА КАРТЫ В МОТОРЕ, Я НАДЕЮСЬ?!
LASTCHM:
; ВХОД:	<BC> - XY ПРЕДПОЛАГАЕМЫЕ МЭНА
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	POP B
	LDAX D
	CPI 252
	JNC LCM2
	CPI 204
	RC
	CPI 216
	JC LCM2
	CPI 224
	RC
LCM2:	PUSH D
	MVI A,20H
	ADD D
	MOV D,A
	LDAX D
	POP D
	CPI 252
	RET ; CY БУДЕТ РАВЕН 1, ЕСЛИ КОД МЕНЬШЕ 252 (ПУСТОТЫ)
COUNTTANKS:
;СЧИТАEМ ТАНКИ
	LDA MOTHEROBJ
	CPI 2
	RNC ;СТРЕЛЯЛ НЕ ИГРОК, А КОМП - ВСЕ
	PUSH H
	LXI D,0EH
	DAD D
	MOV A,M ;БЕРЕМ MOTHEROBJ (КОД КАРТИНКИ)
;ДЕЛИМ ЕГО НА 16
	REPT 4
	ORA A
	RAR
	ENDM
	LXI H,MAXMEN ;0 NE ДОЛЖЕН БЫТЬ, ЕСЛИ ЭТО НЕ T-34
	ADDHL
	DCR M
	CALL SETFLAG
	POP H
	RET
SETFLAG:
	;ПОСТАВИМ ФЛАГ ЧЕРЕЗ КАЖДЫЕ ТРИ ПОДБИЫХ ТАНКА
	LXI H,NUMOFTANKS
	MOV A,M
	INR A
	ANI 3
	MOV M,A
	RNZ ; НЕ 3-ИЙ ПОДРЯД
	LXI H,FLAGS
	MOV A,M
	INR A
	ANI 3
	MOV M,A
	MVI A,216  ; КОД ЗВЕЗДЫ
	JZ $+5
	MVI A,220  ; КОД ФЛАГА
;  В <BC> - КООРДИНАТЫ ТАНКА
	PUSH B
	PUSH PSW
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	POP PSW
	PUSH PSW
	CALL PUTINMAP ;ПОМЕСТИМ В КАРТУ ОБ'ЕКТ (STAR/FLAG)
	LXI H,NUMOFSTO ;ЧИСЛО СТАТИЧЕСКИХ ОБ'ЕКТОВ
	MOV A,M
	INR M
	INR M
	INR M
	INR M
	ADD A
	ADD A
	LXI H,STOBJXY
	ADDHL
	POP PSW
	POP B
; СОХРАНИМ 4 КООРДИНАТЫ ОБ'ЕКТА, ЧТОБЫ PUTSTOBJ ЕГО ВЫВЕЛА
; ПОЗЖЕ НА ЭКРАН
	STOSB B
	STOSB C
	STOSB
	INX H
	INR B
	STOSB B
	STOSB C
	STOSB
	INX H
	INR C
	STOSB B
	STOSB C
	STOSB
	INX H
	DCR B
	STOSB B
	STOSB C
	STOSB
	DCR C ; ВЕРНЕМ <BC>, ТАК КАК ОН ИСПОЛЬЗУЕТСЯ ДАЛЕЕ
	RET   ; ВСЕ? {SETFLAG}

;//////////// САМ <CONTROLOBJ> НА ЭТОМ ОКОНЧЕН \\\\\\\\\\

BEARTANKS:
;	ПОЯВЛЕНИЕ ТАНКОВ В УРОВНЕ
	LDA CYCLES  ;ЦИКЛЫ ИГРЫ
	ANI 7
	RNZ
	LDA NOENEMY
	ORA A
	RNZ ; НЕТ ВРАГА - ВСЕ
	LDA NUMOFBP
BEART1:	DCR A
	RM
	PUSH PSW
	MOV B,A
	RND
	CPI 30H   ; ЗНАЧЕНИЕ МОЖНО ИЗМЕНИТЬ,
	JC BEART9 ; ЕСЛИ ТАНКИ БУДУТ ПОЯВЛЯТЬСЯ РЕДКО
	MOV A,B
	LXI H,BPXY
	ADD A
	ADDHL
	MOV B,M
	INX H
	MOV C,M
	CALL BPCHECK ;ПРОВЕРИМ, ЕСТЬ ЛИ МЕСТО ДЛЯ ТАНКА
	JC BEART9 ;NICHT
	INR B
	CALL BPCHECK
	JC BEART9
	INR C
	CALL BPCHECK
	JC BEART9
	DCR B
	CALL BPCHEK
	JC BEART9  ; МЕСТО ЗАНЯТО - СЛЕД.ТАНК
	DCR C
	RND
	RLC
	ANI 7
	JZ BEART9
	LXI H,TANKS
	MOV E,A
	XLAT
	ORA A
	JZ BEART9 ; НЕ РОЖДАЕМ, ЕСЛИ ЧИСЛО ВИДА РАВНО 0
	DCR M  ; УМЕНЬШИМ ЧИСЛО ДАННОГО ВИДОВ
	MOV A,E
	LXI D,TABTANK ;ТАБЛИЦА ТАНКОВ
	ADD A
	ADD A
	ADDDE
	PUSH D
	PUSH B
	CALL FINDFREEOBJ ;ИЩЕМ СВОБОДНЫЙ ОБ'ЕКТ
	POP B
	POP D
	JC BEART9 ;НЕ НАЙДЕН - СЛЕД.ТАНК
	MVI M,1 ;CONDITION=NORMAL
	INX H
	RND
	RRC
	ANI 3 ;DIR - RANDOM
	PUSH PSW
	XCHG
	ADD A
	ADD A
	ADD M ; A = DIR * 4 + MOTHERNUMBER ИЗ ТАБЛИЦЫ
	XCHG
	MOV M,A ; ПОЛУЧИЛСЯ VID (КОД КОНКРEТНОЙ КАРТИНКИ)
	INX H
; ЗАДАДИМ СТАРЫЕ И НОВЫЕ КООРДИНАТЫ РОДИВШЕГОСЯ ТАНКА
	STOSB B
	STOSB C
	STOSB B
	STOSB C
	POP PSW ; restore DIR
	STOSB
	LDAI
	MOV B,A ; MOHERNUMBER -> <B>
	LDAI
; ВЗЯЛИ ARMOR ИЗ ТАБЛИЦА ТАНКОВ (TABTANK)
; И ПИШЕМ ЕЕ В ARMOR & HP РОИВШЕГОСЯ ТАНЧИКА
	STOSB
	STOSB
	MVI M,0
	INX H
	LDAI
	MOV C,A ;SHTM -> <C>
	LDAX D ; БЕРЕМ WTYPE
	STOSB
	STOSB C
	MVI M,0 ;CSH
	INX H
	INX H
	STOSB B ;MOTHERNUMBER
BEART9:
	POP PSW ;СЧЕТЧИК BP
	JMP BEART1 ; ЦИКЛ НЕ ВЕЧЕН
BPCHECK:
;ПРОВЕРКА MAP1 НА ЗAНЯТОСТЬ
	PUSH B
	MOV A,C
	MOV C,B
	CALL GETMAPXY
	MVI A,20H
	ADD D
	MOV D,A
	LDAX D
	POP B
	CPI 252 ; ВЫСТАВИМ CY
	RET     ; И ВЕРНЕМСЯ В BEARTANKS

;////// ОБСЛУЖИВАНИЕ ПУШЕК \\\\\\\\\\\\\\
SERVETURRET:
	LDA CYCLES
	RRC
	ANI 3
	RNZ
	LDA NUMOFTP ; ЧИCЛО TURRET POINTS
SRVT1:	DCR A
	RM
	PUSH PSW ;ЗАПОМНИМ СЧЕТЧИК ПУШЕК
	LXI H,TPXY ;ИНФО О ТУРРЕТАХ
	ADD A
	ADD A
	ADDHL
	RND
	CPI 0C0H
	JNC SRVT9 ; НЕ СТРЕЛЯЕМ
	MOV A,M   ; TPXY.X
	STA CURX
	INX H
	MOV A,M   ; TPXY.Y
	STA CURY
	INX H
	MOV A,M ; TPXY.HP
	ORA A
	JM SRVT9
	JZ SRVT9
	INX H
	MOV A,M
	ANI 3
	STA DIR
	MVI E,2 ; E=2 (PROJ)
	MOV A,M
	RLC
	JNC $+4
	INR E
	MOV A,E
	STA WTYPE ;ТИП ОРУЖИЯ (ПРОЖЕКТЫ/РАКЕТЫ)
	LDA DIR
	ADD A
	LXI H,SHIFTS ; ТАБЛИЦА СДВИГОВ
	ADDHL
	MOV C,M ; BЫБИРАЕМ DSHIFT
	INX H
	MOV B,M ; И XSHIFT
	MVI A,255
	STA NUMOBJ ; СИГНАЛ - ПУШКA
	LXI D,INCCOOR16 ;УКАЖЕМ ТАБЛИЦУ ПРИРАЩЕНИЙ
; (ОНА ТАКАЯ ЖЕ КАК У ТАНКОВ)
	CALL CREATEBULL ; СОЗДАЕМ ПУЛЮ
SRVT9:	POP PSW
	JMP SRVT1 ; ЦИКЛИМСЯ
	
	ENDM
;///////КОНЕЦ БИБЛИОТЕКИ ENGINE2.LIB\\\\\\\\\\\\\\
