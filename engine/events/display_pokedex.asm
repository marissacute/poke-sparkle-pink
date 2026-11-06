_DisplayPokedex::
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	predef ShowPokedexData
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call ReloadMapData
	ld c, 10
	call DelayFrames
	predef IndexToPokedex
	ld a, [wPokedexNum]
	and a
	jr z, .skipSeenFlag ; MissingNo. has no dex entry
	dec a
	ld c, a
	ld b, FLAG_SET
	ld hl, wPokedexSeen
	predef FlagActionPredef
.skipSeenFlag
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret
