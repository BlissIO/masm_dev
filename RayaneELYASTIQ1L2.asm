; AddTwo.asm - adds two 32-bit integers.
; Chapter 3 example
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data

    monday BYTE "Monday",0
    tuesday BYTE "Tuesday",0
    wednesday BYTE "Wednesday",0
    thursday BYTE "Thursday",0
    friday BYTE "Friday",0
    saturday BYTE "Saturday",0
    sunday BYTE "Sunday",0
    dayArray DWORD   monday,  tuesday,  wednesday,  thursday,  friday,  saturday, sunday
    numDays = ($ -  dayArray) / 4

    ; BLOCK COMMENT:
    ; The above approach to calculate the size of the array will not work
    ; because the $ symbol represents the current location counter value,
    ; which only holds the address of the next available memory location.
    ; It does not take into account the actual size of the string data.
    ; Therefore, the calculation ($ - dayArray) / 4 will not give the correct
    ; size of the array.

    ; Redefining day names and recalculating array size:
    monday2 BYTE "Monday",0
    tuesday2 BYTE "Tuesday",0
    wednesday2 BYTE "Wednesday",0
    thursday2 BYTE "Thursday",0
    friday2 BYTE "Friday",0
    saturday2 BYTE "Saturday",0
    sunday2 BYTE "Sunday",0
    dayArray2 DWORD   monday2,  tuesday2,  wednesday2,  thursday2,  friday2,  saturday2, sunday2
    numDays2 = ($ -  dayArray2) / (SIZEOF dayArray2 / 7)

.code
main proc
    mov eax, numDays
    mov ebx, numDays2
    invoke ExitProcess,0
main endp
end main