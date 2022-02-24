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
RADIXX = 16d

.code
org 100h

; ===--------------------------------------------------===

start:
	mov di, offset string1 		;# str1
	mov si, offset string_atoi	;# str2
	mov bx, offset string_atoi

	mov ax, 4d
	mov si, 3d
	call atoi2
	call exitp

	call strncpy
	call setVideo
	mov bx, offset string0
	call print
	call exitp


; ===--------------------------------------------------===
; @brief | converts a literal string to a number #FASTER#
; @use   | {ax,cx,di}
; @ret   | ax - number
; @dest  | di, si
; #Example function with cdecl type convention
; #parameters are passed from right to left across
; #the stack and the stack pointer is returned by
; #the calling program
atoi proc
	push ax
	xor ax, ax
	xor di, di
	call _atoi
	pop ax
	ret
endp

_atoi proc
	mov bp, sp
@@repeat:
	mov dx, [bp + 2d]		; #next tens place
	mul dx
	xor dh, dh

	mov cx, [bx + di]		; #push new tens
	xor ch, ch
	sub cx, '0'
	add ax, cx

	add di, 1d
	cmp si, di
	jne @@repeat
	ret
endp


; ===--------------------------------------------------===
; @brief | converts a literal string to a number
; @use   | {ax,cx,di}
; @ret   | ax - number
; @dest  | di, si
; #Example function with cdecl type convention
; #parameters are passed from right to left across
; #the stack and the stack pointer is returned by
; #the calling program
atoi2 proc
	push ax
	xor ax, ax
	xor di, di
	call _atoi2
	pop ax
	ret
endp

_atoi2 proc
	mov bp, sp
@@repeat:
	push cx
	mov cx, [bp + 2d]		; #next tens place
	shl ax, cl
	xor dh, dh
	pop cx

	mov cx, [bx + di]		; #push new tens
	xor ch, ch
	sub cx, '0'
	add ax, cx

	add di, 1d
	cmp si, di
	jne @@repeat
	ret
endp


; ===--------------------------------------------------===
; @brief | returns the length of the
;        | string (counts characters)
; @use   | {ax,cx,di}
; @ret   | cx number of symbols
; @dest  | ax,cx
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
; brief | copies the contents of one string to another
; use   | {ax}[with save]
;       | ds:[si] - ptr to first str  (copy from here)
;       | es:[di] - ptr to second str (write here)
; ret   | nthg
; dest  | {si, di}
; #example of common regs-function
; #registers are reset in the wrapper and
; #fed into the function for filling
strncpy proc
	cld
	xor ax, ax
call _strncpy
	ret
endp

_strncpy proc
@@repeat:
	movsb
	cmp es:[di],al
	je @@end
	cmp ds:[si], al
	je @@end

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
; #Example function with cdecl type convention
; #parameters are passed from right to left across
; #the stack and the stack pointer is returned by
; #the calling program
strcmp proc
	cld
	push di
	call strlen
	inc cx
	pop di
call _strcmp
	ret
endp

;#LOCAL-DEFINES
equiv = 0
less  = -1
more  = 1
; #############
_strcmp proc
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
	ret
endp


; ===--------------------------------------------------===
; brief | returns the index of a char in a str
; use   | {ax, es, di, si}
;       | es:[di] - ptr str (looking here)
; ret   | {bx} - index of char
; dest  | {bx,ax,si,di}
; #Example function with cdecl type convention
; #parameters are passed from right to left across
; #the stack and the stack pointer is returned by
; #the calling program
strchr proc
	cld
	xor bx, bx
	push ax
	push di
	call strlen
	pop di
	pop ax

	push ax
	call _strchr
	pop ax
	ret
endp

_strchr proc
	mov bp, sp
	mov ax, [bp + 2d]
@@continueSearch:
	scasb
	je @@end

	inc bx
	loop @@continueSearch

	noSymbol:
	mov ax, -1

@@end:
	ret
endp


; ===--------------------------------------------------===
; brief | write string buffer on screen
; use   | {di,si}
;       | es:[di] - ptr to video segment
; ret   | nthg
; dest  | {si}
; #example of <<Pascal>> wrapper function
; #arguments are passed from left to right, the
; #stack pointer is restored by the called function
print proc
	xor ax, ax
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


; ===--------------------------------------------------===
; brief | pause until the user presses any key
; use   | {ax}[with save]
; ret   | nthg
; #example of simple regs-function
; #registers are stored on the stack
; #for the duration of the function
Pause proc
	push ax
	xor ax, ax
	int 16h
	pop ax
	ret
endp


; ===--------------------------------------------------===
; @breif | sets video memory address to es:[di]
; @use   | {es}
; @ret   | nthg
; @dest  | {di,es}
; #example of simple regs-function
; #registers are stored on the stack
; #for the duration of the function
setVideo proc
	push ax
	mov ax, VIDEO_PTR
	mov es, ax
	xor di, di
	pop ax
	ret
endp


; ===--------------------------------------------------===
; brief | terminates the program
; #example of simple regs-function
exitp proc
	mov ax, 4C00h
	int 21h
	ret
endp


string_atoi 	db '123', 0
string0 	db 'hello', 0
string1 	db 'MEEOOOWW!', 0
string2 	db '.net bl at gaf', 0
string3 	db '______', 0

end start