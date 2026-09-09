	db DEX_LEDIAN ; pokedex id

	db  55,  110,  50,  85,  55
	;   hp  atk  def  spd  spc

	db BUG, FIGHTING ; type
	db 90 ; catch rate
	db 134 ; base exp

	INCBIN "gfx/pokemon/gsfront/ledian.pic", 0, 1 ; sprite dimensions

	dw LedianPicFront, LedianPicBack

	db TACKLE, SUPERSONIC, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm MEGA_PUNCH,   HYPER_BEAM,   TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  RAGE,         MEGA_DRAIN,   SOLARBEAM,    DIG,          \
	     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         SWIFT,        \
	     REST,         SUBSTITUTE,   FLASH,        SUBMISSION,   STRENGTH
	; end

	db BANK(LedianPicFront)
