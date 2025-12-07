CeruleanCaveB1F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CeruleanCaveB1FTrainerHeaders
	ld de, CeruleanCaveB1F_ScriptPointers
	ld a, [wCeruleanCaveB1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeruleanCaveB1FCurScript], a
	ret

CeruleanCaveB1FResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wCeruleanCaveB1FCurScript], a
	ld [wCurMapScript], a
	ret

CeruleanCaveB1F_ScriptPointers:
	def_script_pointers
	dw_const CeruleanCaveB1FDefaultScript,          SCRIPT_CERULEANCAVEB1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_CERULEANCAVEB1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_CERULEANCAVEB1F_END_BATTLE
	dw_const CeruleanCaveB1FMewtwoPostBattleScript, SCRIPT_CERULEANCAVEB1F_MEWTWO_POST_BATTLE

CeruleanCaveB1F_TextPointers:
	def_text_pointers
	dw_const MewtwoStartBattle, 		TEXT_CERULEANCAVEB1F_MEWTWO
	dw_const PickUpItemText,            TEXT_CERULEANCAVEB1F_ULTRA_BALL
	dw_const PickUpItemText,            TEXT_CERULEANCAVEB1F_MAX_REVIVE
	dw_const MewtwoAfterBattleText, 	TEXT_CERULEANCAVEB1F_MEWTWO_AFTER_BATTLE

MewtwoStartBattle:
	text_far _MewtwoBeforeBattleText
	text_asm
	ld a, MEWTWO
	call PlayCry
	call WaitForSoundToFinish
	SetEvent EVENT_FIGHT_MEWTWO
	jp TextScriptEnd

CeruleanCaveB1FDefaultScript:
	CheckEventHL EVENT_BEAT_MEWTWO
	jp nz, CheckFightingMapTrainers
	CheckEventReuseHL EVENT_FIGHT_MEWTWO
	ResetEventReuseHL EVENT_FIGHT_MEWTWO
	jp z, CheckFightingMapTrainers
	ld a, MEWTWO
	ld [wCurOpponent], a
	ld a, 70
	ld [wCurEnemyLevel], a
	ld a, HS_MEWTWO
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, SCRIPT_CERULEANCAVEB1F_MEWTWO_POST_BATTLE
	ld [wCeruleanCaveB1FCurScript], a
	ld [wCurMapScript], a
	ret

CeruleanCaveB1FMewtwoPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, CeruleanCaveB1FResetScripts
	call UpdateSprites
	ld a, TEXT_CERULEANCAVEB1F_MEWTWO_AFTER_BATTLE
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_MEWTWO
	call Delay3
	ld a, SCRIPT_CERULEANCAVEB1F_DEFAULT
	ld [wCeruleanCaveB1FCurScript], a
	ld [wCurMapScript], a
	ret
	
MewtwoAfterBattleText:
	text_far _MewtwoAfterBattleText
	text_end

CeruleanCaveB1FTrainerHeaders:
	def_trainers
	db -1 ; end