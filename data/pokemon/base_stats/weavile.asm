	db DEX_WEAVILE ; pokedex id

	db  70, 120,  65, 125,  45
	;   hp  atk  def  spd  spc

	db DARK, ICE ; type
	db 45 ; catch rate
	db 179 ; base exp

	INCBIN "gfx/pokemon/gsfront/weavile.pic", 0, 1 ; sprite dimensions

	dw WeavilePicFront, WeavilePicBack

	db SCRATCH, LEER, QUICK_ATTACK, SLASH ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  ICE_BEAM, \
	     BLIZZARD,     HYPER_BEAM,   COUNTER,      SEISMIC_TOSS, RAGE, \
	     DIG,          MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE, \
	     METRONOME,    REST,         SHADOW_BALL,  SUBSTITUTE,   SURF, \
	     STRENGTH,     FLASH
	; end

	db BANK(WeavilePicFront)
