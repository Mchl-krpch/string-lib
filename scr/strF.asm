; ===--------------------------------------------------===
; library for string functions
; #second sub-project on asm
;
; 1 strlen
; 2 strncpy
; 3 strchr
; 4 strncmp
; 5 itoa
; 6 atoi
; 
; #I use commands like
;  -scasb          compares value es:[di] with al
;  -stosw          copys    value ax to es:[di]
;  -smpsb          compares value ds:[si] with es:[di]
;  -movsb          writes   ds:[si] to es:[di]
;  -loop           repeats some action until cx is
;.                 reset to zero
; ===--------------------------------------------------===

locals @@
.model tiny

VIDEO_PTR = 0b800h

.code
org 100h

start:
	;call keyPause
	mov	di, offset string1
	mov si, offset string2

	call strlen

	call keyPause
	call setVideo

	mov bx, offset string1
	call print

	call exitp


; ===--------------------------------------------------===
; @brief | returns the length of the
;        | string (counts characters)
; @use   | {ax,cx,di}
; @ret   | cx number of symbols
; @dest  | ax,cx
; ===--------------------------------------------------===
; #example of common regs-function
; #registers are reset in the wrapper and
; #fed into the function for filling
strlen proc
	cld
	xor al, al
	xor cx, cx
call _strlen
	ret
endp

_strlen	proc
@@NextChar:
	scasb
	je @@EndFunc
	inc cx

	jmp @@NextChar
@@EndFunc:
	ret
endp


; ===--------------------------------------------------===
atoi proc
endp


strcpy proc
	cld
	push ax
call _strcpy
	pop ax
	ret
endp

; ===--------------------------------------------------===
; brief | copies the contents of one string to another
; use   | {ax}[with save]
;       | ds:[si] - ptr to first str  (copy from here)
;       | es:[di] - ptr to second str (write here)
; ret   | nthg
; dest  | {si, di}
; ===--------------------------------------------------===
_strcpy proc
@@repeat:
	scasb
	je @@end
	cmp ds:[si], al
	je @@end

	inc di
	movsb
	jmp @@repeat

@@end:
	ret
endp



; ===--------------------------------------------------===
; brief | compares strings lexicographically
; use   | {ax}[with save], {di, si, es}
;       | ds:[si] - ptr to first str
;       | es:[di] - ptr to second str
; ret   | cmp value, line below decryption
; dest  | {si, di}
equiv = 0
less  = -1
more  = 1
strcmp 	proc
	
	cld
	push di
	call strlen
	inc cx
	pop di
	; #---------------------------------------------

	repe cmpsb
	ja @@less
	jb @@more
	je @@equiv

@@equiv:
	mov ax, equiv
	jmp @@end

@@less:
	mov ax, less
	jmp @@end

@@more:
	mov ax, more
	jmp @@end
	
@@end:

	; #---------------------------------------------
	ret
endp


; ===--------------------------------------------------===
; brief | returns the index of a char in a str
; use   | {ax, es, di, si}
;       | es:[di] - ptr str (looking here)
; ret   | {bx} - index of char
; dest  | {ax, si, di}
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



; ===--------------------------------------------------===
; brief | pause until the user presses any key
; use   | {ax}[with save]
; ret   | nthg
keyPause proc
	xor ax, ax
	int 16h
	ret
endp



; ===--------------------------------------------------===
; brief | terminates the program
exitp proc
	mov ax, 4C00h
	int 21h
	ret
endp


; ===--------------------------------------------------===
setVideo proc
	
	push ax
	; #---------------------------------------------

	mov ax, VIDEO_PTR
	mov es, ax
	xor di, di

	; #---------------------------------------------
	pop ax

	ret
endp


; ===--------------------------------------------------===
; brief | write string buffer on screen
; use   | {di,si}
;       | es:[di] - ptr to video segment
; ret   | nthg
; dest  | {si}
; #example of Pascal wrapper function
; #arguments are passed from left to right, the
; #stack pointer is restored by the called function
print proc
	xor al, al
	xor si, si

	push di

	call _print
	ret
endp

_print proc
	mov bp, sp
	mov di, [bp + 2d]
@@repeat:
	scasb
	je @@end

	inc di
	mov ax, [bx + si]
	mov es:[di], al
	xor al, al
	inc si
	jmp @@repeat
@@end:
	pop ax
	pop ax
	ret
endp

string1 db 'MEEOOOWW!', 0
string2 db '.net bl at gaf', 0
string3 db '______', 0

end start