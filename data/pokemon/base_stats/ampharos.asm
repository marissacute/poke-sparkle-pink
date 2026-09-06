	db DEX_AMPHAROS ; pokedex id

	db  90,  75,  75,  55,  115
	;   hp  atk  def  spd  spc

	db ELECTRIC, DRAGON ; type
	db 45 ; catch rate
	db 194 ; base exp

	INCBIN "gfx/pokemon/gsfront/ampharos.pic", 0, 1 ; sprite dimensions

	dw AmpharosPicFront, AmpharosPicBack

	db TACKLE, GROWL, THUNDERSHOCK, THUNDER_WAVE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  HYPER_BEAM,   SUBMISSION,   SEISMIC_TOSS, RAGE,         \
	     THUNDERBOLT,  THUNDER,      MIMIC,        DOUBLE_TEAM,  REFLECT,      \
	     BIDE,         SWIFT,        SKULL_BASH,   REST,         THUNDER_WAVE, \
	     SUBSTITUTE,   STRENGTH,     FLASH
	; end

	db BANK(AmpharosPicFront)
