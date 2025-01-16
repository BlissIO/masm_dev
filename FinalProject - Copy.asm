; Program template
; Program Description: 2d platformer inspired by celest pico-8
; Author:Rayane EL YASTI
; Creation Date: 11/9/2024
; Revisions:00

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
Include Irvine32.inc
Include Macros.inc

.data
    top BYTE      "#####################################################", 0
    sides BYTE    "#                   #                               #", 0
    ground BYTE   "#####################################################", 0
    gg BYTE   "################################", 0
    controls BYTE "Press X to exit the game. Use WASD to move the player!",0
    playerX BYTE 30
    playerY BYTE 15
    sideY BYTE 1
    inputChar BYTE ?

    line BYTE 1

.code
; Irvine32 Library Function Reference and Usage Prototype

; Console Input Functions
ReadChar PROTO       ; Read a single character from console
    ; Example: call ReadChar   ; AL will contain the character

ReadString PROTO     ; Read a string from console into a buffer
    ; Example: 
    ; mov edx, OFFSET myBuffer
    ; mov ecx, SIZEOF myBuffer
    ; call ReadString

ReadInt PROTO        ; Read a signed integer from console
    ; Example: call ReadInt   ; EAX will contain the integer

ReadDec PROTO        ; Read an unsigned decimal integer
    ; Example: call ReadDec   ; EAX will contain the unsigned integer

ReadHex PROTO        ; Read a hexadecimal integer
    ; Example: call ReadHex   ; EAX will contain the hex value

ReadKey PROTO        ; Check for keyboard input without waiting
    ; Example: call ReadKey   ; ZF=0 if key pressed, AL contains key

; Console Output Functions
WriteChar PROTO      ; Write a single character to console
    ; Example: mov al, 'A'
    ; call WriteChar

WriteString PROTO    ; Write a null-terminated string to console
    ; Example: 
    ; mov edx, OFFSET myString
    ; call WriteString

WriteDec PROTO       ; Write unsigned decimal integer
    ; Example: mov eax, 42
    ; call WriteDec

WriteInt PROTO       ; Write signed integer
    ; Example: mov eax, -17
    ; call WriteInt

WriteHex PROTO       ; Write hexadecimal value
    ; Example: mov eax, 0FFh
    ; call WriteHex

WriteBin PROTO       ; Write binary representation
    ; Example: mov eax, 1010b
    ; call WriteBin

; Screen Manipulation
Clrscr PROTO         ; Clear entire console screen
    ; Example: call Clrscr

Gotoxy PROTO         ; Move cursor to specific screen coordinates
    ; Example: 
    ; mov dh, 10   ; row
    ; mov dl, 20   ; column
    ; call Gotoxy

GetMaxXY PROTO       ; Get console window dimensions
    ; Example: 
    ; call GetMaxXY
    ; Returns: AX = columns, DX = rows

SetTextColor PROTO   ; Change console text color
    ; Example: 
    ; mov eax, white + (blue * 16)
    ; call SetTextColor

; Delay and Timing
Delay PROTO          ; Pause execution for specified milliseconds
    ; Example: 
    ; mov eax, 1000  ; 1 second
    ; call Delay

GetMseconds PROTO    ; Get milliseconds past midnight
    ; Example: call GetMseconds
    ; Returns milliseconds in EAX

Randomize PROTO      ; Seed random number generator
    ; Example: call Randomize

RandomRange PROTO    ; Generate random number in range
    ; Example: 
    ; mov eax, 100  ; range 0-99
    ; call RandomRange

; File Operations
CreateOutputFile PROTO  ; Create a file for writing
    ; Example: 
    ; mov edx, OFFSET filename
    ; call CreateOutputFile
    ; Returns file handle in EAX

OpenInputFile PROTO     ; Open existing file for reading
    ; Example: 
    ; mov edx, OFFSET filename
    ; call OpenInputFile
    ; Returns file handle in EAX

ReadFromFile PROTO      ; Read from an open file
    ; Example: 
    ; mov eax, fileHandle
    ; mov edx, OFFSET buffer
    ; mov ecx, bufferSize
    ; call ReadFromFile

WriteToFile PROTO       ; Write to an open file
    ; Example: 
    ; mov eax, fileHandle
    ; mov edx, OFFSET buffer
    ; mov ecx, bufferSize
    ; call WriteToFile

CloseFile PROTO         ; Close an open file handle
    ; Example: 
    ; mov eax, fileHandle
    ; call CloseFile

; String Manipulation
Str_length PROTO        ; Get length of null-terminated string
    ; Example: 
    ; mov edx, OFFSET myString
    ; call Str_length
    ; Returns length in EAX

Str_copy PROTO          ; Copy one string to another
    ; Example: 
    ; mov esi, OFFSET sourceStr
    ; mov edi, OFFSET destStr
    ; call Str_copy

Str_compare PROTO       ; Compare two strings
    ; Example: 
    ; mov esi, OFFSET str1
    ; mov edi, OFFSET str2
    ; call Str_compare
    ; Sets Zero and Carry flags like CMP

; Miscellaneous Utilities
WaitMsg PROTO           ; Display wait message, wait for Enter
    ; Example: call WaitMsg

MsgBox PROTO            ; Display a message box
    ; Example: 
    ; mov edx, OFFSET message
    ; call MsgBox

GetDateTime PROTO       ; Get system date and time
    ; Example: 
    ; mov esi, OFFSET timeBuffer
    ; call GetDateTime

; Special Debugging Functions
DumpRegs PROTO          ; Display contents of all registers
    ; Example: call DumpRegs

DumpMem PROTO           ; Display memory contents
    ; Example: 
    ; mov esi, OFFSET memoryStart
    ; mov ecx, itemCount
    ; mov ebx, itemSize
    ; call DumpMem

; Note: Always include Irvine32.inc and link with Irvine32.lib


END main