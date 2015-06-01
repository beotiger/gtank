;///////////// G - T A N K \\\\\\\\\\\\\\\\\\\\
; ФАЙЛ SYSTEM
; МАКАР: __SYSTEM__
; САБЫ:		ANALYSER  - АНАЛИЗАТОР МОТОРА
;		GIVBONUS - РАЗДАЧА БОНУСА
;		PLMUSIC  - ЗВУКОВЫЕ ЭФФЕКТЫ
SYSTEM	MACRO
ANALYSER:
	LXI H,CYCLES
	INR M
	MOV A,M
	ANI 15
	JNZ ANAL1
	LXI H,NUMDEMON ; НОМЕР ДЕМОНСТРАЦИИ
	MOV A,M
	INR A
	ANI 7
	MOV M,A
ANAL1:	LXI H,GAMETIM
	MOV A,M
	ORA A
	JZ ANAL ; СЧЕТЧИК НЕ ВКЛЮЧЕН - ПРОСТО АНАЛИЗИРУЕМ
	DCR M
	RNZ ; ИНАЧЕ ЖДЕМ КОНЦА СЧЕТЧИКА
	LDA GAMECON ; СОСТОЯНИЕ ИГРЫ
	DCR A
	JZ TRYNL     ; СЛЕД.УРОВЕНЬ
	JNZ GAMEOVER ; КОНЕЦ ИГРЫ
ANAL:	LDA FIRSTOBJ
	ORA A
	JNZ ANAL2
	LXI H,PL1LIV ; ЖИЗНИ КОНЦИЛИСЬ?
	MOV A,M
	ORA A
	JZ ANAL10 ; ДА - ВЫКЛЮЧАЕМ 1-ГО ИГРОКА
	DCR M
	LXI H,FIRSTOBJ
	CALL FILLPLSTR
	JMP ANAL2
ANAL10:	LDA PL2LIV
	ORA M  ; А У ВТОРОГО ТОЖЕ КОНЧИЛИСЬ?
	JZ ENDGAME
	MVI A,255
	STA FIRSTOBJ+5  ;PL1.CURY=255
ANAL2:	; ТОО ЖЕ ПРОВЕРИМ У ВТОРОГО
	LDA FIRSTOBJ+10H ; СОТОЯНИЕ
	ORA A
	JNZ ANAL3 ; ЖИВ ДУРИЛКА
	LXI H,PL2LIV
	MOV A,M
	ORA A
	JZ ANAL20
	DCR M ; УМЕНЬШИМ ЖИЗНИ 2-GO
	LXI H,FIRSTOBJ+10H ; ЗАПОЛНИМ ЕГО СТРУКТУРУ
	CALL FILLPLSTR
	JMP ANAL3
ANAL20:	MVI A,255
	STA FIRSTOBJ+15H
ANAL3:
; ТЕПЕРЬ ПРОВЕРИМ СОСТОЯНИЕ УРОВНЯ (БАЗУ/ПРОТИВНИКА)
	LXI H,LEVGOAL
	LDA YBASE
	ORA A
	JZ ANAL4 ; БАЗА ЦЕЛА
	MOV A,M ; ЕЛЬ ИГРЫ
	DCR A
	JZ ENDGAME ; ЗАЩИТА БАЗЫ - ВСЕ
	DCR A
	JZ NEXTLEVEL ; АТАКА БАЗЫ - ВСЕ
ANAL4:	LDA NOENEMY
	ORA A
	JZ ANAL5  ; ВРАГ ЕСТЬ - ИГРАЕМ
	MOV A,M
	CPI 3
	JZ NEXTLEVEL ; ЦЕЛЬ ИГРЫ - УНИЧТОЖ.ВРАГА - СЛЕД.УРОВНЬ
	DCR A
	JZ NEXTLEVEL ; ИЛИ ЗАЩИТА - ВСЕ
; ОПРЕДЕЛЯЕМ НАЛИЧИЕ ВРАГОВ В ИГРЕ
ANAL5:	LXI H,MAXMEN
	MOV A,M
	REPT 7
	INX H
	ORA M
	ENDM
	JNZ ANAL6 ; ВРАГ ЕСТЬ, ЕСЛИ РЕЗУЛЬТАТ НЕ  0
	MVI A,1
	STA NOENEMY ; ИНАЧЕ ВЫБРАЫВАЕМ ФЛАГ
ANAL6:	LDA YDEMO
	CPI 255 ; ДЕМО КОНЧИЛОСЬ?
	JZ GAMES ; ДА - СРАЗУ НА ЗАСТАВКУ
	IN 1
	CMA
	ANI 0E0H
	RZ  ; НЕТ НАЖАТИЯ РУС/УС/СС
	RLC
	JC RUSPR ; НАЖАТА РУС - МЕНЮ
	RLC
	JC USPR
; ИНАЧЕ НАЖАТА СС
	POP H  ; ЧИСТИМ СТЕК
	JMP GAMEP-3  ; ПЕРЕХОДИМ НА СТАТИСТИКУ
USPR:	; НАЖАТА УС, ПРОБУЕМ ОРГАНИЗОВАТЬ ПАУЗУ
	IN 1
	ANI 40H
	JZ USPR ; ЖДЕМ ОТПУСКАНИЯ УС
USPR1:	LDA KEY
	CPI 0FEH
	JZ TABPR ; НАЖАЛИ ТАБ
	IN 1
	ANI 40H
	JNZ USPR1
	RET  ; ВЫХОД ИЗ АНАЛИЗАТОРА
TABPR:	LDA HAMODE
	ORA A
	JZ USPR1 ; ЕСЛИ НЕ В МАСТЕР-МДЕ, ТО ТАБ НЕ РАБОТАЕТ
NEXTLEVEL:
	MVI A,1
NELE234:
	STA GAMECON ; СОСТОЯГИЕ ИГРЫ - СЛЕД.УРОВЕНЬ
	RND
	ANI 15
	ADI 8
	STA GAMETIM
	RET
ENDGAME:
; КОНЕЦ ИГРЫ ОРГАНИЗУЕМ АНАЛОГИЧНО
	MVI A,2
	JMP NELE234
RUSPR:	JMP MENU
GAMEOVER:
; ФИЗИЧЕСКОЕ ЗАВЕРШЕНИЕ ИГРЫ
	JMP GAMES ; НА ЗАСТАВКУ	
TRYNL:	LDA NUMLEV ; ЧИСЛО УРОВНЕЙ В ИГРЕ
	LXI H,CURLEV ; ТЕК.УРОВЕНЬ
	CMP M
	JZ FINITA ; ПОЛНЫЙ КОНЕЦ
	INR M
	MOV A,M
	CALL FINDLEVEL ; НАХОДИМ УРОВЕНЬ
	LDA CURLEV
	LXI H,LEVTAB
	MVI C,5
TRYNL1:	CMP M
	INX H
	JZ SETMAX ;ПРОБУЕМ ЗАПОЛНИТЬ MAXLEV
	DCR C
	JNZ TRYNL1
TYPENL1:
	POP H     ; ЧИСТИМ СТЕК ОТ ANALYSER
	JMP GAME  ; ПЕРЕХОДИМ НА НАЧАЛО ИГРЫ
SETMAX:
	MOV B,A     ; B = CURLEV
	LXI H,MAXLEV
	MOV A,M
	CMP B       ; MAXLEV > CURLEV?
	JNC TYPENL1 ;
	MOV M,B
	JMP TYPENL1
LEVTAB:	DB 3,7,10,13,15 ; НОМЕРА УРОВНЕЙ ДЛЯ МАКСИМАЛЬНОГО
FINITA:
; ФИНИШ ИГРЫ - ПАРАД, САЛЮТ, МУЗЫКА, ЦВЕТЫ, ЖЕНЩИНЫ
;		ДЕНЬГИ, ЗДОРОВЬЕ, СВОБОДА И СЧАСТЬЕ!!!
GIVBONUS:
	;РАЗДАЧА БОНУСОВ
	LDA YBON
	ORA A
	RZ
	XRA A
	STA YBON
; ЗАПОЛНИМ УКАЗАТЕЛИ ДЛЯ 1-ГО ИГРОКА
	LXI H,FIRSTOBJ
	LXI D,PL1BON
	LXI B,PL1LIV
	LDA BONOBJ
	RRC
	CC GIVBO1 ; ДАТЬ 1-МУ БОНУС
; ЗАПОЛНМ УКАЗАТЕЛИ ДЛЯ ВТОРОГО
	LXI H,FIRSTOBJ+10H
	LXI D,PL2BON
	LXI B,PL2LIV
	LDA BONOBJ
	ANI 2
	CNZ GIVBO1 ; 2-МУ ТОЖЕ БОНУС?
	XRA A
	STA BONOBJ
	RET ; ВСЕ?
GIVBO1:	XCHG
	INR M ; PLxON=+1
	MOV A,M
	XCHG
	CPI 12 ; ЗНАЧЕНИЕ МОЖНО МЕНЯТЬ
	JZ GIVROCK
	ANI 7 ; КРАТНО 8-МИ?
	JZ GIVLIFE ; ДА- ДАТЬ ЖИЗНЬ
	ANI 3
	JZ GVPOWER ; ДАТЬ МОЩЬ
	RND
	CPI 80H
	JC GIVINV ; ДАТЬ НЕУЯЗВИМОСТЬ
; ИНАЧЕ ЗАМОРОЗИМ ВСЕ ТАНКИ ПРОТИВНИКА
	LXI H,FIRSTOBJ+20H
	MVI C,MAXOBJ-2
NEXTFT:	MOV A,M
	ORA A   ; СОСТОЯНИЕ - НОРМАЛ?
	JZ GIVBO2
	PUSH H
	LXI D,9
	DAD D
	MOV A,M
	POP H
	ORA A
	JNZ GIVBO2 ; НЕ ТАНК - ВСЕ
	MVI M,3 ; CONDITION=3
	LXI D,15
	DAD D
	RND
	ANI 15
	ADI 10
	MOV M,A ; TMEROBJ=RANDOM 10..25
	INX H
	JMP GIVBO3
GIVBO2:	LXI D,10H
	DAD D
GIVBO3:	DCR C
	JNZ NEXTFT
	RET
GIVINV:	MVI M,2
	LXI D,15
	DAD D
	RND
	ANI 15
	ADI 16
	MOV M,A 
	RET
GIVPOWER:
;	УВЕЛИЧИМ ХАРАКТЕРИСТИКИ ТАНКА
	LXI D,7
	DAD D
	MOV A,M
	CPI 24 ; ARMOR=24?
	JNC GIVP1 ; ДА - НЕ УВЕЛИЧИВАЕМ ЕЕ БОЛЬШЕ
	ADI 3
	MOV M,A
GIVP1:	LXI D,4
	DAD D
	MOV A,M
	CPI 5
	RNC
	INR M ; SHTM= SHTM + 1
	RET
GIVLIFE:
; ДАДИМ ЕМУ ЖИЗНЬ!?
	LDAX B
	INR A
	STAX B ; ИЛИ: INC [BC]
	RET
GIVROCK:
	LXI D,10
	DAD D
	MVI M,3 ; WTYPE = ROCKETS
	INX H
	MVI M,1 ; SHTM = 1
	RET
PLMUSIC:
	LDA YDEMO
	ORA A
	RNZ
	LDA YSOUND
	ORA A
	RZ  ; ЗВУК ОТКЛЮЧЕН - ВСЕ
	LDA NUMMEL
	ORA A
	RZ ; НЕТ МЕЛОДИИ ДЛЯ ИГРЫ - ВСЕ

	RET ; ПОКА ЗВУКОВХ ЭФФЕКТОВ НЕТ, НО БУДУТ!

	ENDM
