	db DEX_CLODSIRE ; pokedex id

	db  130,  75,  60,  20,  80
	;   hp  atk  def  spd  spc

	db POISON, GROUND ; type
	db 90 ; catch rate
	db 151 ; base exp

	INCBIN "gfx/pokemon/gsfront/clodsire.pic", 0, 1 ; sprite dimensions

	dw ClodsirePicFront, ClodsirePicBack

	db POISON_STING, TAIL_WHIP, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        HORN_DRILL,   BODY_SLAM,    \
	     TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   WATER_GUN,    HYPER_BEAM,   \
	     SUBMISSION,   COUNTER,      SEISMIC_TOSS, RAGE,         EARTHQUAKE,   \
	     FISSURE,      MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         \
	     FIRE_BLAST,   SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE,   \
	     SURF,         STRENGTH  
	; end

	db BANK(ClodsirePicFront)
