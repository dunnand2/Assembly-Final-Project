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
	prompt_2			BYTE	"You entered the following numbers:", 13, 10, 0
	string_separator	BYTE	", ", 0
	userString			BYTE	7 DUP(0) 
	validChar			DWORD	?
	userArray			SDWORD	10 DUP(?)


; (insert variable definitions here)

.code
main PROC
	; Introduction
	PUSH OFFSET intro_1
	PUSH OFFSET intro_2
	CALL introduction

	PUSH ARRAYSIZE
	PUSH OFFSET validChar
	PUSH OFFSET error_1
	PUSH OFFSET prompt_1
	PUSH OFFSET userString
	PUSH SIZEOF userString
	PUSH OFFSET userArray
	CALL getAllValues

	;PUSH OFFSET prompt_2
	;PUSH ARRAYSIZE
	;PUSH OFFSET userArray
	;CALL displayList

	PUSH OFFSET string_separator
	PUSH OFFSET prompt_2
	PUSH ARRAYSIZE
	PUSH OFFSET userArray
	CALL writeAllValues

	;PUSH OFFSET userArray
	;CALL WriteVal

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
;  Name: getAllValues
;	
;  Gets 10 values from user
;
;  Receives: 
;
;  Preconditions:  None
;
;  Postconditions: Displays introductory messages, intro_2 OFFSET in EDX
;
;  Returns: None
; ---------------------------------------------------------------------------------
getAllValues PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EDI
	PUSH ECX

	MOV EDI, [EBP + 8]			; userArray Offset
	MOV ECX, [EBP + 32]			; ArraySize

_getNumberLoop:
	PUSH [EBP + 28]				; Push validChar 
	PUSH [EBP + 24]				; Push error message
	PUSH [EBP + 20]				; Push prompt message
	PUSH [EBP + 16]				; push userString
	PUSH [EBP + 12]				; Push Max sizeOf user string	
	PUSH EDI					; Push userArray Offset
	CALL ReadVal

	ADD EDI, 4
	LOOP _getNumberLoop
	
	; return procedure
	POP ECX
	POP EDI
	POP EBP
	RET 28
getAllValues ENDP

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

	MOV EDI, [EBP + 8]
	MOV EBX, [EBP + 28]		; validChar OFFSET 
	XOR EAX, EAX
	MOV [EBX], EAX			; Reset validChar to 0

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
;  Name: writeAllValues
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
writeAllValues PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH ECX
	PUSH ESI
	PUSH EDX
	PUSH EAX

	MOV EBX, [EBP + 20]		; Array separator/commma string
	MOV ECX, [EBP + 12]		; ArraySize
	MOV ESI, [EBP + 8]		; Array OFFSET
	MOV EDX, [EBP + 16]		; Header
	

	mDisplayString EDX


_writeArrayValues:
	; Read value current value into EAX and print
	MOV EAX, [ESI]
	PUSH EAX
	CALL WriteVal
	DEC ECX
	CMP ECX, 0
	JE _finishWritingValues
	mDisplayString [EBP + 20]
	ADD ESI, 4
	JMP _writeArrayValues

_finishWritingValues:

	; reset stack frame
	Call Crlf
	Call Crlf

	POP EAX
	POP EDX
	POP ESI
	POP ECX
	POP EBP
	RET 16
writeAllValues ENDP

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
	LOCAL stringOutput[30]:BYTE 
	LOCAL reversedString[30]:BYTE
	PUSHAD
	
	MOV EAX, [EBP + 8]
	XOR EDX, EDX
	MOV EDI, EBP
	SUB EDI, 60
	XOR ECX, ECX

_checkNegativity:
	CMP EAX, 0
	JG _intToStringLoop
	NEG EAX

_intToStringLoop:
	CLD
	INC ECX
	XOR EDX, EDX
	MOV EBX, 10
	DIV EBX
	ADD EDX, 48
	MOV EBX, EAX
	MOV AL, DL 
	STOSB
	MOV EAX, EBX
	CMP EBX, 0
	JE _addNegativeSign
	CMP EBX, 10
	JL _convertFinalDigit
	JMP _intToStringLoop 

_convertFinalDigit:
	INC ECX
	MOV AL, BL
	ADD AL, 48
	STOSB
	;XOR AL, AL
	;STOSB

_addNegativeSign:
	; If value 0 or positive continue to reverse string
	MOV EAX, [EBP + 8]
	CMP EAX, 0
	JGE _flipString

	; Else add minus sign to string
	INC ECX
	MOV AL, '-'
	STOSB

_flipString:
	MOV ESI, EBP 
	SUB ESI, 60
	ADD ESI, ECX	; ECX is string length
	DEC ESI
	MOV EDI, EBP 
	SUB EDI, 30

_revLoop:
    STD
    LODSB
    CLD
    STOSB
	LOOP   _revLoop

	; Null terminate the string
	mov byte ptr[edi],0 

_displayString:
	MOV EAX, EBP
	SUB EAX, 30
	mDisplayString EAX
	POPAD
	RET 4

WriteVal ENDP

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
