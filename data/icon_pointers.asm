; Party menu icon graphics, indexed by the ICON_* constants
; (see constants/icon_constants.asm). Each icon is 16x16 pixels: the first
; MON_ICON_TILES tiles of the graphics are the top (static) animation frame.
MACRO mon_icon
	dw \1 ; graphics
	db BANK(\1)
ENDM

MonIconTable:
	table_width 3, MonIconTable
	mon_icon PoliwagIcon
	mon_icon JigglypuffIcon
	mon_icon DiglettIcon
	mon_icon PikachuIcon
	mon_icon StaryuIcon
	mon_icon FishIcon
	mon_icon BirdIcon
	mon_icon MonsterIcon
	mon_icon ClefairyIcon
	mon_icon OddishIcon
	mon_icon BugIcon
	mon_icon GhostIcon
	mon_icon LaprasIcon
	mon_icon HumanshapeIcon
	mon_icon FoxIcon
	mon_icon EquineIcon
	mon_icon ShellIcon
	mon_icon BlobIcon
	mon_icon SerpentIcon
	mon_icon VoltorbIcon
	mon_icon SquirtleIcon
	mon_icon BulbasaurIcon
	mon_icon CharmanderIcon
	mon_icon CaterpillarIcon
	mon_icon UnownIcon
	mon_icon GeodudeIcon
	mon_icon FighterIcon
	mon_icon EggIcon
	mon_icon JellyfishIcon
	mon_icon MothIcon
	mon_icon BatIcon
	mon_icon SnorlaxIcon
	mon_icon HoOhIcon
	mon_icon LugiaIcon
	mon_icon GyaradosIcon
	mon_icon SlowpokeIcon
	mon_icon SudowoodoIcon
	mon_icon BigmonIcon
	assert_table_length NUM_MON_ICONS
