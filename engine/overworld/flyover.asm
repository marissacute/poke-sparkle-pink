; Real-map Fly cutscene.
;
; The 36 outdoor maps are stitched at build time by tools/gen_flyover_map.py
; into a 174x180 global block map, split over two ROM banks.  During the
; cutscene the stock overworld camera pans over that map: AdvancePlayerSprite
; performs one 16-pixel step per frame, while a patched LoadCurrentMapView
; builds wTileMap from the global map instead of wOverworldMap.  The bird is
; four manual OAM entries held at (bird - camera).
;
; Block IDs use bit 7 to select the PLATEAU blockset.

DEF FLYOVER_SCREEN_CENTER_X EQU 80
DEF FLYOVER_SCREEN_CENTER_Y EQU 72

SECTION "Flyover Map 1", ROMX
FlyoverMapPart1:: INCBIN "gfx/flyover/kanto_blocks_1.bin"

SECTION "Flyover Map 2", ROMX
FlyoverMapPart2:: INCBIN "gfx/flyover/kanto_blocks_2.bin"

SECTION "Flyover WRAM", WRAM0
wFlyoverCamX:: dw
wFlyoverCamY:: dw
wFlyoverBirdX:: dw
wFlyoverBirdY:: dw
wFlyoverEndX:: dw
wFlyoverEndY:: dw
wFlyoverDX:: dw
wFlyoverDY:: dw
wFlyoverErr:: dw
wFlyoverSX:: db
wFlyoverSY:: db
wFlyoverTick:: db
wFlyoverGrace:: db
wFlyoverBaseX:: db
wFlyoverBaseY:: db
wFlyoverIndex:: db
wFlyoverTmp:: db
wFlyoverBlockTiles:: ds 16


SECTION "Flyover Code", ROMX

INCLUDE "data/flyover/tables.asm"


; Entry point, called from LeaveMapAnim in bank 0 when BIT_USED_FLY is set.
FlyoverCutscene::
	; --- validate the origin map ---
	ld a, [wCurMap]
	cp $25
	jp nc, .fallback
	ld hl, FlyoverMapOrigins
	ld bc, 5
	call AddNTimes
	ld a, [hli]
	and a
	jp z, .fallback
	; keep the origin pixel in EndX/EndY until the real destination is read
	ld a, [hli]
	ld [wFlyoverEndX], a
	ld a, [hli]
	ld [wFlyoverEndX + 1], a
	ld a, [hli]
	ld [wFlyoverEndY], a
	ld a, [hl]
	ld [wFlyoverEndY + 1], a

	; start = origin + player coordinates * 16 + 8
	ld a, [wXCoord]
	call FlyoverTimes16
	ld a, [wFlyoverEndX]
	ld c, a
	ld a, [wFlyoverEndX + 1]
	ld b, a
	add hl, bc
	ld bc, 8
	add hl, bc
	ld a, l
	ld [wFlyoverBirdX], a
	ld a, h
	ld [wFlyoverBirdX + 1], a

	ld a, [wYCoord]
	call FlyoverTimes16
	ld a, [wFlyoverEndY]
	ld c, a
	ld a, [wFlyoverEndY + 1]
	ld b, a
	add hl, bc
	ld bc, 8
	add hl, bc
	ld a, l
	ld [wFlyoverBirdY], a
	ld a, h
	ld [wFlyoverBirdY + 1], a

	; --- destination ---
	ld a, [wDestinationMap]
	cp NUM_CITY_MAPS
	jp nc, .fallback
	ld hl, FlyoverDestCoords
	ld bc, 4
	call AddNTimes
	ld a, [hli]
	ld [wFlyoverEndX], a
	ld a, [hli]
	ld [wFlyoverEndX + 1], a
	ld a, [hli]
	ld [wFlyoverEndY], a
	ld a, [hl]
	ld [wFlyoverEndY + 1], a

	; --- line deltas in 16-pixel steps ---
	; X
	ld a, [wFlyoverEndX]
	ld l, a
	ld a, [wFlyoverEndX + 1]
	ld h, a
	ld a, [wFlyoverBirdX]
	ld e, a
	ld a, [wFlyoverBirdX + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	jr c, .xNegative
	ld a, 1
	ld [wFlyoverSX], a
	jr .xAbs
.xNegative
	ld a, -1
	ld [wFlyoverSX], a
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
.xAbs
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	ld [wFlyoverDX], a
	ld a, h
	ld [wFlyoverDX + 1], a

	; Y
	ld a, [wFlyoverEndY]
	ld l, a
	ld a, [wFlyoverEndY + 1]
	ld h, a
	ld a, [wFlyoverBirdY]
	ld e, a
	ld a, [wFlyoverBirdY + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	jr c, .yNegative
	ld a, 1
	ld [wFlyoverSY], a
	jr .yAbs
.yNegative
	ld a, -1
	ld [wFlyoverSY], a
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
.yAbs
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	ld [wFlyoverDY], a
	ld a, h
	ld [wFlyoverDY + 1], a

	; err = dx - dy
	ld a, [wFlyoverDX]
	ld l, a
	ld a, [wFlyoverDX + 1]
	ld h, a
	ld a, [wFlyoverDY]
	ld e, a
	ld a, [wFlyoverDY + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, l
	ld [wFlyoverErr], a
	ld a, h
	ld [wFlyoverErr + 1], a

	xor a
	ld [wFlyoverTick], a
	ld a, 30
	ld [wFlyoverGrace], a

	; --- initial camera: centred on the bird, 16-pixel aligned, clamped ---
	ld a, [wFlyoverBirdX]
	ld l, a
	ld a, [wFlyoverBirdX + 1]
	ld h, a
	ld de, -FLYOVER_SCREEN_CENTER_X
	add hl, de
	bit 7, h
	jr z, .camXPositive
	ld hl, 0
.camXPositive
	ld de, FLYOVER_MAP_WIDTH_PX - SCREEN_WIDTH_PX
	call FlyoverClampHL
	ld a, l
	and $f0
	ld l, a
	ld a, l
	ld [wFlyoverCamX], a
	ld a, h
	ld [wFlyoverCamX + 1], a

	ld a, [wFlyoverBirdY]
	ld l, a
	ld a, [wFlyoverBirdY + 1]
	ld h, a
	ld de, -FLYOVER_SCREEN_CENTER_Y
	add hl, de
	bit 7, h
	jr z, .camYPositive
	ld hl, 0
.camYPositive
	ld de, FLYOVER_MAP_HEIGHT_PX - SCREEN_HEIGHT_PX
	call FlyoverClampHL
	ld a, l
	and $f0
	ld l, a
	ld a, l
	ld [wFlyoverCamY], a
	ld a, h
	ld [wFlyoverCamY + 1], a

	; --- take over the screen ---
	ld a, 4
	call StopMusic
	ld a, SFX_FLY
	call PlaySound
	call HideSprites
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	xor a
	ld [wNumSprites], a
	ldh [hTileAnimations], a
	call DisableLCD

	; overworld and plateau tilesets, and the bird
	ld hl, Overworld_GFX
	ld de, vTileset
	ld bc, Overworld_Block - Overworld_GFX
	ld a, BANK(Overworld_GFX)
	call FarCopyData2

	ld hl, Plateau_GFX
	ld de, vChars1
	ld bc, Plateau_Block - Plateau_GFX
	ld a, BANK(Plateau_GFX)
	call FarCopyData2

	ld hl, BirdSprite
	ld de, vSprites
	ld bc, 24 * TILE_SIZE
	ld a, BANK(BirdSprite)
	call FarCopyData2

	; overworld palette set; PlateauPalSet is identical to OverworldPalSet
	ld a, OVERWORLD
	ld [wCurMapTileset], a
	ld b, SET_PAL_OVERWORLD
	call RunPaletteCommand

	; plateau tiles are remapped to tile IDs 128-197; copy their palette
	; assignments over the text-palette defaults at +128
	ld a, 2
	ldh [rWBK], a
	ld hl, FlyoverPlateauPalettes
	ld de, W2_TilesetPaletteMap + 128
	ld bc, 70
.plateauPaletteLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .plateauPaletteLoop
	xor a
	ldh [rWBK], a

	; clear BG map 0 (tiles and attributes)
	ld hl, vBGMap0
	ld bc, TILEMAP_AREA
	xor a
.clearTileLoop
	ld [hli], a
	dec bc
	ld d, a
	ld a, b
	or c
	ld a, d
	jr nz, .clearTileLoop

	ld a, 1
	ldh [rVBK], a
	ld hl, vBGMap0
	ld bc, TILEMAP_AREA
	xor a
.clearAttributeLoop
	ld [hli], a
	dec bc
	ld d, a
	ld a, b
	or c
	ld a, d
	jr nz, .clearAttributeLoop
	xor a
	ldh [rVBK], a

	; build and upload the initial view
	call FlyoverBuildView
	call _LoadMapVramAndColors

	ld a, LOW(vBGMap0)
	ld [wMapViewVRAMPointer], a
	ld a, HIGH(vBGMap0)
	ld [wMapViewVRAMPointer + 1], a
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	ld [wWalkCounter], a
	ldh [hAutoBGTransferEnabled], a
	ldh [hRedrawRowOrColumnMode], a
	ldh [rVBK], a
	ldh [rWBK], a
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ldh [rWY], a

	call EnableLCD
	ld hl, wStatusFlags7
	set BIT_FLYOVER_ACTIVE, [hl]
	call FlyoverDrawBird

.frameLoop
	call FlyoverCheckDone
	jr z, .flightDone
	call FlyoverBresenhamStep
	call FlyoverCameraStep
	call FlyoverDrawBird
	call DelayFrame
	ld hl, wFlyoverTick
	inc [hl]
	ld hl, wFlyoverGrace
	ld a, [hl]
	and a
	jr z, .pollSkip
	dec [hl]
	jr .frameLoop
.pollSkip
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and PAD_A | PAD_B | PAD_START
	jr z, .frameLoop

.flightDone
	call GBFadeOutToWhite
	call HideSprites
	xor a
	ldh [hRedrawRowOrColumnMode], a
	ldh [rVBK], a
	ldh [rWBK], a
	ld hl, wStatusFlags7
	res BIT_FLYOVER_ACTIVE, [hl]
	res BIT_USED_FLY, [hl]
	set BIT_FLYOVER_DONE, [hl]
	ld hl, wStatusFlags6
	res BIT_FLY_WARP, [hl]
	ret

.fallback
	farjp _LeaveMapAnim


; Reads one 6-block row of the global map into the redraw scratch buffer.
; \1 = row offset 0..4 within the 6x5 block window.
MACRO flyover_read_row
	; default the whole run to the void block
	ld hl, wRedrawRowOrColumnSrcTiles + (\1) * 6
	ld a, FLYOVER_VOID_BLOCK
	REPT 6
		ld [hli], a
	ENDR

	ld a, [wFlyoverBaseY]
	add \1
	ld b, a
	cp FLYOVER_MAP_HEIGHT_BLOCKS
	jr nc, .done\@

	ld a, [wFlyoverBaseX]
	cp FLYOVER_MAP_WIDTH_BLOCKS
	jr nc, .done\@

	; count = min(6, 174 - x)
	ld c, a
	ld a, FLYOVER_MAP_WIDTH_BLOCKS
	sub c
	cp 6
	jr c, .countOk\@
	ld a, 6
.countOk\@
	ld c, a
	ld b, 0
	push bc

	; pick the map half and keep the local row
	ld a, [wFlyoverBaseY]
	add \1
	cp FLYOVER_SPLIT_ROW
	jr nc, .part2\@
	ld b, a
	ld de, FlyoverMapPart1
	ld a, BANK(FlyoverMapPart1)
	jr .havePart\@
.part2\@
	sub FLYOVER_SPLIT_ROW
	ld b, a
	ld de, FlyoverMapPart2
	ld a, BANK(FlyoverMapPart2)
.havePart\@
	push af
	push de

	ld a, b
	call FlyoverTimes174
	ld a, [wFlyoverBaseX]
	ld c, a
	ld b, 0
	add hl, bc
	pop de
	add hl, de
	pop af
	pop bc
	ld de, wRedrawRowOrColumnSrcTiles + (\1) * 6
	call FarCopyData2
.done\@
ENDM


; Builds wTileMap from the global block map for the camera position.
; Called via LoadCurrentMapView while BIT_FLYOVER_ACTIVE is set.
FlyoverBuildView::
	; base block = camera / 32
	ld a, [wFlyoverCamX]
	ld l, a
	ld a, [wFlyoverCamX + 1]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	ld [wFlyoverBaseX], a

	ld a, [wFlyoverCamY]
	ld l, a
	ld a, [wFlyoverCamY + 1]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	ld [wFlyoverBaseY], a

	flyover_read_row 0
	flyover_read_row 1
	flyover_read_row 2
	flyover_read_row 3
	flyover_read_row 4

	call FlyoverExpandBlocks
	call FlyoverCopyWindow
	ret




; Expands the 6x5 block window into wSurroundingTiles (24x20 tiles).
FlyoverExpandBlocks:
	xor a
	ld [wFlyoverIndex], a

.blockLoop
	; row = index / 6, col = index % 6
	ld a, [wFlyoverIndex]
	ld b, 0
.divideLoop
	cp 6
	jr c, .divided
	sub 6
	inc b
	jr .divideLoop
.divided
	ld c, a                  ; c = block column
	; dest = wSurroundingTiles + row * 96 + col * 4
	ld l, b
	ld h, 0
	add hl, hl               ; 2
	add hl, hl               ; 4
	add hl, hl               ; 8
	add hl, hl               ; 16
	add hl, hl               ; 32
	ld d, h
	ld e, l
	add hl, hl               ; 64
	add hl, de               ; 96
	ld a, c
	add a, a
	add a, a
	ld c, a
	ld b, 0
	add hl, bc
	ld de, wSurroundingTiles
	add hl, de
	ld a, l
	ld [wFlyoverBaseX], a
	ld a, h
	ld [wFlyoverBaseY], a

	; block ID from the row buffer
	ld a, [wFlyoverIndex]
	ld e, a
	ld d, 0
	ld hl, wRedrawRowOrColumnSrcTiles
	add hl, de
	ld a, [hl]

	; select blockset and compute source = label + id * 16
	ld de, Overworld_Block
	bit 7, a
	jr z, .haveBlockset
	ld de, Plateau_Block
	and $7f
.haveBlockset
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de

	ld a, BANK(Overworld_Block)
	ld de, wFlyoverBlockTiles
	ld bc, 16
	call FarCopyData2

	; plateau tile IDs are remapped to 128-197
	ld a, [wFlyoverIndex]
	ld e, a
	ld d, 0
	ld hl, wRedrawRowOrColumnSrcTiles
	add hl, de
	ld a, [hl]
	and $80
	ld c, a

	; copy 4x4 tile IDs to the surrounding buffer
	ld hl, wFlyoverBlockTiles
	ld a, [wFlyoverBaseX]
	ld e, a
	ld a, [wFlyoverBaseY]
	ld d, a
	ld b, 4
.tileRowLoop
	REPT 4
		ld a, [hli]
		add a, c
		ld [de], a
		inc de
	ENDR
	ld a, 20
	add a, e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	dec b
	jr nz, .tileRowLoop

	ld hl, wFlyoverIndex
	inc [hl]
	ld a, [hl]
	cp SCREEN_BLOCK_WIDTH * SCREEN_BLOCK_HEIGHT
	jp c, .blockLoop
	ret


; Copies the visible 20x18 window out of wSurroundingTiles into wTileMap.
FlyoverCopyWindow:
	; subX = (camX >> 3) & 3
	ld a, [wFlyoverCamX]
	ld l, a
	ld a, [wFlyoverCamX + 1]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and 3
	ld [wFlyoverBaseX], a

	; subY = (camY >> 3) & 3
	ld a, [wFlyoverCamY]
	ld l, a
	ld a, [wFlyoverCamY + 1]
	ld h, a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	and 3
	ld [wFlyoverBaseY], a

	; source = wSurroundingTiles + subY * 24 + subX
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	add hl, hl
	add hl, de
	ld a, [wFlyoverBaseX]
	ld c, a
	ld b, 0
	add hl, bc
	ld de, wSurroundingTiles
	add hl, de

	ld de, wTileMap
	ld b, SCREEN_HEIGHT
.rowLoop
	ld c, SCREEN_WIDTH
.columnLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .columnLoop
	ld a, 4
	add a, l
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	dec b
	jr nz, .rowLoop
	ret


; One 16-pixel step along the 16-pixel Bresenham line.
FlyoverBresenhamStep:
	ld a, [wFlyoverErr]
	ld l, a
	ld a, [wFlyoverErr + 1]
	ld h, a
	add hl, hl               ; 2 * err
	ld a, [wFlyoverDY]
	ld e, a
	ld a, [wFlyoverDY + 1]
	ld d, a
	add hl, de               ; 2 * err + dy
	bit 7, h
	jr nz, .tryY

	call FlyoverXAtEnd
	jr z, .moveY
	call FlyoverMoveX
	jp FlyoverErrMinusDY

.tryY
	call FlyoverYAtEnd
	jr z, .moveX
.moveY
	call FlyoverMoveY
	jp FlyoverErrPlusDX
.moveX
	call FlyoverMoveX
	jp FlyoverErrMinusDY


FlyoverXAtEnd:
	ld a, [wFlyoverBirdX]
	ld b, a
	ld a, [wFlyoverEndX]
	cp b
	ret nz
	ld a, [wFlyoverBirdX + 1]
	ld b, a
	ld a, [wFlyoverEndX + 1]
	cp b
	ret

FlyoverYAtEnd:
	ld a, [wFlyoverBirdY]
	ld b, a
	ld a, [wFlyoverEndY]
	cp b
	ret nz
	ld a, [wFlyoverBirdY + 1]
	ld b, a
	ld a, [wFlyoverEndY + 1]
	cp b
	ret

FlyoverMoveX:
	ld a, [wFlyoverBirdX]
	ld l, a
	ld a, [wFlyoverBirdX + 1]
	ld h, a
	ld a, [wFlyoverSX]
	cp 1
	jr nz, .west
	ld bc, 16
	add hl, bc
	jr .store
.west
	ld bc, -16
	add hl, bc
.store
	ld a, l
	ld [wFlyoverBirdX], a
	ld a, h
	ld [wFlyoverBirdX + 1], a
	ret

FlyoverMoveY:
	ld a, [wFlyoverBirdY]
	ld l, a
	ld a, [wFlyoverBirdY + 1]
	ld h, a
	ld a, [wFlyoverSY]
	cp 1
	jr nz, .north
	ld bc, 16
	add hl, bc
	jr .store
.north
	ld bc, -16
	add hl, bc
.store
	ld a, l
	ld [wFlyoverBirdY], a
	ld a, h
	ld [wFlyoverBirdY + 1], a
	ret

FlyoverErrMinusDY:
	ld a, [wFlyoverErr]
	ld l, a
	ld a, [wFlyoverErr + 1]
	ld h, a
	ld a, [wFlyoverDY]
	ld e, a
	ld a, [wFlyoverDY + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, l
	ld [wFlyoverErr], a
	ld a, h
	ld [wFlyoverErr + 1], a
	ret

FlyoverErrPlusDX:
	ld a, [wFlyoverErr]
	ld l, a
	ld a, [wFlyoverErr + 1]
	ld h, a
	ld a, [wFlyoverDX]
	ld e, a
	ld a, [wFlyoverDX + 1]
	ld d, a
	ld a, l
	add e
	ld l, a
	ld a, h
	adc d
	ld h, a
	ld a, l
	ld [wFlyoverErr], a
	ld a, h
	ld [wFlyoverErr + 1], a
	ret


; Steps the camera one 16-pixel step toward the bird, using AdvancePlayerSprite.
FlyoverCameraStep:
	; desired X = birdX - 80, clamped to [0, map width - screen width]
	ld a, [wFlyoverBirdX]
	ld l, a
	ld a, [wFlyoverBirdX + 1]
	ld h, a
	ld de, -FLYOVER_SCREEN_CENTER_X
	add hl, de
	bit 7, h
	jr z, .xPositive
	ld hl, 0
.xPositive
	ld de, FLYOVER_MAP_WIDTH_PX - SCREEN_WIDTH_PX
	call FlyoverClampHL
	ld a, [wFlyoverCamX]
	ld e, a
	ld a, [wFlyoverCamX + 1]
	ld d, a
	call FlyoverSignedDiff
	ld a, l
	ld [wFlyoverBaseX], a
	ld a, h
	ld [wFlyoverBaseY], a

	; desired Y = birdY - 72
	ld a, [wFlyoverBirdY]
	ld l, a
	ld a, [wFlyoverBirdY + 1]
	ld h, a
	ld de, -FLYOVER_SCREEN_CENTER_Y
	add hl, de
	bit 7, h
	jr z, .yPositive
	ld hl, 0
.yPositive
	ld de, FLYOVER_MAP_HEIGHT_PX - SCREEN_HEIGHT_PX
	call FlyoverClampHL
	ld a, [wFlyoverCamY]
	ld e, a
	ld a, [wFlyoverCamY + 1]
	ld d, a
	call FlyoverSignedDiff
	ld a, l
	ld [wFlyoverIndex], a
	ld a, h
	ld [wFlyoverTmp], a

	; choose the axis with the larger absolute difference
	ld a, [wFlyoverBaseY]
	and $7f
	ld h, a
	ld a, [wFlyoverBaseX]
	ld l, a
	ld a, [wFlyoverTmp]
	and $7f
	ld d, a
	ld a, [wFlyoverIndex]
	ld e, a
	ld a, h
	cp d
	jr c, .chooseY
	jr nz, .chooseX
	ld a, l
	cp e
	jr c, .chooseY

.chooseX
	ld a, h
	and a
	jr nz, .stepX
	ld a, l
	cp 16
	jp c, .noStep
.stepX
	ld a, [wFlyoverBaseY]
	bit 7, a
	jr nz, .stepXWest
	ld a, [wFlyoverCamX]
	add 16
	ld [wFlyoverCamX], a
	ld a, [wFlyoverCamX + 1]
	adc 0
	ld [wFlyoverCamX + 1], a
	ld a, 1
	ld [wSpritePlayerStateData1XStepVector], a
	jr .stepXDone
.stepXWest
	ld a, [wFlyoverCamX]
	sub 16
	ld [wFlyoverCamX], a
	ld a, [wFlyoverCamX + 1]
	sbc 0
	ld [wFlyoverCamX + 1], a
	ld a, -1
	ld [wSpritePlayerStateData1XStepVector], a
.stepXDone
	xor a
	ld [wSpritePlayerStateData1YStepVector], a
	jr .doStep

.chooseY
	ld a, [wFlyoverTmp]
	and $7f
	ld h, a
	ld a, [wFlyoverIndex]
	ld l, a
	ld a, h
	and a
	jr nz, .stepY
	ld a, l
	cp 16
	jp c, .noStep
.stepY
	ld a, [wFlyoverTmp]
	bit 7, a
	jr nz, .stepYNorth
	ld a, [wFlyoverCamY]
	add 16
	ld [wFlyoverCamY], a
	ld a, [wFlyoverCamY + 1]
	adc 0
	ld [wFlyoverCamY + 1], a
	ld a, 1
	ld [wSpritePlayerStateData1YStepVector], a
	jr .stepYDone
.stepYNorth
	ld a, [wFlyoverCamY]
	sub 16
	ld [wFlyoverCamY], a
	ld a, [wFlyoverCamY + 1]
	sbc 0
	ld [wFlyoverCamY + 1], a
	ld a, -1
	ld [wSpritePlayerStateData1YStepVector], a
.stepYDone
	xor a
	ld [wSpritePlayerStateData1XStepVector], a

.doStep
	ld a, 8
	ld [wWalkCounter], a
	REPT 8
		call AdvancePlayerSprite
	ENDR
	ret

.noStep
	ret


; \1 = clamp hl to de (hl = min(hl, de))
FlyoverClampHL:
	ld a, h
	cp d
	jr c, .done
	jr nz, .set
	ld a, l
	cp e
	jr c, .done
	jr z, .done
.set
	ld h, d
	ld l, e
.done
	ret


; hl = target - camera, with bit 15 set when the result is negative.
; in: hl = target, de = camera
FlyoverSignedDiff:
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	bit 7, h
	jr z, .positive
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
	set 7, h
.positive
	ret


FlyoverCheckDone:
	ld a, [wFlyoverBirdX]
	ld b, a
	ld a, [wFlyoverEndX]
	cp b
	ret nz
	ld a, [wFlyoverBirdX + 1]
	ld b, a
	ld a, [wFlyoverEndX + 1]
	cp b
	ret nz
	ld a, [wFlyoverBirdY]
	ld b, a
	ld a, [wFlyoverEndY]
	cp b
	ret nz
	ld a, [wFlyoverBirdY + 1]
	ld b, a
	ld a, [wFlyoverEndY + 1]
	cp b
	ret


; Draws the bird at (bird - camera).  Four OAM entries, 16x16.
FlyoverDrawBird:
	; screen X
	ld a, [wFlyoverBirdX]
	ld l, a
	ld a, [wFlyoverBirdX + 1]
	ld h, a
	ld a, [wFlyoverCamX]
	ld e, a
	ld a, [wFlyoverCamX + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	bit 7, h
	jp nz, .hide
	ld a, h
	and a
	jp nz, .hide
	ld a, l
	cp SCREEN_WIDTH_PX + 1
	jp nc, .hide
	ld a, l
	ld [wFlyoverBaseX], a

	; screen Y
	ld a, [wFlyoverBirdY]
	ld l, a
	ld a, [wFlyoverBirdY + 1]
	ld h, a
	ld a, [wFlyoverCamY]
	ld e, a
	ld a, [wFlyoverCamY + 1]
	ld d, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	bit 7, h
	jp nz, .hide
	ld a, h
	and a
	jp nz, .hide
	ld a, l
	cp SCREEN_HEIGHT_PX + 1
	jp nc, .hide
	ld a, l
	ld [wFlyoverBaseY], a

	; frame: horizontal 8, down 0, up 4; flip when flying east
	ld a, [wFlyoverDX + 1]
	ld b, a
	ld a, [wFlyoverDY + 1]
	cp b
	jr c, .horizontal
	jr nz, .vertical
	ld a, [wFlyoverDX]
	ld b, a
	ld a, [wFlyoverDY]
	cp b
	jr c, .horizontal
.vertical
	ld a, [wFlyoverSY]
	cp 1
	jr nz, .up
	ld b, 0
	jr .noFlip
.up
	ld b, 4
.noFlip
	xor a
	ld c, a
	jr .haveFrame
.horizontal
	ld b, 8
	ld a, [wFlyoverSX]
	cp 1
	jr nz, .facingLeft
	ld c, OAM_XFLIP
	jr .haveFrame
.facingLeft
	xor a
	ld c, a
.haveFrame
	ld a, [wFlyoverTick]
	and 4
	jr z, .noFlap
	ld a, b
	add 12
	ld b, a
.noFlap

	ld a, [wFlyoverBaseY]
	add OAM_Y_OFS - 8
	ld d, a
	ld a, [wFlyoverBaseX]
	ld e, a

	ld hl, wShadowOAMSprite00
	ld a, c
	and a
	jr nz, .flipped

	ld [hl], d
	inc hl
	ld [hl], e
	inc hl
	ld [hl], b
	inc hl
	ld [hl], c
	inc hl

	ld [hl], d
	inc hl
	ld a, e
	add 8
	ld [hl], a
	inc hl
	ld a, b
	inc a
	ld [hl], a
	inc hl
	ld [hl], c
	inc hl

	ld a, d
	add 8
	ld [hl], a
	inc hl
	ld [hl], e
	inc hl
	ld a, b
	add 2
	ld [hl], a
	inc hl
	ld [hl], c
	inc hl

	ld a, d
	add 8
	ld [hl], a
	inc hl
	ld a, e
	add 8
	ld [hl], a
	inc hl
	ld a, b
	add 3
	ld [hl], a
	inc hl
	ld [hl], c
	ret

.flipped
	; top-left = base+1, top-right = base, bottom-left = base+3,
	; bottom-right = base+2, all with OAM_XFLIP
	ld [hl], d
	inc hl
	ld [hl], e
	inc hl
	ld a, b
	inc a
	ld [hl], a
	inc hl
	ld [hl], c
	inc hl

	ld [hl], d
	inc hl
	ld a, e
	add 8
	ld [hl], a
	inc hl
	ld [hl], b
	inc hl
	ld [hl], c
	inc hl

	ld a, d
	add 8
	ld [hl], a
	inc hl
	ld [hl], e
	inc hl
	ld a, b
	add 3
	ld [hl], a
	inc hl
	ld [hl], c
	inc hl

	ld a, d
	add 8
	ld [hl], a
	inc hl
	ld a, e
	add 8
	ld [hl], a
	inc hl
	ld a, b
	add 2
	ld [hl], a
	inc hl
	ld [hl], c
	ret

.hide
	ld hl, wShadowOAMSprite00YCoord
	ld de, OBJ_SIZE
	ld a, SCREEN_HEIGHT_PX + OAM_Y_OFS
	ld b, 4
.hideLoop
	ld [hl], a
	add hl, de
	dec b
	jp nz, .hideLoop
	ret


; hl = row * 174.  in: a = row.  clobbers a, b, de, hl.
FlyoverTimes174:
	ld l, a
	ld h, 0
	ld d, h
	ld e, l
	ld hl, 0
	ld a, 174
	ld b, 8
.shiftLoop
	add hl, hl
	sla a
	jr nc, .noAdd
	add hl, de
.noAdd
	dec b
	jr nz, .shiftLoop
	ret


; hl = a * 16.  clobbers hl only.
FlyoverTimes16:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ret
