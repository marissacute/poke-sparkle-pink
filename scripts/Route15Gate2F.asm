Route15Gate2F_Script:
	jp DisableAutoTextBoxDrawing

Route15Gate2F_TextPointers:
	def_text_pointers
	dw_const Route15Gate2FOaksAideText,   TEXT_ROUTE15GATE2F_OAKS_AIDE
	dw_const Route15Gate2FBinocularsText, TEXT_ROUTE15GATE2F_BINOCULARS

Route15Gate2FOaksAideText:
	text_asm
	CheckEvent EVENT_GOT_ROUTE15_STARTER
	jp nz, .afterGift

	ld hl, .IntroText
	call PrintText

; as before, the aide wants the player to have caught 50 kinds of #MON
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	ldh [hOaksAideNumMonsOwned], a
	cp 50
	jp c, .notEnoughMons

	ld hl, .ExperiencedText
	call PrintText

.askWhichOne
	ld hl, .WhichOneText
	call PrintText

.chooseMon
; draw the menu of the three starters
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld a, PAD_A | PAD_B
	ld [wMenuWatchedKeys], a
	ld a, 2
	ld [wMaxMenuItem], a
	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
	hlcoord 0, 0
	ld b, 6
	ld c, 12
	call TextBoxBorder
	call UpdateSprites
	call .PrintStarterMenu
	call HandleMenuInput
	bit B_PAD_B, a
	jr nz, .comeBack

; the menu cursor indexes the list of starters
	ld a, [wCurrentMenuItem]
	ld hl, .StarterList
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld [wNamedObjectIndex], a

	ld hl, .WantBulbasaurText
	cp BULBASAUR
	jr z, .confirm
	ld hl, .WantCharmanderText
	cp CHARMANDER
	jr z, .confirm
	ld hl, .WantSquirtleText
.confirm
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .askWhichOne ; said no, so ask which one they want again

	ld a, [wCurPartySpecies]
	ld b, a
	ld c, 5
	call GivePokemon
	jr nc, .done ; both the party and the current box are full
	SetEvent EVENT_GOT_ROUTE15_STARTER
.done
	jp TextScriptEnd

.comeBack
	ld hl, .ComeBackText
	call PrintText
	jp TextScriptEnd

.notEnoughMons
	ld a, 50
	ldh [hOaksAideRequirement], a
	ld hl, .NotEnoughMonsText
	call PrintText
	jp TextScriptEnd

.afterGift
	ld hl, .AfterGiftText
	call PrintText
	jp TextScriptEnd

; print the name of each starter, one every other row of the menu
.PrintStarterMenu
	ld a, BULBASAUR
	ld [wNamedObjectIndex], a
	call GetMonName
	ld de, wNameBuffer
	hlcoord 2, 2
	call PlaceString

	ld a, CHARMANDER
	ld [wNamedObjectIndex], a
	call GetMonName
	ld de, wNameBuffer
	hlcoord 2, 4
	call PlaceString

	ld a, SQUIRTLE
	ld [wNamedObjectIndex], a
	call GetMonName
	ld de, wNameBuffer
	hlcoord 2, 6
	call PlaceString
	ret

.StarterList
	db BULBASAUR
	db CHARMANDER
	db SQUIRTLE

.IntroText:
	text_far _Route15Gate2FOaksAideIntroText
	text_end

.ExperiencedText:
    text_far _Route15Gate2FOaksAideExperiencedText
	text_end

.WhichOneText:
	text_far _Route15Gate2FOaksAideWhichOneText
	text_end

.WantBulbasaurText:
	text_far _Route15Gate2FOaksAideWantBulbasaurText
	text_end

.WantCharmanderText:
	text_far _Route15Gate2FOaksAideWantCharmanderText
	text_end

.WantSquirtleText:
	text_far _Route15Gate2FOaksAideWantSquirtleText
	text_end

.NotEnoughMonsText:
	text_far _Route15Gate2FOaksAideNotEnoughMonsText
	text_end

.ComeBackText:
	text_far _Route15Gate2FOaksAideComeBackText
	text_end

.AfterGiftText:
	text_far _Route15Gate2FOaksAideAfterGiftText
	text_end

Route15Gate2FBinocularsText:
	text_asm
	ld hl, .Text
	jp GateUpstairsScript_PrintIfFacingUp

.Text:
	text_far _Route15Gate2FBinocularsText
	text_end
