HazeEffect_:
	ld a, $7
; store 7 on every stat mod
	ld hl, wPlayerMonAttackMod
	call ResetStatMods
	ld hl, wEnemyMonAttackMod
	call ResetStatMods
; copy unmodified stats to battle stats
	ld hl, wPlayerMonUnmodifiedAttack
	ld de, wBattleMonAttack
	call ResetStats
	ld hl, wEnemyMonUnmodifiedAttack
	ld de, wEnemyMonAttack
	call ResetStats
; cure non-volatile status, but only for the target
	ld hl, wEnemyMonStatus
	ld de, wEnemySelectedMove
	ldh a, [hWhoseTurn]
	and a
	jr z, .cureStatuses
	ld hl, wBattleMonStatus
	dec de ; wPlayerSelectedMove

.cureStatuses
	ld a, [hl]
	ld [hl], $0
	push af
	push de
; Haze cured the target's status, so also clear Toxic's battle bit and counter.
; (A badly poisoned mon that is not the target keeps its bad poison intact.)
	ldh a, [hWhoseTurn]
	and a
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
	jr z, .clearTargetToxic
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerToxicCounter
.clearTargetToxic
	res BADLY_POISONED, [hl]
	xor a
	ld [de], a
	pop de
	pop af
	and (1 << FRZ) | SLP_MASK
	jr z, .cureVolatileStatuses
; prevent the Pokemon from executing a move if it was asleep or frozen
	ld a, $ff
	ld [de], a

.cureVolatileStatuses
	xor a
	ld [wPlayerDisabledMove], a
	ld [wEnemyDisabledMove], a
	ld hl, wPlayerDisabledMoveNumber
	ld [hli], a
	ld [hl], a
	ld hl, wPlayerBattleStatus1
	call CureVolatileStatuses
	ld hl, wEnemyBattleStatus1
	call CureVolatileStatuses
	ld hl, PlayCurrentMoveAnimation
	call CallBankF
	ld hl, StatusChangesEliminatedText
	jp PrintText

CureVolatileStatuses:
	res CONFUSED, [hl]
	inc hl ; BATTSTATUS2
	ld a, [hl]
	; clear USING_X_ACCURACY, PROTECTED_BY_MIST, and GETTING_PUMPED.
	; Haze no longer clears Leech Seed or bad poison (Generation II); a badly
	; poisoned target is handled separately in .cureStatuses.
	and ~((1 << USING_X_ACCURACY) | (1 << PROTECTED_BY_MIST) | (1 << GETTING_PUMPED))
	ld [hl], a
	ret

ResetStatMods:
	ld b, NUM_STAT_MODS
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

ResetStats:
	ld b, (NUM_STATS - 1) * 2 ; doesn't reset STAT_HEALTH
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ret

StatusChangesEliminatedText:
	text_far _StatusChangesEliminatedText
	text_end
