;/////////// G - T A N K \\\\\\\\\\\\\\\\\\
;
; ОПИСАНИЕ ИДЕНТИФИКАТОРОВ ПРОГИ Г-ТАНК
; И ТАБЛИЦЫ

NUMLEV	EQU 4800H ;АДРЕС НАЧАЛА ВСЕХ УРОВНЕЙ G-TANK'A!?
FIRSTLEVEL	EQU NUMLEV+1 ; АДРЕС НАЧАЛА ВСЕХ УРОВНЕЙ
QBANK	EQU 20H
TABL2SYM	EQU TABLSYM+800H
TABLCOLSYM	EQU TABL2SYM+800H
FIRSTOBJ	EQU 7E00H  ; АДРЕС НАЧАЛА ОПИСАНИЯ ОБ'ЕКТОВ
MAN1	EQU 240
ARM1	EQU 22
ARM4	EQU 25
STOLB	EQU 20
NIZ	EQU 26
POINTS0	EQU 27
CHEREP	EQU 3
CPRT	EQU 127
CHESS	EQU 16
CROSS	EQU 128 ;КРЕСТ - УКАЗАТЕЛЬ КУРСОРА
LEVPTR:	DW FIRSTLEVEL ; УКАЗАТЕЛЬ НА ТЕК.УРОВЕНЬ

; LEVEL'S  HEADER
LMAXY:	DS 1

MODE:	DB 0 ;РЕЖИМ 0/1/-1 (CR - УС - АР2)
UKAZ:	DB 0
JOYPU:	DB 0
COLSYM:	DB 7	; ЦВЕТ СИМВОЛОВ В PUTSCHAR


CURX:	DB 0
CURY:	DB 0

ELEVY:	DB 0 ; ТЕК.LEVY ДЛЯ РЕДАКТРОВАНИЯ
CURCODE:
	DB 252
CURLEV:	DB 1  ;ТЕКУЩИЙ УРОВЕНЬ
BUFFER:	DS 3
WERROR:	DB 'Ошибка при записи',0
MEMERR:	DB 'НЕТ ПАМЯТИ!',0
QUITSTR:
	DB 'Выйти?',0
VYBOR:	DB 'ВЫБОР:',0
NNAME:	REPT 14
	DB ' '
	ENDM
	DB 0
