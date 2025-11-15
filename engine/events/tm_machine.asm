DisplayTMMachine_::
	ld hl, TMMachineGreetingText
	call PrintText
	call SaveScreenTilesToBuffer1
.buyMenuLoop
	call LoadScreenTilesFromBuffer1

    ; Display the box that shows how much money you have
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID

    ; Load our item list
	ld hl, TMMachineItemList 
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a

    ; Set options for DisplayListMenuID
	xor a 
	ld [wCurrentMenuItem], a ; wCurrentMenuItem = 0
	inc a
	ld [wPrintItemPrices], a ; wPrintItemPrices = TRUE
	inc a ; a = 2 (PRICEDITEMLISTMENU)
	ld [wListMenuID], a ; wListMenuID = PRICEDITEMLISTMENU
	call DisplayListMenuID

    ; If the player closed the menu
	jp c, .done 

	ld a, [wCurItem]
	ld [wNamedObjectIndex], a

    ld a, 1
	ld [wItemQuantity], a ; buy 1 TM

	; load final price from hItemPrice
	ld a, [hItemPrice]
	ld [hMoney], a
	ld a, [hItemPrice+1]
	ld [hMoney+1], a
	ld a, [hItemPrice+2]
	ld [hMoney+2], a

	call GetItemName
	call CopyToStringBuffer
	ld hl, TMMachineTellBuyPriceText
	call PrintText
	hlcoord 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID ; yes/no menu
	ld a, [wMenuExitMethod]
	cp CHOSE_SECOND_ITEM
	jp z, .buyMenuLoop ; if the player chose No or pressed the B button

.buyItem
	call .isThereEnoughMoney
	jr c, .notEnoughMoney
	ld hl, wNumBagItems
	call AddItemToInventory
	jr nc, .bagFull
	call SubtractAmountPaidFromMoney
	ld a, [wBoughtOrSoldItemInMart]
	and a
	jr nz, .skipSettingFlag2
	ld a, 1
	ld [wBoughtOrSoldItemInMart], a

.skipSettingFlag2
	ld b, 60 ; number of times to play the "brrrrr" sound
.playDeliverySound
	ld c, 2
	call DelayFrames
	push bc
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	pop bc
	dec b
	jr nz, .playDeliverySound

	ld hl, TMMachineBoughtItemText
	call PrintText
	jp .buyMenuLoop

.isThereEnoughMoney
	ld de, wPlayerMoney
	ld hl, hMoney
	ld c, 3 ; length of money in bytes
	jp StringCmp
.notEnoughMoney
	ld hl, TMMachineNotEnoughMoneyText
	call PrintText
	jr .done
.bagFull
	ld hl, TMMachineItemBagFullText
	call PrintText
	jr .done

.done
	ld hl, TMMachineThankYouText
	call PrintText
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	call UpdateSprites
	ld a, [wSavedListScrollOffset]
	ld [wListScrollOffset], a
	ret

TMMachineItemList:
    db 50
    db TM_MEGA_PUNCH
    db TM_RAZOR_WIND
    db TM_SWORDS_DANCE
	db TM_WHIRLWIND
	db TM_MEGA_KICK
	db TM_TOXIC
	db TM_HORN_DRILL
	db TM_BODY_SLAM
	db TM_TAKE_DOWN
	db TM_DOUBLE_EDGE
	db TM_BUBBLEBEAM
	db TM_WATER_GUN
	db TM_ICE_BEAM
	db TM_BLIZZARD
	db TM_HYPER_BEAM
	db TM_PAY_DAY
	db TM_SUBMISSION
	db TM_COUNTER
	db TM_SEISMIC_TOSS
	db TM_RAGE
	db TM_MEGA_DRAIN
	db TM_SOLARBEAM
	db TM_DRAGON_RAGE
	db TM_THUNDERBOLT
	db TM_THUNDER
	db TM_EARTHQUAKE
	db TM_FISSURE
	db TM_DIG
	db TM_PSYCHIC_M
	db TM_TELEPORT
	db TM_MIMIC
	db TM_DOUBLE_TEAM
	db TM_REFLECT
	db TM_BIDE
	db TM_METRONOME
	db TM_SELFDESTRUCT
	db TM_EGG_BOMB
	db TM_FIRE_BLAST
	db TM_SWIFT
	db TM_SKULL_BASH
	db TM_SOFTBOILED
	db TM_DREAM_EATER
	db TM_SKY_ATTACK
	db TM_REST
	db TM_THUNDER_WAVE
	db TM_SHADOW_BALL
	db TM_EXPLOSION
	db TM_ROCK_SLIDE
	db TM_TRI_ATTACK
	db TM_SUBSTITUTE
	db $ff

TMMachineGreetingText:
	text_far _TMMachineGreetingText
	text_end

TMMachineTellBuyPriceText:
	text_far _TMMachineTellBuyPriceText
	text_end

TMMachineBoughtItemText:
	text_far _TMMachineBoughtItemText
	text_end

TMMachineNotEnoughMoneyText:
	text_far _TMMachineNotEnoughMoneyText
	text_end

TMMachineItemBagFullText:
	text_far _TMMachineItemBagFullText
	text_end

TMMachineThankYouText:
	text_far _TMMachineThankYouText
	text_end