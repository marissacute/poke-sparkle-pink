	db DEX_HAPPINY ; pokedex id

	db 100,   5,   5,  30,  65
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 130 ; catch rate
	db 110 ; base exp

	INCBIN "gfx/pokemon/gsfront/happiny.pic", 0, 1 ; sprite dimensions

	dw HappinyPicFront, HappinyPicBack

	db POUND, GROWL, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  COUNTER,      \
	     SEISMIC_TOSS, RAGE,         SOLARBEAM,    PSYCHIC_M,    DIG,          \
	     MIMIC,        DOUBLE_TEAM,  EGG_BOMB,     REFLECT,      BIDE,         \
	     METRONOME,    SOFTBOILED,   REST,         THUNDER_WAVE, SHADOW_BALL,  \
	     SUBSTITUTE,   FLASH
	; end

	db BANK(HappinyPicFront)
