.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword
Include Irvine32.inc
Include Macros.inc
includelib Winmm.lib
PlaySoundA PROTO,
        pszSound:PTR BYTE, 
        hmod:DWORD, 
        fdwSound:DWORD
.data
    file BYTE "CIGARETTE.wav",0

    ; Menu Strings
    titleArt1  BYTE "   ____     _     ____ ____ ___    ____   ____  ___ ", 0
    titleArt2  BYTE "  / __/_ __/ |   / __// __// _ \  / __/  / __/ / _ \", 0
    titleArt3  BYTE " _\ \ / // /|  |/ _/ / _/ / , _/ / _/   / _/  / , _/", 0
    titleArt4  BYTE "/___/ \_, //___/___//___//_/|_| /___/  /___/ /_/|_|", 0
    titleArt5  BYTE "     /___/                                         ", 0
    
    menuOption1 BYTE "1. Start Game", 0
    menuOption2 BYTE "2. Instructions", 0
    menuOption3 BYTE "3. Exit", 0
    pressKey BYTE "Press the corresponding number to select an option", 0
    
    instructionsTitle BYTE "How to Play:", 0
    instruction1 BYTE "- Use X and C to move up and down", 0
    instruction2 BYTE "- Press E to select an action", 0
    instruction3 BYTE "- Attack to deal damage to the enemy", 0
    instruction4 BYTE "- Guard to reduce incoming damage", 0
    instruction5 BYTE "- Heal to restore health (3 charges)", 0
    instruction6 BYTE "Press SPACE to return to menu", 0
    
    gameOverText BYTE "Game Over!", 0
    victoryText BYTE "Victory!", 0
    playAgainText BYTE "Press SPACE to play again or ESC to exit", 0
    
    exitText BYTE "Thanks for playing! Press any key to exit.", 0

    top BYTE      "#####################################################", 0
    sides BYTE    "#                   #                               #", 0
    ground BYTE   "#####################################################", 0
    gg BYTE       "################################", 0
                   
    option1 BYTE "Attack", 0
    option2 BYTE "Guard",0
    option3 BYTE "Heal",0
    controls BYTE "Press X/C to move, E to select, ESC to exit",0
    playerX BYTE 6
    playerY BYTE 17
    sideY BYTE 1
    inputChar BYTE ?

    ; Game State
    gameState BYTE 0  ; 0 = Menu, 1 = Game, 2 = Instructions, 3 = Game Over

    ; Combat Stats
    playerHealth BYTE 100
    playerDamage BYTE 20
    playerIsBlocking BYTE 0    
    playerCanHeal BYTE 3      
    healAmount BYTE 30        

    enemyHealth BYTE 120
    enemyDamage BYTE 15
    enemyIsAttacking BYTE 0   

    ; Status Messages
    healthStr BYTE "Player Health: ", 0
    enemyStr BYTE "Enemy Health: ", 0
    blockStr BYTE "BLOCKED!", 0
    missStr BYTE "MISSED!", 0
    healChargesStr BYTE "Heals Left: ", 0

    line BYTE 1
    selectedOption BYTE 1     
    actionTaken BYTE 0        

.code
main PROC
    call ClrScr
    INVOKE PlaySoundA, OFFSET file, NULL, 20001H
    mainLoop:
        mov al, gameState
        cmp al, 0
        je showMenu
        cmp al, 1
        je startGame
        cmp al, 2
        je showInstructions
        cmp al, 3
        je showGameOver
        jmp exitGame

    showMenu:
        call DrawMenu
        call ReadChar
        
        cmp al, '1'
        je initializeGame
        cmp al, '2'
        je showInstructionsState
        cmp al, '3'
        je exitGame
        jmp mainLoop

    showInstructionsState:
        mov gameState, 2
        call ClrScr
        jmp mainLoop

    initializeGame:
        mov gameState, 1
        mov playerHealth, 100
        mov enemyHealth, 120
        mov playerCanHeal, 3
        call ClrScr
        jmp mainLoop

    startGame:
        call GameLoop
        jmp mainLoop

    showGameOver:
        call DrawGameOver
        call ReadChar
        cmp al, 20h  ; Space
        je initializeGame
        cmp al, 1Bh  ; Escape
        je exitGame
        jmp mainLoop

    exitGame:
        call ClrScr
        mov dl, 25
        mov dh, 12
        call Gotoxy
        mov edx, OFFSET exitText
        call WriteString
        call ReadChar
        invoke ExitProcess, 0
main ENDP

DrawMenu PROC
    mov dl, 15
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET titleArt1
    call WriteString
    
    mov dl, 15
    mov dh, 6
    call Gotoxy
    mov edx, OFFSET titleArt2
    call WriteString
    
    mov dl, 15
    mov dh, 7
    call Gotoxy
    mov edx, OFFSET titleArt3
    call WriteString
    
    mov dl, 15
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET titleArt4
    call WriteString
    
    mov dl, 15
    mov dh, 9
    call Gotoxy
    mov edx, OFFSET titleArt5
    call WriteString

    mov dl, 25
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET menuOption1
    call WriteString

    mov dl, 25
    mov dh, 17
    call Gotoxy
    mov edx, OFFSET menuOption2
    call WriteString

    mov dl, 25
    mov dh, 19
    call Gotoxy
    mov edx, OFFSET menuOption3
    call WriteString

    mov dl, 15
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET pressKey
    call WriteString

    ret
DrawMenu ENDP

ShowInstructions PROC
    ; Clear screen first
    call ClrScr
    
    ; Display instructions
    mov dl, 25
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET instructionsTitle
    call WriteString

    mov dl, 20
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET instruction1
    call WriteString

    mov dl, 20
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET instruction2
    call WriteString

    mov dl, 20
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET instruction3
    call WriteString

    mov dl, 20
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET instruction4
    call WriteString

    mov dl, 20
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET instruction5
    call WriteString

    mov dl, 20
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET instruction6
    call WriteString

instructionLoop:
    call ReadChar
    cmp al, 20h  ; Check for space key
    jne instructionLoop    ; If not space, keep waiting
    
    ; If space was pressed, return to menu
    mov gameState, 0      ; Set state back to menu
    call ClrScr           ; Clear the screen
    ret                   ; Return to main
ShowInstructions ENDP

DrawGameOver PROC
    call ClrScr
    mov dl, 25
    mov dh, 10
    call Gotoxy
    
    cmp playerHealth, 0
    jle showLoss
    
    mov edx, OFFSET victoryText
    jmp continueGameOver
    
showLoss:
    mov edx, OFFSET gameOverText
    
continueGameOver:
    call WriteString
    
    mov dl, 15
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET playAgainText
    call WriteString
    ret
DrawGameOver ENDP

GameLoop PROC
    call DrawUI
    call DrawPlayer

gameLoopStart:
    cmp playerHealth, 0
    jle gameOver
    cmp enemyHealth, 0
    jle gameOver

    call UpdateHealthDisplay

    call ReadChar
    mov inputChar, al

    cmp inputChar, 1Bh  ; ESC key
    je exitToMenu

    cmp inputChar, "x"
    je checkMoveUp     

    cmp inputChar, "c"
    je checkMoveDown   

    cmp inputChar, "e"
    je selectOption

    jmp gameLoopStart

exitToMenu:
    mov gameState, 0
    call ClrScr
    ret

gameOver:
    mov gameState, 3
    ret

checkMoveUp:              
    call UpdatePlayer
    cmp playerY, 15
    je wrapToBottom
    sub playerY, 2
    dec selectedOption
    call DrawPlayer      
    jmp gameLoopStart       

checkMoveDown:           
    call UpdatePlayer
    cmp playerY, 19
    je wrapToTop
    add playerY, 2
    inc selectedOption
    call DrawPlayer      
    jmp gameLoopStart        

wrapToBottom:
    mov playerY, 19
    mov selectedOption, 2
    call DrawPlayer
    jmp gameLoopStart

wrapToTop:
    mov playerY, 15      
    mov selectedOption, 0
    call DrawPlayer
    jmp gameLoopStart

selectOption:
    mov actionTaken, 1    
    cmp selectedOption, 0
    je performAttack

    cmp selectedOption, 1
    je performGuard

    cmp selectedOption, 2
    je performHeal

    jmp gameLoopStart

performAttack:
    mov dl, 7
    mov dh, 15
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET option1
    call WriteString

    movzx eax, playerDamage
    call RandomRange      
    add al, 15            
    sub enemyHealth, al   

    mov dl, 22
    mov dh, 3
    call Gotoxy
    mWrite "Player attacks for "
    movzx eax, al
    call WriteDec
    mWrite " damage!"

    mov eax, 1000
    call Delay
    call ResetOptionColors
    
    call EnemyTurn
    
    jmp gameLoopStart

performGuard:
    mov dl, 7
    mov dh, 17
    call Gotoxy
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    mov edx, OFFSET option2
    call WriteString

    mov playerIsBlocking, 1
    
    mov dl, 22
    mov dh, 4
    call Gotoxy
    mWrite "Player is guarding!"

    mov eax, 1000
    call Delay
    call ResetOptionColors
    
    call EnemyTurn
    
    jmp gameLoopStart

performHeal:
    cmp playerCanHeal, 0
    je healFailed

    mov dl, 22
    mov dh, 5
    call Gotoxy
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov edx, OFFSET option3
    call WriteString

    dec playerCanHeal
    movzx eax, healAmount
    add playerHealth, al
    cmp playerHealth, 100
    jle skipHealthCap
    mov playerHealth, 100
skipHealthCap:
    
    mov dl, 30
    mov dh, 19
    call Gotoxy
    mWrite "Healed for "
    movzx eax, healAmount
    call WriteDec
    mWrite " HP!"

    mov eax, 1000
    call Delay
    call ResetOptionColors
    
    call EnemyTurn
    
    jmp gameLoopStart

healFailed:
    mov dl, 30
    mov dh, 19
    call Gotoxy
    mWrite "No healing charges left!"
    mov eax, 1000
    call Delay
    jmp gameLoopStart
GameLoop ENDP

EnemyTurn PROC
    mov playerIsBlocking, 0
    
    mov eax, 4
    call RandomRange
    cmp eax, 3
    je enemyMiss
    
    movzx eax, enemyDamage
    call RandomRange
    add al, 10
    
    cmp playerIsBlocking, 1
    je enemyBlocked
    
    sub playerHealth, al
    
    mov dl, 22
    mov dh, 14
    call Gotoxy
    mWrite "Enemy attacks for "
    movzx eax, al
    call WriteDec
    mWrite " damage!"
    jmp enemyTurnEnd
    
enemyBlocked:
    mov dl, 22
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET blockStr
    call WriteString
    jmp enemyTurnEnd
    
enemyMiss:
    mov dl, 22
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET missStr
    call WriteString
    
enemyTurnEnd:
    mov eax, 1000
    call Delay
    ret
EnemyTurn ENDP

UpdateHealthDisplay PROC
    mov dl, 23
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET healthStr
    call WriteString
    movzx eax, playerHealth
    call WriteDec
    
    mov dl, 23
    mov dh, 23
    call Gotoxy
    mov edx, OFFSET enemyStr
    call WriteString
    movzx eax, enemyHealth
    call WriteDec
    
    mov dl, 23
    mov dh, 24
    call Gotoxy
    mov edx, OFFSET healChargesStr
    call WriteString
    movzx eax, playerCanHeal
    call WriteDec
    
    ret
UpdateHealthDisplay ENDP

ResetOptionColors PROC
    pushad
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dl, 7
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET option1
    call WriteString
    
    mov dl, 7
    mov dh, 17
    call Gotoxy
    mov edx, OFFSET option2
    call WriteString
    
    mov dl, 7
    mov dh, 19
    call Gotoxy
    mov edx, OFFSET option3
    call WriteString
    
    popad
    ret
ResetOptionColors ENDP

DrawUI PROC
    
    
    mov dl,0
    mov dh, 28
    call Gotoxy
    mov edx, OFFSET ground
    call WriteString
    ;Draw top
    mov dl,0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET top
    call WriteString
    
    ;Loop sides
    mov ecx, 27
    mov line, 1
        sideLoop:
            mov dl, 0
            mov dh, line
            call Gotoxy
            mov edx, OFFSET sides
            call WriteString
            inc line
        loop sideLoop

    mov dl,0
    mov dh, 29
    call Gotoxy
    mov edx, OFFSET controls
    call WriteString

    mov dl,21
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET gg
    call WriteString

    mov dl,7
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET option1
    call WriteString

    mov dl,7
    mov dh, 17
    call Gotoxy
    mov edx, OFFSET option2
    call WriteString

    mov dl,7
    mov dh, 19
    call Gotoxy
    mov edx, OFFSET option3
    call WriteString
    ret
DrawUI ENDP

UpdatePlayer PROC
    mov dl,PlayerX
    mov dh,PlayerY
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov al," "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawPlayer PROC
    mov dl,PlayerX
    mov dh,PlayerY
    call Gotoxy
    mov al,"X"
    call WriteChar
    ret
DrawPlayer ENDP

END main
