; \1 species, \2 level
; Also defines PRIZE_LEVEL_<species> so data/events/prizes.asm can assert that
; every mon its menus offer actually has an entry here. This file is therefore
; INCLUDEd before prizes.asm.
MACRO prize_level
	ASSERT !DEF(PRIZE_LEVEL_\1), "duplicate PrizeMonLevelDictionary entry for \1"
	DEF PRIZE_LEVEL_\1 EQU \2
	db \1, \2
ENDM

; The level used if a prize species is somehow missing. It cannot happen while
; the assert in PrizeMenuMon1Entries/PrizeMenuMon2Entries passes, but the
; lookup must not run away reading past the table if it ever does.
DEF PRIZE_MON_FALLBACK_LEVEL EQU 5

PrizeMonLevelDictionary:
	prize_level GOLDEEN,   10
	prize_level HAPPINY,   5
	prize_level SMOOCHUM,  5

	prize_level EEVEE,    25
	prize_level SCYTHER,  25
	prize_level PORYGON,  25

	db 0, 0 ; terminator; NO_MON is never offered as a prize
