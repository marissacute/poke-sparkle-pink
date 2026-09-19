	db DEX_MILTANK ; pokedex id

	db  95,  80, 105, 100,  40
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 45 ; catch rate
	db 200 ; base exp

	INCBIN "gfx/pokemon/gsfront/miltank.pic", 0, 1 ; sprite dimensions

	dw MiltankPicFront, MiltankPicBack

	db TACKLE, GROWL, NO_MOVE, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  ICE_BEAM,     BLIZZARD,     HYPER_BEAM,   COUNTER,      \
	     SEISMIC_TOSS, RAGE,         EARTHQUAKE,   MIMIC,        DOUBLE_TEAM,  \
	     BIDE,         METRONOME,    EGG_BOMB,     REST,         THUNDER_WAVE, \
	     SHADOW_BALL,  ROCK_SLIDE,   SUBSTITUTE,   SURF,         STRENGTH,     \
	     FLASH
	; end

	db BANK(MiltankPicFront)
