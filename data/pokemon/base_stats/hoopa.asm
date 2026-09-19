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
	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  HYPER_BEAM,   SUBMISSION,   COUNTER,      SEISMIC_TOSS, \
	     RAGE,         MEGA_DRAIN,   SOLARBEAM,    THUNDERBOLT,  THUNDER,      \
	     DIG,          PSYCHIC_M,    TELEPORT,     MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         METRONOME,    DREAM_EATER,  REST,         \
	     THUNDER_WAVE, SHADOW_BALL,  ROCK_SLIDE,   TRI_ATTACK,   SUBSTITUTE,   \
	     FLASH
	; end

	db BANK(HoopaPicFront)
