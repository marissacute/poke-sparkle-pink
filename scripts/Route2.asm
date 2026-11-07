Route2_Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route2TrainerHeaders
	ld de, Route2_ScriptPointers
	ld a, [wRoute2CurScript]
	call ExecuteCurMapScriptInTable
	ld [wRoute2CurScript], a
	ret

Route2_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_ROUTE2_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_ROUTE2_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_ROUTE2_END_BATTLE

Route2_TextPointers:
	def_text_pointers
	dw_const PickUpItemText,             TEXT_ROUTE2_MOON_STONE
	dw_const PickUpItemText,             TEXT_ROUTE2_HP_UP
	dw_const Route2BugCatcherText,       TEXT_ROUTE2_BUG_CATCHER
	dw_const Route2SignText,             TEXT_ROUTE2_SIGN
	dw_const Route2DiglettsCaveSignText, TEXT_ROUTE2_DIGLETTS_CAVE_SIGN

Route2TrainerHeaders:
	def_trainers 3
Route2TrainerHeader0:
	trainer EVENT_BEAT_ROUTE_2_TRAINER_0, 3, Route2BugCatcherBattleText, Route2BugCatcherEndBattleText, Route2BugCatcherAfterBattleText
	db -1 ; end

Route2BugCatcherText:
	text_asm
	ld hl, Route2TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

Route2BugCatcherBattleText:
	text_far _Route2BugCatcherBattleText
	text_end

Route2BugCatcherEndBattleText:
	text_far _Route2BugCatcherEndBattleText
	text_end

Route2BugCatcherAfterBattleText:
	text_far _Route2BugCatcherAfterBattleText
	text_end

Route2SignText:
	text_far _Route2SignText
	text_end

Route2DiglettsCaveSignText:
	text_far _Route2DiglettsCaveSignText
	text_end
