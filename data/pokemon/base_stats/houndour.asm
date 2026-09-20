	db DEX_HOUNDOUR ; pokedex id

	db  45,  60,  30,  65,  80
	;   hp  atk  def  spd  spc

	db DARK, FIRE ; type
	db 120 ; catch rate
	db 66 ; base exp

	INCBIN "gfx/pokemon/gsfront/houndour.pic", 0, 1 ; sprite dimensions

	dw HoundourPicFront, HoundourPicBack

	db LEER, EMBER, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  COUNTER,      \
	     RAGE,         SOLARBEAM,    DIG,          MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         FIRE_BLAST,   SWIFT,        SKULL_BASH,   \
	     REST,         SUBSTITUTE,   FLASH
	; end

	db BANK(HoundourPicFront)
