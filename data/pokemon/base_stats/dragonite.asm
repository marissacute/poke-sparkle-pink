    db DEX_DRAGONITE ; pokedex id

    db  91, 109,  75,  80, 70
    ;   hp  atk  def  spd  spc

    db DRAGON, FLYING ; type
    db 45 ; catch rate
    db 218 ; base exp

IF GEN_2_GRAPHICS
    INCBIN "gfx/pokemon/gsfront/dragonite.pic", 0, 1 ; sprite dimensions
ELSE
    INCBIN "gfx/pokemon/front/dragonite.pic", 0, 1 ; sprite dimensions
ENDC
    dw DragonitePicFront, DragonitePicBack

    db TACKLE, LEER, THUNDER_WAVE, DRAGON_RAGE ; level 1 learnset
    db GROWTH_MEDIUM_SLOW ; growth rate

    ; tm/hm learnset
    tmhm RAZOR_WIND,   TOXIC,        HORN_DRILL,   BODY_SLAM,    TAKE_DOWN,    \
         DOUBLE_EDGE,  BUBBLEBEAM,   WATER_GUN,    ICE_BEAM,     BLIZZARD,     \
         HYPER_BEAM,   RAGE,         DRAGON_RAGE,  THUNDERBOLT,  THUNDER,      \
         MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         FIRE_BLAST,   \
         SWIFT,        SKULL_BASH,   REST,         THUNDER_WAVE, SUBSTITUTE,   \
         SURF,         STRENGTH
    ; end

    db BANK(DragonitePicFront)
