TITLE Project 6     (Proj6_dunnand.asm)

; Author: Andrew Dunn
; Last Modified: 2/28/2021
; OSU email address: dunnand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 3/14/2021
; Description: This program generates a random array of 200 integers between 10 and 29.
; It then sorts the array and prints the sorted values. It calculates the median value and prints it
; It then counts the total of each number within the sorted array and creates a new array with the
; counts of each number between 10 and 29.


INCLUDE Irvine32.inc

mGetString MACRO outputLocation, outputLocationSize
	; get user input and allowable input size
	MOV EDX, outputLocation
	MOV ECX, outputLocationSize
	CALL ReadString
ENDM

mDisplayString MACRO inputLocation
	; Display input string
	MOV EDX, inputLocation
	CALL WriteString
ENDM

ARRAYSIZE = 10

.data
	intro_1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10 
						BYTE	"Written by: Andrew Dunn" , 13, 10, 0
	intro_2				BYTE	"Please provide 10 signed decimal integers.", 13, 10
						BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 13, 10
						BYTE	"After you have finished inputting the raw numbers I will display", 13, 10
						BYTE	"a list of the integers, their sum, and their average value.", 13, 10, 0
	error_1				BYTE	"ERROR: You did not enter a signed number or your number was too big.", 13, 10
						BYTE	"Please try again: ", 0
	outro_1				BYTE	"Thanks for playing!", 0
	prompt_1			BYTE	"Please enter an signed number: ", 0
	userString			BYTE	33 DUP(0) 
	validChar			DWORD	?
	userArray			SDWORD	10 DUP(?)
	tempHeader			BYTE	"REMOVE ME: ", 13, 10, 0


; (insert variable definitions here)

.code
main PROC
	; Introduction
	PUSH OFFSET intro_1
	PUSH OFFSET intro_2
	CALL introduction

	PUSH OFFSET validChar
	PUSH OFFSET error_1
	PUSH OFFSET prompt_1
	PUSH OFFSET userString
	PUSH SIZEOF userString
	PUSH OFFSET userArray
	CALL ReadVal

	PUSH OFFSET tempHeader
	PUSH ARRAYSIZE
	PUSH OFFSET userArray
	CALL displayList

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
;  Name: ReadVal
;	
;  Prompts user for an integer value, reads it as a string and converts to SDWORD, 
;	and then stores this value in 
;
;  Receives: prompt_1, userString, userArray
;
;  Preconditions: randomArray must be a DWORD array
;
;  Postconditions: None
;
;  Returns: userArray
; ---------------------------------------------------------------------------------

ReadVal PROC
	; build stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EDX
	PUSH ECX
	PUSH EBX

	; Set loop counter (EBX because macro uses ECX.)
	MOV EBX, 10
	MOV EDI, [EBP + 8]

	;prompt user for input
_promptUserNumber:
	mDisplayString [EBP + 20]

	; Call getString Macro
_getString:
	mGetString [EBP + 16], [EBP + 12]
	; Postconditions: number of bytes read in EAX. Entered string in EDX
	
	PUSH [EBP + 28]			; validChar offset
	PUSH EAX				; Number of Bytes read
	PUSH EDI				; userArray offset
	PUSH EDX				; This is the current string OFFSET
	CALL convertString

	; Compare validChar to 0, continue with loop if valid, alert user if invalid number
	MOV EDX, [EBP + 28]		
	MOV EAX, [EDX]
	CMP EAX, 0
	JG _errorInvalidNumber
	JMP _noError

_errorInvalidNumber:
	mDisplayString [EBP + 24]
	JMP _getString

_noError:
	ADD EDI, 4
	DEC	EBX
	CMP EBX, 0
	JNE _promptUserNumber

	POP EBX
	POP ECX
	POP EDX
	POP EBP
	RET 24
ReadVal ENDP

; ---------------------------------------------------------------------------------
;  Name: convertString
;	
;  Converts a string value to integer using string primitives
;
;  Receives: userString, userString Size, userArray
;
;  Preconditions:  None
;
;  Postconditions: None
;
;  Returns: userString
; ---------------------------------------------------------------------------------
convertString PROC
	LOCAL numInt:SDWORD
	LOCAL negVal:DWORD
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH EDI
	PUSH ESI

	; Assign values from the stack 
	XOR EAX, EAX
	MOV numInt, EAX
	MOV negVal, EAX
	MOV EDI, [EBP + 12]			; userArray to store numeric values
	MOV ESI, [EBP + 8]			; user entered string
	MOV ECX, [EBP + 16]			; length of string
	MOV EDX, [EBP + 20]			; validChar offset used to validate string
	MOV [EDX], EAX				; initialize validChar to 0 (valid status)
	
	; Load first value
	LODSB

	; Check if value is + sign, else continue to loop 
	CMP AL, 43
	JE _positiveSign

	; Check if value is - sign, else continue to loop 
	CMP AL, 45
	JE _negativeSign
	JMP _checkString

_positiveSign:
	; Invalidate if plus sign only string value entered
	DEC ECX
	CMP ECX, 0
	JE _invalid
	JMP _stringLoop

_negativeSign:
	; Invalidate if minus sign only string value entered
	DEC ECX
	CMP ECX, 0
	JE _invalid

	; Set negVal to 1 (indicates a negative value)
	MOV EAX, 1
	MOV negVal, EAX
	JMP _stringLoop

_stringLoop:
	LODSB

_checkString:
	CMP AL, 48
	JL _invalid
	CMP AL, 57
	JG _invalid

	MOVZX EBX, AL
	SUB EBX, 48
	MOV EAX, 10
	MUL numInt
	ADD EAX, EBX
	MOV numInt, EAX
	DEC ECX
	CMP ECX, 0
	JE _storeString
	JMP _stringLoop

_storeString:
	; Check if negVal was set to 1 (indicates a - sign was entered at start of string)
	MOV EBX, negVal
	CMP EBX, 1
	JNE _positive
	NEG EAX			; set value negative if negVal 1

	; Store numeric value in user Array
_positive:
	MOV [EDI], EAX
	JMP _valid

_invalid:
	; If invalid update validChar to 1 (invalid status)
	MOV EAX, 1
	MOV [EDX], EAX
	JMP _doneConverting

_valid:
	XOR EAX, EAX
	MOV [EBP + 20], EAX

_doneConverting:
	POP ESI
	POP EDI
	POP EDX
	POP ECX
	POP EBX
	POP EAX
	RET 16
convertString ENDP

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


	MOV ECX, [EBP + 12]		; ArraySize
	MOV ESI, [EBP + 8]		; Array OFFSET
	MOV EDX, [EBP + 16]		; Header
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
	CALL WriteInt
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
;  Name: WriteVal
;	
;  Sorts the array passed to the procedure
;
;  Receives: SDWORD input
;
;  Preconditions:  
;
;  Postconditions:   
;
;  Returns: displays SDWORD value to output
; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL stringOutput:BYTE 

	MOV EAX, [EBP + 8] ; Numeric SDWORD
	XOR EDX, EDX
	MOV EDI, [EBP - 4]

_intToStringLoop:
	CLD
	DIV 10
	CMP EDX, 0 
	JE 
	MOV AL, DL
	STOSB
	JMP intToStringLoop 

	RET 4
WriteVal ENDP

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
