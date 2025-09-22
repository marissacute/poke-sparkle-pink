	db DEX_ESPEON ; pokedex id

	db  100,  70,  70,  60,  130
	;   hp  atk  def  spd  spc

	db FAIRY, FAIRY ; type
	db 45 ; catch rate
	db 196 ; base exp

	INCBIN "gfx/pokemon/gsfront/sylveon.pic", 0, 1 ; sprite dimensions

	dw SylveonPicFront, SylveonPicBack

	db TACKLE, SAND_ATTACK, QUICK_ATTACK, FAIRY_WIND ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         SUBSTITUTE,   PSYCHIC_M,    TRI_ATTACK,   \
	     SHADOW_BALL
	; end

	db BANK(SylveonPicFront)
