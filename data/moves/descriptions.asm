PrintMoveDescription::
    ld a, [wMoveNum]
	ld hl, MoveDescriptions
; Add stuff until we are at the right pointer
	ld de, 4 ; size of the data to copy
.loop
	dec a
	jr z, .copyNameData
	add hl, de
	jr .loop

.copyNameData
	ld a, [hli]
	ld [wNameBuffer], a
	ld a, [hli]
	ld [wNameBuffer+1], a
	ld a, [hli]
	ld [wNameBuffer+2], a
	ld a, [hli]
	ld [wNameBuffer+3], a
	ld a, TX_END
	ld [wNameBuffer+4], a

	hlcoord 1, 13
	lb bc, 4, 18
	call ClearScreenArea

	ld hl, wNameBuffer
	call PrintText_NoCreatingTextBox
	ret

MoveDescriptions:
    text_far _PoundDescription
    text_far _KarateChopDescription
    text_far _DoubleSlapDescription
    text_far _MachPunchDescription
    text_far _MegaPunchDescription
    text_far _PayDayDescription
    text_far _FirePunchDescription
    text_far _IcePunchDescription
    text_far _ThunderPunchDescription
    text_far _ScratchDescription
    text_far _ViceGripDescription
    text_far _GuillotineDescription
    text_far _RazorWindDescription
    text_far _SwordsDanceDescription
    text_far _CutDescription
    text_far _GustDescription
    text_far _WingAttackDescription
    text_far _WhirlwindDescription
    text_far _FlyDescription
    text_far _BindDescription
    text_far _DragonSlamDescription
    text_far _VineWhipDescription
    text_far _StompDescription
    text_far _DoubleKickDescription
    text_far _MegaKickDescription
    text_far _JumpKickDescription
    text_far _RollingKickDescription
    text_far _SandAttackDescription
    text_far _HeadbuttDescription
    text_far _HornAttackDescription
    text_far _FuryAttackDescription
    text_far _HornDrillDescription
    text_far _TackleDescription
    text_far _BodySlamDescription
    text_far _WrapDescription
    text_far _TakeDownDescription
    text_far _ThrashDescription
    text_far _DoubleEdgeDescription
    text_far _TailWhipDescription
    text_far _PoisonStingDescription
    text_far _TwineedleDescription
    text_far _PinMissileDescription
    text_far _LeerDescription
    text_far _BiteDescription
    text_far _GrowlDescription
    text_far _RoarDescription
    text_far _SingDescription
    text_far _SupersonicDescription
    text_far _SonicBoomDescription
    text_far _DisableDescription
    text_far _AcidDescription
    text_far _EmberDescription
    text_far _FlamethrowerDescription
    text_far _MistDescription
    text_far _WaterGunDescription
    text_far _HydroPumpDescription
    text_far _SurfDescription
    text_far _IceBeamDescription
    text_far _BlizzardDescription
    text_far _PsybeamDescription
    text_far _BubbleBeamDescription
    text_far _AuroraBeamDescription
    text_far _HyperBeamDescription
    text_far _PeckDescription
    text_far _DrillPeckDescription
    text_far _SubmissionDescription
    text_far _LowKickDescription
    text_far _CounterDescription
    text_far _SeismicTossDescription
    text_far _StrengthDescription
    text_far _AbsorbDescription
    text_far _MegaDrainDescription
    text_far _LeechSeedDescription
    text_far _GrowthDescription
    text_far _RazorLeafDescription
    text_far _SolarBeamDescription
    text_far _PoisonPowderDescription
    text_far _StunSporeDescription
    text_far _SleepPowderDescription
    text_far _PetalDanceDescription
    text_far _StringShotDescription
    text_far _DragonRageDescription
    text_far _FireSpinDescription
    text_far _ThunderShockDescription
    text_far _ThunderboltDescription
    text_far _ThunderWaveDescription
    text_far _ThunderDescription
    text_far _RockThrowDescription
    text_far _EarthquakeDescription
    text_far _FissureDescription
    text_far _DigDescription
    text_far _ToxicDescription
    text_far _ConfusionDescription
    text_far _PsychicMDescription
    text_far _HypnosisDescription
    text_far _MeditateDescription
    text_far _AgilityDescription
    text_far _QuickAttackDescription
    text_far _RageDescription
    text_far _TeleportDescription
    text_far _NightShadeDescription
    text_far _MimicDescription
    text_far _ScreechDescription
    text_far _DoubleTeamDescription
    text_far _RecoverDescription
    text_far _HardenDescription
    text_far _MinimizeDescription
    text_far _SmokescreenDescription
    text_far _ConfuseRayDescription
    text_far _WithdrawDescription
    text_far _DefenseCurlDescription
    text_far _BarrierDescription
    text_far _LightScreenDescription
    text_far _HazeDescription
    text_far _ReflectDescription
    text_far _FocusEnergyDescription
    text_far _BideDescription
    text_far _MetronomeDescription
    text_far _MirrorMoveDescription
    text_far _SelfdestructDescription
    text_far _EggBombDescription
    text_far _LickDescription
    text_far _SmogDescription
    text_far _SludgeDescription
    text_far _BoneClubDescription
    text_far _FireBlastDescription
    text_far _WaterfallDescription
    text_far _ClampDescription
    text_far _SwiftDescription
    text_far _SkullBashDescription
    text_far _SpikeCannonDescription
    text_far _ConstrictDescription
    text_far _AmnesiaDescription
    text_far _SoftboiledDescription
    text_far _HiJumpKickDescription
    text_far _GlareDescription
    text_far _DreamEaterDescription
    text_far _PoisonGasDescription
    text_far _BarrageDescription
    text_far _LeechLifeDescription
    text_far _LovelyKissDescription
    text_far _SkyAttackDescription
    text_far _TransformDescription
    text_far _BubbleDescription
    text_far _DizzyPunchDescription
    text_far _SporeDescription
    text_far _FlashDescription
    text_far _PsywaveDescription
    text_far _SplashDescription
    text_far _AcidArmorDescription
    text_far _CrabhammerDescription
    text_far _ExplosionDescription
    text_far _FurySwipesDescription
    text_far _BonemerangDescription
    text_far _RestDescription
    text_far _RockSlideDescription
    text_far _HyperFangDescription
    text_far _SharpenDescription
    text_far _ConversionDescription
    text_far _TriAttackDescription
    text_far _SuperFangDescription
    text_far _SlashDescription
    text_far _SubstituteDescription
    text_far _MetalClawDescription
    text_far _MagnetBombDescription
    text_far _IronDefenseDescription
    text_far _FlashCannonDescription
    text_far _FeintAttackDescription
    text_far _CrunchDescription
    text_far _NightSlashDescription
    text_far _MoonblastDescription
    text_far _FairyWindDescription
    text_far _DrainingKissDescription
    text_far _XScissorDescription
    text_far _FuryCutterDescription
    text_far _CrossChopDescription
    text_far _ShadowBallDescription
    text_far _WaterPulseDescription
    text_far _StruggleDescription

_PoundDescription::
    text "Pounds the foe"
    line "to deal damage."
    done

_KarateChopDescription::
    text "Often lands a"
    line "critical hit."
    done

_DoubleSlapDescription::
    text "Slaps the foe"
    line "2 to 5 times."
    done

_MachPunchDescription::
    text "A fast punch that"
    line "strikes first."
    done

_MegaPunchDescription::
    text "Lands a punch"
    line "to deal damage."
    done

_PayDayDescription::
    text "Throws coins and"
    line "gets them back."
    done

_FirePunchDescription::
    text "A fiery punch that"
    line "may burn the foe."
    done

_IcePunchDescription::
    text "An icy punch that"
    line "may freeze the foe"
    done

_ThunderPunchDescription::
    text "An electric punch"
    line "that may paralyze"
    done

_ScratchDescription::
    text "Scratches the foe"
    line "with claws."
    done

_ViceGripDescription::
    text "Crushes the foe"
    line "with pincers."
    done

_GuillotineDescription::
    text "Often lands a"
    line "critical hit."
    done

_RazorWindDescription::
    text "Charges first,"
    line "then hits hard."
    done

_SwordsDanceDescription::
    text "Sharply raises"
    line "ATTACK."
    done

_CutDescription::
    text "Cuts the foe"
    line "with blades."
    done

_GustDescription::
    text "A basic wind"
    line "attack."
    done

_WingAttackDescription::
    text "Strikes the foe"
    line "with wings."
    done

_WhirlwindDescription::
    text "Blows the foe away"
    line "to end a battle."
    done

_FlyDescription::
    text "Flies up high,"
    line "then attacks."
    done

_BindDescription::
    text "Binds the target"
    line "for 2-5 turns."
    done

_DragonSlamDescription::
    text "Hits the foe hard"
    line "with dragon force."
    done

_VineWhipDescription::
    text "Hits the foe"
    line "with vines."
    done

_StompDescription::
    text "Stomps the foe,"
    line "may flinch."
    done

_DoubleKickDescription::
    text "Kicks the foe"
    line "twice."
    done

_MegaKickDescription::
    text "A powerful kick"
    line "that may miss."
    done

_JumpKickDescription::
    text "May miss, dama-"
    line "ging the user."
    done

_RollingKickDescription::
    text "A spinning kick,"
    line "may flinch."
    done

_SandAttackDescription::
    text "Throws sand to"
    line "lower ACCURACY."
    done

_HeadbuttDescription::
    text "Rams into the foe,"
    line "may flinch."
    done

_HornAttackDescription::
    text "Strikes the foe"
    line "with a horn."
    done

_FuryAttackDescription::
    text "Hits the foe"
    line "2 to 5 times."
    done

_HornDrillDescription::
    text "Drills the ground"
    line "with a horn."
    done

_TackleDescription::
    text "A basic body"
    line "charge attack."
    done

_BodySlamDescription::
    text "A full body hit"
    line "that may paralyze."
    done

_WrapDescription::
    text "Wraps the foe"
    line "for 2-5 turns."
    done

_TakeDownDescription::
    text "A wild charge that"
    line "damages the user."
    done

_ThrashDescription::
    text "Rampages wildly"
    line "for 3-4 turns."
    done

_DoubleEdgeDescription::
    text "A reckless hit,"
    line "hurts the user."
    done

_TailWhipDescription::
    text "Lowers the foe's"
    line "DEFENSE stat."
    done

_PoisonStingDescription::
    text "Stings the foe,"
    line "may cause poison."
    done

_TwineedleDescription::
    text "Stings twice,"
    line "may cause poison."
    done

_PinMissileDescription::
    text "Hits 2 to 5 times"
    line "with sharp pins."
    done

_LeerDescription::
    text "Lowers the foe's"
    line "DEFENSE stat."
    done

_BiteDescription::
    text "Bites the foe,"
    line "may flinch."
    done

_GrowlDescription::
    text "Lowers the foe's"
    line "ATTACK stat."
    done

_RoarDescription::
    text "Roars loudly to"
    line "end a battle."
    done

_SingDescription::
    text "A lullaby that"
    line "causes sleep."
    done

_SupersonicDescription::
    text "Confuses the foe"
    line "with sound waves."
    done

_SonicBoomDescription::
    text "Always inflicts"
    line "20HP of damage."
    done

_DisableDescription::
    text "Blocks a target's"
    line "move temporarily."
    done

_AcidDescription::
    text "Sprays with acid,"
    line "may lower DEFENSE."
    done

_EmberDescription::
    text "A small flame that"
    line "may burn the foe."
    done

_FlamethrowerDescription::
    text "A strong FIRE"
    line "attack, may burn."
    done

_MistDescription::
    text "White mist that"
    line "stops stat loss."
    done

_WaterGunDescription::
    text "Shoots water jets"
    line "at the target."
    done

_HydroPumpDescription::
    text "A huge water"
    line "cannon attack."
    done

_SurfDescription::
    text "Hits the target"
    line "with a large wave."
    done

_IceBeamDescription::
    text "May freeze the"
    line "opponent."
    done

_BlizzardDescription::
    text "A huge snow attack"
    line "that may freeze."
    done

_PsybeamDescription::
    text "A psychic ray that"
    line "may confuse."
    done

_BubbleBeamDescription::
    text "Hits with bubbles,"
    line "may lower SPEED."
    done

_AuroraBeamDescription::
    text "A rainbow beam,"
    line "may lower ATTACK."
    done

_HyperBeamDescription::
    text "Attacks first,"
    line "then recharges."
    done

_PeckDescription::
    text "Pecks the foe"
    line "with a sharp beak."
    done

_DrillPeckDescription::
    text "A spinning drill"
    line "peck attack."
    done

_SubmissionDescription::
    text "A strong slam that"
    line "hurts the user."
    done

_LowKickDescription::
    text "A low kick that"
    line "may flinch."
    done

_CounterDescription::
    text "Returns previous"
    line "damage dealt."
    done

_SeismicTossDescription::
    text "Deals damage equal"
    line "to user's level."
    done

_StrengthDescription::
    text "A powerful"
    line "physical attack."
    done

_AbsorbDescription::
    text "Steals HP from"
    line "the target."
    done

_MegaDrainDescription::
    text "Drains more HP"
    line "from the foe."
    done

_LeechSeedDescription::
    text "Plants a seed"
    line "that drains HP."
    done

_GrowthDescription::
    text "Raises the user's"
    line "SPECIAL stat."
    done

_RazorLeafDescription::
    text "Often lands a"
    line "critical hit."
    done

_SolarBeamDescription::
    text "Absorbs light,"
    line "then attacks."
    done

_PoisonPowderDescription::
    text "Scatters powder"
    line "that poisons."
    done

_StunSporeDescription::
    text "Scatters spores"
    line "that paralyze."
    done

_SleepPowderDescription::
    text "Scatters powder"
    line "that induce sleep."
    done

_PetalDanceDescription::
    text "Attacks wildly"
    line "with petals."
    done

_StringShotDescription::
    text "Binds the foe to"
    line "lower SPEED."
    done

_DragonRageDescription::
    text "Hits the foe with"
    line "draconic anger."
    done

_FireSpinDescription::
    text "Traps in flames"
    line "for 2-5 turns."
    done

_ThunderShockDescription::
    text "An electric jolt"
    line "that may paralyze."
    done

_ThunderboltDescription::
    text "A strong bolt"
    line "that may paralyze."
    done

_ThunderWaveDescription::
    text "A weak shock"
    line "that paralyzes."
    done

_ThunderDescription::
    text "A devastating"
    line "lightning strike."
    done

_RockThrowDescription::
    text "Drops rocks on"
    line "the foe."
    done

_EarthquakeDescription::
    text "A powerful quake,"
    line "does heavy damage."
    done

_FissureDescription::
    text "One-hit KO by"
    line "splitting earth."
    done

_DigDescription::
    text "Digs underground"
    line "to strike later."
    done

_ToxicDescription::
    text "Badly poisons"
    line "the target."
    done

_ConfusionDescription::
    text "A psychic attack"
    line "that may confuse."
    done

_PsychicMDescription::
    text "A strong psychic"
    line "attack."
    done

_HypnosisDescription::
    text "Lulls the foe"
    line "into sleep."
    done

_MeditateDescription::
    text "Calms the mind"
    line "to raise ATTACK."
    done

_AgilityDescription::
    text "Sharply raises"
    line "the SPEED stat."
    done

_QuickAttackDescription::
    text "Moves quickly to"
    line "attack first."
    done

_RageDescription::
    text "Boosts attack"
    line "when user is hit."
    done

_TeleportDescription::
    text "Warps away from"
    line "the battle."
    done

_NightShadeDescription::
    text "Deals damage equal"
    line "to user's level."
    done

_MimicDescription::
    text "Copies a move"
    line "used by the foe."
    done

_ScreechDescription::
    text "Sharply lowers"
    line "foe's DEFENSE."
    done

_DoubleTeamDescription::
    text "Creates copies to"
    line "raise EVASION."
    done

_RecoverDescription::
    text "Restores half of"
    line "the user's HP."
    done

_HardenDescription::
    text "Stiffens the body"
    line "to boost DEFENSE."
    done

_MinimizeDescription::
    text "Shrinks the body"
    line "to raise EVASION."
    done

_SmokescreenDescription::
    text "Lowers ACCURACY"
    line "with smoke."
    done

_ConfuseRayDescription::
    text "A sinister ray"
    line "that confuses."
    done

_WithdrawDescription::
    text "Hides in shell"
    line "to raise DEFENSE."
    done

_DefenseCurlDescription::
    text "Curls up to"
    line "raise DEFENSE."
    done

_BarrierDescription::
    text "Creates barriers"
    line "to boost DEFENSE."
    done

_LightScreenDescription::
    text "Reduces special"
    line "damage taken."
    done

_HazeDescription::
    text "Eliminates all"
    line "stat changes."
    done

_ReflectDescription::
    text "Reduces physical"
    line "damage taken."
    done

_FocusEnergyDescription::
    text "Raises critical"
    line "hit ratio."
    done

_BideDescription::
    text "Endures attacks,"
    line "then strikes."
    done

_MetronomeDescription::
    text "Uses a random"
    line "move."
    done

_MirrorMoveDescription::
    text "Counters with"
    line "the same move."
    done

_SelfdestructDescription::
    text "User explodes"
    line "to attack."
    done

_EggBombDescription::
    text "Hurls an egg"
    line "at the foe."
    done

_LickDescription::
    text "Licks the foe,"
    line "may paralyze."
    done

_SmogDescription::
    text "Emits toxic gas"
    line "to poison."
    done

_SludgeDescription::
    text "Hurls sludge"
    line "that poisons."
    done

_BoneClubDescription::
    text "Hits with clubs,"
    line "may flinch."
    done

_FireBlastDescription::
    text "A massive firey"
    line "blast, may burn."
    done

_WaterfallDescription::
    text "Charges with"
    line "falling water."
    done

_ClampDescription::
    text "Traps the foe"
    line "for 2-5 turns."
    done

_SwiftDescription::
    text "Star-shaped rays"
    line "that never miss."
    done

_SkullBashDescription::
    text "Tucks in head,"
    line "then strikes."
    done

_SpikeCannonDescription::
    text "Fires spikes"
    line "2 to 5 times."
    done

_ConstrictDescription::
    text "Squeezes the foe,"
    line "may lower SPEED."
    done

_AmnesiaDescription::
    text "Forgets worries"
    line "to boost SPECIAL."
    done

_SoftboiledDescription::
    text "Recovers HP by"
    line "eating an egg."
    done

_HiJumpKickDescription::
    text "Damages the user"
    line "when missed."
    done

_GlareDescription::
    text "Intimidates the"
    line "foe to paralyze."
    done

_DreamEaterDescription::
    text "Steals HP from"
    line "sleeping foes."
    done

_PoisonGasDescription::
    text "Engulfs the foe"
    line "in poison gas."
    done

_BarrageDescription::
    text "Throws objects"
    line "2 to 5 times."
    done

_LeechLifeDescription::
    text "Drains HP with"
    line "a bite."
    done

_LovelyKissDescription::
    text "A sweet kiss that"
    line "induces sleep."
    done

_SkyAttackDescription::
    text "Charges power,"
    line "then attacks."
    done

_TransformDescription::
    text "Copies the foe's"
    line "appearance."
    done

_BubbleDescription::
    text "Fires bubbles,"
    line "may lower SPEED."
    done

_DizzyPunchDescription::
    text "A rhythmic punch"
    line "attack."
    done

_SporeDescription::
    text "Scatters spores"
    line "that cause sleep."
    done

_FlashDescription::
    text "Bright light that"
    line "lowers accuracy."
    done

_PsywaveDescription::
    text "Psychic waves do"
    line "random damage."
    done

_SplashDescription::
    text "The user jumps."
    line "Does nothing."
    done

_AcidArmorDescription::
    text "Liquefies body"
    line "to boost DEFENSE."
    done

_CrabhammerDescription::
    text "A strong claw"
    line "hammer strike."
    done

_ExplosionDescription::
    text "User explodes"
    line "with force."
    done

_FurySwipesDescription::
    text "Slashes wildly"
    line "2 to 5 times."
    done

_BonemerangDescription::
    text "Throws a bone"
    line "twice."
    done

_RestDescription::
    text "Sleeps to fully"
    line "recover HP."
    done

_RockSlideDescription::
    text "Large boulders"
    line "are hurled."
    done

_HyperFangDescription::
    text "A powerful bite"
    line "that may flinch."
    done

_SharpenDescription::
    text "Sharpens edges"
    line "to raise ATTACK."
    done

_ConversionDescription::
    text "Changes type to"
    line "match a move."
    done

_TriAttackDescription::
    text "Strikes with"
    line "three beams."
    done

_SuperFangDescription::
    text "Cuts foe's HP"
    line "in half."
    done

_SlashDescription::
    text "Slashes with"
    line "sharp claws."
    done

_SubstituteDescription::
    text "Creates a decoy"
    line "using 1/4 HP."
    done

_MetalClawDescription::
    text "Strikes the foe"
    line "with steel claws."
    done

_MagnetBombDescription::
    text "Hits the foe"
    line "with magnets"
    done

_IronDefenseDescription::
    text "Sharply raises the"
    line "user's DEFENSE."
    done

_FlashCannonDescription::
    text "A bright steel"
    line "blast."
    done

_FeintAttackDescription::
    text "Sneaks up to"
    line "never miss."
    done

_CrunchDescription::
    text "Crunches hard,"
    line "may lower SPECIAL."
    done

_NightSlashDescription::
    text "A dark slash,"
    line "often lands crits."
    done

_MoonblastDescription::
    text "Attacks with the"
    line "power of the moon."
    done

_FairyWindDescription::
    text "Stirs up a"
    line "fairy wind."
    done

_DrainingKissDescription::
    text "Drains HP with"
    line "a cute kiss."
    done

_XScissorDescription::
    text "Crosses scythes"
    line "to attack."
    done

_FuryCutterDescription::
    text "Repeated slashes"
    line "strike the foe."
    done

_CrossChopDescription::
    text "A fierce martial"
    line "arts attack."
    done

_ShadowBallDescription::
    text "Hurls a dark"
    line "shadow."
    done

_WaterPulseDescription::
    text "A pulsing blast,"
    line "may confuse."
    done

_StruggleDescription::
    text "A last ditch hit,"
    line "hurts the user."
    done