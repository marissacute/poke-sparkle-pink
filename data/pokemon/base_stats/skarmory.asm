	db DEX_SKARMORY ; pokedex id

	db  65,  80, 140,  70,  40
	;   hp  atk  def  spd  spc

	db STEEL, FLYING ; type
	db 25 ; catch rate
	db 163 ; base exp

	INCBIN "gfx/pokemon/gsfront/skarmory.pic", 0, 1 ; sprite dimensions

	dw SkarmoryPicFront, SkarmoryPicBack

	db LEER, PECK, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm RAZOR_WIND,   WHIRLWIND,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  HYPER_BEAM,   COUNTER,      RAGE,         MIMIC,        \
	     DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        SKY_ATTACK,   \
	     REST,         SUBSTITUTE,   CUT,          FLY
	; end

	db BANK(SkarmoryPicFront)
