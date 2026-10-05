; copies a string from de to wStringBuffer
; The source is supposed to be '@'-terminated, but if it isn't, an unbounded copy
; walks straight out of wStringBuffer and through the item, menu and battle
; variables that follow it. Stop at the end of the buffer instead and terminate
; there; a truncated string beats a wiped save.
CopyToStringBuffer::
	push bc
	ld hl, wStringBuffer
	ld b, NAME_BUFFER_LENGTH - 1
.loop
	ld a, [de]
	inc de
	ld [hli], a
	cp '@'
	jr z, .done
	dec b
	jr nz, .loop
	ld a, '@'
	ld [hl], a
.done
	pop bc
	ret

; copies a string from de to hl
CopyString::
	ld a, [de]
	inc de
	ld [hli], a
	cp '@'
	jr nz, CopyString
	ret
