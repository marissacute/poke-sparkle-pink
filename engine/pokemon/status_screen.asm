DrawHP:
; Draws the HP bar in the stats screen
	call GetPredefRegisters
	ld a, $1
	jr DrawHP_

DrawHP2:
; Draws the HP bar in the party screen
	call GetPredefRegisters
	ld a, $2

DrawHP_:
	ld [wHPBarType], a
	push hl
	ld a, [wLoadedMonHP]
	ld b, a
	ld a, [wLoadedMonHP + 1]
	ld c, a
	or b
	jr nz, .nonzeroHP
	xor a
	ld c, a
	ld e, a
	ld a, $6
	ld d, a
	jp .drawHPBarAndPrintFraction
.nonzeroHP
	ld a, [wLoadedMonMaxHP]
	ld d, a
	ld a, [wLoadedMonMaxHP + 1]
	ld e, a
	predef HPBarLength
	ld a, $6
	ld d, a
	ld c, a
.drawHPBarAndPrintFraction
	pop hl
	push de
	push hl
	push hl
	call DrawHPBar
	pop hl
	ldh a, [hUILayoutFlags]
	bit BIT_PARTY_MENU_HP_BAR, a
	jr z, .printFractionBelowBar
	ld bc, $9 ; right of bar
	jr .printFraction
.printFractionBelowBar
	ld bc, SCREEN_WIDTH + 1 ; below bar
.printFraction
	add hl, bc
	ld de, wLoadedMonHP
	lb bc, 2, 3
	call PrintNumber
	ld a, '/'
	ld [hli], a
	ld de, wLoadedMonMaxHP
	lb bc, 2, 3
	call PrintNumber
	pop hl
	pop de
	ret

StatusScreen:
	call LoadMonData
	ld a, [wMonDataLocation]
	cp BOX_DATA
	jr c, .DontRecalculate
; mon is in a box or daycare
	ld a, [wLoadedMonBoxLevel]
	ld [wLoadedMonLevel], a
	ld [wCurEnemyLevel], a
	ld hl, wLoadedMonHPExp - 1
	ld de, wLoadedMonStats
	ld b, $1
	call CalcStats
.DontRecalculate
	ld hl, wStatusFlags2
	set BIT_NO_AUDIO_FADE_OUT, [hl]
	ld a, $33
	ldh [rAUDVOL], a ; Reduce the volume
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	call UpdateSprites
	call LoadHpBarAndStatusTilePatterns
	ld de, BattleHudTiles1  ; source
	ld hl, vChars2 tile $6d ; dest
	lb bc, BANK(BattleHudTiles1), 3
	call CopyVideoDataDouble ; ·│ :L and halfarrow line end
	ld de, BattleHudTiles2
	ld hl, vChars2 tile $78
	lb bc, BANK(BattleHudTiles2), 1
	call CopyVideoDataDouble ; │
	ld de, BattleHudTiles3
	ld hl, vChars2 tile $76
	lb bc, BANK(BattleHudTiles3), 2
	call CopyVideoDataDouble ; ─ ┘
	ld de, PTile
	ld hl, vChars2 tile $72
	lb bc, BANK(PTile), 1
	call CopyVideoDataDouble ; bold P (for PP)
	ldh a, [hTileAnimations]
	push af
	xor a
	ldh [hTileAnimations], a
IF GEN_2_GRAPHICS
	hlcoord 19, 3
	lb bc, 2, 8
ELSE
	hlcoord 19, 1
	lb bc, 6, 10
ENDC
	call DrawLineBox ; Draws the box around name, HP and status
	hlcoord 2, 7
	nop
	ld [hl], '<DOT>'
	dec hl
	ld [hl], '№'
	hlcoord 10, 9
	ld de, SpeciesText
	call PlaceString
	hlcoord 10, 12
	ld de, Type1Text
	call PlaceString
	hlcoord 10, 14
	ld de, Type2Text
	call PlaceString
	hlcoord 11, 3
	predef DrawHP
	ld hl, wStatusScreenHPBarColor
	call GetHealthBarColor
	ld b, SET_PAL_STATUS_SCREEN
	call StatusScreenHook ; HAX: Draws EXP bar if GEN_2_GRAPHICS is set
	hlcoord 16, 6
	ld de, wLoadedMonStatus
	call PrintStatusCondition
	jr nz, .StatusWritten
	hlcoord 16, 6
	ld de, OKText
	call PlaceString ; "OK"
.StatusWritten
	hlcoord 9, 6
	ld de, StatusText
	call PlaceString ; "STATUS/"
	hlcoord 14, 2
	call PrintLevel
	ld a, [wMonHIndex]
	ld [wPokedexNum], a
	ld [wCurSpecies], a
	predef IndexToPokedex
	hlcoord 3, 7
	ld de, wPokedexNum
	lb bc, LEADING_ZEROES | 1, 3
	call PrintNumber ; Pokémon no.
	hlcoord 11, 13
	predef PrintMonType
	ld a, [wMonHIndex]
	ld [wNamedObjectIndex], a
	call GetMonName
; print the species name, shifted left if it is too long to fit
	ld hl, wNameBuffer
	ld b, 0
.countSpeciesName
	ld a, [hli]
	cp '@'
	jr z, .gotSpeciesNameLength
	inc b
	jr .countSpeciesName
.gotSpeciesNameLength
	ld a, b
	cp 10
	hlcoord 11, 10
	jr c, .placeSpeciesName
	hlcoord 10, 10
.placeSpeciesName
	ld de, wNameBuffer
	call PlaceString
	ld hl, NamePointers2
	call .GetStringPointer
	ld d, h
	ld e, l
	hlcoord 9, 1
	call PlaceString ; Pokémon name
	ld d, STATUS_SCREEN_STATS_BOX
	call PrintStatsBox
	call Delay3
	call GBPalNormal
	hlcoord 1, 0
	call LoadFlippedFrontSpriteByMonIndex ; draw Pokémon picture
	ld a, [wCurPartySpecies]
	call PlayCry
	call WaitForTextScrollButtonPress
	pop af
	ldh [hTileAnimations], a
	ret

.GetStringPointer
	ld a, [wMonDataLocation]
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wMonDataLocation]
	cp DAYCARE_DATA
	ret z
	ld a, [wWhichPokemon]
	jp SkipFixedLengthTextEntries

OTPointers:
	dw wPartyMonOT
	dw wEnemyMonOT
	dw wBoxMonOT
	dw wDayCareMonOT

NamePointers2:
	dw wPartyMonNicks
	dw wEnemyMonNicks
	dw wBoxMonNicks
	dw wDayCareMonName

SpeciesText:
	db "SPECIES/@"

Type1Text:
	db "TYPE1/@"

Type2Text:
	db "TYPE2/@"


StatusText:
	db "STATUS/@"

OKText:
	db "OK@"

; Draws a line starting from hl high b and wide c
DrawLineBox:
	ld de, SCREEN_WIDTH ; New line
.PrintVerticalLine
	ld [hl], $78 ; │
	add hl, de
	dec b
	jr nz, .PrintVerticalLine
	ld [hl], $77 ; ┘
	dec hl
.PrintHorizLine
	ld [hl], $76 ; ─
	dec hl
	dec c
	jr nz, .PrintHorizLine
	ld [hl], $6f ; ← (halfarrow ending)
	ret

PTile: INCBIN "gfx/font/P.1bpp"

PrintStatsBox:
	ld a, d
	ASSERT STATUS_SCREEN_STATS_BOX == 0
	and a
	jr nz, .LevelUpStatsBox ; battle or Rare Candy
	hlcoord 0, 8
	ld b, 8
	ld c, 8
	call TextBoxBorder
	hlcoord 1, 9
	ld bc, SCREEN_WIDTH + 5 ; one row down and 5 columns right
	jr .PrintStats
.LevelUpStatsBox
	hlcoord 9, 2
	ld b, 8
	ld c, 9
	call TextBoxBorder
	hlcoord 11, 3
	ld bc, SCREEN_WIDTH + 4 ; one row down and 4 columns right
.PrintStats
	push bc
	push hl
	ld de, .StatsText
	call PlaceString
	pop hl
	pop bc
	add hl, bc
	ld de, wLoadedMonAttack
	lb bc, 2, 3
	call .PrintStat
	ld de, wLoadedMonDefense
	call .PrintStat
	ld de, wLoadedMonSpeed
	call .PrintStat
	ld de, wLoadedMonSpecial
	jp PrintNumber

.PrintStat:
	push hl
	call PrintNumber
	pop hl
	ld de, SCREEN_WIDTH * 2
	add hl, de
	ret

.StatsText:
	db   "ATTACK"
	next "DEFENSE"
	next "SPEED"
	next "SPECIAL@"

StatusScreen2:
	ldh a, [hTileAnimations]
	push af
	xor a
	ldh [hTileAnimations], a
	ldh [hAutoBGTransferEnabled], a
	hlcoord 9, 2
	lb bc, 5, 10
	call ClearScreenArea ; Clear under name
IF GEN_2_GRAPHICS
	call StatusScreen2Hook
	nop
	nop
ELSE
	hlcoord 19, 3
	ld [hl], $78
ENDC
	hlcoord 12, 8
	lb bc, 10, 8
	call ClearScreenArea ; clear the old screen 1 text from the right column
	hlcoord 0, 8
	ld b, 8
	ld c, 10
	call TextBoxBorder ; Draw IV container
	hlcoord 1, 9
	ld de, IVText
	call PlaceString
; print the four IVs, right-aligned inside the box
	hlcoord 9, 10
	ld a, [wLoadedMonDVs]
	swap a
	and $f
	ld [wTempNumber], a
	ld de, wTempNumber
	lb bc, 1, 2
	call PrintNumber
	hlcoord 9, 12
	ld a, [wLoadedMonDVs]
	and $f
	ld [wTempNumber], a
	ld de, wTempNumber
	lb bc, 1, 2
	call PrintNumber
	hlcoord 9, 14
	ld a, [wLoadedMonDVs + 1]
	swap a
	and $f
	ld [wTempNumber], a
	ld de, wTempNumber
	lb bc, 1, 2
	call PrintNumber
	hlcoord 9, 16
	ld a, [wLoadedMonDVs + 1]
	and $f
	ld [wTempNumber], a
	ld de, wTempNumber
	lb bc, 1, 2
	call PrintNumber
; ID No. and OT
	hlcoord 12, 9
	ld de, IDText
	call PlaceString
	hlcoord 13, 10
	ld de, wLoadedMonOTID
	lb bc, LEADING_ZEROES | 2, 5
	call PrintNumber
	hlcoord 12, 11
	ld de, OTText
	call PlaceString
	ld hl, OTPointers
	call StatusScreen_GetNamePointer
	ld d, h
	ld e, l
	hlcoord 13, 12
	call PlaceString
	hlcoord 9, 3
	ld de, StatusScreenExpText
	call PlaceString
	ld a, [wLoadedMonLevel]
	push af
	cp MAX_LEVEL
	jr z, .Level100
	inc a
	ld [wLoadedMonLevel], a ; Increase temporarily if not 100
.Level100
	hlcoord 14, 6
	ld [hl], '<to>'
	inc hl
	inc hl
	call PrintLevel
	pop af
	ld [wLoadedMonLevel], a
	ld de, wLoadedMonExp
	hlcoord 12, 4
	lb bc, 3, 7
	call PrintNumber ; exp
	call CalcExpToLevelUp
	ld de, wLoadedMonExp
	hlcoord 7, 6
	lb bc, 3, 7
	call PrintNumber ; exp needed to level up

	; unneeded, this clears the diacritic characters in JPN versions
	hlcoord 9, 0
	call StatusScreen_ClearName

	hlcoord 9, 1
	call StatusScreen_ClearName
	ld a, [wMonHIndex]
	ld [wNamedObjectIndex], a
	call GetMonName
	hlcoord 9, 1
	call PlaceString
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	call WaitForTextScrollButtonPress
	pop af
	ldh [hTileAnimations], a
	call GBPalWhiteOut
	jp ClearScreen

; hl = pointer table for the current mon's data source
; returns the pointer to the current mon's entry in hl
StatusScreen_GetNamePointer:
	ld a, [wMonDataLocation]
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wMonDataLocation]
	cp DAYCARE_DATA
	ret z
	ld a, [wWhichPokemon]
	jp SkipFixedLengthTextEntries

IVText:
	db   "ATTACK DV"
	next "DEFENSE DV"
	next "SPEED DV"
	next "SPECIAL DV@"

IDText:
	db "<ID>№/@"

OTText:
	db "OT/@"

CalcExpToLevelUp:
	ld a, [wLoadedMonLevel]
	cp MAX_LEVEL
	jr z, .atMaxLevel
	inc a
	ld d, a
	callfar CalcExperience
	ld hl, wLoadedMonExp + 2
	ldh a, [hExperience + 2]
	sub [hl]
	ld [hld], a
	ldh a, [hExperience + 1]
	sbc [hl]
	ld [hld], a
	ldh a, [hExperience]
	sbc [hl]
	ld [hld], a
	ret
.atMaxLevel
	ld hl, wLoadedMonExp
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

StatusScreenExpText:
	db   "EXP POINTS"
	next "LEVEL UP@"

StatusScreen_ClearName:
	ld bc, NAME_LENGTH - 1
	ld a, ' '
	jp FillMemory

StatusScreen_PrintPP:
; print PP or -- c times, going down two rows each time
	ld [hli], a
	ld [hld], a
	add hl, de
	dec c
	jr nz, StatusScreen_PrintPP
	ret

StatusScreen3:
	ldh a, [hTileAnimations]
	push af
	xor a
	ldh [hTileAnimations], a
; build the move name list
	ld bc, NUM_MOVES + 1
	ld hl, wMoves
	call FillMemory
	ld hl, wLoadedMonMoves
	ld de, wMoves
	ld bc, NUM_MOVES
	call CopyData
	callfar FormatMovesString
; draw the move list
	hlcoord 0, 0
	ld b, 8
	ld c, 18
	call TextBoxBorder
	hlcoord 2, 1
	ld de, wMovesString
	call PlaceString
	call StatusScreen3_PrintPPs
; draw the description container, then the move info box over its top-left corner
	hlcoord 0, 13
	ld b, 3
	ld c, 18
	call TextBoxBorder
	hlcoord 0, 10
	ld b, 2
	ld c, 10
	call TextBoxBorder
	ld hl, wTopMenuItemY
	ld a, 1
	ld [hli], a ; wTopMenuItemY
	ld a, 1
	ld [hli], a ; wTopMenuItemX
	xor a
	ld [hli], a ; wCurrentMenuItem
	inc hl
	ld a, [wNumMovesMinusOne]
	ld [hli], a ; wMaxMenuItem
	ld a, PAD_A | PAD_B | PAD_DOWN | PAD_UP
	ld [hli], a ; wMenuWatchedKeys
	ld [hl], 0 ; wLastMenuItem
	ld hl, hUILayoutFlags
	res BIT_DOUBLE_SPACED_MENU, [hl]
	call GBPalNormal
.menuLoop
	call StatusScreen3_PrintMoveInfo
	call HandleMenuInput
	push af
	call PlaceMenuCursor
	pop af
	bit B_PAD_A, a
	jr nz, .done
	bit B_PAD_B, a
	jr nz, .done
	jr .menuLoop
.done
	pop af
	ldh [hTileAnimations], a
	ld hl, wStatusFlags2
	res BIT_NO_AUDIO_FADE_OUT, [hl]
	ld a, $77
	ldh [rAUDVOL], a
	call GBPalWhiteOut
	jp ClearScreen

; prints the PP of every known move in the move list
StatusScreen3_PrintPPs:
	ld hl, wLoadedMonMoves
	decoord 14, 2
	ld b, 0
.PrintPP
	ld a, [hli]
	and a
	ret z
	push bc
	push hl
	push de
; print "PP" to the left of the numbers
	ld h, d
	ld l, e
	ld bc, -3
	add hl, bc
	ld de, .PPText
	call PlaceString
	pop de
	pop hl
	pop bc
	push bc
	push hl
	push de
	ld hl, wCurrentMenuItem
	ld a, [hl]
	push af
	ld a, b
	ld [hl], a
	push hl
	callfar GetMaxPP
	pop hl
	pop af
	ld [hl], a
	pop de
	pop hl
	push hl
	ld bc, MON_PP - MON_MOVES - 1
	add hl, bc
	ld a, [hl]
	and PP_MASK
	ld [wStatusScreenCurrentPP], a
	ld h, d
	ld l, e
	push hl
	ld de, wStatusScreenCurrentPP
	lb bc, 1, 2
	call PrintNumber
	ld a, '/'
	ld [hli], a
	ld de, wMaxPP
	lb bc, 1, 2
	call PrintNumber
	pop hl
	ld de, SCREEN_WIDTH * 2
	add hl, de
	ld d, h
	ld e, l
	pop hl
	pop bc
	inc b
	ld a, b
	cp NUM_MOVES
	jr nz, .PrintPP
	ret
.PPText:
	db "<BOLD_P><BOLD_P> @"

; prints the highlighted move's type, power, accuracy and description
StatusScreen3_PrintMoveInfo:
	hlcoord 1, 11
	ld b, 2
	ld c, 10
	call ClearScreenArea
	ld hl, wLoadedMonMoves
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wMoveNum], a
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld de, wPlayerMoveNum
	ld bc, MOVE_LENGTH
	ld a, BANK(Moves)
	call FarCopyData
	hlcoord 2, 11
	predef PrintMoveType
	hlcoord 2, 12
	ld de, wPlayerMovePower
	lb bc, 1, 3
	call PrintNumber
	hlcoord 5, 12
	ld [hl], '/'
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand + 1], a
	ld a, [wPlayerMoveAccuracy]
	ldh [hMultiplicand + 2], a
	ld a, 100
	ldh [hMultiplier], a
	call Multiply
	ldh a, [hProduct + 2]
	inc a ; accuracies are slightly off in gen 1
	ld [wTempNumber], a
	hlcoord 7, 12
	ld de, wTempNumber
	lb bc, 1, 3
	call PrintNumber
	hlcoord 10, 12
	ld [hl], 223 ; percent sign
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	farcall PrintMoveDescription
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
; redraw the borders that PrintMoveDescription erases
	hlcoord 1, 13
	ld a, '─'
	ld b, 10
.restoreMoveInfoBorder
	ld [hli], a
	dec b
	jr nz, .restoreMoveInfoBorder
	ld [hl], '┘' ; right edge of the move info box
	inc hl
	ld b, 7
.restoreDescriptionBorder
	ld [hli], a
	dec b
	jr nz, .restoreDescriptionBorder
	ret
