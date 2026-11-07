	db DEX_KOFFING ; pokedex id

	db  40,  65,  95,  35,  60
	;   hp  atk  def  spd  spc

	db POISON, FAIRY ; type
	db 190 ; catch rate
	db 114 ; base exp

	INCBIN "gfx/pokemon/gsfront/koffing.pic", 0, 1 ; sprite dimensions

	dw KoffingPicFront, KoffingPicBack

	db TACKLE, SMOG, SMOKESCREEN, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        RAGE,         THUNDERBOLT,  THUNDER,      MIMIC,        \
	     DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, FIRE_BLAST,   REST,         \
	     EXPLOSION,    SUBSTITUTE,   SHADOW_BALL
	; end

	db BANK(KoffingPicFront)
