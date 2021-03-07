TITLE Project 5     (Proj5_dunnand.asm)

; Author: Andrew Dunn
; Last Modified: 2/28/2021
; OSU email address: dunnand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 2/28/2021
; Description: This program generates a random array of 200 integers between 10 and 29.
; It then sorts the array and prints the sorted values. It calculates the median value and prints it
; It then counts the total of each number within the sorted array and creates a new array with the
; counts of each number between 10 and 29.


INCLUDE Irvine32.inc

;mGetSring MACRO
;ENDM



.data
	intro_1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10 
						BYTE	"Written by: Andrew Dunn" , 13, 10, 0
	intro_2				BYTE	"Please provide 10 signed decimal integers.", 13, 10
						BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 13, 10
						BYTE	"After you have finished inputting the raw numbers I will display", 13, 10
						BYTE	"a list of the integers, their sum, and their average value.", 13, 10, 0
	outro_1				BYTE	"Thanks for playing!", 0
	prompt_1			BYTE	"Please enter an signed number: ", 0
	userString			BYTE	33 DUP(0) ;

; (insert variable definitions here)

.code
main PROC
	; Introduction
	PUSH OFFSET intro_1
	PUSH OFFSET intro_2
	CALL introduction

	PUSH OFFSET userString
	PUSH OFFSET prompt_1


	; Goodbye
	PUSH OFFSET outro_1
	CALL farewell
; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
;  Name: introduction
;	
;  Introduces the name of the program and programmer
;
;  Receives: intro_1, intro_2
;
;  Preconditions:  None
;
;  Postconditions: Displays introductory messages, intro_2 OFFSET in EDX
;
;  Returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP

	; print intro_1
	MOV EDX, [EBP+12]
	CALL WriteString
	CALL Crlf

	; print intro_2
	MOV EDX, [EBP+8]
	CALL WriteString
	CALL Crlf
	
	; return procedure
	POP EBP
	RET 8
introduction ENDP

; ---------------------------------------------------------------------------------
;  Name: fillArray
;	
;  Fills randomArray with random integers
;
;  Receives: randomArray, LO, HI, ARRAYSIZE
;
;  Preconditions: randomArray must be a DWORD array
;
;  Postconditions: None
;
;  Returns: randomArray
; ---------------------------------------------------------------------------------

fillArray PROC
	; build stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EAX
	PUSH EBX
	PUSH EDI

	; put address of first element of random array into ESI and start counter
	MOV ECX, [EBP + 12]
	MOV EDI, [EBP + 8]
	
_fillLoop:
	MOV EAX, [EBP+20]		; HI Value
	MOV EBX, [EBP+16]		; LO Value

	; Generate random number and add to array
	SUB EAX, EBX
	INC EAX
	CALL RandomRange
	ADD EAX, EBX
	MOV [EDI], EAX

	; Increment memory
	ADD EDI, 4
	LOOP _fillLoop

	; return procedure
	POP EDI
	POP EBX
	POP EAX
	POP EBP
	RET 16
fillArray ENDP

; ---------------------------------------------------------------------------------
;  Name: displayList
;	
;  Displays the random array
;
;  Receives: unsortedHeader, randomArray, ARRAYSIZE
;
;  Preconditions:  randomArray must be a DWORD array
;
;  Postconditions: EAX, EBX changed
;
;  Returns: randomArray
; ---------------------------------------------------------------------------------
displayList PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH ECX
	PUSH ESI
	PUSH EDX


	MOV ECX, [EBP + 12]
	MOV ESI, [EBP + 8]
	MOV EDX, [EBP + 16]
	MOV EBX, 20

	CALL WriteString 

_printLoop:
	; check if new line
	MOV EAX, [EBP + 12]			; Move ARRAYSIZE into EAX
	SUB EAX, ECX				; Subtract counter from ARRAYSIZE for total printed
	XOR EDX, EDX
	DIV EBX						; Divide by 20
	CMP EDX, 0					; Print new line if divisible by 20
	JNE _printCurrValue
	Call Crlf

_printCurrValue:
	; Read value current value into EAX and print
	MOV EAX, [ESI]
	CALL WriteDec
	MOV AL, ' '
	CALL WriteChar
	ADD ESI, 4
	LOOP _printLoop

	; reset stack frame
	Call Crlf
	Call Crlf
	POP EDX
	POP ESI
	POP ECX
	POP EBP
	RET 8
displayList ENDP

; ---------------------------------------------------------------------------------
;  Name: sortList
;	
;  Sorts the array passed to the procedure
;
;  Receives: randomArray, ARRAYSIZE
;
;  Preconditions:  randomArray must be DWORD array
;
;  Postconditions:  EAX changed, EDX changed 
;
;  Returns: randomArray
; ---------------------------------------------------------------------------------
sortList PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH ECX
	PUSH EDI

	; Assign counter (Array size) and array address
	MOV ECX, [EBP + 12]
	MOV EDI, [EBP + 8]
	SUB ECX, 1

_outerLoop:
	PUSH ECX	; Loop Counter
	PUSH EDI
	_innerLoop:
		; Compare values at adjacent indices, swap if first index is greater than second
		MOV EAX, [EDI]
		MOV EDX, [EDI + 4]
		CMP EAX, EDX
		JG _swap
		JMP _loop
		
	_swap:
		CALL exchangeElements

	_loop:
		ADD EDI, 4
		LOOP _innerLoop
	POP EDI
	POP ECX
	LOOP _outerLoop

	POP EDI
	POP ECX
	POP EBP
	RET 8
sortList ENDP

; ---------------------------------------------------------------------------------
;  Name: exchangeElements
;	
;  exchanges two elements of an array
;
;  Receives: None
;
;  Preconditions: randomArray must be a DWORD array, value of current index in EAX, value of next index in EDX, address of current index in EDI
;
;  Postconditions: None
;
;  Returns: current and next index values are swapped 
; ---------------------------------------------------------------------------------
exchangeElements PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP

	; swap the values
	MOV [EDI], EDX
	MOV [EDI + 4], EAX

	POP EBP
	RET
exchangeElements ENDP

; ---------------------------------------------------------------------------------
;  Name: displayMedian
;	
;  Sorts the array passed to the procedure
;
;  Receives: randomArray, ARRAYSIZE
;
;  Preconditions:  randomArray must be DWORD array
;
;  Postconditions:   EAX, EBX, ECX, and EDX changed, median displayed
;
;  Returns: None
; ---------------------------------------------------------------------------------
displayMedian PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP

	MOV EAX, [EBP + 12]			; ARRAYSIZE
	MOV ESI, [EBP + 8]			; randomArray address

	; Check if ARRAYSIZE is odd or even
	XOR EDX, EDX
	MOV ECX, 2
	DIV ECX
	CMP EDX, 0
	JNE _oddNumberedArray

	; If array is even, get addresses of the middle two numbers of the sorted array
	MOV EBX, 4					; EAX is quotient of ARRAYSIZE DIV 2
	MUL EBX						; MUL EBX gives address of middle index in EAX
	MOV EDX, [ESI + EAX]		; Middle number 1
	SUB EAX, EBX
	MOV EBX, [ESI + EAX]		; Middle number 2
	
	; Find average of two middle numbers
	ADD EBX, EDX
	MOV EAX, EBX
	MOV EBX, 2
	XOR EDX, EDX
	DIV EBX
	
	; If integer, print the result, else round up and print the result
	CMP EDX, 0 
	JE _printMedian
	INC EAX
	JMP _printMedian

_oddNumberedArray:
	; If odd numbered array, find the middle of array and print result
	MOV EBX, 4					; EAX is quotient of ARRAYSIZE DIV 2
	MUL EBX						; MUL EBX gives address of middle index in EAX
	MOV EBX, [ESI+EAX]
	MOV EAX, EBX
	
_printMedian:
	MOV EDX, [EBP + 16]
	CALL WriteString
	CALL WriteDec
	CALL Crlf
	CALL Crlf

	POP EBP
	RET 8
displayMedian ENDP

; ---------------------------------------------------------------------------------
;  Name: generateCounts
;	
;  populates the counts array with total amount of each random number
;
;  Preconditions: counts must be DWORD array
;
;  Postconditions: EAX, ECX, EDX changed, Goodbye message displayed
;
;  Receives: Arraysize, counts, HI, LO
;
;  Returns: None
; ---------------------------------------------------------------------------------
generateCounts PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH ESI
	PUSH EDI

	MOV ECX, [EBP + 24]			; ARRAYSIZE
	MOV EDI, [EBP + 20]			; counts
	MOV ESI, [EBP + 8]			; randomArray                                                                                                                                                          ]
	MOV EAX, [EBP + 12]			; LO
	XOR EDX, EDX				; current count

_startCount:
	MOV EBX, [ESI]
	CMP EAX, EBX
	JNE _endCount
	INC EDX
	ADD ESI, 4
	DEC ECX
	JNZ _startCount

_endCount:
	MOV [EDI], EDX
	ADD EDI, 4
	XOR EDX, EDX
	INC EAX
	CMP ECX, 0
	JE _doneCounting
	JMP _startCount

_doneCounting:
	POP EDI
	POP ESI
	POP EBP
	RET 20
generateCounts ENDP

; ---------------------------------------------------------------------------------
;  Name: farewell
;	
;  Displays goodbye message to the user
;
;  Preconditions: None
;
;  Postconditions: Goodbye message displayed
;
;  Receives: outro_1
;
;  Returns: None
; ---------------------------------------------------------------------------------
farewell PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP

	; print greeting_1
	MOV EDX, [EBP+8]
	CALL WriteString
	CALL Crlf
	
	; return procedure
	POP EBP
	RET 8
farewell ENDP

END main
