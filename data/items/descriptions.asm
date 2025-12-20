PrintItemDescription::
	ld a, [wListMenuID]
	and a ; PCPOKEMONLISTMENU?
	ret z ; this only works for item menus

	ld a, [wCurrentMenuItem]
	ld c, a
	ld a, [wListScrollOffset]
	add c
	ld c, a
	ld a, [wListCount]
	cp c
	jr z, .cancel

	ld a, [wCurListMenuItem]
	cp HM01 ; is this a TM/HM?
	jr nc, .machine

	ld hl, ItemDescriptions
; Add stuff until we are at the right pointer
	ld de, 4 ; size of the data to copy
.loop
	dec a
	jr z, .copyNameData
	add hl, de
	jr .loop

.machine
	sub TM01
	jr nc, .skipAdding
	add NUM_TMS + NUM_HMS ; adjust HM IDs to come after TM IDs
.skipAdding
	inc a
	ld [wTempTMHM], a
	predef TMToMove ; get move ID from TM/HM ID
	ld a, [wTempTMHM]
	ld [wMoveNum], a
	jp PrintMoveDescription

.cancel
	ld hl, CancelMenuText
	; fallthrough

.copyNameData
	ld a, [hli]
	ld [wNameBuffer], a
	ld a, [hli]
	ld [wNameBuffer+1], a
	ld a, [hli]
	ld [wNameBuffer+2], a
	ld a, [hli]
	ld [wNameBuffer+3], a
	ld a, TX_END
	ld [wNameBuffer+4], a

	hlcoord 1, 13
	lb bc, 4, 18
	call ClearScreenArea

	ld hl, wNameBuffer
	call PrintText_NoCreatingTextBox
	ret

TMHMName:
	text_far _TMHMName

_TMHMName::
    text "Teaches a move"
	line "to a #MON."
	done

CancelMenuText:
	text_far _CancelMenuText
	text_end

_CancelMenuText::
	text "Close the menu."
	line ""
	done

ItemDescriptions:
	text_far _MasterBallDescription
	text_far _UltraBallDescription
	text_far _GreatBallDescription
	text_far _PokeBallDescription
	text_far _TownMapDescription
	text_far _BicycleDescription
	text_far _SurfboardDescription
	text_far _SafariBallDescription
	text_far _PokedexDescription
	text_far _MoonStoneDescription
	text_far _AntidoteDescription
	text_far _BurnHealDescription
	text_far _IceHealDescription
	text_far _AwakeningDescription
	text_far _ParlyzHealDescription
	text_far _FullRestoreDescription
	text_far _MaxPotionDescription
	text_far _HyperPotionDescription
	text_far _SuperPotionDescription
	text_far _PotionDescription
	text_far _BoulderBadgeDescription
	text_far _CascadeBadgeDescription
	text_far _ThunderBadgeDescription
	text_far _RainbowBadgeDescription
	text_far _SoulBadgeDescription
	text_far _MarshBadgeDescription
	text_far _VolcanoBadgeDescription
	text_far _EarthBadgeDescription
	text_far _EscapeRopeDescription
	text_far _RepelDescription
	text_far _OldAmberDescription
	text_far _FireStoneDescription
	text_far _ThunderStoneDescription
	text_far _WaterStoneDescription
	text_far _HPUpDescription
	text_far _ProteinDescription
	text_far _IronDescription
	text_far _CarbosDescription
	text_far _CalciumDescription
	text_far _RareCandyDescription
	text_far _DomeFossilDescription
	text_far _HelixFossilDescription
	text_far _SecretKeyDescription
	text_far _SunStoneDescription
	text_far _BikeVoucherDescription
	text_far _XAccuracyDescription
	text_far _LeafStoneDescription
	text_far _CardKeyDescription
	text_far _NuggetDescription
	text_far _MetalCoatDescription
	text_far _PokeDollDescription
	text_far _FullHealDescription
	text_far _ReviveDescription
	text_far _MaxReviveDescription
	text_far _GuardSpecDescription
	text_far _SuperRepelDescription
	text_far _MaxRepelDescription
	text_far _DireHitDescription
	text_far _CoinDescription
	text_far _FreshWaterDescription
	text_far _SodaPopDescription
	text_far _LemonadeDescription
	text_far _SSTicketDescription
	text_far _GoldTeethDescription
	text_far _XAttackDescription
	text_far _XDefendDescription
	text_far _XSpeedDescription
	text_far _XSpecialDescription
	text_far _CoinCaseDescription
	text_far _OaksParcelDescription
	text_far _ItemfinderDescription
	text_far _SilphScopeDescription
	text_far _PokeFluteDescription
	text_far _LiftKeyDescription
	text_far _ExpAllDescription
	text_far _OldRodDescription
	text_far _GoodRodDescription
	text_far _SuperRodDescription
	text_far _PPUpDescription
	text_far _EtherDescription
	text_far _MaxEtherDescription
	text_far _ElixerDescription
	text_far _MaxElixerDescription

_MasterBallDescription::
	text "Will catch #MON"
	line "without fail."
	done

_UltraBallDescription::
	text "A top quality"
	line "POKé BALL."
	done

_GreatBallDescription::
	text "A good quality"
	line "POKé BALL."
	done

_PokeBallDescription::
	text "Used to catch"
	line "#MON."
	done

_TownMapDescription::
	text "A map of the"
	line "#MON world."
	done

_BicycleDescription::
	text "Allows faster"
	line "travel."
	done

_SurfboardDescription::
	text "A board for"
	line "riding waves."
	done

_SafariBallDescription::
	text "A special BALL"
	line "for the SAFARI."
	done

_PokedexDescription::
	text "Records data on"
	line "#MON."
	done

_MoonStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_AntidoteDescription::
	text "Heals a poisoned"
	line "#MON."
	done

_BurnHealDescription::
	text "Heals a burned"
	line "#MON."
	done

_IceHealDescription::
	text "Defrosts a frozen"
	line "#MON."
	done

_AwakeningDescription::
	text "Wakes a sleeping"
	line "#MON."
	done

_ParlyzHealDescription::
	text "Heals a paralyzed"
	line "#MON."
	done

_FullRestoreDescription::
	text "Fully restores HP"
	line "and status."
	done

_MaxPotionDescription::
	text "Fully restores"
	line "HP."
	done

_HyperPotionDescription::
	text "Restores 200 HP."
	line ""
	done

_SuperPotionDescription::
	text "Restores 50 HP."
	line ""
	done

_PotionDescription::
	text "Restores 20 HP."
	line ""
	done

_BoulderBadgeDescription::
	text "A badge from"
	line "PEWTER CITY."
	done

_CascadeBadgeDescription::
	text "A badge from"
	line "CERULEAN CITY."
	done

_ThunderBadgeDescription::
	text "A badge from"
	line "VERMILION CITY."
	done

_RainbowBadgeDescription::
	text "A badge from"
	line "CELADON CITY."
	done

_SoulBadgeDescription::
	text "A badge from"
	line "FUCHSIA CITY."
	done

_MarshBadgeDescription::
	text "A badge from"
	line "SAFFRON CITY."
	done

_VolcanoBadgeDescription::
	text "A badge from"
	line "CINNABAR ISLAND."
	done

_EarthBadgeDescription::
	text "A badge from"
	line "VIRIDIAN CITY."
	done

_EscapeRopeDescription::
	text "Use to escape"
	line "instantly."
	done

_RepelDescription::
	text "Repels weak"
	line "#MON."
	done

_OldAmberDescription::
	text "An ancient"
	line "fossil."
	done

_FireStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_ThunderStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_WaterStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_HPUpDescription::
	text "Raises base"
	line "HP points."
	done

_ProteinDescription::
	text "Raises base"
	line "ATTACK points."
	done

_IronDescription::
	text "Raises base"
	line "DEFENSE points."
	done

_CarbosDescription::
	text "Raises base"
	line "SPEED points."
	done

_CalciumDescription::
	text "Raises base"
	line "SPECIAL points."
	done

_RareCandyDescription::
	text "Raises level by"
	line "one."
	done

_DomeFossilDescription::
	text "A fossil of an"
	line "ancient #MON."
	done

_HelixFossilDescription::
	text "A fossil of an"
	line "ancient #MON."
	done

_SecretKeyDescription::
	text "Opens a locked"
	line "door."
	done

_SunStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_BikeVoucherDescription::
	text "Can be exchanged"
	line "for a BICYCLE."
	done

_XAccuracyDescription::
	text "Raises accuracy"
	line "in battle."
	done

_LeafStoneDescription::
	text "Evolves certain"
	line "#MON."
	done

_CardKeyDescription::
	text "Opens SILPH CO."
	line "doors."
	done

_NuggetDescription::
	text "Can be sold for"
	line "a high price."
	done

_MetalCoatDescription::
	text "Evolves certain"
	line "#MON."
	done

_PokeDollDescription::
	text "Use to escape"
	line "battle."
	done

_FullHealDescription::
	text "Eliminates all"
	line "status."
	done

_ReviveDescription::
	text "Revives fainted"
	line "#MON."
	done

_MaxReviveDescription::
	text "Fully revives"
	line "#MON."
	done

_GuardSpecDescription::
	text "Prevents stat loss"
	line "in battle."
	done

_SuperRepelDescription::
	text "Repels weak"
	line "#MON longer."
	done

_MaxRepelDescription::
	text "Repels weak"
	line "#MON longest."
	done

_DireHitDescription::
	text "Raises critical"
	line "hit chance."
	done

_CoinDescription::
	text "Used at GAME"
	line "CORNER."
	done

_FreshWaterDescription::
	text "Restores 50 HP."
	line ""
	done

_SodaPopDescription::
	text "Restores 60 HP."
	line ""
	done

_LemonadeDescription::
	text "Restores 80 HP."
	line ""
	done

_SSTicketDescription::
	text "A ticket for"
	line "the S.S. ANNE."
	done

_GoldTeethDescription::
	text "A set of gold"
	line "teeth."
	done

_XAttackDescription::
	text "Raises ATTACK"
	line "in battle."
	done

_XDefendDescription::
	text "Raises DEFENSE"
	line "in battle."
	done

_XSpeedDescription::
	text "Raises SPEED"
	line "in battle."
	done

_XSpecialDescription::
	text "Raises SPECIAL"
	line "in battle."
	done

_CoinCaseDescription::
	text "Holds GAME"
	line "CORNER COINS."
	done

_OaksParcelDescription::
	text "A parcel for"
	line "PROF. OAK."
	done

_ItemfinderDescription::
	text "Finds hidden"
	line "items."
	done

_SilphScopeDescription::
	text "Identifies ghost"
	line "#MON."
	done

_PokeFluteDescription::
	text "Awakens sleeping"
	line "#MON."
	done

_LiftKeyDescription::
	text "Opens elevator"
	line "doors."
	done

_ExpAllDescription::
	text "Shares EXP with"
	line "all #MON."
	done

_OldRodDescription::
	text "Used to fish"
	line "#MON."
	done

_GoodRodDescription::
	text "A good fishing"
	line "rod."
	done

_SuperRodDescription::
	text "The best fishing"
	line "rod."
	done

_PPUpDescription::
	text "Raises max PP."
	line ""
	done

_EtherDescription::
	text "Restores PP"
	line "for a move."
	done

_MaxEtherDescription::
	text "Fully restores"
	line "a move's PP."
	done

_ElixerDescription::
	text "Restores PP"
	line "for all moves."
	done

_MaxElixerDescription::
	text "Fully restores"
	line "all PP."
	done
