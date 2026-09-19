	db DEX_FORRETRESS ; pokedex id

	db  75,  90, 140,  40,  60
	;   hp  atk  def  spd  spc

	db BUG, STEEL ; type
	db 75 ; catch rate
	db 118 ; base exp

	INCBIN "gfx/pokemon/gsfront/forretress.pic", 0, 1 ; sprite dimensions

	dw ForretressPicFront, ForretressPicBack

	db TACKLE, HARDEN, SELFDESTRUCT, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM,   \
	     COUNTER,      RAGE,         MEGA_DRAIN,   SOLARBEAM,    DIG,          \
	     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         SELFDESTRUCT, \
	     SWIFT,        REST,         EXPLOSION,    ROCK_SLIDE,   SUBSTITUTE,   \
	     STRENGTH
	; end

	db BANK(ForretressPicFront)
