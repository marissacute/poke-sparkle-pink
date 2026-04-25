	db DEX_WOOPER ; pokedex id

	db  55,  45,  45,  15,  25
	;   hp  atk  def  spd  spc

	db WATER, GROUND ; type
	db 255 ; catch rate
	db 52 ; base exp

	INCBIN "gfx/pokemon/gsfront/wooper.pic", 0, 1 ; sprite dimensions

	dw WooperPicFront, WooperPicBack

	db WATER_GUN, TAIL_WHIP, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     RAGE,         FLASH,        \
	     EARTHQUAKE,   FISSURE,      DIG,          MIMIC,        DOUBLE_TEAM,  \
	     BIDE,         SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE,   \
	     SURF,         STRENGTH
	; end

	db BANK(WooperPicFront)
