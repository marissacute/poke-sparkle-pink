GainExperience:
; give the exp gained from a fainted enemy mon to every party mon that has a
; flag set in wPartyGainExpFlags, splitting it evenly between them. bit 7 of
; the flags says the exp is halved, which the exp share sets so that the mons
; that fought and the ones that sat the battle out each share one half
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z ; return if link battle
	ld hl, wPartyMon1
	xor a
	ld [wWhichPokemon], a
.partyMonLoop ; loop over each mon and add gained exp
	inc hl
	ld a, [hli]
	or [hl] ; is mon's HP 0?
	jp z, .nextMon ; if so, go to next mon
	push hl
	ld hl, wPartyGainExpFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, FLAG_TEST
	predef FlagActionPredef
	ld a, c
	and a ; is mon's gain exp flag set?
	pop hl
	jp z, .nextMon ; if mon's gain exp flag not set, go to next mon
	ld de, (MON_HP_EXP + 1) - (MON_HP + 1)
	add hl, de
	ld d, h
	ld e, l
	ld hl, wEnemyMonBaseStats
	ld c, NUM_STATS
.gainStatExpLoop
	ld a, [hli]
	call DivideStatExpShare
	ld b, a ; enemy mon base stat
	ld a, [de] ; stat exp
	add b ; add enemy mon base state to stat exp
	ld [de], a
	jr nc, .nextBaseStat
; if there was a carry, increment the upper byte
	dec de
	ld a, [de]
	inc a
	jr z, .maxStatExp ; jump if the value overflowed
	ld [de], a
	inc de
	jr .nextBaseStat
.maxStatExp ; if the upper byte also overflowed, then we have hit the max stat exp
	ld a, $ff
	ld [de], a
	inc de
	ld [de], a
.nextBaseStat
	dec c
	jr z, .statExpDone
	inc de
	inc de
	jr .gainStatExpLoop
.statExpDone
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand + 1], a
	ld a, [wEnemyMonBaseExp]
	ldh [hMultiplicand + 2], a
	ld a, [wEnemyMonLevel]
	ldh [hMultiplier], a
	call Multiply
	ld a, 7
	ldh [hDivisor], a
	ld b, 4
	call Divide
	call DivideExpShare
	ld hl, MON_OTID - (MON_DVS - 1)
	add hl, de
	ld b, [hl] ; wPartyMon*OTID
	inc hl
	ld a, [wPlayerID]
	cp b
	jr nz, .tradedMon
	ld b, [hl]
	ld a, [wPlayerID + 1]
	cp b
	ld a, 0
	jr z, .next
.tradedMon
	call BoostExp ; traded mon exp boost
	ld a, 1
.next
	ld [wGainBoostedExp], a
	ld a, [wIsInBattle]
	dec a ; is it a trainer battle?
	call nz, BoostExp ; if so, boost exp
	inc hl
	inc hl
	inc hl
; add the gained exp to the party mon's exp
	ld b, [hl]
	ldh a, [hQuotient + 3]
	ld [wExpAmountGained + 1], a
	add b
	ld [hld], a
	ld b, [hl]
	ldh a, [hQuotient + 2]
	ld [wExpAmountGained], a
	adc b
	ld [hl], a
	jr nc, .noCarry
	dec hl
	inc [hl]
	inc hl
.noCarry
; calculate exp for the mon at max level, and cap the exp at that value
	inc hl
	push hl
	ld a, [wWhichPokemon]
	ld c, a
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl]
	ld [wCurSpecies], a
	call GetMonHeader
	ld d, MAX_LEVEL
	callfar CalcExperience ; get max exp
; compare max exp with current exp
	ldh a, [hExperience]
	ld b, a
	ldh a, [hExperience + 1]
	ld c, a
	ldh a, [hExperience + 2]
	ld d, a
	pop hl
	ld a, [hld]
	sub d
	ld a, [hld]
	sbc c
	ld a, [hl]
	sbc b
	jr c, .next2
; the mon's exp is greater than the max exp, so overwrite it with the max exp
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, d
	ld [hld], a
	dec hl
.next2
	push hl
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, GainedText
	call PrintText
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
IF GEN_2_GRAPHICS
	call AnimateEXPBar
ELSE
	call LoadMonData
ENDC
	pop hl
	ld bc, MON_LEVEL - MON_EXP
	add hl, bc
	push hl
	farcall CalcLevelFromExperience
	pop hl
	ld a, [hl] ; current level
	cp d
	jp z, .nextMon ; if level didn't change, go to next mon
IF GEN_2_GRAPHICS
	call KeepEXPBarFull
ELSE
	ld a, [wCurEnemyLevel]
ENDC
	push af
	push hl
	ld a, d
	ld [wCurEnemyLevel], a
	ld [hl], a
	ld bc, MON_SPECIES - MON_LEVEL
	add hl, bc
	ld a, [hl]
	ld [wCurSpecies], a
	ld [wPokedexNum], a
	call GetMonHeader
	ld bc, (MON_MAXHP + 1) - MON_SPECIES
	add hl, bc
	push hl
	ld a, [hld]
	ld c, a
	ld b, [hl]
	push bc ; push max HP (from before levelling up)
	ld d, h
	ld e, l
	ld bc, (MON_HP_EXP - 1) - MON_MAXHP
	add hl, bc
	ld b, $1 ; consider stat exp when calculating stats
	call CalcStats
	pop bc ; pop max HP (from before levelling up)
	pop hl
	ld a, [hld]
	sub c
	ld c, a
	ld a, [hl]
	sbc b
	ld b, a ; bc = difference between old max HP and new max HP after levelling
	ld de, (MON_HP + 1) - MON_MAXHP
	add hl, de
; add to the current HP the amount of max HP gained when levelling
	ld a, [hl] ; wPartyMon*HP + 1
	add c
	ld [hld], a
	ld a, [hl] ; wPartyMon*HP + 1
	adc b
	ld [hl], a ; wPartyMon*HP
	ld a, [wPlayerMonNumber]
	ld b, a
	ld a, [wWhichPokemon]
	cp b ; is the current mon in battle?
	jr nz, .printGrewLevelText
; current mon is in battle
	ld de, wBattleMonHP
; copy party mon HP to battle mon HP
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
; copy other stats from party mon to battle mon
	ld bc, MON_LEVEL - (MON_HP + 1)
	add hl, bc
	push hl
	ld de, wBattleMonLevel
	ld bc, 1 + NUM_STATS * 2 ; size of stats
	call CopyData
	pop hl
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	jr nz, .recalcStatChanges
; the mon is not transformed, so update the unmodified stats
	ld de, wPlayerMonUnmodifiedLevel
	ld bc, 1 + NUM_STATS * 2
	call CopyData
.recalcStatChanges
	xor a ; battle mon
	ld [wCalculateWhoseStats], a
	callfar CalculateModifiedStats
	callfar ApplyBurnAndParalysisPenaltiesToPlayer
	callfar ApplyBadgeStatBoosts
	callfar DrawPlayerHUDAndHPBar
	callfar PrintEmptyString
	call SaveScreenTilesToBuffer1
.printGrewLevelText
	ld hl, GrewLevelText
	call PrintText
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
IF GEN_2_GRAPHICS
	call AnimateEXPBarAgain
ELSE
	call LoadMonData
ENDC
	ld d, LEVEL_UP_STATS_BOX
	callfar PrintStatsBox
	call WaitForTextScrollButtonPress
	call LoadScreenTilesFromBuffer1
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	ld a, [wCurSpecies]
	ld [wPokedexNum], a
	predef LearnMoveFromLevelUp
	ld hl, wCanEvolveFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, FLAG_SET
	predef FlagActionPredef
	pop hl
	pop af
	ld [wCurEnemyLevel], a

.nextMon
	ld a, [wPartyCount]
	ld b, a
	ld a, [wWhichPokemon]
	inc a
	cp b
	jr z, .done
	ld [wWhichPokemon], a
	ld bc, PARTYMON_STRUCT_LENGTH
	ld hl, wPartyMon1
	call AddNTimes
	jp .partyMonLoop
.done
	ld hl, wPartyGainExpFlags
	xor a
	ld [hl], a ; clear gain exp flags
	ld a, [wPlayerMonNumber]
	ld c, a
	ld b, FLAG_SET
	push bc
	predef FlagActionPredef ; set the gain exp flag for the mon that is currently out
	ld hl, wPartyFoughtCurrentEnemyFlags
	xor a
	ld [hl], a
	pop bc
	predef_jump FlagActionPredef ; set the fought current enemy flag for the mon that is currently out

; returns in a how many shares the gained exp is being divided into: the number
; of party members with a gain exp flag, doubled when the exp is being halved by
; the exp share. preserves hl, de and bc, which the callers are using
GetExpShareDivisor:
	push hl
	push de
	push bc
	ld a, [wPartyGainExpFlags]
	and (1 << PARTY_LENGTH) - 1 ; only the party members' flags are shares
	ld e, a
	xor a
	ld c, PARTY_LENGTH
.countSetBitsLoop ; loop to count set bits in wPartyGainExpFlags
	srl e
	adc a, 0
	dec c
	jr nz, .countSetBitsLoop
	and a
	jr nz, .gotCount
	inc a ; never 0, so that it is safe to divide by
.gotCount
	ld d, a
	ld a, [wPartyGainExpFlags]
	bit 7, a ; is the exp being halved?
	ld a, d
	jr z, .done
	add a ; the share is halved: it is split into twice as many
.done
	pop bc
	pop de
	pop hl
	ret

; divide the enemy mon's base stat in a by the number of mons sharing the exp,
; rounding to the nearest point so that no stat exp is lost
DivideStatExpShare:
	ldh [hDividend + 1], a
	xor a
	ldh [hDividend], a
	call GetExpShareDivisor
	cp 2
	jr c, .noShare ; a single share: the mon gets the whole base stat
	ldh [hDivisor], a
	ld b, 2
	call Divide
	ldh a, [hRemainder]
	add a ; is the remainder at least half of the divisor?
	jr nc, .remainderFits
	ld a, $ff ; twice the remainder overflowed, so it is certainly over half
.remainderFits
	ld b, a
	call GetExpShareDivisor
	cp b
	jr c, .roundUp ; the remainder is more than half
	jr z, .roundUp ; the remainder is exactly half
	ldh a, [hQuotient + 3]
	ret
.roundUp
	ldh a, [hQuotient + 3]
	inc a
	ret
.noShare
	ldh a, [hDividend + 1]
	ret

; divide the exp the enemy mon is worth, in hQuotient, by the number of mons
; sharing it, rounding to the nearest point so that no exp is lost
DivideExpShare:
	call GetExpShareDivisor
	cp 2
	ret c ; a single share: the mon gets the whole exp
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hRemainder]
	add a ; is the remainder at least half of the divisor?
	jr nc, .remainderFits
	ld a, $ff ; twice the remainder overflowed, so it is certainly over half
.remainderFits
	ld b, a
	call GetExpShareDivisor
	cp b
	jr c, .roundUp ; the remainder is more than half
	jr z, .roundUp ; the remainder is exactly half
	ret
.roundUp
	ldh a, [hQuotient + 3]
	add a, 1
	ldh [hQuotient + 3], a
	ret nc ; the low byte didn't overflow
	ldh a, [hQuotient + 2]
	inc a
	ldh [hQuotient + 2], a
	ret

; multiplies exp by 1.5
BoostExp:
	ldh a, [hQuotient + 2]
	ld b, a
	ldh a, [hQuotient + 3]
	ld c, a
	srl b
	rr c
	add c
	ldh [hQuotient + 3], a
	ldh a, [hQuotient + 2]
	adc b
	ldh [hQuotient + 2], a
	ret

GainedText:
	text_far _GainedText
	text_asm
	ld hl, ExpPointsText
	ld a, [wGainBoostedExp]
	and a
	ret z
	ld hl, BoostedText
	ret

BoostedText:
	text_far _BoostedText

ExpPointsText:
	text_far _ExpPointsText
	text_end

GrewLevelText:
	text_far _GrewLevelText
	sound_level_up
	text_end
