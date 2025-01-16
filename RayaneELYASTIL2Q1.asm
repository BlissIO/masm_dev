; Program template
; Program Description: This program calculates the byte length of arrays containing days of the week.
; Author:Rayane EL YASTI
; Creation Date: 11/7/2024
; Revisions:00
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
	sum DWORD 0

.code
;defining the symbolic constants with null termination
	m equ <"Monday",0>
	t equ <"Tuesday",0>
	w equ <"Wednesday",0>
	r equ <"Thursday",0>
	f equ <"Friday",0>
	s equ <"Saturday",0>
	su equ <"Sunday",0>
	week BYTE m,t,w,r,f,s,su ; Setting the array holding all days as strings with null terminators
	arrayLength = ($ - week) ; Calculate the total byte length of the previous array
	COMMENT !
	It is counting all the bytes in the array so every letter and null terminators
	which resultes in a bigger number than how many days in the week there are.
	To fix this we will set every symbolic constant to 3 letters and devide
	($ - week) by 4 ta calculate every 4 bytes instead of 1
	!

	;defining the symbolic constants with null termination
	m2 equ <"Mon",0>
	t2 equ <"Tue",0>
	w2 equ <"Wed",0>
	r2 equ <"Thu",0>
	f2 equ <"Fri",0>
	s2 equ <"Sat",0>
	su2 equ <"Sun",0>
	week2 BYTE m2,t2,w2,r2,f2,s2,su2 ; Setting the array holding all days as strings with null terminators
	arrayLength2 = ($ - week2) / 4 ; Calculate the total byte length of the previous array
main PROC
	; Testing the numbers by moving then to eax
	mov eax, arrayLength
	mov eax, arrayLength2
	
INVOKE ExitProcess,0
main ENDP

END main