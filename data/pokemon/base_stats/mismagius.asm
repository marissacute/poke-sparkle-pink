	db DEX_MISMAGIUS ; pokedex id

	db  60,  60,  60, 105, 105
	;   hp  atk  def  spd  spc

	db GHOST, GHOST ; type
	db 45 ; catch rate
	db 173 ; base exp

	INCBIN "gfx/pokemon/gsfront/mismagius.pic", 0, 1 ; sprite dimensions

	dw MismagiusPicFront, MismagiusPicBack

	db GROWL, CONFUSION, CONFUSE_RAY, NIGHT_SHADE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        FLASH,        MEGA_DRAIN,   THUNDERBOLT,  THUNDER, \
	     PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, \
	     DREAM_EATER,  REST,         SHADOW_BALL,  EXPLOSION,    SUBSTITUTE
	; end

	db BANK(MismagiusPicFront)
