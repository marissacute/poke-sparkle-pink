	object_const_def
	const_export FUCHSIAMOVEHOUSE_MOVE_DELETER
	const_export FUCHSIAMOVEHOUSE_MOVE_RELEARNER

FuchsiaMoveHouse_Object:
	db $a ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 10
	warp_event  3,  7, LAST_MAP, 10

	def_bg_events

	def_object_events
	object_event  3,  5, SPRITE_MIDDLE_AGED_MAN, STAY, UP, TEXT_FUCHSIAMOVEHOUSE_MOVE_DELETER
	object_event  5,  4, SPRITE_FISHER, STAY, LEFT, TEXT_FUCHSIAMOVEHOUSE_MOVE_RELEARNER

	def_warps_to FUCHSIA_MOVE_HOUSE
