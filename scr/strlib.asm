;-------------------------------------------------------------------------------
; File:     strlib.asm
; Date:     Feb 2022 
;
; String-function library written in turbo assembler  -using short "scary commands"
;
; Purpose:
; - To unleash the potential of commands that replace several 
; 	operations with registers (thereby hanging up the readability of the code)
;
; Ideas:  [.cdecl, pascal]:conventions
; - Implement parameter passing according to different conventions
;   in the language
;
; @Michael-krpch
;-------------------------------------------------------------------------------
		locals					; Use of local labels in the program
		.186					; Specialization of the program to work with the processor 186
;-------------------------------------------------------------------------------

		.model tiny				; using memory model for small programs

;-------------------------------------------------------------------------------
	.code 	; The library uses wrappers
EXIT_CODE = 04C00H
PAUSE_VAL = 00000H
VIDEO_PTR = 0B800H
RADIX_SYS = 16D

org 100h
;-------------------------------------------------------------------------------

		;-Some conventions when using registers in the library
;es:[di] ~ ptr to str №1, ds:[si] ~ ptr to str №2, cx  ~ counter,  al ~ symbol
start:; callable functions are used with < _ > prefix
		CALL  set_video
		CALL  prog_delay
		MOV   BX, 
		CALL  exit_program



strlen proc 						; [unsave]-string length
		PUSH   AX 					; #cdecl wrapper
		CLD 						; Set direction of increment
		XOR	  CX, CX 				; Prepare parameters
		XOR	  AL, AL 				;
		CALL   _strlen
		POP    AX
		RET
		ENDP
_strlen proc 						; Cxecute
find_nul:
		scasb 						; cmp al, es:[di] ~ word-ptr
		JE	  @@end 				; End if we find symbol
		INC	  CX
		JMP	  find_nul
@@end:
		RET
		ENDP

		;#.utilities functions for library (with wrappers for some)
prog_delay proc 					; [safe]-program delay.
		PUSH  AX 					; #cdecl wrapper 
		JMP   proc
		POP   AX
		RET
		ENDP
_pause proc 						; Simple pause with cathcing symbol
		MOV   AX,PAUSE_VAL 			
		INT   16H 					; Using the 16th interrupt to read a character
		RET
		ENDP

set_video proc 						; [safe]-video memory pointer.
		PUSH  AX 					; #cdecl wrapper 
		CALL  _video_indtaller
		POP   AX
		RET
		ENDP
_video_indtaller proc
		MOV   AX,VIDEO_PTR
		MOV   ES,AX
		XOR   DI,DI
		RET
		ENDP

exit_program proc 					; #programm finalist.
		MOV   AX,EXIT_CODE 			; (uses interrupt 21)
		INT   21H
		RET
		ENDP


str1 db 'meow meow meow purr!', 0
str2 db 'abobus.86-64', 0

END start