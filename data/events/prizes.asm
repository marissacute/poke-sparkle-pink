PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries, PrizeMenuMon1Cost
	dw PrizeMenuMon2Entries, PrizeMenuMon2Cost
	dw PrizeMenuTMsEntries,  PrizeMenuTMsCost

NoThanksText:
	db "NO THANKS@"

; \1 species
; The prize menus and PrizeMonLevelDictionary are two separate tables, and
; nothing used to tie them together -- Nidorina lingered in the dictionary for
; years after it stopped being a prize, and a species with no entry made
; GetPrizeMonLevel scan off the end of the table. Assert the link instead.
MACRO prize_mon
	db \1
	ASSERT DEF(PRIZE_LEVEL_\1), "no PrizeMonLevelDictionary entry for \1"
ENDM

PrizeMenuMon1Entries:
	prize_mon GOLDEEN
	prize_mon HAPPINY
	prize_mon SMOOCHUM
	db "@"

PrizeMenuMon1Cost:
	bcd2 500
	bcd2 750
	bcd2 1000
	db "@"

PrizeMenuMon2Entries:
	prize_mon EEVEE
	prize_mon SCYTHER
	prize_mon PORYGON
	db "@"

PrizeMenuMon2Cost:
	bcd2 500
	bcd2 1000
	bcd2 1500
	db "@"

PrizeMenuTMsEntries:
	db TM_DRAGON_RAGE
	db TM_HYPER_BEAM
	db TM_SUBSTITUTE
	db "@"

PrizeMenuTMsCost:
	bcd2 1300
	bcd2 1500
	bcd2 1700
	db "@"
