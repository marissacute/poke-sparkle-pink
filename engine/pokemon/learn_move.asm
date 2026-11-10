LearnMove:
	call SaveScreenTilesToBuffer1
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, wNameBuffer
	ld de, wLearnMoveMonName
	ld bc, NAME_LENGTH
	call CopyData

DontAbandonLearning:
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
.findEmptyMoveSlotLoop
	ld a, [hl]
	and a
	jr z, .next
	inc hl
	dec b
	jr nz, .findEmptyMoveSlotLoop
	push de
	call TryingToLearn
	pop de
	jp c, AbandonLearning
	push hl
	push de
	ld [wNamedObjectIndex], a
	call GetMoveName
	ld hl, OneTwoAndText
	call PrintText
	pop de
	pop hl
.next
	ld a, [wMoveNum]
	ld [hl], a
	ld bc, MON_PP - MON_MOVES
	add hl, bc
	push hl
	push de
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld de, wBuffer
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wBuffer + 5] ; a = move's max PP
	pop de
	pop hl
	ld [hl], a
	ld a, [wIsInBattle]
	and a
	jp z, PrintLearnedMove
	ld a, [wWhichPokemon]
	ld b, a
	ld a, [wPlayerMonNumber]
	cp b
	jp nz, PrintLearnedMove
	ld h, d
	ld l, e
	ld de, wBattleMonMoves
	ld bc, NUM_MOVES
	call CopyData
	ld bc, MON_PP - MON_OTID
	add hl, bc
	ld de, wBattleMonPP
	ld bc, NUM_MOVES
	call CopyData
	jp PrintLearnedMove

AbandonLearning:
	ld hl, AbandonLearningText
	call PrintText
	hlcoord 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID ; yes/no menu
	ld a, [wCurrentMenuItem]
	and a
	jp nz, DontAbandonLearning
	ld hl, DidNotLearnText
	call PrintText
	ld b, 0
	ret

PrintLearnedMove:
	ld hl, LearnedMove1Text
	call PrintText
	ld b, 1
	ret

TryingToLearn:
	push hl
	ld hl, TryingToLearnText
	call PrintText
	hlcoord 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID ; yes/no menu
	pop hl
	ld a, [wCurrentMenuItem]
	rra
	ret c
	ld bc, -NUM_MOVES
	add hl, bc
	push hl
	ld de, wMoves
	ld bc, NUM_MOVES
	call CopyData
	callfar FormatMovesString
	pop hl
	ld a, [wMoveNum]
	ld [wSavedMoveNum], a
; save the sprites so they can be put back when leaving this menu
	push hl ; save the pointer to the mon's moves
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, OBJ_SIZE * 4 * PARTY_LENGTH
	call CopyData
; start from a blank screen with no sprites
	ld a, [wUpdateSpritesEnabled]
	ld [wSavedUpdateSprites], a
	xor a
	ld [wUpdateSpritesEnabled], a
	call ClearSprites
	call ClearScreen
	pop hl
.loop
	push hl
; draw the move list, with the new move at the bottom
	hlcoord 0, 0
	ld b, 5
	ld c, 18
	call TextBoxBorder
; draw the move names without letter delays
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	hlcoord 2, 1
	ld de, wMovesString
	ldh a, [hUILayoutFlags]
	set BIT_SINGLE_SPACED_LINES, a
	ldh [hUILayoutFlags], a
	call PlaceString
	ldh a, [hUILayoutFlags]
	res BIT_SINGLE_SPACED_LINES, a
	ldh [hUILayoutFlags], a
	call PrintNewMoveListEntry
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
; draw the box that shows the highlighted move's stats
	hlcoord 0, 7
	ld b, 3
	ld c, 9
	call TextBoxBorder
; draw the box that shows the highlighted move's description
	ld a, MESSAGE_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld hl, wTopMenuItemY
	ld a, 1
	ld [hli], a ; wTopMenuItemY
	ld a, 1
	ld [hli], a ; wTopMenuItemX
	xor a
	ld [hli], a ; wCurrentMenuItem
	inc hl
	ld a, NUM_MOVES ; the new move is the last menu item
	ld [hli], a ; wMaxMenuItem
	ld a, PAD_A | PAD_B | PAD_DOWN | PAD_UP
	ld [hli], a ; wMenuWatchedKeys
	ld [hl], 0 ; wLastMenuItem
	ld hl, hUILayoutFlags
	set BIT_DOUBLE_SPACED_MENU, [hl]
.menuLoop
	call PrintLearnMoveInfoNoDelay
	call HandleMenuInput
	push af
	call PlaceMenuCursor
	pop af
	bit B_PAD_A, a
	jr nz, .choseMove
	bit B_PAD_B, a
	jr nz, .choseMove
	jp .menuLoop ; the cursor moved, so show the new move's info
.choseMove
	ld hl, hUILayoutFlags
	res BIT_DOUBLE_SPACED_MENU, [hl]
	pop hl
	bit B_PAD_B, a
	jr nz, .cancel
	ld a, [wCurrentMenuItem]
	cp NUM_MOVES
	jr z, .cancel ; choosing the new move means not forgetting a move
	push hl
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	push af
	push bc
	call IsMoveHM
	pop bc
	pop de
	ld a, d
	jr c, .hm
	pop hl
	add hl, bc
	push hl
	push af
	call .leaveMenu
	pop af
	pop hl
	and a
	ret
.hm
	ld hl, HMCantDeleteText
	call PrintText
	pop hl
	jp .loop
.cancel
	call .leaveMenu
	scf
	ret
.leaveMenu
	push af
	call LoadScreenTilesFromBuffer1
; put back the sprites that were on screen before the menu
	ld hl, wMonPartySpritesSavedOAM
	ld de, wShadowOAM
	ld bc, OBJ_SIZE * 4 * PARTY_LENGTH
	call CopyData
	ld a, [wSavedUpdateSprites]
	ld [wUpdateSpritesEnabled], a
	pop af
	ret

; loads the data of move a into wPlayerMoveNum through wPlayerMoveMaxPP
LoadMoveForLearnMenu:
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld de, wPlayerMoveNum
	ld bc, MOVE_LENGTH
	ld a, BANK(Moves)
	call FarCopyData
	ret

; draws the list entry for the move being learned, tagged as new
PrintNewMoveListEntry:
	ld a, [wSavedMoveNum]
	ld [wNamedObjectIndex], a
	call GetMoveName
	hlcoord 2, 5
	call PlaceString
; bc is the tile just after the name
	ld a, c
	sub LOW(wTileMap + 5 * SCREEN_WIDTH)
	cp 14 ; does the name leave room for a space before "(new)"?
	ld de, .NoSpaceText
	jr nc, .placeSuffix
	ld de, .WithSpaceText
.placeSuffix
	ld h, b
	ld l, c
	jp PlaceString
.WithSpaceText:
	db " (new)@"
.NoSpaceText:
	db "(new)@"

; prints the highlighted move's info box and description without letter delays
PrintLearnMoveInfoNoDelay:
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	call PrintLearnMoveInfo
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ret

PrintLearnMoveInfo:
	hlcoord 1, 8
	ld b, 3
	ld c, 9
	call ClearScreenArea
	ld a, [wCurrentMenuItem]
	cp NUM_MOVES
	jr z, .newMove
; an existing move
	ld hl, wMoves
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	call LoadMoveForLearnMenu
; current PP
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld bc, MON_PP - MON_MOVES
	add hl, bc
	ld a, [hl]
	and PP_MASK
	ld [wTempNumber], a
; max PP
	xor a
	ld [wMonDataLocation], a ; PLAYER_PARTY_DATA
	callfar GetMaxPP
	jr .drawInfo
.newMove
	ld a, [wSavedMoveNum]
	call LoadMoveForLearnMenu
	ld a, [wPlayerMoveMaxPP]
	ld [wTempNumber], a ; the new move has full PP
	ld [wMaxPP], a
.drawInfo
; type
	hlcoord 1, 8
	predef PrintMoveType
; power
	hlcoord 1, 9
	ld de, wPlayerMovePower
	lb bc, 1, 3
	call PrintNumber
; slash between power and accuracy
	hlcoord 4, 9
	ld [hl], '/'
; PP:
	hlcoord 1, 10
	ld de, .PPText
	call PlaceString
; current PP
	hlcoord 5, 10
	ld de, wTempNumber
	lb bc, 1, 2
	call PrintNumber
; slash between current and max PP
	hlcoord 7, 10
	ld [hl], '/'
; max PP
	hlcoord 8, 10
	ld de, wMaxPP
	lb bc, 1, 2
	call PrintNumber
; accuracy
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
	hlcoord 6, 9
	ld de, wTempNumber
	lb bc, 1, 3
	call PrintNumber
; percent sign
	hlcoord 9, 9
	ld [hl], 223
; description
	ld a, [wCurrentMenuItem]
	cp NUM_MOVES
	jr z, .newMoveDescription
	ld hl, wMoves
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	jr .gotDescription
.newMoveDescription
	ld a, [wSavedMoveNum]
.gotDescription
	ld [wMoveNum], a
	farcall PrintMoveDescription
	ld a, [wSavedMoveNum]
	ld [wMoveNum], a
	ret
.PPText:
	db "PP:@"

LearnedMove1Text:
	text_far _LearnedMove1Text
	sound_get_item_1 ; plays SFX_GET_ITEM_1 in the party menu (rare candy) and plays SFX_LEVEL_UP in battle
	text_promptbutton
	text_end

WhichMoveToForgetText:
	text_far _WhichMoveToForgetText
	text_end

AbandonLearningText:
	text_far _AbandonLearningText
	text_end

DidNotLearnText:
	text_far _DidNotLearnText
	text_end

TryingToLearnText:
	text_far _TryingToLearnText
	text_end

OneTwoAndText:
	text_far _OneTwoAndText
	text_pause
	text_asm
	ld a, SFX_SWAP
	call PlaySoundWaitForCurrent
	ld hl, PoofText
	ret

PoofText:
	text_far _PoofText
	text_pause
ForgotAndText:
	text_far _ForgotAndText
	text_end

HMCantDeleteText:
	text_far _HMCantDeleteText
	text_end
