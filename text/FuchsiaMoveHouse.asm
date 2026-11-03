_FuchsiaMoveHouseMoveDeleterIntroText::
	text "We are the MOVE"
	line "BROTHERS!"

	para "I'm the oldest,"
	line "I specialise in"
	cont "deleting moves."

	para "Do you have a"
	line "#MON that you"
	cont "want a move"
	cont "deleted for?"
	done

_FuchsiaMoveHouseMoveDeleterWhichMoveText::
	text "Alright! What"
	line "move do you want"
	cont "deleted?"
	prompt

_FuchsiaMoveHouseMoveDeleterConfirmText::
	text "Forget the move"
	line "@"
	text_ram wNameBuffer
	text "?"
	done

_FuchsiaMoveHouseMoveDeleterForgotText::
	text "1, 2 and...@"
	text_pause
	text " Poof!"
	line "@"
	text_ram wLearnMoveMonName
	text " forgot@"
	text_scroll
	text_ram wNameBuffer
	text "!"
	prompt

_FuchsiaMoveHouseMoveDeleterClosingText::
	text "Hehe, that worked"
	line "well. Come back"
	cont "later if you"
	cont "need other moves"
	cont "deleted!"
	done

_FuchsiaMoveHouseMoveDeleterNoMovesText::
	text "It doesn't know"
	line "any moves!"

	para "There's nothing"
	line "for me to delete."
	done

_FuchsiaMoveHouseMoveDeleterComeBackText::
	text "Hehe, come back"
	line "later if you"
	cont "need other moves"
	cont "deleted!"
	done

_FuchsiaMoveHouseMoveRelearnerIntroText::
	text "We are the MOVE"
	line "BROTHERS!"

	para "I'm the youngest,"
	line "I specialise in"
	cont "relearning moves."

	para "Do you have a"
	line "#MON that"
	cont "wants to relearn"
	cont "a move it"
	cont "forgot earlier?"

	para "I can only help"
	line "it remember"
	cont "level-up moves."
	
	para "So no moves from"
	line "a TM or HM!"
	cont "Understood?"
	done

_FuchsiaMoveHouseMoveRelearnerWhichMoveText::
	text "Alright! What"
	line "move do you want"
	cont "it to remember?"
	prompt

_FuchsiaMoveHouseMoveRelearnerNoMovesText::
	text "It can't remember"
	line "any more level-up"
	cont "moves!"

	para "There's nothing"
	line "I can teach it."
	done

_FuchsiaMoveHouseMoveRelearnerComeBackText::
	text "Come back later"
	line "if you need a"
	cont "move remembered!"
	done

_FuchsiaMoveHouseMoveDeleterLastMoveText::
	text "That #MON only"
	line "knows one move!"

	para "I can't delete"
	line "its last move!"
	done
