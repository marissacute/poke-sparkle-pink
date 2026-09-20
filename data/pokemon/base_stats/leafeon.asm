	db DEX_LEAFEON ; pokedex id

	db  65, 110, 130,  95,  60
	;   hp  atk  def  spd  spc

	db GRASS, GRASS ; type
	db 45 ; catch rate
	db 184 ; base exp

	INCBIN "gfx/pokemon/gsfront/leafeon.pic", 0, 1 ; sprite dimensions

	dw LeafeonPicFront, LeafeonPicBack

	db TACKLE, GROWL, BITE, SWIFT ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM, \
	     RAGE,         MEGA_DRAIN,   SOLARBEAM,    MIMIC,        DOUBLE_TEAM, \
	     REFLECT,      BIDE,         SWIFT,        SKULL_BASH,   REST, \
	     SUBSTITUTE,   FLASH
	; end

	db BANK(LeafeonPicFront)
