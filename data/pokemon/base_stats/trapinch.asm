	db DEX_TRAPINCH ; pokedex id

	db  45, 100,  45,  10,  45
	;   hp  atk  def  spd  spc

	db GROUND, GROUND ; type
	db 255 ; catch rate
	db 58 ; base exp

	INCBIN "gfx/pokemon/gsfront/trapinch.pic", 0, 1 ; sprite dimensions

	dw TrapinchPicFront, TrapinchPicBack

	db SAND_ATTACK, BITE, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM, \
	     RAGE,         EARTHQUAKE,   FISSURE,      DIG,          MIMIC, \
	     DOUBLE_TEAM,  BIDE,         REST,         ROCK_SLIDE,   SUBSTITUTE, \
	     STRENGTH
	; end

	db BANK(TrapinchPicFront)
