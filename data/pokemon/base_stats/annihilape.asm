	db DEX_ANNIHILAPE ; pokedex id

	db 110, 115,  80,  90,  50
	;   hp  atk  def  spd  spc

	db FIGHTING, GHOST ; type
	db 45 ; catch rate
	db 255 ; base exp

	INCBIN "gfx/pokemon/gsfront/annihilape.pic", 0, 1 ; sprite dimensions

	dw AnnihilapePicFront, AnnihilapePicBack

	db SCRATCH, LEER, COUNTER, FOCUS_ENERGY ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM, \
	     SUBMISSION,   COUNTER,      SEISMIC_TOSS, RAGE,         EARTHQUAKE, \
	     DIG,          MIMIC,        DOUBLE_TEAM,  BIDE,         METRONOME, \
	     FIRE_BLAST,   SKULL_BASH,   REST,         ROCK_SLIDE,   SUBSTITUTE, \
	     STRENGTH
	; end

	db BANK(AnnihilapePicFront)
