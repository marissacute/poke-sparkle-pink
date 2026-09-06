	db DEX_FLAAFFY ; pokedex id

	db  70,  55,  55,  45,  80
	;   hp  atk  def  spd  spc

	db ELECTRIC, ELECTRIC ; type
	db 120 ; catch rate
	db 117 ; base exp

	INCBIN "gfx/pokemon/gsfront/flaaffy.pic", 0, 1 ; sprite dimensions

	dw FlaaffyPicFront, FlaaffyPicBack

	db TACKLE, GROWL, THUNDERSHOCK, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     THUNDERBOLT,  THUNDER,      MIMIC,        DOUBLE_TEAM,  REFLECT,      \
	     BIDE,         SWIFT,        SKULL_BASH,   REST,         THUNDER_WAVE, \
	     SUBSTITUTE,   STRENGTH,     FLASH
	; end

	db BANK(FlaaffyPicFront)
