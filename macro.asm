;-------------------------------------------------------------
; MDrawImage 
;-------------------------------------------------------------
; Input:
;   StartX, StartY - Image location
;   Imgname        - Name of data image
;   IsRestore      - Restore background or draw image
; Output:
; 	The image
; Registers
;   AX, SI 
;----------------------------------------------------------
MACRO MDrawImage StartX, StartY, ImgName, IsRestore
    mov ax, [StartX]
    mov [current_X], ax
    mov ax, [StartY]
    mov [current_Y], ax
    mov al, [IsRestore]
    mov [is_restore],al
    mov si, offset ImgName
	call PDrawImage
ENDM MDrawImage

;-------------------------------------------------------------
; MSaveBkGround 
;-------------------------------------------------------------
; Input:
;   StartX, StartY - Image location
;   temp_array     - the array for save a back ground 
; Output:
;   None
; Registers
;   AX, SI 
;----------------------------------------------------------
MACRO MSaveBkGround  StartX, StartY, array 
    mov ax, [StartX]
    mov [current_X], ax
    mov ax, [StartY]
    mov [current_Y], ax

    mov si, offset array
    call PSaveBkGround
ENDM MDrawImage
;-------------------------------------------------------------
; SHOWPCX 
;-------------------------------------------------------------
; Input:
;   StartX1, StartY1 - pcx location
;   fName     - the pcx address 
; Output:
;   None
; Registers
;   AX, dx 
;----------------------------------------------------------
MACRO SHOWPCX StartX1, StartY1, fName 
        mov ax, [StartX1]
        mov [Point_X], ax
        mov ax, [StartY1]
        mov [Point_Y], ax

        mov dx, offset fName

        call ShowPCXFile
ENDM SHOWPCX
;-------------------------------------------------------------
; Up player is in jump 
;-------------------------------------------------------------
; Input:
;   status - the player mode in the bord
;    
; Output:
;   None
; Registers
;   None
;----------------------------------------------------------
MACRO Up status
	local change, outOfUpMacro
    cmp [status], 2
	je change
	jmp outOfUpMacro
	
change:
    mov [status], 1 

outOfUpMacro:

ENDM Up
;-------------------------------------------------------------
; MoveRight calculates the new loaction
;-------------------------------------------------------------
; Input:
;   PlayerX, PlayerY - the loaction of the player
;    
; Output:
;   None
; Registers
;   None
;----------------------------------------------------------
MACRO MoveRight PlayerX, PlayerY
	CopyTo newX, playerX
	add [newX], 1
	MoveIfPossibaleRight newX, playerY, playerX
	
ENDM MoveRight	
;-------------------------------------------------------------
; MoveLeft calculates the new loaction
;-------------------------------------------------------------
; Input:
;   PlayerX, PlayerY - the loaction of the player
;    
; Output:
;   None
; Registers
;   None
;----------------------------------------------------------
MACRO MoveLeft PlayerX, PlayerY
	CopyTo newX, playerX
	sub [newX], 1
	MoveIfPossibaleLeft newX, playerY, playerX
	
ENDM MoveLeft
;-------------------------------------------------------------
; MoveHorizontal- chack if the player is in jump. move the player accordingly
;-------------------------------------------------------------
; Input:
;   PlayerX, PlayerY - the loaction of the player
;   status - the player mode in the bord
;   HighJump - height of the jump 
; Output:
;   None
; Registers
;   None
;----------------------------------------------------------
MACRO MoveVertical PlayerX, playerY, status, HighJump
    local goUp, goDown, changeStatusDown, changeStatus0, outOfMacro, chackIfCan,inmove, chackIfCan2, changeHighJump,slow3, playerXLoop,slow1, playerXLoop2, 
	CopyTo savey, playerY
	mov [done], 1 
	cmp [status], 1 ; going up
	je goUp
	cmp [status], 2 ; going down
	je goDown
    jmp outOfMacro ; in ground 
goUp:
	mov [move], 1
    CopyTo tempPlayerY, playerY

chackIfCan: ; if the player can jump    
	CopyTo tempPlayerX, PlayerX
	CopyTo loopTemp, w_img1
	mov cx,[tempPlayerX]
	
playerXLoop:
	mov dx,[tempPlayerY]
	mov bx, 0h 
    mov ah,0Dh
    int 10h
    cmp al, 07h
	je changeStatusDown
	dec [loopTemp]
	inc [tempPlayerX]
	cmp [loopTemp], 0
	jne playerXLoop	
	dec [tempPlayerY]
	CopyTo playerY, tempPlayerY
	jmp outOfMacro
	
goDown:
    CopyTo tempPlayerY, playerY
	AddTO tempPlayerY, h_img1
	
chackIfCan2: ; if the player can jump    
	CopyTo tempPlayerX, PlayerX
	CopyTo loopTemp, w_img1
	mov cx,[tempPlayerX]

playerXLoop2:
	mov dx,[tempPlayerY]
	mov bx, 0h 
    mov ah,0Dh
    int 10h
    cmp al, 07h
	je changeStatus0
	dec [loopTemp]
	inc [tempPlayerX]
	cmp [loopTemp], 0
	jne playerXLoop2	
	inc [tempPlayerY]
	jmp changeStatus0

changeStatusDown:
	CopyTo playerY, tempPlayerY
    mov [status], 2
	jmp outOfMacro
changeStatus0:
	SubTo tempPlayerY, h_img1
	CopyTo playerY,  tempPlayerY
    mov [status], 2
	mov ax, [savey]
	cmp [playerY], ax
	jne inmove
	jmp outOfMacro
inmove:
	mov [move] , 1
outOfMacro:
		
ENDM MoveHorizontal


;-------------------------------------------------------------
; MoveIfPossibaleLeft - chack according the color if the player can move.
; if he can- move the player
;-------------------------------------------------------------
; Input:
;   newX, newY playerX - the new loaction
;   playerX - the x of the player
; Output:
;   None
; Registers
;   ax, bx, cx, dx
;----------------------------------------------------------
MACRO MoveIfPossibaleLeft newX, newY, playerX
    local outL, HLoopLeft 
HLoopLeft:
	mov cx,[newX]
    mov dx,[newY]
    mov ah,0Dh
	mov bx, 0h
    int 10h
    cmp al, 7h
	je outL	
	mov [move], 1
	CopyTo playerX, newX
outL:

ENDM MoveIfPossibaleLeft
;-------------------------------------------------------------
; MoveIfPossibaleRight - chack according the color if the player can move.
; if he can- move the player
;-------------------------------------------------------------
; Input:
;   newX, newY playerX - the new loaction
;   playerX - the x of the player
; Output:
;   None
; Registers
;   ax, bx, cx, dx
;----------------------------------------------------------
MACRO MoveIfPossibaleRight newX, newY, playerX
    local outR, HLoopRight
	CopyTo tempPlayerX, newX
	AddTo  tempPlayerX, w_img1
HLoopRight:
	mov cx,[tempPlayerX]
    mov dx,[newY]
    mov ah,0Dh
	mov bx, 0h
    int 10h
    cmp al, 7h
	je outR
	mov [move], 1
	CopyTo playerX, newX
outR:

ENDM MoveIfPossibaleRight
;-------------------------------------------------------------
; CopyTo - copy one object to other object
;-------------------------------------------------------------
; Input:
;   destination - the object to change
;   toCopy - the object to copy
; Output:
;   None
; Registers
;   ax
;----------------------------------------------------------
MACRO CopyTo destination, toCopy
	mov ax, [toCopy]
	mov [destination], ax

ENDM CopyTo
;-------------------------------------------------------------
; AddTo - add one object to other object
;-------------------------------------------------------------
; Input:
;   destination - the object to change
;   toAdd - the object to add
; Output:
;   None
; Registers
;   ax
;----------------------------------------------------------
MACRO AddTO  destination, toAdd
	mov ax, [toAdd]
	add [destination], ax
ENDM AddTO
;-------------------------------------------------------------
; SubTo - sub one object to other object
;-------------------------------------------------------------
; Input:
;   destination - the object to change
;   toSub - the object to sub
; Output:
;   None
; Registers
;   ax
;----------------------------------------------------------
MACRO SubTo destination, toSub
	mov ax, [toSub]
	sub [destination], ax 
ENDM SubTo
;-------------------------------------------------------------
; ObTwo - chack if the player fied
;-------------------------------------------------------------
; Input:
;   playerX, playerY - player loaction
; Output:
;   None
; Registers
;   dx
;----------------------------------------------------------
MACRO ObTwo playerX, playerY
    local completed2
    cmp [playerX], 210
	jbe completed2
	cmp [playerX], 230
	jae completed2
	jmp ExitScreen2
completed2:
	
ENDM ObTwo

