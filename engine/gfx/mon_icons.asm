AnimatePartyMon_ForceSpeed1:
; Animate the icon in the first party slot. Used by the naming screen, where
; there is no party menu cursor and no health bar to pick a speed from.
	xor a
	ld [wCurrentMenuItem], a
	ld b, a
	inc a
	jr GetAnimationSpeed

AnimatePartyMon::
; Animate the icon of the mon the party menu cursor is on. The speed depends on
; that mon's health: wPartyMenuHPBarColors is 0 for green, 1 yellow, 2 red.
	ld hl, wPartyMenuHPBarColors
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]

GetAnimationSpeed:
	ld c, a
	ld hl, PartyMonSpeeds
	add hl, bc
	ld a, [wOnSGB]
	xor $1
	add [hl]
	ld c, a
	add a
	ld b, a
	ld a, [wAnimCounter]
	and a
	jr z, .resetSprites
	cp c
	jr z, .animateSprite
.incTimer
	inc a
	cp b
	jr nz, .skipResetTimer
	xor a ; reset timer
.skipResetTimer
	ld [wAnimCounter], a
	jp DelayFrame

.resetSprites
	push bc
	ld hl, wMonPartySpritesSavedOAM
	ld de, wShadowOAM
	ld bc, OBJ_SIZE * 4 * PARTY_LENGTH
	call CopyData
	pop bc
	xor a
	jr .incTimer

.animateSprite
; Switch the selected mon's icon to its second animation frame, which is loaded
; MON_ICON_TILES tiles after the first.
	push bc
	ld hl, wShadowOAMSprite00TileID
	ld bc, OBJ_SIZE * 4
	ld a, [wCurrentMenuItem]
	call AddNTimes
	ld c, MON_ICON_TILES ; frame offset
	ld b, 4 ; OAM sprites per icon
	ld de, OBJ_SIZE
.loop
	ld a, [hl]
	add c
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	pop bc
	ld a, c
	jr .incTimer

; Party mon animations cycle between 2 frames.
; The members of the PartyMonSpeeds array specify the number of V-blanks
; that each frame lasts for green HP, yellow HP, and red HP in order.
; On the naming screen, the yellow HP speed is always used.
PartyMonSpeeds:
	db 5, 16, 32

LoadPartyMonIcons:
; Load both animation frames of every party mon's icon into its own VRAM slot:
; MON_ICON_SLOT_TILES tiles at vSprites tile [party slot * MON_ICON_SLOT_TILES].
; Must be called whenever the party order may have changed, since the tile
; slots follow the party position rather than the species.
	ld hl, wPartySpecies
	ld c, 0 ; VRAM tile for the current slot's icon
.loop
	ld a, [hli]
	cp $ff ; reached the terminator?
	ret z
	push hl
	push bc
	call LoadMonIconGfx
	pop bc
	pop hl
	ld a, c
	add MON_ICON_SLOT_TILES
	ld c, a
	jr .loop

LoadMonIconGfx:
; Load both animation frames of the icon for species a into tile c.
	ld l, c
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ; hl = c * TILE_SIZE
	push hl ; save the VRAM offset
	call GetMonIconID
	ld e, a
	ld d, 0
	ld hl, MonIconTable
	add hl, de
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = icon graphics
	ld b, [hl] ; b = icon graphics bank
	pop hl
	ld a, h
	add HIGH(vSprites)
	ld h, a
	ld c, MON_ICON_SLOT_TILES
	jp CopyVideoData

GetMonIconID:
; a = species -> a = party menu icon (index into MonIconTable)
	ld [wPokedexNum], a
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld hl, MonPartyData
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	ret

LoadTradeBubbleGfx:
; Load the graphic that circles the mon shown during a trade animation.
; Both animation frames are loaded: the trade animation alternates between
; them by adding MON_ICON_TILES to the sprites' tile IDs (see Trade_AnimCircledMon).
	ld de, TradeBubbleIconGFX
	ld b, BANK(TradeBubbleIconGFX)
	ld hl, vSprites tile TRADE_BUBBLE_TILE
	ld c, MON_ICON_SLOT_TILES
	jp CopyVideoData

WriteMonPartySpriteOAMByPartyIndex:
; Write the OAM blocks for the party mon in [hPartyMonIndex].
	jp WriteMonPartySpriteOAM

WriteMonPartySpriteOAMBySpecies:
; Load the icon of [wMonPartySpriteSpecies] into the first VRAM slot and write
; its OAM blocks.
	xor a
	ldh [hPartyMonIndex], a
	ld a, [wMonPartySpriteSpecies]
	ld c, 0
	call LoadMonIconGfx
	; fall through

WriteMonPartySpriteOAM:
; Write the 4 OAM blocks for the party mon in [hPartyMonIndex]. Its icon must
; already be loaded at vSprites tile [hPartyMonIndex * MON_ICON_SLOT_TILES].
	ldh a, [hPartyMonIndex]
	add a
	add a
	add a ; * MON_ICON_SLOT_TILES
	ASSERT MON_ICON_SLOT_TILES == 8
	ld [wOAMBaseTile], a
	ld c, $10 ; x coord
	ld h, HIGH(wShadowOAM)
	ldh a, [hPartyMonIndex]
	swap a
	ld l, a ; OAM offset
	add $10
	ld b, a ; y coord
; Gen 2 icons are asymmetric, so all 4 of their tile patterns are needed.
	call WriteAsymmetricMonPartySpriteOAM
; Make a copy of the OAM buffer with the first animation frame written; the
; animation restores from it instead of tracking the second frame.
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, OBJ_SIZE * 4 * PARTY_LENGTH
	jp CopyData

LoadAnimSpriteGfx:
; Load animated sprite tile patterns into VRAM during V-blank. hl is the address
; of an array of structures that contain arguments for CopyVideoData and a is
; the number of structures in the array.
	ld bc, $0
.loop
	push af
	push bc
	push hl
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CopyVideoData
	pop hl
	pop bc
	ld a, $6
	add c
	ld c, a
	pop af
	dec a
	jr nz, .loop
	ret

INCLUDE "data/icon_pointers.asm"

INCLUDE "data/pokemon/menu_icons.asm"

TradeBubbleIconGFX: INCBIN "gfx/trade/bubble.2bpp"
