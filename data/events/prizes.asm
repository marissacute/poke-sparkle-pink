PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries, PrizeMenuMon1Cost
	dw PrizeMenuMon2Entries, PrizeMenuMon2Cost
	dw PrizeMenuTMsEntries,  PrizeMenuTMsCost

NoThanksText:
	db "NO THANKS@"

PrizeMenuMon1Entries:
	db ABRA
	db CLEFAIRY
	db DRATINI
	db "@"

PrizeMenuMon1Cost:
	bcd2 500
	bcd2 750
	bcd2 1000
	db "@"

PrizeMenuMon2Entries:
	db EEVEE
	db SCYTHER
	db PORYGON
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
