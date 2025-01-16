.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
Include Irvine32.inc
Include Macros.inc

.data
    ; Room descriptions
    currentRoom BYTE 0
    hasKey      BYTE 0
    hasLantern  BYTE 0
    gameWon     BYTE 0
    
    ; UI Elements
    titleArt    BYTE "=================================",0dh,0ah
                BYTE "       ESCAPE THE DUNGEON        ",0dh,0ah
                BYTE "=================================",0
                
    prompt      BYTE "> ",0
    invalidCmd  BYTE "I don't understand that command.",0
    
    ; Room Descriptions
    room0Desc   BYTE "You are in a dark cell. Moonlight filters through a tiny window.",0dh,0ah
                BYTE "There's a door to the EAST. The floor looks interesting.",0
    room1Desc   BYTE "You're in a dimly lit corridor. There's a strange smell.",0dh,0ah
                BYTE "Paths lead WEST and NORTH. A LANTERN hangs on the wall.",0
    room2Desc   BYTE "This appears to be a guard room. Dusty chairs surround a table.",0dh,0ah
                BYTE "Exits are SOUTH and EAST. Something glints under the table.",0
    room3Desc   BYTE "You've found the exit chamber! A heavy door dominates the wall.",0dh,0ah
                BYTE "The only path is WEST. The door needs a KEY.",0
                
    ; Item Descriptions
    lookFloor0  BYTE "You notice something metallic partially buried in the dirt.",0
    lookTable2  BYTE "You spot a rusty key under the table!",0
    noLantern   BYTE "It's too dark to see anything clearly in here.",0
    hasLanternMsg BYTE "Your lantern illuminates the room.",0
    
    ; Action Messages
    doorLocked  BYTE "The door is locked. You need a key!",0
    gotKey      BYTE "You found a key!",0
    gotLantern  BYTE "You take the lantern from the wall.",0
    alreadyHave BYTE "You already have that.",0
    escaped     BYTE "You unlock the door and escape! YOU WIN!",0
    
    ; Input buffer
    buffer      BYTE 50 DUP(0)
    command     BYTE 20 DUP(0)
    param       BYTE 20 DUP(0)

.code
main PROC
    ; Set up console
    call Initialize
    
GameLoop:
    ; Main game loop
    call DisplayRoom
    call GetCommand
    call ProcessCommand
    
    ; Check if game is won
    cmp gameWon, 1
    je GameOver
    
    jmp GameLoop
    
GameOver:
    call WaitMsg
    invoke ExitProcess,0
main ENDP

;------------------------------------------------
Initialize PROC
;
; Sets up the game
;------------------------------------------------
    ; Set text color
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Clear screen and display title
    call Clrscr
    mov edx, OFFSET titleArt
    call WriteString
    call Crlf
    call Crlf
    
    ; Initialize game state
    mov currentRoom, 0
    mov hasKey, 0
    mov hasLantern, 0
    mov gameWon, 0
    
    ret
Initialize ENDP

;------------------------------------------------
DisplayRoom PROC
;
; Shows current room description
;------------------------------------------------
    pushad
    call Crlf
    
    ; Select room description based on currentRoom
    movzx eax, currentRoom
    .IF eax == 0
        mov edx, OFFSET room0Desc
    .ELSEIF eax == 1
        mov edx, OFFSET room1Desc
    .ELSEIF eax == 2
        .IF hasLantern == 0
            mov edx, OFFSET noLantern
            jmp DisplayText
        .ENDIF
        mov edx, OFFSET room2Desc
    .ELSE
        mov edx, OFFSET room3Desc
    .ENDIF
    
DisplayText:
    call WriteString
    call Crlf
    
    ; Display inventory status
    call Crlf
    call DisplayInventory
    call Crlf
    
    popad
    ret
DisplayRoom ENDP

;------------------------------------------------
DisplayInventory PROC
;
; Shows player's inventory
;------------------------------------------------
    pushad
    
    mWrite "Inventory: "
    
    ; Check and display items
    mov bl, 0    ; Flag for if anything is in inventory
    
    cmp hasKey, 1
    jne CheckLantern
    mWrite "Key "
    mov bl, 1
    
CheckLantern:
    cmp hasLantern, 1
    jne EndInventory
    mWrite "Lantern "
    mov bl, 1
    
EndInventory:
    cmp bl, 0
    jne InventoryDone
    mWrite "Empty"
    
InventoryDone:
    call Crlf
    
    popad
    ret
DisplayInventory ENDP

;------------------------------------------------
GetCommand PROC
;
; Gets and parses user input
;------------------------------------------------
    push edx
    
    ; Display prompt
    mov edx, OFFSET prompt
    call WriteString
    
    ; Get input
    mov edx, OFFSET buffer
    mov ecx, SIZEOF buffer
    call ReadString
    
    ; Convert to uppercase for easier comparison
    push ecx
    mov ecx, LENGTHOF buffer
    mov esi, OFFSET buffer
ToUpper:
    mov al, [esi]
    cmp al, 'a'
    jl NextChar
    cmp al, 'z'
    jg NextChar
    sub al, 32
    mov [esi], al
NextChar:
    inc esi
    loop ToUpper
    pop ecx
    
    pop edx
    ret
GetCommand ENDP

;------------------------------------------------
ProcessCommand PROC
;
; Processes the player's command
;------------------------------------------------
    LOCAL commandType:BYTE
    pushad
    
    ; Parse first word of command
    mov esi, OFFSET buffer
    mov edi, OFFSET command
ParseCmd:
    mov al, [esi]
    cmp al, ' '
    je EndParseCmd
    cmp al, 0
    je EndParseCmd
    mov [edi], al
    inc esi
    inc edi
    jmp ParseCmd
EndParseCmd:
    mov BYTE PTR [edi], 0
    
    ; Check command type
    mov edx, OFFSET command
    
    ; Movement commands
    .IF BYTE PTR [edx] == 'N'
        call MoveNorth
    .ELSEIF BYTE PTR [edx] == 'S'
        call MoveSouth
    .ELSEIF BYTE PTR [edx] == 'E'
        call MoveEast
    .ELSEIF BYTE PTR [edx] == 'W'
        call MoveWest
    .ELSEIF BYTE PTR [edx] == 'L'
        call LookAround
    .ELSEIF BYTE PTR [edx] == 'T'
        call TakeItem
    .ELSE
        mov edx, OFFSET invalidCmd
        call WriteString
        call Crlf
    .ENDIF
    
    popad
    ret
ProcessCommand ENDP

;------------------------------------------------
MoveNorth PROC
;
; Handles northward movement
;------------------------------------------------
    .IF currentRoom == 1
        mov currentRoom, 2
    .ELSE
        mWrite "You can't go that way."
        call Crlf
    .ENDIF
    ret
MoveNorth ENDP

;------------------------------------------------
MoveSouth PROC
;
; Handles southward movement
;------------------------------------------------
    .IF currentRoom == 2
        mov currentRoom, 1
    .ELSE
        mWrite "You can't go that way."
        call Crlf
    .ENDIF
    ret
MoveSouth ENDP

;------------------------------------------------
MoveEast PROC
;
; Handles eastward movement
;------------------------------------------------
    movzx eax, currentRoom
    .IF eax == 0
        mov currentRoom, 1
    .ELSEIF eax == 2
        .IF hasKey == 1
            mov gameWon, 1
            mov edx, OFFSET escaped
            call WriteString
            call Crlf
        .ELSE
            mov edx, OFFSET doorLocked
            call WriteString
            call Crlf
        .ENDIF
    .ELSE
        mWrite "You can't go that way."
        call Crlf
    .ENDIF
    ret
MoveEast ENDP

;------------------------------------------------
MoveWest PROC
;
; Handles westward movement
;------------------------------------------------
    movzx eax, currentRoom
    .IF eax == 1
        mov currentRoom, 0
    .ELSE
        mWrite "You can't go that way."
        call Crlf
    .ENDIF
    ret
MoveWest ENDP

;------------------------------------------------
LookAround PROC
;
; Handles detailed look command
;------------------------------------------------
    movzx eax, currentRoom
    .IF eax == 0
        mov edx, OFFSET lookFloor0
    .ELSEIF eax == 2
        .IF hasLantern == 1
            mov edx, OFFSET lookTable2
        .ELSE
            mov edx, OFFSET noLantern
        .ENDIF
    .ELSE
        mov edx, OFFSET room1Desc
    .ENDIF
    
    call WriteString
    call Crlf
    ret
LookAround ENDP

;------------------------------------------------
TakeItem PROC
;
; Handles item pickup
;------------------------------------------------
    movzx eax, currentRoom
    .IF eax == 0
        .IF hasKey == 0
            mov hasKey, 1
            mov edx, OFFSET gotKey
            call WriteString
            call Crlf
        .ELSE
            mov edx, OFFSET alreadyHave
            call WriteString
            call Crlf
        .ENDIF
    .ELSEIF eax == 1
        .IF hasLantern == 0
            mov hasLantern, 1
            mov edx, OFFSET gotLantern
            call WriteString
            call Crlf
        .ELSE
            mov edx, OFFSET alreadyHave
            call WriteString
            call Crlf
        .ENDIF
    .ENDIF
    ret
TakeItem ENDP

END main