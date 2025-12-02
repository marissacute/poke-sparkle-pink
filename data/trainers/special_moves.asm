; Yellow entry format:
;	db trainerclass, trainerid
;	repeat { db partymon location, partymon move, move id }
;	db 0

SpecialTrainerMoves:
	db BROCK, 1
	db 2, 3, BIND
	db 2, 4, BIDE
	db 0

	db MISTY, 1
	db 2, 4, BUBBLEBEAM
	db 0

	db MISTY, 2
	db 5, 3, SURF
	db 5, 4, PSYCHIC_M
	db 0

	db LT_SURGE, 1
	db 3, 3, THUNDERBOLT
	db 3, 4, MEGA_PUNCH
	db 0

	db LT_SURGE, 2
	db 1, 1, THUNDERBOLT
	db 1, 3, THUNDER_WAVE
	db 4, 1, THUNDERBOLT
	db 5, 3, THUNDER
	db 5, 4, SUBMISSION
	db 0

	db ERIKA, 1
	db 3, 3, MEGA_DRAIN
	db 0

	db KOGA, 1
    db 4, 3, TOXIC
	db 0

	db BLAINE, 1
	db 2, 2, FLAMETHROWER
	db 3, 1, FLAMETHROWER
	db 3, 4, CONFUSE_RAY
	db 4, 1, AGILITY
	db 4, 3, FIRE_BLAST
	db 0

	db SABRINA, 1
	db 3, 3, PSYCHIC_M
	db 4, 1, SHADOW_BALL
	db 0

	db GIOVANNI, 3
	db 2, 2, DOUBLE_TEAM
	db 3, 1, EARTHQUAKE
	db 4, 1, EARTHQUAKE
	db 4, 3, THUNDERBOLT
	db 5, 2, FISSURE
	db 0

	db LORELEI, 1
	db 1, 1, BUBBLEBEAM
	db 3, 1, SURF
	db 4, 3, LOVELY_KISS
	db 5, 3, BLIZZARD
	db 0

	db BRUNO, 1
	db 4, 1, BODY_SLAM
	db 5, 2, MEGA_PUNCH
	db 0

	db AGATHA, 1
	db 1, 1, CONFUSE_RAY
	db 2, 1, PSYWAVE
	db 4, 2, SHADOW_BALL
    db 5, 1, TOXIC
	db 0

	db LANCE, 1
	db 2, 4, THUNDERBOLT
	db 5, 1, BLIZZARD
	db 0

	db RIVAL3, 1
	; Pidgeot
	db 1, 1, SAND_ATTACK
	db 1, 4, QUICK_ATTACK
	; Arcanine
	db 4, 1, FLAMETHROWER
	; Exeggutor
	db 5, 1, SLEEP_POWDER
	db 5, 2, PSYCHIC_M
	db 5, 3, EXPLOSION
	db 5, 4, MEGA_DRAIN
	; Magnezone
	db 6, 1, THUNDERBOLT
	db 6, 4, THUNDER_WAVE
	db 0

	db RIVAL3, 2
	; Pidgeot
	db 1, 1, SAND_ATTACK
	db 1, 4, QUICK_ATTACK
	; Gyarados
	db 4, 1, SURF
	; Arcanine
	db 5, 1, FLAMETHROWER
	db 0

	db RIVAL3, 3
	; Pidgeot
	db 1, 1, SAND_ATTACK
	db 1, 4, QUICK_ATTACK
	; Exeggutor
	db 4, 1, SLEEP_POWDER
	db 4, 2, PSYCHIC_M
	db 4, 3, EXPLOSION
	db 4, 4, MEGA_DRAIN
	; Gyarados
	db 5, 1, SURF
	db 0

	db -1 ; end