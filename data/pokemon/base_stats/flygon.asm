	db DEX_FLYGON ; pokedex id

	db  80, 100,  80, 100,  80
	;   hp  atk  def  spd  spc

	db GROUND, DRAGON ; type
	db 45 ; catch rate
	db 234 ; base exp

	INCBIN "gfx/pokemon/gsfront/flygon.pic", 0, 1 ; sprite dimensions

	dw FlygonPicFront, FlygonPicBack

	db DRAGON_SLAM, SAND_ATTACK, SUPERSONIC, BITE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM, \
	     RAGE,         DRAGON_RAGE,  EARTHQUAKE,   FISSURE,      DIG, \
	     MIMIC,        DOUBLE_TEAM,  BIDE,         SWIFT,        REST, \
	     ROCK_SLIDE,   SUBSTITUTE,   STRENGTH,     FLY,          FIRE_BLAST
	; end

	db BANK(FlygonPicFront)
