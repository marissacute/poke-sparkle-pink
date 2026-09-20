	db DEX_GLACEON ; pokedex id

	db  65,  60, 110,  65, 130
	;   hp  atk  def  spd  spc

	db ICE, ICE ; type
	db 45 ; catch rate
	db 184 ; base exp

	INCBIN "gfx/pokemon/gsfront/glaceon.pic", 0, 1 ; sprite dimensions

	dw GlaceonPicFront, GlaceonPicBack

	db TACKLE, GROWL, BITE, SWIFT ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  ICE_BEAM, \
	     BLIZZARD,     HYPER_BEAM,   RAGE,         MIMIC,        DOUBLE_TEAM, \
	     REFLECT,      BIDE,         SWIFT,        SKULL_BASH,   REST, \
	     SUBSTITUTE,   FLASH
	; end

	db BANK(GlaceonPicFront)
