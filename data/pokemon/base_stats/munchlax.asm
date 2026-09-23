	db DEX_MUNCHLAX ; pokedex id

	db 135,  85,  40,   5,  40
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 50 ; catch rate
	db 78 ; base exp

	INCBIN "gfx/pokemon/gsfront/munchlax.pic", 0, 1 ; sprite dimensions

	dw MunchlaxPicFront, MunchlaxPicBack

	db TACKLE, LICK, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  BUBBLEBEAM,   WATER_GUN,    ICE_BEAM,     BLIZZARD,     \
	     HYPER_BEAM,   PAY_DAY,      SUBMISSION,   COUNTER,      SEISMIC_TOSS, \
	     RAGE,         SOLARBEAM,    THUNDERBOLT,  THUNDER,      EARTHQUAKE,   \
	     FISSURE,      PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  REFLECT,      \
	     BIDE,         METRONOME,    SELFDESTRUCT, FIRE_BLAST,   SKULL_BASH,   \
	     REST,         ROCK_SLIDE,   SUBSTITUTE,   SURF,         SHADOW_BALL,   \
	     STRENGTH
	; end

	db BANK(MunchlaxPicFront)
