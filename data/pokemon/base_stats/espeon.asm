	db DEX_ESPEON ; pokedex id

	db  65,  65,  60,  110,  130
	;   hp  atk  def  spd  spc

	db PSYCHIC_TYPE, PSYCHIC_TYPE ; type
	db 45 ; catch rate
	db 196 ; base exp

IF GEN_2_GRAPHICS
	INCBIN "gfx/pokemon/gsfront/espeon.pic", 0, 1 ; sprite dimensions
ELSE
	INCBIN "gfx/pokemon/front/espeon.pic", 0, 1 ; sprite dimensions
ENDC
	dw EspeonPicFront, EspeonPicBack

	db TACKLE, SAND_ATTACK, QUICK_ATTACK, CONFUSION ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         SUBSTITUTE,   PSYCHIC_M,    SHADOW_BALL,  \
	     TRI_ATTACK
	; end

	db BANK(EspeonPicFront)
