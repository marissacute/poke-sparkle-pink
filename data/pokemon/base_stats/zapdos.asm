	db DEX_ZAPDOS ; pokedex id

	db  90, 125, 90, 100, 85
	;   hp  atk  def  spd  spc

	db FIGHTING, FLYING ; type
	db 3 ; catch rate
	db 216 ; base exp

	INCBIN "gfx/pokemon/gsfront/zapdos.pic", 0, 1 ; sprite dimensions

	dw ZapdosPicFront, ZapdosPicBack

	db DOUBLE_KICK, DRILL_PECK, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm RAZOR_WIND,   WHIRLWIND,    TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  \
	     HYPER_BEAM,   RAGE,         SUBMISSION,   EARTHQUAKE,   MIMIC,        \
	     DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        SKY_ATTACK,   \
	     REST,         SEISMIC_TOSS, SUBSTITUTE,   FLY,          STRENGTH
	; end

	db BANK(ZapdosPicFront)
