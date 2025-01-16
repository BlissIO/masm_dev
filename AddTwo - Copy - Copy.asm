; ===============================================================================================
; Cigarette Game - Advanced Assembly Implementation
; Features:
;   - Animated menu borders
;   - Dynamic audio control system
;   - Turn-based combat mechanics
;   - State-based game flow management
; ===============================================================================================

; Forward declarations of all procedures
UpdateBorderAnimation PROTO C
DrawMenu PROTO C
ShowInstructions PROTO C
GameLoop PROTO C
ProcessMenuState PROTO C
DrawUI PROTO C
UpdateHealthDisplay PROTO C
DrawPlayer PROTO C
UpdatePlayer PROTO C
InsideLogo PROTO C
ToggleMusicMute PROTO C
DrawGameOver PROTO C
ResetOptionColors PROTO C
EnemyTurn PROTO C
InitializeBorderChars PROTO C

; ==== Processor and Memory Configuration ====
.386                    ; Target 32-bit x86 processor
.model flat, stdcall    ; Memory model and calling convention
.stack 4096             ; Stack space allocation

; ==== External Windows API Functions ====
ExitProcess PROTO, dwExitCode:dword
PlaySoundA PROTO,
    pszSound:PTR BYTE,     ; Sound file path or memory location
    hmod:DWORD,            ; Module instance handle
    fdwSound:DWORD         ; Playback control flags

; ==== Audio System Constants ====
SND_ASYNC       = 0001h        ; Non-blocking audio playback
SND_LOOP        = 0008h        ; Continuous audio loop
SND_FILENAME    = 00020000h    ; Sound source is a file

; ==== Required Library Inclusions ====
Include Irvine32.inc            ; Core system functionality
Include Macros.inc              ; Macro definitions
includelib Winmm.lib            ; Windows multimedia support

; ==== Data Section ====
.data
    ; ---- Border Characters (Using Standard ASCII) ----
    BORDER_CHAR_H    db '-'    ; Horizontal border
    BORDER_CHAR_V    db '|'    ; Vertical border
    BORDER_CHAR_C    db '+'    ; Corner border

    ; ---- Audio System Configuration ----
    soundFile BYTE "CIGARETTE.wav", 0
    isMuted BYTE 0
    muteMessage BYTE "Press M to toggle music", 0
    mutedStatus BYTE "Music: MUTED", 0
    unmutedStatus BYTE "Music: PLAYING", 0

    ; ---- Logo Art ----
    logoArt1 BYTE "   ________", 0
    logoArt2 BYTE "  / __/ __/", 0  
    logoArt3 BYTE " _\ \_\ \  ", 0
    logoArt4 BYTE "/___/___/  ", 0

    ; ---- Game Title ASCII Art ----
    titleArt1 BYTE "   ______           __             ______      _ __      ", 0
    titleArt2 BYTE "  / __/ /  ___ ____/ /__ _    __  / __/ /_____(_) /_____ ", 0
    titleArt3 BYTE " _\ \/ _ \/ _ `/ _  / _ \ |/|/ / _\ \/ __/ __/ /  '_/ -_)", 0
    titleArt4 BYTE "/___/_//_/\_,_/\_,_/\___/__,__/ /___/\__/_/ /_/_/\_\\__/ ", 0
    titleArt5 BYTE "                                                         ", 0

    ; ---- Menu Options ----
    menuOption1 BYTE "1. Start Game", 0
    menuOption2 BYTE "2. Instructions", 0
    menuOption3 BYTE "3. Exit", 0
    pressKeyPrompt BYTE "Press the corresponding number to select an option", 0

    ; ---- Border Animation Variables ----
    borderX BYTE 0              ; Current X coordinate
    borderY BYTE 0              ; Current Y coordinate
    borderDirection BYTE 0      ; 0=right, 1=down, 2=left, 3=up
    borderChars BYTE 4 DUP(?)   ; Border character cycle array
    borderCharIndex BYTE 0      ; Current border character index
    lastBorderPos DWORD 100 DUP(0)  ; Position history buffer
    borderTrailLength BYTE 15   ; Trail effect length
    trailIndex BYTE 0           ; Current trail position

    ; ---- Menu Boundary Constants ----
    MENU_TOP = 4
    MENU_BOTTOM = 23
    MENU_LEFT = 14
    MENU_RIGHT = 65

    ; ---- Game Instructions Text ----
    instructionsTitle BYTE "How to Play:", 0
    instruction1 BYTE "- Use X and C to move up and down", 0
    instruction2 BYTE "- Press E to select an action", 0
    instruction3 BYTE "- Attack to deal damage to the enemy", 0
    instruction4 BYTE "- Guard to reduce incoming damage", 0
    instruction5 BYTE "- Heal to restore health (3 charges)", 0
    instruction6 BYTE "Press SPACE to return to menu", 0

    ; ---- End Game Messages ----
    gameOverText BYTE "Game Over!", 0
    victoryText BYTE "Victory!", 0
    playAgainText BYTE "Press SPACE to play again or ESC to exit", 0
    exitText BYTE "Thanks for playing! Press any key to exit.", 0

    ; ---- UI Border Elements ----
    top    BYTE "#####################################################", 0
    sides  BYTE "#                   #                               #", 0
    ground BYTE "#####################################################", 0
    gameGround BYTE "################################", 0

    ; ---- Combat Menu Options ----
    option1 BYTE "Attack", 0
    option2 BYTE "Guard", 0
    option3 BYTE "Heal", 0
    controlsText BYTE "Press X/C to move, E to select, ESC to exit", 0

    ; ---- Player and Game State Variables ----
    playerX BYTE 6
    playerY BYTE 17
    sideY BYTE 1
    inputChar BYTE ?
    gameState BYTE 0            ; 0=Menu, 1=Game, 2=Instructions, 3=GameOver

    ; ---- Combat Statistics ----
    playerHealth BYTE 100
    playerDamage BYTE 20
    playerIsBlocking BYTE 0
    playerCanHeal BYTE 3        ; Healing charge count
    healAmount BYTE 30          ; Health restored per heal
    enemyHealth BYTE 100
    enemyDamage BYTE 20
    enemyIsAttacking BYTE 0
    MAX_HEALTH = 100

    ; ---- Status Display Text ----
    healthStatusText BYTE "Player Health: ", 0
    enemyStatusText BYTE "Enemy Health: ", 0
    blockMessage BYTE "BLOCKED!", 0
    missMessage BYTE "MISSED!", 0
    healChargesText BYTE "Heals Left: ", 0

    ; ---- UI Tracking Variables ----
    line BYTE 1
    selectedOption BYTE 1
    actionTaken BYTE 0

.code
main PROC C
    call ClrScr
    call InitializeBorderChars   ; Initialize border characters
    INVOKE PlaySoundA, OFFSET soundFile, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
    
mainGameLoop:
    ; Display audio controls
    mov dl, 2
    mov dh, 30
    call Gotoxy
    mov edx, OFFSET muteMessage
    call WriteString
    
    ; Update mute status display
    mov dl, 40
    mov dh, 30
    call Gotoxy
    cmp isMuted, 1
    je showMuted
    mov edx, OFFSET unmutedStatus
    jmp displayMuteStatus
showMuted:
    mov edx, OFFSET mutedStatus
displayMuteStatus:
    call WriteString

    ; Process game state
    mov al, gameState
    cmp al, 0
    je MenuState
    cmp al, 1
    je ProcessGameState
    cmp al, 2
    je ProcessInstructionsState
    cmp al, 3
    je ProcessGameOverState
    jmp ExitGameProcedure

MenuState:
    call ProcessMenuState
    jmp mainGameLoop

ProcessGameState:
    call GameLoop
    jmp mainGameLoop

ProcessInstructionsState:
    call ShowInstructions
    jmp mainGameLoop

ProcessGameOverState:
    call DrawGameOver
    call ReadChar
    cmp al, 20h
    je InitializeNewGame
    cmp al, 1Bh
    je ExitGameProcedure
    jmp mainGameLoop

InitializeNewGame:
    mov gameState, 1
    mov playerHealth, 100
    mov enemyHealth, 100
    mov playerCanHeal, 3
    call ClrScr
    jmp mainGameLoop

ExitGameProcedure:
    call ClrScr
    mov dl, 25
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET exitText
    call WriteString
    call ReadChar
    invoke ExitProcess, 0
main ENDP

InitializeBorderChars PROC C
    mov al, BORDER_CHAR_H
    mov borderChars[0], al
    mov al, BORDER_CHAR_V
    mov borderChars[1], al
    mov borderChars[2], al
    mov borderChars[3], al
    ret
InitializeBorderChars ENDP

ProcessMenuState PROC C
    pushad      ; Save all registers
    
MenuLoop:
    call DrawMenu
    
    ; Check for keypress without waiting
    call ReadKey
    jz ContinueMenuAnimation    ; No key pressed
    
    ; Process key input
    cmp al, '1'
    je StartGame
    cmp al, '2'
    je StartInstructions
    cmp al, '3'
    je ExitGame
    cmp al, 'm'
    je ToggleAudio
    
ContinueMenuAnimation:
    call UpdateBorderAnimation
    jmp MenuLoop

StartGame:
    mov gameState, 1
    call ClrScr
    jmp MenuDone

StartInstructions:
    mov gameState, 2
    call ClrScr
    jmp MenuDone

ExitGame:
    mov gameState, 3
    jmp MenuDone

ToggleAudio:
    call ToggleMusicMute
    jmp MenuLoop

MenuDone:
    popad       ; Restore all registers
    ret
ProcessMenuState ENDP

ToggleMusicMute PROC C
    pushad
    xor isMuted, 1
    
    cmp isMuted, 1
    je MuteBackgroundMusic
    
    INVOKE PlaySoundA, OFFSET soundFile, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
    jmp ToggleMusicDone
    
MuteBackgroundMusic:
    INVOKE PlaySoundA, NULL, NULL, 0

ToggleMusicDone:
    popad
    ret
ToggleMusicMute ENDP

DrawMenu PROC C
    pushad
    
    ; Initialize border position if needed
    cmp borderX, 0
    jne SkipBorderInit
    mov borderX, MENU_LEFT
    mov borderY, MENU_TOP
    
SkipBorderInit:
    ; Draw title art
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

    ; Draw menu options
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
    mov edx, OFFSET pressKeyPrompt
    call WriteString
    
    popad
    ret
DrawMenu ENDP

ShowInstructions PROC C
    pushad
    call ClrScr
    
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

InstructionWaitLoop:
    call ReadChar
    cmp al, 20h          ; Check for spacebar
    jne InstructionWaitLoop
    mov gameState, 0
    call ClrScr
    
    popad
    ret
ShowInstructions ENDP
GameLoop PROC C
    pushad
    call DrawUI
    call DrawPlayer

GameLoopStart:
    movsx eax, playerHealth
    cmp eax, 0
    jle GameOverState
    movsx eax, enemyHealth
    cmp eax, 0
    jle GameOverState

    call UpdateHealthDisplay
    call ReadChar
    mov inputChar, al

    cmp inputChar, 1Bh    ; ESC key
    je ReturnToMenu
    cmp inputChar, "x"
    je MovePlayerUp
    cmp inputChar, "c"
    je MovePlayerDown
    cmp inputChar, "e"
    je SelectGameOption
    cmp inputChar, "m"
    je ToggleAudioInGame
    jmp GameLoopStart

ReturnToMenu:
    mov gameState, 0
    call ClrScr
    popad
    ret

GameOverState:
    mov gameState, 3
    popad
    ret

MovePlayerUp:
    call UpdatePlayer
    cmp playerY, 15
    je WrapToBottom
    sub playerY, 2
    dec selectedOption
    call DrawPlayer
    jmp GameLoopStart

MovePlayerDown:
    call UpdatePlayer
    cmp playerY, 19
    je WrapToTop
    add playerY, 2
    inc selectedOption
    call DrawPlayer
    jmp GameLoopStart

WrapToBottom:
    mov playerY, 19
    mov selectedOption, 2
    call DrawPlayer
    jmp GameLoopStart

WrapToTop:
    mov playerY, 15
    mov selectedOption, 0
    call DrawPlayer
    jmp GameLoopStart

SelectGameOption:
    mov actionTaken, 1
    cmp selectedOption, 0
    je ExecuteAttack
    cmp selectedOption, 1
    je ExecuteGuard
    cmp selectedOption, 2
    je ExecuteHeal
    jmp GameLoopStart

ToggleAudioInGame:
    call ToggleMusicMute
    jmp GameLoopStart

ExecuteAttack:
    mov dl, 7
    mov dh, 15
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET option1
    call WriteString

    mov eax, 15
    call RandomRange
    add al, 5

    movsx ebx, enemyHealth
    sub bl, al
    cmp bl, 0
    jge StoreEnemyDamage
    xor bl, bl

StoreEnemyDamage:
    mov enemyHealth, bl
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
    jmp GameLoopStart

ExecuteGuard:
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
    jmp GameLoopStart

ExecuteHeal:
    cmp playerCanHeal, 0
    je HealFailed

    mov dl, 22
    mov dh, 5
    call Gotoxy
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov edx, OFFSET option3
    call WriteString

    dec playerCanHeal
    movzx eax, healAmount
    movzx ebx, playerHealth
    add bl, al
    cmp bl, MAX_HEALTH
    jle StorePlayerHealth
    mov bl, MAX_HEALTH

StorePlayerHealth:
    mov playerHealth, bl
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
    jmp GameLoopStart

HealFailed:
    mov dl, 30
    mov dh, 19
    call Gotoxy
    mWrite "No healing charges left!"
    mov eax, 1000
    call Delay
    jmp GameLoopStart

GameLoop ENDP

EnemyTurn PROC C
    pushad
    mov playerIsBlocking, 0
    
    mov eax, 4
    call RandomRange
    cmp eax, 3
    je EnemyMiss
    
    mov eax, 15
    call RandomRange
    add al, 5
    
    cmp playerIsBlocking, 1
    je EnemyBlocked
    
    movsx ebx, playerHealth
    sub bl, al
    cmp bl, 0
    jge StorePlayerDamage
    xor bl, bl

StorePlayerDamage:
    mov playerHealth, bl
    mov dl, 22
    mov dh, 14
    call Gotoxy
    mWrite "Enemy attacks for "
    movzx eax, al
    call WriteDec
    mWrite " damage!"
    jmp EnemyTurnEnd

EnemyBlocked:
    mov dl, 22
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET blockMessage
    call WriteString
    jmp EnemyTurnEnd

EnemyMiss:
    mov dl, 22
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET missMessage
    call WriteString

EnemyTurnEnd:
    mov eax, 1000
    call Delay
    popad
    ret
EnemyTurn ENDP

DrawUI PROC C
    pushad
    mov dl, 0
    mov dh, 28
    call Gotoxy
    mov edx, OFFSET ground
    call WriteString

    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET top
    call WriteString

    mov ecx, 27
    mov line, 1
DrawSides:
    mov dl, 0
    mov dh, line
    call Gotoxy
    mov edx, OFFSET sides
    call WriteString
    inc line
    loop DrawSides

    call InsideLogo
    mov dl, 0
    mov dh, 29
    call Gotoxy
    mov edx, OFFSET controlsText
    call WriteString

    mov dl, 21
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET gameGround
    call WriteString

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
DrawUI ENDP

UpdateHealthDisplay PROC C
    pushad
    mov dl, 23
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET healthStatusText
    call WriteString
    movzx eax, playerHealth
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar

    mov dl, 23
    mov dh, 23
    call Gotoxy
    mov edx, OFFSET enemyStatusText
    call WriteString
    movzx eax, enemyHealth
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar

    mov dl, 23
    mov dh, 24
    call Gotoxy
    mov edx, OFFSET healChargesText
    call WriteString
    movzx eax, playerCanHeal
    call WriteDec
    popad
    ret
UpdateHealthDisplay ENDP

ResetOptionColors PROC C
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

UpdatePlayer PROC C
    pushad
    mov dl, playerX
    mov dh, playerY
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov al, " "
    call WriteChar
    popad
    ret
UpdatePlayer ENDP

DrawPlayer PROC C
    pushad
    mov dl, playerX
    mov dh, playerY
    call Gotoxy
    mov al, "X"
    call WriteChar
    popad
    ret
DrawPlayer ENDP

DrawGameOver PROC C
    pushad
    call ClrScr
    mov dl, 25
    mov dh, 10
    call Gotoxy
    
    cmp playerHealth, 0
    jle DisplayLoss
    
    mov edx, OFFSET victoryText
    jmp ContinueGameOver
    
DisplayLoss:
    mov edx, OFFSET gameOverText
    
ContinueGameOver:
    call WriteString
    mov dl, 15
    mov dh, 15
    call Gotoxy
    mov edx, OFFSET playAgainText
    call WriteString
    popad
    ret
DrawGameOver ENDP

InsideLogo PROC C
    pushad
    mov dl, 5
    mov dh, 2
    call Gotoxy
    mov edx, OFFSET logoArt1
    call WriteString

    mov dl, 5
    mov dh, 3
    call Gotoxy
    mov edx, OFFSET logoArt2
    call WriteString
    
    mov dl, 5
    mov dh, 4
    call Gotoxy
    mov edx, OFFSET logoArt3
    call WriteString

    mov dl, 5
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET logoArt4
    call WriteString
    
    popad
    ret
InsideLogo ENDP

UpdateBorderAnimation PROC C
    pushad
    
    ; Store current position in trail buffer
    movzx eax, trailIndex
    mov ebx, 0
    mov bl, borderX
    shl ebx, 8
    mov bl, borderY
    mov [lastBorderPos + eax * 4], ebx
    
    ; Update trail index with wraparound
    inc trailIndex
    mov al, trailIndex
    cmp al, borderTrailLength
    jb SkipTrailReset
    mov trailIndex, 0
    
SkipTrailReset:
    ; Clear old positions and draw new trail
    mov ecx, 0
    
DrawTrail:
    cmp ecx, LENGTHOF lastBorderPos
    jae UpdatePosition
    
    mov eax, [lastBorderPos + ecx * 4]
    test eax, eax
    jz UpdatePosition
    
    ; Position cursor for trail segment
    mov dl, ah
    mov dh, al
    call Gotoxy
    
    ; Draw trail character if within trail length
    mov al, cl
    cmp al, borderTrailLength
    jae DrawSpace
    
    mov al, BORDER_CHAR_H
    cmp borderDirection, 1
    je @F
    cmp borderDirection, 3
    je @F
    mov al, BORDER_CHAR_V
@@:
    call WriteChar
    jmp ContinueTrail
    
DrawSpace:
    mov al, ' '
    call WriteChar
    
ContinueTrail:
    inc ecx
    jmp DrawTrail
    
UpdatePosition:
    ; Update position based on direction
    mov al, borderDirection
    cmp al, 0
    je MoveRight
    cmp al, 1
    je MoveDown
    cmp al, 2
    je MoveLeft
    cmp al, 3
    je MoveUp
    
MoveRight:
    inc borderX
    mov al, borderX
    cmp al, MENU_RIGHT
    jne AnimationDone
    mov borderDirection, 1
    jmp AnimationDone
    
MoveDown:
    inc borderY
    mov al, borderY
    cmp al, MENU_BOTTOM
    jne AnimationDone
    mov borderDirection, 2
    jmp AnimationDone
    
MoveLeft:
    dec borderX
    mov al, borderX
    cmp al, MENU_LEFT
    jne AnimationDone
    mov borderDirection, 3
    jmp AnimationDone
    
MoveUp:
    dec borderY
    mov al, borderY
    cmp al, MENU_TOP
    jne AnimationDone
    mov borderDirection, 0
    
AnimationDone:
    ; Add small delay
    mov eax, 10
    call Delay
    
    popad
    ret
UpdateBorderAnimation ENDP

END main
