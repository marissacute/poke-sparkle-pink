	db 0 ; pokedex id (MissingNo. is #000)
	db 33, 136, 0, 29, 6
	;   hp  atk  def  spd  spc

	db BIRD, NORMAL ; type
	db 29 ; catch rate
	db 143 ; base exp (0x8F, per the GlitchDex RB data)

	INCBIN "gfx/pokemon/gsfront/missingno.pic", 0, 1 ; sprite dimensions

	dw MissingNoPicFront, MissingNoPicBack

	db WATER_GUN, WATER_GUN, SKY_ATTACK, NO_MOVE ; level 1 learnset
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm

	db BANK(MissingNoPicFront)
