TransformEffect_:
	ld hl, wBattleMonSpecies
	ld de, wEnemyMonSpecies
	ld bc, wEnemyBattleStatus3
	; bug: on enemy's turn, a is overloaded with hWhoseTurn,
	; before the check for INVULNERABLE
	ld a, [wEnemyBattleStatus1]
	ldh a, [hWhoseTurn]
	and a
	jr nz, .hitTest
; player's turn
	ld hl, wEnemyMonSpecies
	ld de, wBattleMonSpecies
	ld bc, wPlayerBattleStatus3
	ld [wPlayerMoveListIndex], a
	; bug: this should be target's BattleStatus1 (i.e. wEnemyBattleStatus1)
	ld a, [wPlayerBattleStatus1]
.hitTest
	bit INVULNERABLE, a ; is mon invulnerable to typical attacks? (fly/dig)
	                    ; this check doesn't work due to above bugs
	jp nz, .failed
	push hl
	push de
	push bc
	ld hl, wPlayerBattleStatus2
	ldh a, [hWhoseTurn]
	and a
	jr z, .transformEffect
	ld hl, wEnemyBattleStatus2
.transformEffect
; animation(s) played are different if target has Substitute up
	bit HAS_SUBSTITUTE_UP, [hl]
	push af
	ld hl, HideSubstituteShowMonAnim
	ld b, BANK(HideSubstituteShowMonAnim)
	call nz, Bankswitch
	ld a, [wOptions]
	add a
	ld hl, PlayCurrentMoveAnimation
	ld b, BANK(PlayCurrentMoveAnimation)
	jr nc, .gotAnimToPlay
	ld hl, AnimationTransformMon
	ld b, BANK(AnimationTransformMon)
.gotAnimToPlay
	call Bankswitch
	ld hl, ReshowSubstituteAnim
	ld b, BANK(ReshowSubstituteAnim)
	pop af
	call nz, Bankswitch
	pop bc
	ld a, [bc]
	set TRANSFORMED, a ; mon is now transformed
	ld [bc], a
	pop de
	pop hl
	push hl
; transform user into opposing Pokemon
; species
	ld a, [hl]
	ld [de], a
; type 1, type 2, catch rate, and moves
	ld bc, $5
	add hl, bc
	inc de
	inc de
	inc de
	inc de
	inc de
	inc bc
	inc bc
	call CopyData
	ldh a, [hWhoseTurn]
	and a
	jr z, .next
; save enemy mon DVs at wTransformedEnemyMonOriginalDVs
	ld a, [de]
	ld [wTransformedEnemyMonOriginalDVs], a
	inc de
	ld a, [de]
	ld [wTransformedEnemyMonOriginalDVs + 1], a
	dec de
.next
; DVs
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
; Skip level and max HP
	inc hl
	inc hl
	inc hl
	inc de
	inc de
	inc de
; Attack, Defense, Speed, and Special stats
	ld bc, (NUM_STATS - 1) * 2
	call CopyData
	ld bc, wBattleMonMoves - wBattleMonPP
	add hl, bc ; ld hl, wBattleMonMoves
	ld b, NUM_MOVES
.copyPPLoop
; 5 PP for all moves
	ld a, [hli]
	and a
	jr z, .lessThanFourMoves
	ld a, 5
	ld [de], a
	inc de
	dec b
	jr nz, .copyPPLoop
	jr .copyStats
.lessThanFourMoves
; 0 PP for blank moves
	xor a
	ld [de], a
	inc de
	dec b
	jr nz, .lessThanFourMoves
.copyStats
; original (unmodified) stats and stat mods
	pop hl
	ld a, [hl]
	ld [wNamedObjectIndex], a
	call GetMonName
	ld hl, wEnemyMonUnmodifiedAttack
	ld de, wPlayerMonUnmodifiedAttack
	call .copyBasedOnTurn ; original (unmodified) stats
	ld hl, wEnemyMonStatMods
	ld de, wPlayerMonStatMods
	call .copyBasedOnTurn ; stat mods
	ld hl, TransformedText
	jp PrintText

.copyBasedOnTurn
	ldh a, [hWhoseTurn]
	and a
	jr z, .gotStatsOrModsToCopy
	push hl
	ld h, d
	ld l, e
	pop de
.gotStatsOrModsToCopy
	ld bc, (NUM_STATS - 1) * 2
	jp CopyData

.failed
	ld hl, PrintButItFailedText_
	jp EffectCallBattleCore

TransformedText:
	text_far _TransformedText
	text_end

; Imposter: auto-Transform when a Ditto is sent into battle.
; Reuses TransformEffect_ (same bank). Callers must have both battle mons
; loaded and the entering side's status bytes already cleared.
TryImposterPlayer:
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z ; link battles must stay in sync
	ld a, [wBattleMonSpecies]
	cp DITTO
	ret nz
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	ret nz
	ld a, [wEnemyMonSpecies]
	and a
	ret z ; no opposing mon loaded (initial trainer send-out)
	ld hl, wEnemyMonHP
	ld a, [hli]
	or [hl]
	ret z ; opposing mon has fainted
	ld a, [wEnemyBattleStatus3]
	bit TRANSFORMED, a
	ret nz ; Imposter fails against a transformed target
	ld a, [wEnemyBattleStatus2]
	bit HAS_SUBSTITUTE_UP, a
	ret nz ; Imposter fails against a target behind a substitute
	ldh a, [hWhoseTurn]
	push af
	ld a, [wPlayerMoveNum]
	push af
	xor a ; player's turn
	ldh [hWhoseTurn], a
	ld a, TRANSFORM
	ld [wPlayerMoveNum], a ; required for the sprite morph animation
	call TransformEffect_
	pop af
	ld [wPlayerMoveNum], a
	pop af
	ldh [hWhoseTurn], a
	ret

TryImposterEnemy:
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	ld a, [wEnemyMonSpecies]
	cp DITTO
	ret nz
	ld a, [wEnemyBattleStatus3]
	bit TRANSFORMED, a
	ret nz
	ld a, [wBattleMonSpecies]
	and a
	ret z ; player mon not loaded yet
	ld hl, wBattleMonHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	ret nz
	ld a, [wPlayerBattleStatus2]
	bit HAS_SUBSTITUTE_UP, a
	ret nz
	ldh a, [hWhoseTurn]
	push af
	ld a, [wEnemyMoveNum]
	push af
	ld a, $1 ; enemy's turn
	ldh [hWhoseTurn], a
	ld a, TRANSFORM
	ld [wEnemyMoveNum], a ; required for the sprite morph animation
	call TransformEffect_
	pop af
	ld [wEnemyMoveNum], a
	pop af
	ldh [hWhoseTurn], a
	ret
