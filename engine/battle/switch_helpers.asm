; Helpers for moves that force a Pokémon to switch (Roar, Whirlwind, and
; Teleport in trainer battles). Kept out of Battle Core, which is full.

; Picks a random able enemy party member other than the active one and stores
; its index in wWhichPokemon. Returns carry set if there is no other able mon.
ChooseRandomEnemyMon:
	ld a, [wEnemyPartyCount]
	and a
	jr z, .none
	ld b, a
	ld c, 0
	ld hl, wEnemyMon1HP
.checkLoop
	ld a, [wEnemyMonPartyPos]
	cp c
	jr z, .nextSlot
	push hl
	ld a, [hli]
	or [hl]
	pop hl
	jr nz, .pick
.nextSlot
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	inc c
	dec b
	jr nz, .checkLoop
.none
	scf
	ret
.pick
	callfar BattleRandom
	ld b, a
	ld a, [wEnemyPartyCount]
	cp b
	jr c, .pick
	jr z, .pick
	ld a, [wEnemyMonPartyPos]
	cp b
	jr z, .pick
	ld a, b
	ld [wWhichPokemon], a
	ld hl, wEnemyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld a, [hli]
	or [hl]
	jr z, .pick
	ld a, [wWhichPokemon]
	and a
	ret

; Picks a random able player party member other than the active one and stores
; its index in wWhichPokemon. Returns carry set if there is no other able mon.
ChooseRandomPlayerMon:
	ld a, [wPartyCount]
	and a
	jr z, .none
	ld b, a
	ld c, 0
	ld hl, wPartyMon1HP
.checkLoop
	ld a, [wPlayerMonNumber]
	cp c
	jr z, .nextSlot
	push hl
	ld a, [hli]
	or [hl]
	pop hl
	jr nz, .pick
.nextSlot
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	inc c
	dec b
	jr nz, .checkLoop
.none
	scf
	ret
.pick
	callfar BattleRandom
	ld b, a
	ld a, [wPartyCount]
	cp b
	jr c, .pick
	jr z, .pick
	ld a, [wPlayerMonNumber]
	cp b
	jr z, .pick
	ld a, b
	ld [wWhichPokemon], a
	ld hl, wPartyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld a, [hli]
	or [hl]
	jr z, .pick
	ld a, [wWhichPokemon]
	and a
	ret

; Sends out the enemy mon whose index is already in wWhichPokemon. The current
; enemy's HP and status are saved to the roster first. Unlike SwitchEnemyMon,
; this prints no "withdrew" message, so the caller can print its own (Roar and
; Whirlwind print "was blown away!").
ForceEnemySwitch:
	ld a, [wEnemyMonPartyPos]
	ld hl, wEnemyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, wEnemyMonHP
	ld bc, MON_STATUS + 1 - MON_HP ; also copies party pos in-between HP and status
	call CopyData
	ld a, 1
	ld [wForcedEnemySwitch], a
	ld [wFirstMonsNotOutYet], a
	callfar EnemySendOut
	xor a
	ld [wFirstMonsNotOutYet], a
	ret
