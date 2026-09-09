	db DEX_LEDYBA ; pokedex id

	db  40,  80,  30,  55,  40
	;   hp  atk  def  spd  spc

	db BUG, BUG ; type
	db 255 ; catch rate
	db 54 ; base exp

	INCBIN "gfx/pokemon/gsfront/ledyba.pic", 0, 1 ; sprite dimensions

	dw LedybaPicFront, LedybaPicBack

	db TACKLE, SUPERSONIC, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     MEGA_DRAIN,   SOLARBEAM,    DIG,          MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         SWIFT,        REST,         SUBSTITUTE,   \
	     FLASH
	; end

	db BANK(LedybaPicFront)
