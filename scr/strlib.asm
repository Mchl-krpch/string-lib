;-------------------------------------------------------------------------------
; File:     strlib.asm
; Date:     Feb 2022 
;
; String-function library written in turbo assembler  -using short "scary commands"
;
; Purpose:
; - To unleash the potential of commands that replace several 
;   operations with registers (thereby hanging up the readability of the code)
;
; Ideas:  [.cdecl, pascal]:conventions
; - Implement parameter passing according to different conventions
;   in the language
;
; @Michael-krpch
;-------------------------------------------------------------------------------
	locals                  ; Use of local labels in the program
	.186                    ; Specialization of the program to work with the processor 186
;-------------------------------------------------------------------------------

	.model tiny             ; using memory model for small programs

;-------------------------------------------------------------------------------
        .code   ; The library uses wrappers
     EXIT_CODE = 04C00H
     PAUSE_VAL = 00000H
     VIDEO_PTR = 0B800H
     RADIX_SYS = 16D
     RADIX_DEG = 4D

        org 100h
;-------------------------------------------------------------------------------

	;-Some conventions when using registers in lib (more often)
;es:[di] ~ ptr to str №1,   ds:[si] ~ ptr to str №2,   cx  ~ counter,    al ~ symbol
start:; callable functions are used with < _ > prefix
	MOV   DI,offset stia
	MOV   BX,RADIX_SYS
	MOV   AX,123D
	CALL  itoa
	CALL  print
	CALL  exit_program

	;#.The main functions of the library (7 functions)
; Ret DI-resulting string  
; Incoming: CX,DI           |! ITOA NOT DONE YET
itoa proc
	PUSH  DI                    ; "strlen" needs di, so we push it
	CALL  strlen                ; Remember string length [in cx]
	POP   DI                    ; Return di
	ADD   DI,CX
	CALL  _itoa
	RET
	ENDP
_itoa proc
	MOV   bp,sp
@@repeat:
	DIV   BX                    ; The whole part is written in AX the remainder - in DX
	MOV   DI,BX
	DEC   DI
	CMP   AX,0D
	JA    @@repeat
	RET
	ENDP

; Ret AX-result number
; Incoming: [cx]-strlen, [di]-ptr to str, [ax]-result, bx-radix
atoi2 proc
	XOR   AX,AX                 ; Clear the future response field
	PUSH  DI                    ; "strlen" needs di, so we push it
	CALL  strlen                ; We consider the length
	POP   DI                    ; Return di
	PUSH  BX
	CALL  _atoi2                ; Let-s start translating
	POP   BX
	RET
	ENDP
_atoi2 proc
	MOV   bp,sp
@@repeat:
	PUSH  CX
	MOV   CX,[bp + 2D]
	SHL   AX,CL                 ; Shift the digits of a number by one digit
	POP   CX
	ADD   AL,es:[DI]            ; Adding the next digit
	INC   DI                    ; Set the pointer to the next digit
	SUB   AL,'0'                ; Subtract character code zero
	loop  @@repeat              ; Repeat until we reach the last burst
	RET
	ENDP

; Ret AX-result number
; Incoming: [cx]-strlen, [di]-ptr to str, [ax]-result, bx-radix
atoi proc
	XOR   AX,AX                 ; Clear the future response field
	PUSH  DI                    ; "strlen" needs di, so we push it
	CALL  strlen                ; We consider the length
	POP   DI                    ; Return di
	CALL  _atoi                 ; Let-s start translating
	RET
	ENDP
_atoi proc
	MOV   bp,sp
@@repeat:
	MUL   BX                    ; Shift the digits of a number by one digit
	ADD   AL,es:[DI]            ; Adding the next digit
	INC   DI                    ; Set the pointer to the next digit
	SUB   AL,'0'                ; Subtract character code zero
	loop  @@repeat              ; Repeat until we reach the last burst
	RET
	ENDP

; Ret: AX-cmp result
; Incoming: al - search-symbol, bx, cx-strlen, {di,si}-ptr to string
strcmp proc                         ; [unsafe]-Put symbols on the screen
	CLD                         ; Set direction of increment
	PUSH  DI                    ; To save DI string pointer
	CALL  strlen
	INC   CX
	POP   DI
call _strcmp
	RET
endp
_strcmp proc                         
	repe  cmpsb                 ; Looking for a mismatched character
	JA    @@less                ; Selects the desired option
	JB    @@more                ;
	JE    @@equiv               ;
@@equiv:
	MOV   AX,1D
	JMP   @@end
@@less:
	MOV   AX,0D
	JMP   @@end
@@more:
	MOV   AX,2D
	JMP   @@end
@@end:
	RET
	ENDP

; Ret: BX-symbol index
; Incoming: al - search-symbol, bx, cx-strlen 
strchr proc                         ; [unsafe]-Search symbol
	CLD                         ; Set direction of increment
	XOR   BX,BX                 ; Will be the index of the found character
	CALL  strlen                ; In cx we write the length of the string
	PUSH  AX
	CALL  _strchr               ; Call executor
	POP   AX
	RET
	ENDP
_strchr proc                        ; [cdecl] doesn-t clear anything
	MOV   bp,sp                 ; Set stack save-pointer
	MOV   AX,[bp + 2D]          ; Search-symbol
@@continueSearch:
	scasb
	JE    @@end
	INC   BX
	loop  @@continueSearch
	MOV   AX, -1
@@end:
	RET
	ENDP

; Ret: Nothing
; Incoming: al - end-of-line char, {bx} - string ptr, si - counter di - pos on screen
print proc                          ; [unsafe]-Put symbols on the screen
	XOR   AL,AL                 ; #pascal wrapper
	XOR   SI,SI                 ; Set begin of the string
	PUSH  DI                    ; Put position on screen
	CALL  _print
	RET
	ENDP
_print proc                         ; [pascal]  clear di position
	MOV   bp,sp
	MOV   di,[bp + 2D]          ; Use di-index
@@repeat:
	scasb                       ; Cmp with end of line char
	JE    @@end
	INC   DI                    ; Next pos on screen
	MOV   AL,[bx + SI]          ; Copy si-symbol to AL
	MOV   es:[di],AL            ; Puts it on the screen
	XOR   AL, AL
	INC   SI
	JMP   @@repeat
@@end:
	POP   DI
	RET
	ENDP

; Ret: NEW-STRING {di pointer}
; Incoming: al - end-of-line character, {si, di} - ptr of strings
strncpy proc                        ; [safe]-copy a string to another
	CLD                         ; Set direction of increment
	CALL  _strncpy              ; Call executor
	RET
	ENDP
_strncpy proc
@@repeat:
	movsb                       ; Copies a byte from DS:[SI] to ES:[DI]
	CMP   es:[DI],AL
	JE    @@end                 ; Check string №1 ending
	CMP   ds:[SI],AL            ; Check string №2 ending
	JE    @@end                 ; Stop copy
	JMP   @@repeat              ; Repeat until one of the lines ends
@@end:
	RET
	ENDP

; Ret: CX -sym.counter
; Incoming: al - end-of-line character, {di} - ptr to string 
strlen_short proc                   ; [unsave]-string length
	PUSH  AX                    ; #cdecl wrapper
	CLD                         ; Set direction of increment
	MOV   CX,0FFFFH             ; [!] | The function subtracts one from the maximum value of the
	XOR   AL,AL                 ;     | word until it finds the desired character, and then subtracts 
	CALL   _strlen_short        ;     | the resulting value from the maximum value of the word
	DEC   CX                    ; if you do not subtract one, then there will be a
	POP   AX                    ; length of the string with zero
	RET
	ENDP
_strlen_short proc                  ; Execute
	repne scasb                 ; cmp al, es:[di] ~ word-ptr
	NOT   CX                    ; [!] | take the complement of two
	RET
	ENDP

; Ret: CX -sym.counter
; Incoming: ax-terminated character, cx-symbol counter   
strlen proc                         ; [unsave]-string length
	PUSH  AX                    ; #cdecl wrapper
	XOR   AX,AX
	CLD                         ; Set direction of increment
	XOR   CX,CX                 ; Prepare parameters
	CALL  _strlen               ; Call executor
	POP   AX
	RET
	ENDP
_strlen proc                        ; Execute
@@find_nul:                         ; Looking for a symbol until we find
	scasb                       ; cmp al, es:[di] ~ word-ptr
	JE    @@end                 ; End if we find symbol
	INC   CX                    ; Continue search
	JMP   @@find_nul
@@end:                              ; End searcing
	RET
	ENDP

	;#.utilities functions for library (with wrappers for some)
prog_delay proc                     ; [safe]-program delay until the key is pressed
	PUSH  AX                    ; #cdecl wrapper 
	JMP   _pause                ; Call executor
	POP   AX
	RET
	ENDP
_pause proc                         ; Simple pause with cathcing symbol
	MOV   AX,PAUSE_VAL          ; = 0D
	INT   16H                   ; Using the 16th interrupt to read a character
	RET
	ENDP

set_video proc                      ; [safe]-video memory pointer.
	PUSH  AX                    ; #cdecl wrapper 
	CALL  _video_ptr            ; Call executor
	POP   AX
	RET
	ENDP
_video_ptr proc
	MOV   AX,VIDEO_PTR
	MOV   ES,AX
	XOR   DI,DI
	RET
	ENDP

exit_program proc                   ; #programm finalist.
	MOV   AX,EXIT_CODE          ; (uses interrupt 21) = 04C00H
	INT   21H                   ; interrupt
	RET
	ENDP

str1 db 'meow meow meow purr!', 0
str2 db 'abobus.86-64', 0
str3 db 'meowWZ', 0
stai db '123', 0
stia db '   ', 0                    ;string to fill with numbers

END start