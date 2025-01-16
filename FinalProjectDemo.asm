.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
Include Irvine32.inc
Include Macros.inc

; Macro Example
demoMacro MACRO
	; Local variable example
	LOCAL charX
	charX BYTE 'X'

	; SetTextColor Example
	; Helpful Refernce: https://csc.csudh.edu/mmccullough/asm/help/source/irvinelib/settextcolor.htm
	mov eax,yellow+(blue*16)
	call SetTextColor
	mov al,charX
	call WriteChar
	call crlf
	call crlf
	mov eax,lightCyan
	call SetTextColor
	mov al,charX
	call WriteChar
ENDM

.data
	one DWORD 1

.code
main proc
	; This calls demoMacro
	demoMacro
	call crlf
	call crlf
	mWrite "Put the string you want to write in here."

	; High-Level Language (If Statement Example)
	mov al,0
	mov ah,2
	.IF(al == 0 && ah == 1)
		mWrite "AL is 0 and AH is 1"
	.ELSEIF(al == 0)
		mWrite "AL is 0 and AH is something other than 1"
	.ELSE
		mWrite "I don't know what AL and AH are."
	.ENDIF

	mov eax,lightCyan
	call SetTextColor

	; High-Level Language (While Loop Example)
	; Use ECX to iterate over something.
	mov ecx, 0
	.WHILE ecx <= 20
		mov eax,ecx
		call WriteDec
		call crlf
		inc ecx
	.ENDW

	; High-Level Language (Infinite Loop Example -- This one is commented out for obvious reasons.)
	;mov eax,5
	;.WHILE eax == 5
	;	mWrite "This is an infinite loop!"
	;	call crlf
	;.ENDW

	; ReadKey Example
	mov ebx,1
	.WHILE one==1
		call ReadKey

		.IF(eax != 1)
			call WriteDec
			call crlf
		.ENDIF
	.ENDW
	call ReadKey

	invoke ExitProcess,0
main endp
end main