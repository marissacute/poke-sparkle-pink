	db DEX_UMBREON ; pokedex id

	db  95,  65, 110,  65,  95
	;   hp  atk  def  spd  spc

	db DARK, DARK ; type
	db 45 ; catch rate
	db 196 ; base exp

IF GEN_2_GRAPHICS
	INCBIN "gfx/pokemon/gsfront/umbreon.pic", 0, 1 ; sprite dimensions
ELSE
	INCBIN "gfx/pokemon/front/umbreon.pic", 0, 1 ; sprite dimensions
ENDC
	dw UmbreonPicFront, UmbreonPicBack

	db TACKLE, SAND_ATTACK, QUICK_ATTACK, FEINT_ATTACK ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         SUBSTITUTE,   COUNTER
	; end

	db BANK(UmbreonPicFront)
