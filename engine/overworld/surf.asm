; if the player is facing water, offer to surf on it
; wTileInFrontOfPlayer is set by the A button handler before this is called
TrySurfWaterInteraction::
	ld a, [wWalkBikeSurfState]
	cp 2 ; surfing
	ret z ; don't offer to surf if the player is already surfing
	call IsNextTileShoreOrWater
	ret c
	call EnableAutoTextBoxDrawing
	tx_pre_jump SurfWaterText

; text script that shows the water text and offers to surf
SurfWaterText::
	text_asm
	ld hl, WaterIsDyedDeepBlueText
	call PrintText
; if the player has a mon that knows SURF and the Soul Badge, offer to surf
	ld a, [wObtainedBadges]
	bit BIT_SOULBADGE, a
	jr z, .done
	ld a, SURF
	call CheckPartyMonHasMove
	jr nc, .done
	ld hl, WouldYouLikeToSurfText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .done ; the player chose not to surf
	farcall IsSurfingAllowed
	ld hl, wStatusFlags1
	bit BIT_SURF_ALLOWED, [hl]
	res BIT_SURF_ALLOWED, [hl]
	jr z, .done ; surfing isn't allowed here
; put the name of the mon that knows SURF in wNameBuffer so the text
; "<PLAYER> got on <mon>" shows the correct name
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	lda_coord 8, 9
	ld [wTilePlayerStandingOn], a ; checked by ItemUseSurfboard for forbidden tile pairs
; surf on the water (same routine as using SURF from the pokemon menu)
	ld a, SURFBOARD
	ld [wCurItem], a
	ld [wPseudoItemID], a
	call UseItem
.done
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

WaterIsDyedDeepBlueText:
	text_far _WaterIsDyedDeepBlueText
	text_end

WouldYouLikeToSurfText:
	text_far _WouldYouLikeToSurfText
	text_end
