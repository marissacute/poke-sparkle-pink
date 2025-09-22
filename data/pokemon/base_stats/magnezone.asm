	db DEX_MAGNEZONE ; pokedex id

	db  70,  65,  110,  70, 110
	;   hp  atk  def  spd  spc

	db ELECTRIC, STEEL ; type
	db 60 ; catch rate
	db 161 ; base exp

	INCBIN "gfx/pokemon/gsfront/magnezone.pic", 0, 1 ; sprite dimensions

	dw MagnezonePicFront, MagnezonePicBack

	db TACKLE, SONICBOOM, THUNDERSHOCK, MAGNET_BOMB ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM,   RAGE,         \
	     THUNDERBOLT,  THUNDER,      TELEPORT,     MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         SWIFT,        REST,         THUNDER_WAVE, \
	     SUBSTITUTE,   FLASH
	; end

	db BANK(MagnezonePicFront)
