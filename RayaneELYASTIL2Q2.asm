; Program template
; Program Description: This program calculates the area and circumference of a circle
; Author:Rayane EL YASTI
; Creation Date: 11/8/2024
; Revisions:00

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	sum DWORD 0

.code
	; Defining my two constants rad for the radius of the circle and pi as 22/7
	rad equ <5>
	pi equ <22/7>
main proc
	; Calculating the area of the circle (Area = pi * r^2)
	mov eax, rad ; Moving the radius into eax
	imul eax, rad ; Multiplying eax by rad
	imul eax, pi ; Multiplying eax by pi to get the area in eax
	
	; Calculating the circumference of the circle (Circumference = 2 * pi * r)
	mov ebx, rad ; Moving the radius into ebx
	imul ebx, 2 ; Multiplying ebx by 2
	imul ebx, pi ; Multiplying ebx by pi to get the circumference in ebx

	COMMENT !
		MASM works with integer operations in eax, ebx etc 
		In assembly, floating-point numbers like the actual value of pi, 3.14159...
		are more complex to work with because they require additional handling 
		by specialized floating-point registers or instructions
	!

	invoke ExitProcess,0
main endp
end main