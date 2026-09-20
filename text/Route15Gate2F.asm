_Route15Gate2FOaksAideIntroText::
	text "PROF.OAK used to"
	line "give new trainers"
	cont "one of three"
	cont "#MON. They"
	cont "were friendly and"
	cont "evolved easily."

	para "But lately, their"
	line "behaviour has"
	cont "changed. They are"
	cont "much harder to"
	cont "raise now! They're"
	cont "not suitable for"
	cont "new trainers"
	cont "anymore..."
	prompt

_Route15Gate2FOaksAideExperiencedText::
	text "Say, you look like"
	line "an experienced"
	cont "trainer now. Can"
	cont "you take care of"
	cont "one of them?"
	prompt

_Route15Gate2FOaksAideWhichOneText::
	text "Which one do you"
	line "want?"
	done

_Route15Gate2FOaksAideWantBulbasaurText::
	text "Do you want the"
	line "flower bulb"
	cont "#MON,"
	cont "BULBASAUR?"
	done

_Route15Gate2FOaksAideWantCharmanderText::
	text "Do you want the"
	line "fire lizard"
	cont "#MON,"
	cont "CHARMANDER?"
	done

_Route15Gate2FOaksAideWantSquirtleText::
	text "Do you want the"
	line "water turtle"
	cont "#MON,"
	cont "SQUIRTLE?"
	done

_Route15Gate2FOaksAideNotEnoughMonsText::
	text "Let's see..."
	line "Uh-oh! You have"
	cont "caught only @"
	text_decimal hOaksAideNumMonsOwned, 1, 3
	text_start
	cont "kinds of #MON!"

	para "You need @"
	text_decimal hOaksAideRequirement, 1, 3
	text " kinds"
	line "if you want"
	cont "this #MON.."
	done

_Route15Gate2FOaksAideComeBackText::
	text "That's OK!"

	para "Come back later"
	line "when you've made"
	cont "a decision!"
	done

_Route15Gate2FOaksAideAfterGiftText::
	text "Take good care"
	line "of this #MON!"
	done

_Route15Gate2FBinocularsText::
	text "Looked into the"
	line "binoculars."

	para "It looks like a"
	line "small island!"
	done
