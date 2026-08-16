	db DEX_HOOPA ; pokedex id

	db  80, 110,  60,  70, 150
	;   hp  atk  def  spd  spc

	db PSYCHIC_TYPE, GHOST ; type
	db 3 ; catch rate
	db 190 ; base exp

	INCBIN "gfx/pokemon/gsfront/hoopa.pic", 0, 1 ; sprite dimensions

	dw HoopaPicFront, HoopaPicBack

	db CONFUSION, PSYWAVE, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        HYPER_BEAM,   THUNDERBOLT,  THUNDER,      PSYCHIC_M,    \
	     SHADOW_BALL,  DOUBLE_TEAM,  REFLECT,      REST,         FLASH,        \
	     THUNDER_WAVE, DREAM_EATER,  SUBSTITUTE,   MIMIC,        METRONOME
	; end

	db BANK(HoopaPicFront)
