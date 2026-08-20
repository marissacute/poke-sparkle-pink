; try to initiate a wild pokemon encounter
; returns success in Z
TryDoWildEncounter:
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wMovementFlags]
	and a ; is player exiting a door, jumping over a ledge, or fishing?
	ret nz
	callfar IsPlayerStandingOnDoorTileOrWarpTile
	jr nc, .notStandingOnDoorOrWarpTile
.CantEncounter
	ld a, $1
	and a
	ret
.notStandingOnDoorOrWarpTile
	callfar IsPlayerJustOutsideMap
	jr z, .CantEncounter
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .next
	dec a
	jr z, .lastRepelStep
	ld [wRepelRemainingSteps], a
.next
; determine if wild pokemon can appear in the half-block we're standing in
; is the bottom right tile (9,9) of the half-block we're standing in a grass/water tile?
	hlcoord 9, 9
	ld c, [hl]
	ld a, [wGrassTile]
	cp c
	ld a, [wGrassRate]
	jr z, .CanEncounter
	ld a, $14 ; in all tilesets with a water tile, this is its id
	cp c
	ld a, [wWaterRate]
	jr z, .CanEncounter
; even if not in grass/water, standing anywhere we can encounter pokemon
; so long as the map is "indoor" and has wild pokemon defined.
; ...as long as it's not Viridian Forest or Safari Zone.
	ld a, [wCurMap]
	cp FIRST_INDOOR_MAP ; is this an indoor map?
	jr c, .CantEncounter2
	ld a, [wCurMapTileset]
	cp FOREST ; Viridian Forest/Safari Zone
	jr z, .CantEncounter2
	ld a, [wGrassRate]
.CanEncounter
; compare encounter chance with a random number to determine if there will be an encounter
	ld b, a
	ldh a, [hRandomAdd]
	cp b
	jr nc, .CantEncounter2
	ldh a, [hRandomSub]
	ld b, a
	ld hl, WildMonEncounterSlotChances
.determineEncounterSlot
	ld a, [hli]
	cp b
	jr nc, .gotEncounterSlot
	inc hl
	jr .determineEncounterSlot
.gotEncounterSlot
; determine which wild pokemon (grass or water) can appear in the half-block we're standing in
	ld c, [hl]
	ld hl, wGrassMons
	lda_coord 8, 9
	cp $14 ; is the bottom left tile (8,9) of the half-block we're standing in a water tile?
	jr nz, .gotWildEncounterType ; else, it's treated as a grass tile by default
	ld hl, wWaterMons
; since the bottom right tile of a "left shore" half-block is $14 but the bottom left tile is not,
; "left shore" half-blocks (such as the one in the east coast of Cinnabar) load grass encounters.
.gotWildEncounterType
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld [wCurEnemyLevel], a
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld [wEnemyMonSpecies2], a
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .willEncounter
	ld a, [wPartyMon1Level]
	ld b, a
	ld a, [wCurEnemyLevel]
	cp b
	jr c, .CantEncounter2 ; repel prevents encounters if the leading party mon's level is higher than the wild mon
	jr .willEncounter
.lastRepelStep
	ld [wRepelRemainingSteps], a
	ld a, TEXT_REPEL_WORE_OFF
	ldh [hTextID], a
	call EnableAutoTextBoxDrawing
	call DisplayTextID
.CantEncounter2
	ld a, $1
	and a
	ret
.willEncounter
	xor a
	ret

; called when the repel effect wears off (see DisplayTextID in home/text_script.asm)
; asks the player if they want to use another one of the same repel
DisplayRepelWoreOffText_::
; [wRepelType] is the ID of the repel that just wore off
	ld a, [wRepelType]
	ld [wNamedObjectIndex], a
	call GetItemName
	call CopyToStringBuffer ; copy the item name to wStringBuffer for text_ram
; how many more of the same repel are in the bag?
	ld a, [wRepelType]
	ld b, a
	predef GetQuantityOfItemInBag ; b = quantity
	ld a, b
	and a
	jr z, .noRepelLeft
; ask whether to use another one
	ld hl, RepelWoreOffText
	call PrintText
	call ManualTextScroll
	ld hl, UseAnotherRepelText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .done ; chose no
; use another one of the same repel
	ld a, [wRepelType]
	ldh [hItemToRemoveID], a
	farcall RemoveItemByID
	ld a, [wRepelType]
	call GetRepelSteps ; c = step count for this repel
	ld a, c
	ld [wRepelRemainingSteps], a
	ld a, SFX_HEAL_AILMENT
	call PlaySound
	jr .done
.noRepelLeft
	ld hl, RepelWoreOffText
	call PrintText
.done
	ret

GetRepelSteps:
; in: a = repel item ID
; out: c = number of steps the repel lasts
	ld b, a
	ld hl, RepelStepsTable
.loop
	ld a, [hli]
	cp -1
	jr z, .notFound
	cp b
	jr z, .found
	inc hl
	jr .loop
.found
	ld c, [hl]
	ret
.notFound
	ld c, 100 ; not in the table (shouldn't happen)
	ret

RepelStepsTable:
; item ID, number of steps
; keep in sync with ItemUseRepel/ItemUseSuperRepel/ItemUseMaxRepel in engine/items/item_effects.asm
	db REPEL, 100
	db SUPER_REPEL, 200
	db MAX_REPEL, 250
	db -1 ; terminator

RepelWoreOffText:
	text_far _RepelWoreOffText
	text_end

UseAnotherRepelText:
	text_far _UseAnotherRepelText
	text_end

INCLUDE "data/wild/probabilities.asm"
