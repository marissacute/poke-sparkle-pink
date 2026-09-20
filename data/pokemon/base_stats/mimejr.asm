	db DEX_MIME_JR ; pokedex id

	db  20,  25,  45,  60,  70
	;   hp  atk  def  spd  spc

	db PSYCHIC_TYPE, FAIRY ; type
	db 145 ; catch rate
	db 62 ; base exp

	INCBIN "gfx/pokemon/gsfront/mimejr.pic", 0, 1 ; sprite dimensions

	dw MimeJrPicFront, MimeJrPicBack

	db TACKLE, HYPNOSIS, CONFUSE_RAY, BARRIER ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  SUBMISSION, \
	     COUNTER,      SEISMIC_TOSS, RAGE,         SOLARBEAM,    THUNDERBOLT, \
	     THUNDER,      PSYCHIC_M,    TELEPORT,     MIMIC,        DOUBLE_TEAM, \
	     REFLECT,      BIDE,         METRONOME,    DREAM_EATER,  REST, \
	     THUNDER_WAVE, SHADOW_BALL,  SUBSTITUTE,   FLASH
	; end

	db BANK(MimeJrPicFront)
