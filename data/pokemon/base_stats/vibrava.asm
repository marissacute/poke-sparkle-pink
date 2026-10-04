	db DEX_VIBRAVA ; pokedex id

	db  50,  70,  50,  70,  50
	;   hp  atk  def  spd  spc

	db GROUND, DRAGON ; type
	db 120 ; catch rate
	db 119 ; base exp

	INCBIN "gfx/pokemon/gsfront/vibrava.pic", 0, 1 ; sprite dimensions

	dw VibravaPicFront, VibravaPicBack

	db BITE, SAND_ATTACK, DIG, WING_ATTACK ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM, \
	     RAGE,         DRAGON_RAGE,  EARTHQUAKE,   FISSURE,      DIG, \
	     MIMIC,        DOUBLE_TEAM,  BIDE,         SWIFT,        REST, \
	     ROCK_SLIDE,   SUBSTITUTE,   STRENGTH,     FLY
	; end

	db BANK(VibravaPicFront)
