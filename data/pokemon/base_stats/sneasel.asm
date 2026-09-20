	db DEX_SNEASEL ; pokedex id

	db  55,  95,  55, 115,  35
	;   hp  atk  def  spd  spc

	db DARK, ICE ; type
	db 60 ; catch rate
	db 86 ; base exp

	INCBIN "gfx/pokemon/gsfront/sneasel.pic", 0, 1 ; sprite dimensions

	dw SneaselPicFront, SneaselPicBack

	db SCRATCH, LEER, QUICK_ATTACK, FURY_SWIPES ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  ICE_BEAM, \
	     BLIZZARD,     HYPER_BEAM,   COUNTER,      SEISMIC_TOSS, RAGE, \
	     DIG,          MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE, \
	     METRONOME,    REST,         SHADOW_BALL,  SUBSTITUTE,   SURF, \
	     STRENGTH,     FLASH
	; end

	db BANK(SneaselPicFront)
