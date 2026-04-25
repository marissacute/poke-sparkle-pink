	db DEX_QUAGSIRE ; pokedex id

	db  95,  85,  85,  35,  65
	;   hp  atk  def  spd  spc

	db WATER, GROUND ; type
	db 90 ; catch rate
	db 137 ; base exp

	INCBIN "gfx/pokemon/gsfront/quagsire.pic", 0, 1 ; sprite dimensions

	dw QuagsirePicFront, QuagsirePicBack

	db WATER_GUN, TAIL_WHIP, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     RAGE,         FLASH,        \
	     EARTHQUAKE,   FISSURE,      DIG,          MIMIC,        DOUBLE_TEAM,  \
	     BIDE,         SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE,   \
	     SURF,         STRENGTH
	; end

	db BANK(QuagsirePicFront)
