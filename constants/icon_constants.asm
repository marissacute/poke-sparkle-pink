; party menu icons
; Indexes into MonIconTable (see data/icon_pointers.asm).
; The order matches the Gen 2 games; data/pokemon/menu_icons.asm decides which
; species uses which icon.
	const_def
	const ICON_POLIWAG     ; $00
	const ICON_JIGGLYPUFF  ; $01
	const ICON_DIGLETT     ; $02
	const ICON_PIKACHU     ; $03
	const ICON_STARYU      ; $04
	const ICON_FISH        ; $05
	const ICON_BIRD        ; $06
	const ICON_MONSTER     ; $07
	const ICON_CLEFAIRY    ; $08
	const ICON_ODDISH      ; $09
	const ICON_BUG         ; $0a
	const ICON_GHOST       ; $0b
	const ICON_LAPRAS      ; $0c
	const ICON_HUMANSHAPE  ; $0d
	const ICON_FOX         ; $0e
	const ICON_EQUINE      ; $0f
	const ICON_SHELL       ; $10
	const ICON_BLOB        ; $11
	const ICON_SERPENT     ; $12
	const ICON_VOLTORB     ; $13
	const ICON_SQUIRTLE    ; $14
	const ICON_BULBASAUR   ; $15
	const ICON_CHARMANDER  ; $16
	const ICON_CATERPILLAR ; $17
	const ICON_UNOWN       ; $18
	const ICON_GEODUDE     ; $19
	const ICON_FIGHTER     ; $1a
	const ICON_EGG         ; $1b
	const ICON_JELLYFISH   ; $1c
	const ICON_MOTH        ; $1d
	const ICON_BAT         ; $1e
	const ICON_SNORLAX     ; $1f
	const ICON_HO_OH       ; $20
	const ICON_LUGIA       ; $21
	const ICON_GYARADOS    ; $22
	const ICON_SLOWPOKE    ; $23
	const ICON_SUDOWOODO   ; $24
	const ICON_BIGMON      ; $25
DEF NUM_MON_ICONS EQU const_value

; Tiles per animation frame of a mon icon (16x16 pixels), and the number of
; tiles a party slot's icon occupies: the two frames are loaded back to back,
; so the second frame starts MON_ICON_TILES tiles after the first.
DEF MON_ICON_TILES EQU 4
DEF MON_ICON_SLOT_TILES EQU MON_ICON_TILES * 2

; VRAM tile the trade bubble's 16x16 graphic is loaded to during a trade.
DEF TRADE_BUBBLE_TILE EQU $38
