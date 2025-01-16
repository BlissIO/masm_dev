; AddTwo.asm - adds two 32-bit integers.
; Chapter 3 example
include Irvine32.inc
include Macros.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	; Game character and item representation
	playerChar BYTE 'A'
	intemChar BYTE '*'
	emptyChar BYTE ' '
	score DWORD 0
	speed DWORD 100

	; Screen dimensions
	screenWidth DWORD 20
	screenheight DWORD 15

	;Player Psition
	playerX DWORD 10
	playerY DWORD 14

	;Falling item pos
	itemX DWORD 10
	itemY DWORD 0

.code
main proc
	call Clrscr
	mov playerX, screenWidth /2  ; Centering the player

gameLoop:
	call 

	invoke ExitProcess,0
main endp
end main