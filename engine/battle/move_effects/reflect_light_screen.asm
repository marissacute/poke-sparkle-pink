ReflectLightScreenEffect_:
; Light Screen and Reflect are side conditions (see wPlayerLightScreenTurns).
; They last five turns, counting the turn they are used, and fail if the same
; screen is already up on the user's side.
	ldh a, [hWhoseTurn]
	and a
	ld de, wPlayerLightScreenTurns
	ld hl, wPlayerMoveEffect
	jr z, .gotSide
	ld de, wEnemyLightScreenTurns
	ld hl, wEnemyMoveEffect
.gotSide
	ld a, [hl]
	cp LIGHT_SCREEN_EFFECT
	ld hl, LightScreenProtectedText
	jr z, .lightScreen
	inc de ; point at the Reflect counter
	ld hl, ReflectGainedArmorText
.lightScreen
	ld a, [de]
	and a ; is this screen already up?
	jr nz, .moveFailed
	ld a, 5
	ld [de], a
	push hl
	ld hl, PlayCurrentMoveAnimation
	call EffectCallBattleCore
	pop hl
	jp PrintText
.moveFailed
	ld c, 50
	call DelayFrames
	ld hl, PrintButItFailedText_
	jp EffectCallBattleCore

LightScreenProtectedText:
	text_far _LightScreenProtectedText
	text_end

ReflectGainedArmorText:
	text_far _ReflectGainedArmorText
	text_end

EffectCallBattleCore:
	ld b, BANK(BattleCore)
	jp Bankswitch
