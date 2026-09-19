	db DEX_PINECO ; pokedex id

	db  50,  65,  90,  15,  35
	;   hp  atk  def  spd  spc

	db BUG, BUG ; type
	db 190 ; catch rate
	db 60 ; base exp

	INCBIN "gfx/pokemon/gsfront/pineco.pic", 0, 1 ; sprite dimensions

	dw PinecoPicFront, PinecoPicBack

	db TACKLE, HARDEN, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  COUNTER,      \
	     RAGE,         MEGA_DRAIN,   SOLARBEAM,    MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         SELFDESTRUCT, SWIFT,        REST,         \
	     EXPLOSION,    SUBSTITUTE
	; end

	db BANK(PinecoPicFront)
