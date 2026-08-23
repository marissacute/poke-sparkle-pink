; if the player is facing a boulder, offer to use STRENGTH to move boulders
; hTextID is the sprite index of the sprite in front of the player, as found
; by the A button handler before this is called
TryStrengthInteraction::
	xor a
	ld [wStrengthInteractionFlag], a ; assume the strength text wasn't shown
	ld a, [wStatusFlags1]
	bit BIT_STRENGTH_ACTIVE, a
	ret nz ; strength is already active, so boulders can already be pushed
	ldh a, [hTextID]
	and a
	ret z ; no sprite in front of the player (i.e. the start menu was opened)
	ld b, a ; sprite index
	ld a, [wNumSprites]
	cp b
	ret c ; hTextID isn't a sprite index (i.e. it's a sign's text ID)
	call GetSpriteMovementByte2Pointer
	ld a, [hl]
	cp BOULDER_MOVEMENT_BYTE_2
	ret nz ; the sprite in front of the player is not a boulder
; the sprite in front of the player is a boulder, so display the strength
; boulder text instead of the text of the boulder sprite; the call never
; returns to the A button handler, it unwinds past it, so the flag is how
; the A button handler tells that the strength text was shown
	ld a, 1
	ld [wStrengthInteractionFlag], a
	call EnableAutoTextBoxDrawing
	tx_pre_jump StrengthBoulderText

; text script that shows the boulder text and offers to use STRENGTH
StrengthBoulderText::
	text_asm
	ld hl, BoulderMayBePushableText
	call PrintText
; if the player has a mon that knows STRENGTH and the Rainbow Badge, offer to use it
	ld a, [wObtainedBadges]
	bit BIT_RAINBOWBADGE, a
	jr z, .done
	ld a, STRENGTH
	call CheckPartyMonHasMove
	jr nc, .done
	ld hl, WouldYouLikeToUseStrengthText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .done ; the player chose not to use strength
; put the name of the mon that knows STRENGTH in wNameBuffer so the text
; "<mon> used STRENGTH!" shows the correct name, and its species in
; wCurPartySpecies so the correct cry plays
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld a, [hl]
	ld [wCurPartySpecies], a
; use strength (same routine as using STRENGTH from the pokemon menu)
	predef PrintStrengthText
.done
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

BoulderMayBePushableText:
	text_far _BoulderMayBePushableText
	text_end

WouldYouLikeToUseStrengthText:
	text_far _WouldYouLikeToUseStrengthText
	text_end
