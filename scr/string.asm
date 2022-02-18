; #========================================================
; #library for string functions
; #second sub-project on asm
;
; #1 strncpy
; #2 strlen
; #3 strchr
; #4 strncmp
; #5 itoa
; #6 atoi
; #========================================================
; #I use commands like
;   -scasb          #compares value es:[di] with al
;   -stosw          #copys    value ax to es:[di]
;   -smpsb          #compares value ds:[si] with es:[di]
;   -movsb          #writes   ds:[si] to es:[di]
;   -loop           #repeats some action until cx is
;                   #reset to zero
; #========================================================

.model tiny

.code
org 100h

start:
	;call keyPause
	mov	di, offset string1
	mov si, offset string2

	call strcmp

	call keyPause
	call exitp

; #========================================================
; #brief |copies the contents of one string to another
; #use   |{ax}[with save]
; #      |ds:[si] - ptr to first str  (copy from here)
; #      |es:[di] - ptr to second str (write here)
; #ret   |nthg
; #dest  |{si, di}
strcpy proc
	
	cld
	push ax
	; #---------------------------------------------

	cpyOneMore:
	scasb
	je copyEnd

	inc di
	movsb
	jmp cpyOneMore

	copyEnd:

	; #---------------------------------------------
	pop ax

	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |compares strings lexicographically
; #use   |{ax}[with save], {di, si, es}
; #      |ds:[si] - ptr to first str
; #      |es:[di] - ptr to second str
; #ret   |cmp value, line below decryption
; #dest  |{si, di}
equiv = 0
less  = -1
more  = 1
strcmp proc
	
	cld
	push di
	call strlen
	inc cx
	pop di
	; #---------------------------------------------

	repe cmpsb
	ja retLess
	jb retMore
	je retEquiv

	retEquiv:
	mov ax, equiv
	jmp cmpEnd

	retLess:
	mov ax, less
	jmp cmpEnd

	retMore:
	mov ax, more
	jmp cmpEnd
	
	cmpEnd:

	; #---------------------------------------------
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |returns the length of the
; #      |string (counts characters)
; #use   |{ax}[with save], {cx}
; #ret   |cx number of symbols
; #dest  |cx
strlen proc
	
	cld
	push ax

	xor al, al
	xor	cx, cx
	; #---------------------------------------------

	cmpAgainStrlen:
	scasb

	je endStrlen
	inc cx

	jmp cmpAgainStrlen
	endStrlen:

	; #---------------------------------------------
	pop ax
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |returns the index of a char in a str
; #use   |{ax, es, di, si}
; #      |es:[di] - ptr str (looking here)
; #ret   |{bx} - index of char
; #dest  |{ax, si, di}
strchr proc

	cld

	xor bx, bx
	push di
	call strlen
	pop di
	; #---------------------------------------------

	continueSearch:
	scasb
	je endSearch

	inc bx
	loop continueSearch

	noSymbol:
	mov ax, -1

	endSearch:

	; #---------------------------------------------
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |pause until the user presses any key
; #use   |{ax}[with save]
; #ret   |nthg
keyPause proc
	xor ax, ax
	int 16h
	ret
endp
; #--------------------------------------------------------


; #========================================================
; #brief |terminates the program
exitp proc
	mov ax, 4C00h
	int 21h
	ret
endp
; #--------------------------------------------------------


string1 db 'STRING', 0
string2 db 'STRING', 0

end start