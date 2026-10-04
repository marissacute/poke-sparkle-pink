PrintBlackboardLinkCableText:
	call EnableAutoTextBoxDrawing
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld a, [wHiddenEventFunctionArgument]
	call PrintPredefTextID
	ret

LinkCableHelp::
	text_asm
	call SaveScreenTilesToBuffer1
	ld hl, LinkCableHelpText1
	call PrintText
	xor a
	ld [wMenuItemOffset], a ; not used
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld a, PAD_A | PAD_B
	ld [wMenuWatchedKeys], a
	ld a, 3
	ld [wMaxMenuItem], a
	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
.linkHelpLoop
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	hlcoord 0, 0
	ld b, 8
	ld c, 13
	call TextBoxBorder
	hlcoord 2, 2
	ld de, HowToLinkText
	call PlaceString
	ld hl, LinkCableHelpText2
	call PrintText
	call HandleMenuInput
	bit B_PAD_B, a
	jr nz, .exit
	ld a, [wCurrentMenuItem]
	cp 3 ; pressed a on "STOP READING"
	jr z, .exit
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ld hl, LinkCableInfoTexts
	add a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	jp .linkHelpLoop
.exit
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call LoadScreenTilesFromBuffer1
	jp TextScriptEnd

LinkCableHelpText1:
	text_far _LinkCableHelpText1
	text_end

LinkCableHelpText2:
	text_far _LinkCableHelpText2
	text_end

HowToLinkText:
	db   "HOW TO LINK"
	next "COLOSSEUM"
	next "TRADE CENTER"
	next "STOP READING@"

LinkCableInfoTexts:
	dw LinkCableInfoText1
	dw LinkCableInfoText2
	dw LinkCableInfoText3

LinkCableInfoText1:
	text_far _LinkCableInfoText1
	text_end

LinkCableInfoText2:
	text_far _LinkCableInfoText2
	text_end

LinkCableInfoText3:
	text_far _LinkCableInfoText3
	text_end

ViridianSchoolBlackboard::
	text_asm
	call SaveScreenTilesToBuffer1
	ld hl, ViridianSchoolBlackboardText1
	call PrintText
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld a, PAD_A | PAD_B
	ld [wMenuWatchedKeys], a
	ld a, 2
	ld [wMaxMenuItem], a
	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
.blackboardLoop
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	hlcoord 0, 0
	lb bc, 6, 10
	call TextBoxBorder
	hlcoord 1, 2
	ld de, BlackboardHeadingText
	call PlaceString
	ld hl, ViridianSchoolBlackboardText2
	call PrintText
	call HandleMenuInput ; pressing up and down is handled in here
	bit B_PAD_B, a ; pressed b
	jr nz, .exitBlackboard
	; we must have pressed a on a heading
	; so print the text
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ld a, [wCurrentMenuItem]
	ld hl, ViridianBlackboardTopicPointers
	add a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	jp .blackboardLoop
.exitBlackboard
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call LoadScreenTilesFromBuffer1
	jp TextScriptEnd

ViridianSchoolBlackboardText1:
	text_far _ViridianSchoolBlackboardText1
	text_end

ViridianSchoolBlackboardText2:
	text_far _ViridianSchoolBlackboardText2
	text_end

BlackboardHeadingText:
	db   " PHYSICAL"
	next " SPECIAL"
	next " ICE TYPE@"

ViridianBlackboardTopicPointers:
	dw ViridianBlackboardPhysicalText
	dw ViridianBlackboardSpecialText
	dw ViridianBlackboardIceTypeText

ViridianBlackboardPhysicalText:
	text_far _ViridianBlackboardPhysicalText
	text_end

ViridianBlackboardSpecialText:
	text_far _ViridianBlackboardSpecialText
	text_end

ViridianBlackboardIceTypeText:
	text_far _ViridianBlackboardIceTypeText
	text_end
