TITLE Project 3     (Proj3_dunnand.asm)

; Author: Andrew Dunn
; Last Modified: 1/24/2021
; OSU email address: dunnand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 1                Due Date: 1/24/2021
; Description: This file gets three positive integers from the user and returns their sums and differences

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data

intro_1				BYTE	"Welcome to the Integer Accumulator by Andrew Dunn", 0
greeting_1			BYTE	"Hello there, ", 0
prompt_1			BYTE	"What is your name? ", 0
userName			BYTE	33 DUP(0) ;
outro_1				BYTE	"We have to stop meeting like this. Farewell, ", 0
prompt_2			BYTE	"Please enter numbers in [-200, -100] or [-50, -1]. ", 0
count				WORD	?					; Count total number of valid inputs
userNumber			SDWORD	?					; placeholder for current number entered by User
sum					SDWORD	?					; Sum of all entered numbers
min					SDWORD	?					; minimum of all entered numbers
max					SDWORD	?					; maximum of all entered numbers
average				SDWORD	?					; average of all entered numbers


; (insert variable definitions here)

.code
main PROC

	;Introduce program and programmer
	mov EDX, OFFSET intro_1
	call writeString
	call Crlf

	; Get name of user
	mov EDX, OFFSET prompt_1
	call WriteString
	; Preconditions of ReadString: (1) Max length saved in ECX, EDX holds pointer to string
	mov EDX, OFFSET userName
	mov ECX, SIZEOF userName
	call Readstring

	; Greet user
	mov EDX, OFFSET greeting_1
	call WriteString
	mov EDX, OFFSET userName
	call WriteString
	call Crlf
	call Crlf
	call Crlf

	; Get second number
	mov EDX, OFFSET prompt_2
	call WriteString
	; Preconditions of ReadDec:
	call ReadDec
	; Postconditions of ReadDec: value is saved in EAX
	mov userNumber, EAX

; Section 5 - Goodbye

	; Say Goodbye
	mov EDX, OFFSET outro_1
	call WriteString
	mov EDX, OFFSET userName
	call WriteString
	call Crlf

; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
