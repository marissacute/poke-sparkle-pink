	db DEX_MISDREAVUS ; pokedex id

	db  60,  60,  60,  115, 115
	;   hp  atk  def  spd  spc

	db GHOST, FAIRY ; type
	db 45 ; catch rate
	db 147 ; base exp

	INCBIN "gfx/pokemon/gsfront/misdreavus.pic", 0, 1 ; sprite dimensions

	dw MisdreavusPicFront, MisdreavusPicBack

	db PSYWAVE, GROWL, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        FLASH,        MEGA_DRAIN,   THUNDERBOLT,  THUNDER,      \
	     PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, \
	     DREAM_EATER,  REST,         SHADOW_BALL,  EXPLOSION,    SUBSTITUTE
	; end

	db BANK(MisdreavusPicFront)
