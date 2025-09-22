	db DEX_BELLOSSOM ; pokedex id

	db  75,  80,  85,  50,  100
	;   hp  atk  def  spd  spc

	db GRASS, GRASS ; type
	db 45 ; catch rate
	db 184 ; base exp

	INCBIN "gfx/pokemon/gsfront/bellossom.pic", 0, 1 ; sprite dimensions
	
	dw BellossomPicFront, BellossomPicBack

	db POISONPOWDER, STUN_SPORE, SLEEP_POWDER, PETAL_DANCE ; level 1 learnset
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	tmhm SWORDS_DANCE, TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         \
	     MEGA_DRAIN,   SOLARBEAM,    MIMIC,        DOUBLE_TEAM,  REFLECT,      \
	     BIDE,         REST,         SUBSTITUTE,   CUT,          PSYCHIC_M
	; end

	db BANK(BellossomPicFront)
