TITLE Project 6     (Proj6_dunnand.asm)

; Author: Andrew Dunn
; Last Modified: 3/15/2021
; OSU email address: dunnand@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 3/16/2021 (two grace days)
; Description: This program prompts the user for 10 integers (positive or negative). 
; It reads those numbers as strings and converts them to integers using string primitive instructions.
; It then calculates the sum and average of those integers. Finally, the program converts those integers
; back to strings using string primitives (including sum and average), and displays the values as strings.


; **EC: This program numbers each line of user input and display a running subtotal of the user’s valid numbers, all using Writeval

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
	sum_prompt			BYTE	"The sum of these numbers is: ", 0
	average_prompt		BYTE	"The rounded average is: ", 0
	linePunctuation		BYTE	". ", 0
	currentSum			BYTE	"Current Sum: ", 0
	string_separator	BYTE	", ", 0
	userString			BYTE	20 DUP(0) 
	validChar			DWORD	?
	userArray			SDWORD	10 DUP(?)
	sum					SDWORD	?
	average				SDWORD	?


; (insert variable definitions here)

.code
main PROC
	; Introduction
	PUSH OFFSET intro_1
	PUSH OFFSET intro_2
	CALL introduction

	; Receive all values, while calculating sum and average
	PUSH OFFSET linePunctuation
	PUSH OFFSET currentSum
	PUSH OFFSET average
	PUSH OFFSET sum
	PUSH ARRAYSIZE
	PUSH OFFSET validChar
	PUSH OFFSET error_1
	PUSH OFFSET prompt_1
	PUSH OFFSET userString
	PUSH SIZEOF userString
	PUSH OFFSET userArray
	CALL getAllValues

	; Write all values in the userArray, as well as sum and average of array values
	PUSH OFFSET sum_prompt 
	PUSH OFFSET average_prompt
	PUSH sum
	PUSH average
	PUSH OFFSET string_separator
	PUSH OFFSET prompt_2
	PUSH ARRAYSIZE
	PUSH OFFSET userArray
	CALL writeAllValues

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
;  Postconditions: Displays introductory messages
;
;  Returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EDX

	; print intro_1
	MOV EDX, [EBP+12]
	CALL WriteString
	CALL Crlf

	; print intro_2
	MOV EDX, [EBP+8]
	CALL WriteString
	CALL Crlf
	
	; return procedure
	POP EDX
	POP EBP
	RET 8
introduction ENDP

; ---------------------------------------------------------------------------------
;  Name: getAllValues
;	
;  Description: Loops through 10 times calling ReadVal. ReadVal converts from string input to integers 
;				and stores in userArray. Calculates sum and average of converted integers. 
;
;  Receives:	average OFFSET, sum OFFSET, ARRAYSIZE, validChar OFFSET, SIZEOF userString 
;				error_1 OFFSET, prompt_1 OFFSET, userString OFFSET, userArray OFFSET, linePunctuation OFFSET,
;				currentSum OFFSET
;
;  Preconditions:  None
;
;  Postconditions: None
;
;  Returns: 10 integers are stored in userArray. Average and sum are updated
; ---------------------------------------------------------------------------------
getAllValues PROC
	; save stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EDI
	PUSH ECX
	PUSH EAX
	PUSH EBX
	PUSH EDX

	; initialize values
	MOV EDI, [EBP + 8]			; userArray Offset
	MOV ECX, [EBP + 32]			; ArraySize
	MOV EBX, [EBP + 36]			; sum offset
	XOR EAX, EAX

	; Make calls to ReadVal equal to ARRAYSIZE
_getNumberLoop:
	PUSH [EBP + 28]				; Push validChar 
	PUSH [EBP + 24]				; Push error message
	PUSH [EBP + 20]				; Push prompt message
	PUSH [EBP + 16]				; push userString
	PUSH [EBP + 12]				; Push Max sizeOf user string	
	PUSH EDI					; Push userArray Offset

	MOV EDX, 11
	SUB EDX, ECX
	PUSH EDX
	CALL WriteVal
	mDisplayString [EBP + 48]
	CALL ReadVal

	; add the converted number to EAX (will be added to sum offset later)
	mDisplayString [EBP + 44]
	ADD EAX, [EDI]
	PUSH EAX
	CALL WriteVal
	Call Crlf


	; increment array destination in memory
	ADD EDI, 4
	LOOP _getNumberLoop
	
	; Add whitespace
	CALL Crlf

	; Move sum (EAX) to sum offset, stored in EBX
	MOV [EBX], EAX
	MOV EBX, [EBP + 40]			; average offset

	; Divide sum (EAX) by ARRAYSIZE to get average
	XOR EDX, EDX
	MOV ECX, [EBP + 32]			; Move ARRAYSIZE (10) to ECX
	DIV ECX
	MOV [EBX], EAX				; Move average to average OFFSET

	; return procedure
	POP EDX
	POP EBX 
	POP EAX
	POP ECX
	POP EDI
	POP EBP
	RET 44
getAllValues ENDP

; ---------------------------------------------------------------------------------
;  Name: ReadVal
;	
;  Prompts user for an integer value, reads it as a string and converts to SDWORD, 
;	and then stores this value in array destination.
;
;  Receives:	validChar OFFSET, error_1 OFFSET, prompt_1 OFFSET, userString OFFSET,
;				SIZEOF userString, userArray OFFSET
;
;  Preconditions: userArray must be a DWORD array
;
;  Postconditions: validChar is changed
;
;  Returns: userArray, 
; ---------------------------------------------------------------------------------

ReadVal PROC
	; build stack frame
	PUSH EBP
	MOV EBP, ESP
	PUSH EDX
	PUSH ECX
	PUSH EBX
	PUSH EAX
	PUSH EDI 

	MOV EDI, [EBP + 8]		; Array location (to store converted integer)
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
	; If invalid number prompt for another number
	mDisplayString [EBP + 24]
	JMP _getString

_noError:
	POP EDI
	POP EAX
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
;  Receives: userString, userString Size, userArray, validChar
;
;  Preconditions:  None
;
;  Postconditions: None
;
;  Returns: userArray, validChar
; ---------------------------------------------------------------------------------
convertString PROC
	LOCAL numInt:SDWORD
	LOCAL negVal:DWORD
	PUSHAD

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

	; Check length
	CMP ECX, 11
	JG _invalid

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
	; Load next string character
	LODSB

_checkString:
	; Check that string is a valid digit
	CMP AL, 48
	JL _invalid
	CMP AL, 57
	JG _invalid

	; zero extend value to 32-bits
	MOVZX EBX, AL

	; Convert from Ascii value to integer value
	SUB EBX, 48

	; multiply by base 10 after each pass to make room for new value
	MOV EAX, 10
	MUL numInt
	ADD EAX, EBX

	; Add most recent number to numInt
	MOV numInt, EAX
	JO _checkEdgeCase

	; End loop once ECX 0
	DEC ECX
	CMP ECX, 0
	JE _checkNegative
	JMP _stringLoop

_checkEdgeCase:
	; Check if value is -2147483648
	CMP EAX, 2147483648
	JNE _invalid
	; If -2147483648, OK
	CMP negVal, 1
	JNE _invalid

_storeString:
	; Check if value overflows
	MOV EAX, NumInt

_checkNegative:
	; Check if negVal was set to 1 (indicates a - sign was entered at start of string)
	MOV EBX, negVal
	CMP EBX, 1
	JNE _positive
	NEG EAX			; set value negative if negVal 1

_positive:
	; Store numeric value in user Array
	MOV [EDI], EAX
	JMP _valid

_invalid:
	; If invalid update validChar to 1 (invalid status)
	MOV EAX, 1
	MOV EDX, [EBP + 20]		; reset EDX to validChar, could hold overflow
	MOV [EDX], EAX
	JMP _doneConverting

_valid:
	; If valid store 0 in valid char to alert ReadVal
	XOR EAX, EAX
	MOV [EBP + 20], EAX

_doneConverting:
	POPAD
	RET 16
convertString ENDP

; ---------------------------------------------------------------------------------
;  Name: writeAllValues
;	
;  Displays values from the array, average, and sum via calls to WriteVal.
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

	; continue until ECX 0
	DEC ECX
	CMP ECX, 0
	JE _finishWritingValues

	; print comma if array still looping
	mDisplayString [EBP + 20]
	ADD ESI, 4
	JMP _writeArrayValues

_finishWritingValues:
	Call Crlf

	; Display sum
	mDisplayString [EBP + 36]
	PUSH [EBP + 28]
	Call WriteVal
	Call Crlf

	; Display average
	mDisplayString [EBP + 32]
	PUSH [EBP + 24]
	Call WriteVal
	Call Crlf
	Call Crlf

	; reset stack frame
	POP EAX
	POP EDX
	POP ESI
	POP ECX
	POP EBP
	RET 32
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
	
	MOV EAX, [EBP + 8]		; SDWORD by value
	XOR EDX, EDX
	MOV EDI, EBP			; Set EDI to local reversedString Array
	SUB EDI, 60				
	XOR ECX, ECX

_checkNegativity:
	; If value is negative, convert back to positive for printing purposes 
	CMP EAX, 0
	JG _intToStringLoop
	NEG EAX

_intToStringLoop:
	; clear direction flag to increment
	CLD

	; ECX will serve as the count of strings
	INC ECX

	; Divide value by 10, remainder is last number of integer
	XOR EDX, EDX
	MOV EBX, 10
	DIV EBX

	; convert to ascii
	ADD EDX, 48
	MOV EBX, EAX

	; Store remainder in AL and write to Array
	MOV AL, DL 
	STOSB

	; If quotient is 0, the remainder was the only digit. Check for negativity
	MOV EAX, EBX
	CMP EBX, 0
	JE _addNegativeSign

	; Else check if quotient is less than 10. If less than 10, quotient is the final digit.
	CMP EBX, 10
	JL _convertFinalDigit
	JMP _intToStringLoop 

_convertFinalDigit:
	; Increment digit counter
	INC ECX

	; Convert quotient to ascii and store in array
	MOV AL, BL
	ADD AL, 48
	STOSB

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
	; Set ESI equal to local "reversedString" array
	MOV ESI, EBP 
	SUB ESI, 60

	; Add the string length to the address of ESI
	ADD ESI, ECX	; ECX is string length

	; Decrement by one to get start of reversed array
	DEC ESI

	; Set EDI equal to stringOutput LOCAL array
	MOV EDI, EBP 
	SUB EDI, 30

_revLoop:
    STD			; decrement
    LODSB		; load reversed string from esi (backwards string)
    CLD			; increment 
    STOSB		; store in edi (string in correct order)
	LOOP   _revLoop

	; Null terminate the string
	mov byte ptr[edi],0 

_displayString:
	; print string value
	MOV EAX, EBP
	SUB EAX, 30
	mDisplayString EAX
	POPAD
	RET 4

WriteVal ENDP

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
