	db DEX_MUNCHLAX ; pokedex id

	db 135,  85,  40,   5,  40
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 50 ; catch rate
	db 78 ; base exp

	INCBIN "gfx/pokemon/gsfront/munchlax.pic", 0, 1 ; sprite dimensions

	dw MunchlaxPicFront, MunchlaxPicBack

	db LICK, TACKLE, DEFENSE_CURL, METRONOME ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM, \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     HYPER_BEAM,   COUNTER, \
	     SEISMIC_TOSS, RAGE,         SOLARBEAM,    THUNDERBOLT,  THUNDER, \
	     EARTHQUAKE,   PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  REFLECT, \
	     BIDE,         METRONOME,    FIRE_BLAST,   SKULL_BASH,   REST, \
	     SUBSTITUTE,   SURF,         STRENGTH,     FLASH
	; end

	db BANK(MunchlaxPicFront)
