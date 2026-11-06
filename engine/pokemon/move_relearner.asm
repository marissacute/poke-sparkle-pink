; Builds a list of the moves a party mon can relearn: the level 1 moves from
; its base stats plus the level-up moves at or below its current level.
; INPUT:
;   [wCurPartySpecies] = species
;   [wWhichPokemon] = party index
; OUTPUT:
;   [wItemList] = number of moves, followed by the move IDs and a $ff terminator
; expects the party data WRAM bank (1) to be selected
BuildRelearnMoveList::
	ld hl, wItemList
	ld [hl], 0
	inc hl
	ld [hl], $ff

; add the level 1 moves from the base stats
	ld a, [wPokedexNum]
	push af
; the base stats are indexed by Pokédex number, not by species
	ld a, [wCurPartySpecies]
	ld [wPokedexNum], a
	predef IndexToPokedex
	ld a, [wPokedexNum]
	and a
	jr z, .missingNoBaseStats
	dec a
	ld hl, BaseStats
	ld bc, BASE_DATA_SIZE
	call AddNTimes
	jr .gotBaseStats
.missingNoBaseStats
	ld hl, MissingNoBaseStats
.gotBaseStats
	ld de, BASE_MOVES
	add hl, de
	ld d, h
	ld e, l ; de = starting moves
	ld b, NUM_MOVES
.baseMoveLoop
	ld a, [de]
	inc de
	and a
	jr z, .nextBaseMove
	push bc
	push de
	ld e, a
	call .TryAddMove
	pop de
	pop bc
.nextBaseMove
	dec b
	jr nz, .baseMoveLoop
	pop af
	ld [wPokedexNum], a

; get the mon's current level
	ld hl, wPartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [hl]
	ld [wTempByteValue], a

; get a pointer to the species' evolutions and learnset
	ld a, [wCurPartySpecies]
	dec a
	add a
	ld hl, EvosMovesPointerTable
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

; skip the evolution data
.skipEvolutionDataLoop
	ld a, [hli]
	and a
	jr nz, .skipEvolutionDataLoop

.learnSetLoop
	ld a, [hli] ; level
	and a
	ret z       ; reached the end of the learnset
	ld b, a
	ld a, [wTempByteValue]
	cp b
	ret c       ; the learnset is sorted, so no later move is low enough
	ld a, [hli] ; move id
	ld e, a
	push hl
	call .TryAddMove
	pop hl
	jr .learnSetLoop

; appends the move in e to the list unless the mon knows it or it is already listed
; preserves de
.TryAddMove:
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld b, NUM_MOVES
.checkKnownMovesLoop
	ld a, [hli]
	cp e
	ret z
	dec b
	jr nz, .checkKnownMovesLoop

	ld hl, wItemList + 1
	ld a, [wItemList]
	and a
	jr z, .addMove
	ld b, a
.checkListLoop
	ld a, [hli]
	cp e
	ret z
	dec b
	jr nz, .checkListLoop

.addMove
	ld a, [wItemList]
	ld c, a
	ld b, 0
	inc a
	ld [wItemList], a
	ld hl, wItemList + 1
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], $ff
	ret
