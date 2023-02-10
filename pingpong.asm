INCLUDE Irvine32.inc
INCLUDE VirtualKeys.inc

main    EQU start@0

.data
    bonusx              BYTE 0
    bonusy              BYTE 0
    directions          SBYTE -1, 1
    upPressedS          BYTE "Up     ", 0
    downPressedS        BYTE "Down   ", 0
    livesS              BYTE "Lives: ", 0
    gameOverS           BYTE "Game Over!", 0
    scoreS              BYTE "Score: ", 0
    blankLines              BYTE 80 dup(219), 0
    deltaX                  BYTE 1
    deltaY                  BYTE 1
    ballX                   BYTE 40
    ballY                   BYTE 10
    prevBallX               BYTE 40
    prevBallY               BYTE 10
    ballCount               BYTE 5
    playerPos           BYTE 10
    lives                   BYTE 5
    score                   BYTE 0
    PLAYER_MAX  = 18
.code

main PROC
    call        Bonuscreate
    mov         eax, white + (black * 16)
    call        SetTextColor
    call        ClrScr                    ; Initialization Code
    mov         edx, 0
    call        Gotoxy
    mov         edx, offset blankLines
    call        WriteString
    mov         dx, 0
    call        Gotoxy
    mov         ecx, 23
border:
    mov         al, 219
    call        WriteChar
    call        Crlf
loop        border

    mov         edx, offset blankLines
    call        WriteString

    mov         edx, 4
    call        Gotoxy
    
    
    call        Randomize
    mov     eax, 2
    call        RandomRange
    cmp     eax, 1
    jne     positive
    mov     deltaX, 1
    jmp     aroundA
positive:
    mov     deltaX, -1
aroundA:
    
    mov     eax, 2
    call        RandomRange
    cmp     eax, 1
    jne         positive1
    mov     deltaY, 1
    jmp         aroundB
positive1:
    mov     deltaY, -1
aroundB:

    call        GameLoop

    mov         eax, 0FFFFFFFFh
    call        Delay

    exit
main ENDP

GameLoop PROC
top:
    call        Input
    call        DrawPlayer
    call        UpdateBall

    mov         eax, 100
    call        Delay
    jmp         top    
GameLoop ENDP

UpdateBall PROC
    push        eax
    push        edx

    mov         dl, ballX       ; Clear the ball from the previous location
    mov         dh, ballY
    call            Gotoxy
    
    mov         al, ' '
    call            WriteChar
    call        checkbonus

    mov         al, ballY       ; Bottom wall collision
    cmp         al, 22
    jb              notBottomWall
    neg         deltaY
    jmp         notYCollide
notBottomWall:

    mov         al, ballY       ; Top wall collision
    cmp         al, 1
    ja              notTopWall
    neg         deltaY
    
notTopWall:
notYCollide:
    mov         al, ballX       ; Paddle collision
    cmp         al, 73
    jbe          notRightWall

    mov         al, ballY
    mov        ah, playerPos
    add        ah, 5
    cmp         al, ah
    jae          notPaddle
    cmp        al, playerPos
    jbe             notPaddle

    neg         deltaX
    inc       score

    jmp         notRightWall
notPaddle:
    
    dec         lives
    
    call            ResetRound
    
notRightWall:

    mov         al, ballX
    cmp         ballX, 1
    ja              notLeftWall
    neg         deltaX

notLeftWall:

    mov         al, ballX       ; Update the ball's X position
    add         al, deltaX
    mov         ballX, al

    mov         al, ballY       ; Update the ball's Y position
    add         al, deltaY
    mov         ballY, al

    mov         dl, ballX       ; Draw the ball in the new position
    mov         dh, ballY
    call        Gotoxy      
    mov         al, '@'
    call        WriteChar

    call        Bonus

    pop         edx
    pop         eax
    ret
UpdateBall ENDP

ResetRound PROC
    
    push    eax
    push        edx
    
    mov     dl, 10
    mov     dh, 5
    call        Gotoxy
    mov     edx, offset livesS
    call        WriteString
    movzx   eax, lives
    call        WriteDec
    
    mov     ballX, 40
    mov     ballY, 10
    
    call        Randomize
    mov     eax, 2
    call        RandomRange
    cmp     eax, 1
    jne     positive
    mov     deltaX, 1
    jmp     aroundA

positive:
    mov     deltaX, -1
aroundA:
    
    mov     eax, 2
    call        RandomRange
    cmp     eax, 1
    jne         positive1
    mov     deltaY, 1
    jmp         aroundB
positive1:
    mov     deltaY, -1
aroundB:

    cmp     lives, 0
    ja      continue
    
    mov         dl, 15
    mov     dh, 20
    call        Gotoxy
    
    mov     edx, offset gameOverS
    call        WriteString
    
    call        WaitMsg
    
    exit
continue:

    pop     edx
    pop     eax

    ret

ResetRound ENDP

DrawPlayer PROC

    pushad

    mov         dl,75           ; Clear the previous Paddle pixels
    mov         dh, 1
    call        Gotoxy
    mov         ecx, (PLAYER_MAX + 4)
    mov         al, ' '
clearLoop:
    call        WriteChar
    inc         dh
    call        Gotoxy
    loop        clearLoop

    mov         dl, 75
    mov         dh, playerPos
    call        Gotoxy

    mov         al, 219
    call        WriteChar
    inc         dh
    call        Gotoxy
    call        WriteChar
    inc         dh
    call        Gotoxy
    call        WriteChar
    inc         dh
    call        Gotoxy
    call        WriteChar
    inc         dh
    call        Gotoxy
    call        WriteChar
    
    mov     dl, 10
    mov     dh, 5
    call        Gotoxy
    mov     edx, offset livesS
    call        WriteString
    movzx   eax, lives
    call        WriteDec
    
    mov     dl, 10
    mov     dh, 6
    call        Gotoxy
    mov     edx, offset scoreS
    call        WriteString
    movzx   eax, score
    call        WriteDec

    popad

    ret

DrawPlayer ENDP

Input PROC
    ; The bounds on player position are 1 and 74?
    ; Todo(Sora): Test the max player position
    mov         edx, 0
    call ReadKey
     ;and         al, 0DFh
    cmp         al, 077h     ; Is up key pressed
    jne         notUp
    call        MoveUp
notUp:
    ;and         al, 0DFh
    cmp         al, 073h     ; Is down key pressed
    jne         notDown
    call        MoveDown
notDown:

    ret

Input ENDP

MoveUp PROC

    push        eax

    movzx       eax, playerPos    
    cmp         eax, 1
    jbe          tooBig

    dec         playerPos
    dec         playerPos

tooBig:
    pop         eax
    ret

MoveUp ENDP

MoveDown PROC

    push        eax

    movzx       eax, playerPos    
    cmp          eax, PLAYER_MAX
    jae            tooSmall

    inc         playerPos
    inc      playerPos
    
tooSmall:
    pop         eax
    ret

MoveDown ENDP

Bonus PROC
    mov         eax, cyan
    call        SetTextColor
    mov         dl, bonusx       
    mov         dh, bonusy
    call        Gotoxy      
    mov         al, 'o'
    call        WriteChar
    mov         eax, white
    call        SetTextColor

    ret
Bonus ENDP

Bonuscreate PROC
    redo:
    call    Randomize
    mov     eax, 70
    call    RandomRange
    mov     bonusx, al

    call    Randomize
    mov     eax, 20
    call    RandomRange
    mov     bonusy, al
    ret
Bonuscreate ENDP

Bonusvanished PROC
    mov         dl, bonusx       
    mov         dh, bonusy
    call        Gotoxy      
    mov         al, ' '
    call        WriteChar

    call        Bonuscreate
    call        Bonus
    ret
Bonusvanished ENDP

checkbonus  PROC
    mov         al,bonusx
    cmp         al,ballX
    je          checkbonusy
    jne         nobonus
checkbonusy:
    mov         al,bonusy
    cmp         al,ballY
    je          newbonus
    jne         nobonus
newbonus:
    inc     score
    call    Bonusvanished
nobonus:
    ret
checkbonus ENDP

END main