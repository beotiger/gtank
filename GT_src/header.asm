;/////////// G - T A N K \\\\\\\\\\\\\\\\\\
;
; ОПИСАНИЕ ИДЕНТИФИКАТОРОВ ПРОГИ Г-ТАНК
; И ТАБЛИЦЫ

HEADER	MACRO

FIRSTLEVEL:
	EQU NUMLEV+1
MAP	EQU 0A000H ; КАРТА В КВАЗИ
MAP1	EQU MAP+2000H
QBANK	EQU 20H
TABLCOLSYM
	EQU TABL2SYM+800H
FIRSTOBJ
	EQU ?  ; АДРЕС НАЧАЛА ОПИСАНИЯ ОБ'ЕКТОВ
DEMOBEG	EQU ? ; АДРЕС НАЧАЛА КОДОВ ДЕМОНСТРАЦИИ
MAN1:	EQU 240
ARM1:	EQU 22
ARM4:	EQU 25
STOLB:	EQU 20
NIZ:	EQU 26
POINTS0	EQU 27
CHEREP	EQU 3
CPRT	EQU 127

; МАКСИМАЛЬНЫЕ ЗНАЧЕНИЯ
MAXBP:	EQU 10 ; ЧИСЛО BEAR_POINTS
MAXTP:	EQU 12 ; ЧИСЛО ТУРРЕT_POINTS
MAXOBJ:	EQU 32 ; ЧИСЛО ДВИЖИМЫХ ОБ'ЕКТОВ
MAXDSP:	EQU 24 ; ЧИСЛО СТАТ.ОБ'ЕКТОВ ДЛЯ СТИРАНИЯ
MAXSTO:	EQU 8  ; ЧИСЛО ВЫВОДИМ.СТАТ.ОБ.
LEVPTR:	DW FIRSTLEVEL ; УКАЗАТЕЛЬ НА ТЕК.УРОВЕНЬ

; LEVEL'S  HEADER
LEVNAME	DS 14
	DB 0
LMAXY	DS 1
LEVY	DS 1 ; НОМЕР ПЕРВОЙ ВИДИМОЙ НА ЭКРАНЕ СТРОКИ
LEVGOAL	DS 1
MAXMEN:	DS 8 ; ЧИСЛО ПРОТИВНИКОВ В УРОВНЕ

TANKS	DS 8 ; ВНАЧАЛЕ - КОПИЯ МАССИВА MAXMEN

;
NOENEMY	DB 0
YBASE:	DB 0
MAXLEV:	DB 1
LEVROLL	DB 0
LEVDIR	DB 0
YDEMO	DB 1 ; ДЕМО ЕСТЬ/НЕТ/КОНЕЦ (1/0/255)
NUMOFPL	DB 1 ; ЧИСЛО ИГРОКОВ 1-2
PL1LIV	DB 3
PL2LIV	DB 3 ; ЖИЗНИ МАТЬ ИХ ДЕРИ
UKAZ	DB 1
PL1CTR	DB 0
PL2CTR:	DB 1 ; НОМЕРА УПРАВЛЕНИЯ
YSOUND	DB 1 ; ЗВУК ЕСТЬ/НЕТ
DEMLEV:	DB 3 ; УРОВЕНЬ ДЛЯ ДЕМО
NUMOFDP	DB 0 ; ЧИСЛО BP
BPXY:	DS 2*MAXBP
NUMOFTP	DB 0
TPXY:	DS 4*MAXTP
DEMON:	DW DEMOBEG ; АДРЕС КОДА ДЛЯ ДЕМО


ADDROBJ:
	DW 0 ; АДРС ТЕК.ОБ'ЕКТА
NUMOBJ:	DB 0 ; НОМЕР ТЕКУЩЕГО ОБ'ЕКТА ( В МОТОРЕ)

; OBJECT STRUCTURE
DESOBJ:
CONDITION:
	DB 0
VID:	DB 0
OLDX:	DB 0
OLDY:	DB 0
CURX:	DB 0
CURY:	DB 0
DIR:	DB 0 ; DIRECTION
ARMOR:
XSHIFT:
	DB 0
HP:
DSHIFT:	DB 0
TYPE:	DB 0
POWER:
WTYPE:	DB 0 ; ТИП НОСИМОГО ОРУЖИЯ (0-3)
		; ИЛИ МОЩЬ УДАРА ДЛЯ ОРУЖИЯ
SHTM:	DB 0 ;СКОРОСТРЕЛЬНОСТЬ
CSH:	DB 0 ;СЧЕТЧИК ВЫСТРЕЛОВ, СОCТ.СТРЕЛЬБЫ(d7)
SPEED:	DB 0 ; СКОРОСТЬ
MOTHERNUMBER:
	DB 0 ; ХЕР КАКОЙ-ТО
TIMEROBJ:
RANGE:	DB 0 ; ИЛИ ТАЙМЕР СОСТОЯНИЙ ОБ'ЕКТОВ, 
		; ЛИБО (ДЛЯ ПУЛЬ) ДАЛЬНОСТЬ ПОЛЕТА
TCODE:	DB 0
NUMMEL:	DB 0
YBON:	DB 0
BONOBJ:
	DB 0
NUMOFDSP:
	DB 0 ; ЧИСЛО DSP
DSPXY:	DS 2*MAXDSP
NUMOFSTO:
	DB 0
STOBJXY:
	DS MAXSTO*4
BASEHP:	DB 12 ; HP OF THE BASE
NUMOFTANKS:
	DB 0
FLAGS:	DB 0
CYCLES:	DB 0 ; ЦИКЛЫ ИГРЫ
NUMDEMON:
	DB 0 ; НОМЕР НАДПИСИ ПРИ ДЕМОШКЕ

;  ЯЧЕЙКИ ДЛЯ MOVETANK
CWALL:	DB 0
STWALLXY:
	DS 4
CFLAG:	DB 0
FLAGXY:	DS 2
CSTAR:	DB 0
STARXY:	DS 2
CMINE:	DB 0
MINEXY:	DS 4
CMAN:	DB 0,0 ; РАЗДАВЛЕН ЛИ МЭН + НОМЕР ЕГО, ЕСЛИ ДА
NCURX:	DB 0 ; НОВЫЙ  CURX
NCURY:	DB 0 ; НОВЫЙ  CURY

; ОБ ИГРЕ ЗАМОЛВИТЕ СЛОВО
GAMECON:
	DB 0
GAMETIM:
	DB 0
PL1BON:	DB 0
PL2BON:	DB 0


;////////// ТАБЛИЦЫ \\\\\\\\\\\\\\\
TABTANK:
	DB 0,6,1,2,16,6,2,2,32,3,1,2
	DB 48,9,1,2,64,12,2,2,80,24,3,3
	DB 96,3,3,1,108,7,2,1
INCTANK:
; ПРИРАЩЕНИЯ ДЛЯ ТАНКА (ДВИЖЕНИЕ/ПРОВЕРКА КАРТЫ)
	DB 0,-1,1,-1
	DB 2,0,2,1
	DB -1,0,-1,+1
	DB 0,2,1,2
INCCOORMAN:
; ПРИРАЩЕНИЯ ДЛЯ ДВИЖЕНИЯ ОБ'ЕКТОВ 8х8
	DB 0,-1,1,0,-1,0,0,1
SHIFTS:	DB 0,4,4,0,4,0,0,4 ; СДВИГИ
INCCOOR16:
	DB 0,-1,2,0,-1,0,0,2

; !!! ВНИМАНИЕ: НЕ ПЕРЕСЕКАТЬ СЛЕД ТАБЛИЦЫ
; !!! ОБЛАСТЬ КРАТНОЙ 100Н БАЙТ !!!!!!
; ИНФО ДЛЯ СОЗДАВЕМОГО СНАРЯДА
POWERS:	DB 0,1,3,5  ; МОЩЬ УДАРА
SPEEDS:	DB 0,3,4,5  ; СКОРОСТЯ
DISTANCE:
	DB 0,8,12,17 ; РАССТОЯНИЯ
VIDS:	DB -1,-1,-1,-1  ; КОДЫ КАРТИНОК
	DB 246,246,246,246
	DB 247,247,247,247
	DB 248,249,250,251

;
	ENDM
