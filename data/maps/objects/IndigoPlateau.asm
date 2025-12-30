IndigoPlateau_Object:
	db $e ; border block

	def_warp_events
	warp_event 17,  5, INDIGO_PLATEAU_LOBBY, 1
	warp_event 18,  5, INDIGO_PLATEAU_LOBBY, 1
	warp_event  3,  5, WORLD_CHAMPIONSHIP, 1
	warp_event  4,  5, WORLD_CHAMPIONSHIP, 2

	def_bg_events

	def_object_events

	def_warps_to INDIGO_PLATEAU
