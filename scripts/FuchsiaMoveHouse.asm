FuchsiaMoveHouse_Script:
	jp EnableAutoTextBoxDrawing

FuchsiaMoveHouse_TextPointers:
	def_text_pointers
	dw_const FuchsiaMoveHouseMoveDeleterText,   TEXT_FUCHSIAMOVEHOUSE_MOVE_DELETER
	dw_const FuchsiaMoveHouseMoveRelearnerText, TEXT_FUCHSIAMOVEHOUSE_MOVE_RELEARNER

FuchsiaMoveHouseMoveDeleterText:
	text_asm
	call SaveScreenTilesToBuffer2
	ld hl, .IntroText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .comeBack
	xor a
	ld [wUpdateSpritesEnabled], a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	jr c, .partyMenuCanceled
; preserve the selection across the screen restore
	ld a, [wWhichPokemon]
	ld [wItemList], a
	ld a, [wCurPartySpecies]
	ld [wItemList + 1], a
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	ld a, [wItemList]
	ld [wWhichPokemon], a
	ld a, [wItemList + 1]
	ld [wCurPartySpecies], a
	jr .partyMenuChosen

.partyMenuCanceled
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	jp .comeBack

.partyMenuChosen

; build a list of the selected mon's moves
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld de, wItemList
	xor a
	ld [de], a
	inc de
	ld b, NUM_MOVES
.copyMovesLoop
	ld a, [hli]
	and a
	jr z, .nextMove
	ld [de], a
	inc de
	ld a, [wItemList]
	inc a
	ld [wItemList], a
.nextMove
	dec b
	jr nz, .copyMovesLoop
	ld a, $ff
	ld [de], a

	ld a, [wItemList]
	and a
	jp z, .noMoves
	cp 1
	jp z, .lastMove

; save the mon's name for the message
	ld hl, wPartyMonNicks
	ld a, [wWhichPokemon]
	call GetPartyMonName
	ld hl, wNameBuffer
	ld de, wLearnMoveMonName
	ld bc, NAME_LENGTH
	call CopyData

	ld hl, .WhichMoveText
	call PrintText

; show the move list
	ld hl, wItemList
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	xor a
	ld [wPrintItemPrices], a
	ld [wCurrentMenuItem], a
	ld [wListScrollOffset], a
	ld [wMenuItemToSwap], a
	ld a, MOVESLISTMENU
	ld [wListMenuID], a
; hide the overworld sprites so they don't draw over the list
	xor a
	ld [wUpdateSpritesEnabled], a
	call ClearSprites
	ld a, [wWhichPokemon]
	ld [wItemList + 26], a
	call DisplayListMenuID
	ld a, [wWhichPokemon] ; chosen entry index
	jp c, .cancelMove
	ld [wItemList + 24], a
	ld a, [wItemList + 26]
	ld [wWhichPokemon], a
	ld a, [wCurItem]
	ld [wItemList + 25], a

; restore the screen and ask for confirmation
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	ld a, [wItemList + 25]
	ld [wNamedObjectIndex], a
	call GetMoveName
	ld hl, .ConfirmText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .comeBack
	ld a, 1
	ldh [rWBK], a

; refresh the names for the message
	ld hl, wPartyMonNicks
	ld a, [wWhichPokemon]
	call GetPartyMonName
	ld hl, wNameBuffer
	ld de, wLearnMoveMonName
	ld bc, NAME_LENGTH
	call CopyData
	ld a, [wItemList + 25]
	ld [wNamedObjectIndex], a
	call GetMoveName
	ld a, [wItemList + 24]
	ld b, a

; delete the move at index b, shifting the following moves and PP down
	push bc
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	pop bc
	ld c, b
	ld b, 0
	add hl, bc
	ld d, h
	ld e, l
	ld a, MON_PP - MON_MOVES
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	ld b, c
	ld a, b
	cp NUM_MOVES - 1
	jr z, .clearLastMove
.shiftMovesLoop
	inc hl
	inc de
	ld a, [hl]
	push af
	ld a, [de]
	ld c, a
	pop af
	dec hl
	dec de
	ld [hli], a
	ld a, c
	ld [de], a
	inc de
	inc b
	ld a, b
	cp NUM_MOVES - 1
	jr nz, .shiftMovesLoop
.clearLastMove
	xor a
	ld [hl], a
	ld [de], a

	ld hl, .ForgotText
	call PrintText
	ld hl, .ClosingText
	call PrintText
	jp TextScriptEnd

.cancelMove
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	ld hl, .ComeBackText
	call PrintText
	jp TextScriptEnd

.comeBack
	ld hl, .ComeBackText
	call PrintText
	jp TextScriptEnd

.noMoves
	ld hl, .NoMovesText
	call PrintText
	jp TextScriptEnd

.lastMove
	ld hl, .LastMoveText
	call PrintText
	jp TextScriptEnd

.IntroText:
	text_far _FuchsiaMoveHouseMoveDeleterIntroText
	text_end

.WhichMoveText:
	text_far _FuchsiaMoveHouseMoveDeleterWhichMoveText
	text_end

.ConfirmText:
	text_far _FuchsiaMoveHouseMoveDeleterConfirmText
	text_end

.ForgotText:
	text_far _FuchsiaMoveHouseMoveDeleterForgotText
	text_end

.ClosingText:
	text_far _FuchsiaMoveHouseMoveDeleterClosingText
	text_end

.NoMovesText:
	text_far _FuchsiaMoveHouseMoveDeleterNoMovesText
	text_end

.ComeBackText:
	text_far _FuchsiaMoveHouseMoveDeleterComeBackText
	text_end

.LastMoveText:
	text_far _FuchsiaMoveHouseMoveDeleterLastMoveText
	text_end

FuchsiaMoveHouseMoveRelearnerText:
	text_asm
	call SaveScreenTilesToBuffer2
	ld hl, .IntroText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .comeBack
	xor a
	ld [wUpdateSpritesEnabled], a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	jr c, .partyMenuCanceled
; preserve the selection across the screen restore
	ld a, [wWhichPokemon]
	ld [wItemList], a
	ld a, [wCurPartySpecies]
	ld [wItemList + 1], a
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	ld a, [wItemList]
	ld [wWhichPokemon], a
	ld a, [wItemList + 1]
	ld [wCurPartySpecies], a
	jr .partyMenuChosen

.partyMenuCanceled
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	jp .comeBack

.partyMenuChosen

	farcall BuildRelearnMoveList
	ld a, [wItemList]
	and a
	jp z, .noMoves

	ld hl, .WhichMoveText
	call PrintText

; show the list of moves the mon can relearn
	ld hl, wItemList
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	xor a
	ld [wPrintItemPrices], a
	ld [wCurrentMenuItem], a
	ld [wListScrollOffset], a
	ld [wMenuItemToSwap], a
	ld a, MOVESLISTMENU
	ld [wListMenuID], a
; hide the overworld sprites so they don't draw over the list
	xor a
	ld [wUpdateSpritesEnabled], a
	call ClearSprites
	ld a, [wWhichPokemon]
	ld [wItemList + 26], a
	call DisplayListMenuID
	jr c, .cancelList
	ld a, [wItemList + 26]
	ld [wWhichPokemon], a
	ld a, [wCurItem]
	ld [wMoveNum], a

	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
; hide the overworld sprites so they don't draw over LearnMove's menus
	xor a
	ld [wUpdateSpritesEnabled], a
	call ClearSprites
	predef LearnMove
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	jp TextScriptEnd

.cancelList
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	ld a, 1
	ldh [rWBK], a
	ld hl, .ComeBackText
	call PrintText
	jp TextScriptEnd

.comeBack
	ld hl, .ComeBackText
	call PrintText
	jp TextScriptEnd

.noMoves
	ld hl, .NoMovesText
	call PrintText
	jp TextScriptEnd

.IntroText:
	text_far _FuchsiaMoveHouseMoveRelearnerIntroText
	text_end

.WhichMoveText:
	text_far _FuchsiaMoveHouseMoveRelearnerWhichMoveText
	text_end

.NoMovesText:
	text_far _FuchsiaMoveHouseMoveRelearnerNoMovesText
	text_end

.ComeBackText:
	text_far _FuchsiaMoveHouseMoveRelearnerComeBackText
	text_end
