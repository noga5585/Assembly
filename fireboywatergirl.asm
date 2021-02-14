;------------------------------------------
; File        : fireboyandwatergirl.asm
; Author      : Noga Shemesh
; Date        : 23/05/2020
; Description : 
;             :
;------------------------------------------
    IDEAL
    MODEL small
P386
    STACK 256

    VGA_SEGMENT equ 0a000h
	; player 1 keys
	RIGHT_KEY equ 77
    LEFT_KEY  equ 75
    UP_KEY    equ 72
	
	; player 2 keys
    D_KEY    equ 20h
    A_KEY    equ 1eh
	W_KEY    equ 11h
	
	ESC_KEY   equ 1 ; to exit


    TRANSPORENT_COLOR equ 0h ; not to paint
    JUMPHIGT equ 1; maximum jump height
DATASEG
include "image.dat"	  
include "charac1.dat" 
include "macro.asm"    
    w_img       dw 00 
    h_img       dw 00
	
	;player 1 changes
	w_img1      dw 11
    h_img1      dw 16
    temp_array  db 11*16 dup(0)
    StartPictX dw 187
    StartPictY dw 165
	HighJump   dw 1
	status     dw 2
	move    db 0 ; if need to draw again 
    current_x   dw ?
    current_y   dw ?
    is_restore  db ?
	befor_x dw ? 
	befor_y dw ? 
	finish1B dw 0	
	tempX dw ?
	loopTemp dw ?
	;player 2 changes
	w_img2      dw 11
    h_img2      dw 16
    temp_array2  db 11*16 dup(0)
    StartPictX2 dw 24
    StartPictY2 dw 179
	HighJump2   dw 3
	status2     dw 2
    current_x2   dw ?
    current_y2   dw ?
    is_restore2  db ?
	befor_x2 dw ? 
	befor_y2 dw ? 
	finish2G dw 0
	
	
	key     db ?
    newX    dw ?
	temp    dw ?
	savey   dw ?
	slow    dd ?
	slow2   dd ?
	temp2    dw ?
	tempH    dw ?
	tempHighJump dw ?
	tempPlayerY dw ?
	tempPlayerX dw ?
	done     dw  0 
	done2    dw  0	
	number   dw 2
	currentNumber dw number
	ErrorReadingFile DB 'Can not open file$'


		FileName1       DB 'board1.pcx',0
        FileName        DW ?    ; offset file name for current file
        FileHandle      DW ?	
        FileSize        DW ?
        ImageSizeInFile DW ?
        ImageWidth      DW ?
        ImageHeigth     DW ?
        PaletteOffset   DW ?
        Point_X         DW ?
        Point_Y         DW ?
        Color           DB ?		
        StartPictX1      DW ?
        StartPictY1      DW ?
   
SEGMENT FILEBUF para public  'DATA'  
        DB 50000 DUP(?) ;size of place - according to size of the pcx file
ENDS
   CODESEG


Start:
    mov ax, @data
    mov ds, ax

menu:

	call OpenScreen
	
GameScreen:
        ; grapic mode 
		mov ax, 013h          
		int 010h
		mov ax, 0A000h
		mov es, ax
	    call Game
	
HelpScreen:
	call Help 
	jmp menu

ExitScreen:
	jmp exit
	
ExitScreen2:
    ; text mode
    mov ax,03h
	int 10h
	call ToExit
	jmp menu 

finishscreen:
    mov ax,03h
	int 10h
	call ToFinish
	jmp menu 
	
start_game: 

    ; grapic mode
    mov ax, 13h
    int 10h
    
	mov [finish1B], 0
	mov [finish2G], 0 
	
	mov [StartPictX],  20
    mov [StartPictY],  179
	mov [StartPictX2],  20
    mov [StartPictY2] , 150
	
	mov [StartPictX1], 0d ; start loaction pcx
	mov [StartPictY1], 0d
    
	SHOWPCX StartPictX1, StartPictY1, FileName1
    mov [w_img],11
	mov [h_img],16 	
    MSaveBkGround StartPictX, StartPictY, temp_array ; save background behind the player
	CopyTo befor_x, StartPictX ; save the current loaction
	CopyTo befor_y, StartPictY 
	
	MSaveBkGround StartPictX2, StartPictY2, temp_array2 ; girl 
    CopyTo befor_x2, StartPictX2 
	CopyTo befor_y2, StartPictY2 
	
    MDrawImage StartPictX, StartPictY, Img, 1
	MDrawImage StartPictX2, StartPictY2, Img2, 1
	CopyTo temp2, StartPictX2

;----- Main loop		
L2:
	cmp [move], 0 ; if the player not move (pressure a key) 
	je no_moving 

    MDrawImage befor_x, befor_y, temp_array,0
    CopyTo befor_x, StartPictX
	CopyTo befor_y, StartPictY
	
	MDrawImage befor_x2, befor_y2, temp_array2,0
	CopyTo befor_x2, StartPictX2
	CopyTo befor_y2, StartPictY2
	
	MSaveBkGround StartPictX, StartPictY, temp_array
	MSaveBkGround StartPictX2, StartPictY2, temp_array2 ; girl 
	
    MDrawImage StartPictX, StartPictY, Img, 1
	MDrawImage StartPictX2, StartPictY2, Img2, 1 ; girl
		
no_moving: 
	
	mov [move], 0
	call BoysObstacles 	
	call GirlsObstacles
	cmp [finish1B], 1
	jne gameNotFinish
	cmp [finish2G], 1
	jne gameNotFinish
	jmp finishscreen

gameNotFinish:
	mov [finish1B], 0
	mov [finish2G], 0 

moveVerticl:
	dec [currentNumber]
	cmp [currentNumber], 0
	jne readKey

    MoveVertical StartPictX, StartPictY, status, HighJump ; boy
    MoveVertical StartPictX2, StartPictY2, status2, HighJump ; girl
	CopyTo currentNumber, number

readKey: 
;----- Read SCAN code from keyboard port
    in al,060h
    mov [key], al
	
	cmp [key], UP_KEY
    je Up1
	
    cmp [key], RIGHT_KEY
    je Right1
 
    cmp [key], LEFT_KEY
    je Left1
	
	cmp [key], W_KEY
    je Up2
	
    cmp [key], D_KEY
    je Right2
 
    cmp [key], A_KEY
    je Left2
	
	jmp cont
	
Up1: 
    Up status
    jmp cont 
	
Right1:
    MoveRight StartPictX, StartPictY
	jmp cont
	
Left1:
    MoveLeft StartPictX, StartPictY 
    jmp cont
	
Up2: 
    Up status2
    jmp cont 
	
Right2:
    MoveRight StartPictX2, StartPictY2
	jmp cont
	
Left2:
    MoveLeft StartPictX2, StartPictY2 
    jmp cont

Cont:
    cmp [key], ESC_KEY
    je quit    
	jmp L2
quit:
    mov ax, 3h
    int 10h
Exit:
    mov ax, 4C00h
    int 21h
;-------------------------------------------
; GirlsObstacles - all the obstacles player 2 
;-------------------------------------------
; Input:
; 	StartPictX2, StartPictY2 
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC GirlsObstacles near
	cmp [StartPictY2], 179
	jae ObOneGirl1
	cmp [StartPictY2], 142
	je ObTwoGirl2
	cmp [StartPictY2], 123
	je ObThreeGirl3
	cmp [StartPictY2], 61
	je ObThreeGirl4
	cmp [StartPictY2], 26
	je finishG2 
	jmp completedG
ObOneGirl1:	
	call ObOneGirl
	jmp completedG
ObTwoGirl2:
	ObTwo StartPictX2, StartPictY2
	jmp completedG
ObThreeGirl3:
	call ObThreeGirl
	jmp completedG
ObThreeGirl4:
	call ObFourGirl
finishG2:
	call finishG
completedG:
ret
ENDP GirlsObstacles
;-------------------------------------------
; BoysObstacles - all the obstacles player 1 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC BoysObstacles near
	cmp [StartPictY], 179
	jae ObOneBoy1
	cmp [StartPictY], 142
	je ObTwoBoy2
	cmp [StartPictY], 123
	je ObThreeBoy3
	cmp [StartPictY], 89
	je ObThreeBoy4
	cmp [StartPictY], 26
	je finish1
	jmp completedB
ObOneBoy1:
	Call ObOneBoy
	jmp completedB
ObTwoBoy2: 
	ObTwo StartPictX, StartPictY
	jmp completedB
ObThreeBoy3:
	call ObThreeBoy
	jmp completedB
ObThreeBoy4:
	call ObFourBoy
finish1:
	call finishB
completedB:
ret
ENDP BoysObstacles

;-------------------------------------------
; ObOneGirl 
;-------------------------------------------
; Input:
; 	StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObOneGirl near
	cmp [StartPictX2], 155
	jnae completedG1
	cmp [StartPictX2], 175
	jnbe completedG1
	jmp ExitScreen2	
completedG1:
ret	
ENDP ObOneGirl
;-------------------------------------------
; ObOneBoy 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObOneBoy near	
    cmp [StartPictX], 225
	jnae completedB1
	cmp [StartPictX], 250
	jnbe completedB1
	jmp ExitScreen2	
completedB1:
	ret	
ENDP ObOneBoy
;-------------------------------------------
; ObThreeGirl 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY, StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObThreeGirl near
	cmp [StartPictX2], 70
	jbe completedG3
	cmp [StartPictX2], 85
	jae completedG3
	mov [move], 1 
	mov [tempPlayerX], 185
	mov [tempPlayerY], 96
	CopyTo StartPictX2, tempPlayerX
	CopyTo StartPictY2, tempPlayerY
completedG3:
ret	
ENDP ObThreeGirl
;-------------------------------------------
; ObThreeBoy 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY, StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObThreeBoy near
	cmp [StartPictX], 70
	jbe completedB3
	cmp [StartPictX], 85
	jae completedB3
	mov [move], 1 
	mov [tempPlayerX], 55
	mov [tempPlayerY], 89
	CopyTo StartPictX, tempPlayerX
	CopyTo StartPictY, tempPlayerY
completedB3:
ret	
ENDP ObThreeBoy
;-------------------------------------------
; ObFourBoy 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY, StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObFourBoy near
	cmp [StartPictX], 85
	jbe completedB4
	cmp [StartPictX], 95
	jae completedB4
	mov [move], 1 
	mov [tempPlayerX], 265
	mov [tempPlayerY], 60
	CopyTo StartPictX2, tempPlayerX
	CopyTo StartPictY2, tempPlayerY
completedB4:
ret	
ENDP ObFourBoy
;-------------------------------------------
; ObFourGirl 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY, StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
PROC ObFourGirl near
	cmp [done2], 1
	je completedB4
	mov [done2], 1
	cmp [StartPictX2], 280
	jae completedG4
	mov [move], 1 
	mov [tempPlayerX], 150
	mov [tempPlayerY], 60
	CopyTo StartPictX2, tempPlayerX
	CopyTo StartPictY2, tempPlayerY
	CopyTo StartPictX, tempPlayerX
	CopyTo StartPictY, tempPlayerY
completedG4:
ret	
ENDP ObFourGirl
;-------------------------------------------
; finishB 
;-------------------------------------------
; Input:
; 	StartPictX, StartPictY
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
Proc finishB near
	cmp [StartPictX], 265
	jbe notfinish
	cmp [StartPictX], 270
	jae notfinish
	mov [finish1B], 1 
notfinish:
ret

EndP finishB
;-------------------------------------------
; finishG 
;-------------------------------------------
; Input:
; 	StartPictX2, StartPictY2
; Output:
; 	
; Registers
;	 none
;-------------------------------------------
Proc finishG near
	cmp [StartPictX2], 295
	jbe notfinishG
	cmp [StartPictX2], 300
	jae notfinishG
	mov [finish2G], 1 
notfinishG:
ret
EndP finishG

;-------------------------------------------
; PDrawImage - draw the image
;-------------------------------------------
; Input:
; 	h_img, w_img, current_x, current_y, TRANSPORENT_COLOR, is_restore
; Output:
; 	
; Registers
;	 ax, bx, cx, dx, si  
;-------------------------------------------
PROC PDrawImage near
    mov cx, [h_img]
vertical_loop:
    push cx
    mov cx, [w_img]
horizontal_loop:
    push cx
    mov bh, 0
    mov cx, [current_x]
    mov dx, [current_y]
    mov al, [si]
    cmp [is_restore], 0
    je draw
    cmp al, TRANSPORENT_COLOR
    je not_draw
draw:
    mov ah, 0ch
    int 10h
not_draw:
    inc [current_x]
    inc si
    pop cx
    loop horizontal_loop
    inc [current_y]
    mov ax, [current_x]
    sub ax, [w_img]
    mov [current_x], ax

    pop cx
    loop vertical_loop
    ret
ENDP PDrawImage
;-------------------------------------------
; PSaveBkGround - save background
;-------------------------------------------
; Input:
; 	h_img, w_img, current_x, current_y
; Output:
; 	
; Registers
;	 ax, bx, cx, dx, si  
;-------------------------------------------
PROC PSaveBkGround near
    mov cx, [h_img]
@@vertical_loop:
    push cx
    mov cx, [w_img]
@@horizontal_loop:
    push cx
    mov bh, 0
    mov cx, [current_x]
    mov dx, [current_y]
    mov ah, 0dh
    int 10h
    mov [si], al
    inc [current_x]
    inc si
    pop cx
    loop @@horizontal_loop
    inc [current_y]
    mov ax, [current_x]
    sub ax, [w_img]
    mov [current_x], ax

    pop cx
    loop @@vertical_loop
    ret
ENDP PSaveBkGround
;-------------------------------------------
; ReadPCXFile - read pcx 
;-------------------------------------------
; Input:
; 	file
; Output:
; 	file read
; Registers
;	 all 
;-------------------------------------------
PROC ReadPCXFile Near
        pusha

;-----  Initialize variables
        mov     [FileHandle],0
        mov     [FileSize],0

;-----  Open file for reading
        mov     ah, 3Dh
        mov     al, 0
        ; mov DX,offset FileName  
        int     21h
        jc      @@Err
        mov     [FileHandle],AX   ; save Handle

;-----  Get the length of a file by setting a pointer to its end
        mov     ah, 42h
        mov     al ,2
        mov     bx, [FileHandle]
        xor     cx, cx
        xor     dx, dx
        int     21h
        jc 		@@Err
        cmp     dx,0
        jne     @@Err  ;file size exceeds 64K

;-----  Save size of file
        mov     [FileSize], ax

;----- Return a pointer to the beginning of the file
        mov     ah, 42h
        mov     al, 0
        mov     bx, [FileHandle]
        xor     cx, cx
        xor     dx, dx
        int  21h
        jc  @@Err

;-----  Read file into FILEBUF
        mov     bx, [FileHandle]
        pusha     
        push    ds
        mov     ax,FILEBUF
        mov     ds, ax
        xor     dx, dx
        mov     cx, 50000
        mov     ah, 3Fh
        int     21H
        pop     ds
        popa
        jc      @@Err

;-----  Close the file
        mov     ah, 3Eh
        mov     bx,[FileHandle]
        int     21H
        jc      @@Err
        popa
        ret
		
;-----  Exit - error reading file
@@Err:  ; Set text mode
        mov     ax, 3
        int     10h
        
        mov     dx, offset ErrorReadingFile
        mov     ah, 09h
        int     21h
        jmp     Exit
		
ENDP ReadPCXFile

;-------------------------------------------
; ShowPCXFile - show PCX file 
;-------------------------------------------
; Input:
; 	File name
; Output:
; 	The file
; Registers
;	 AX, BX, CX, DX, DS
;-------------------------------------------
PROC ShowPCXFile Near	
        pusha
		
        call    ReadPCXFile
		
	    mov	    ax, FILEBUF
        mov     es, ax

;-----  Set ES:SI on the image
        mov     si, 128

;-----  Calculate the width and height of the image
        mov     ax, [es:42h]
        mov     [ImageWidth], ax
        dec     [ImageWidth]
		
        mov     ax, [es:0Ah]
        sub     ax, [es:6]
        inc     ax
        mov     [ImageHeigth], ax

;-----  Calculate the offset from the beginning of the palette file
        mov     ax, [FileSize]
        sub     ax, 768
        mov     [PaletteOffset], ax
        mov     ax, [FileSize]
        sub     ax, 128+768
        mov     [ImageSizeInFile], ax
		
        xor  ch, ch            ; Clear high part of CX for string copies
        push [StartPictX1]      ; Set start position
        pop  [Point_x]
        push [StartPictY1]
        pop  [Point_y]
NextByte:
        mov     cl, [es:si]     ; Get next byte
        cmp     cl, 0C0h        ; Is it a length byte?
        jb      normal          ;  No, just copy it
        and     cl, 3Fh         ; Strip upper two bits from length byte
        inc     si              ; Advance to next byte - color byte

       	mov     al, [es:si]
	mov 	[Color], al
NextPixel:
        call 	PutPixel
        cmp     cx, 1
		je 	CheckEndOfLine
	
        inc     [Point_X]

		loop 	NextPixel		
        jmp     CheckEndOfLine
Normal:
      	mov 	[Color], cl
        call 	PutPixel

CheckEndOfLine:
        mov     ax, [Point_X]
        sub     ax, [StartPictX1]
        cmp     ax, [ImageWidth]
;-----  [Point_X] - [StartPictX] >= [WidthPict] 
        jae     LineFeed
        inc     [Point_x]
        jmp     cont1
LineFeed:
        push    [StartPictX1]
        pop     [Point_x]
        inc     [Point_y]
cont1:
        inc     si
        cmp     si, [ImageSizeInFile]     ; End of file? (written 320x200 bytes)
        jb      nextbyte
        popa
        ret
ENDP ShowPCXFile

;-------------------------------------------
; PutPixel - draw pixel 
;-------------------------------------------
; Input:
; 	x - Point_x, y - Point_y, Color - color
; Output:
; 	The pixel
; Registers
;	 AX, BH, CX, DX
;-------------------------------------------
PROC PutPixel near
        pusha
        mov 	bh, 0h
        mov 	cx, [Point_x]
        mov 	dx, [Point_Y]
        mov 	al, [color]
        mov 	ah, 0ch
        int 	10h
        popa
        ret
ENDP PutPixel		
		

;----------------------------------------------------------
; OpenScreen the first screen in game there is the menu.
;----------------------------------------------------------
; Input:
; 	ax 
; Output:
; 	dx
; Registers
;	 AX, dx
;----------------------------------------------------------

proc OpenScreen

	; show intro game
	mov ah,09h
	mov dx,offset intro
	int 21h
	;Check when to go according the using coice.
	mov ah,07h
	int 21h 
	cmp al,031h ;if == 1 (game) 
	je return
	cmp al,032h ;if == 2 (help)
	je HelpScreen
	cmp al,033h ; if== 3 (exit) 
	je ExitScreen
	
return:
		
	ret
		
endp

;----------------------------------------------------------
; Game the real game
;----------------------------------------------------------
; Input:
; 	 ah
; Output:
; 	dx
; Registers
;	 ah, dx
;----------------------------------------------------------
proc Game
		jmp start_game
	ret
endp


;----------------------------------------------------------
; help for the ueser
;----------------------------------------------------------
; Input:
; 	 ah
; Output:
; 	dx
; Registers
;	 ah, dx
;----------------------------------------------------------
proc Help 

       ;show help screen
		mov ah,09h
		mov dx,offset help1
		int 21h
		; Press any key to continue
		mov ah,00h
		int 16h
		
	ret
endp

;----------------------------------------------------------
; exit the game
;----------------------------------------------------------
; Input:
; 	 ah
; Output:
; 	dx
; Registers
;	 ah, dx
;----------------------------------------------------------
	
proc ToExit near
        mov ah, 0ch
		mov al, 0h
		int 21h
       ;show exit screen
		mov ah,09h
		mov dx,offset exit1
		int 21h
		;Press any key
		mov ah, 07h
		int 21h
		
	ret
endp
;----------------------------------------------------------
; exit the game
;----------------------------------------------------------
; Input:
; 	 ah
; Output:
; 	dx
; Registers
;	 ah, dx
;----------------------------------------------------------
proc ToFinish near
        mov ah, 0ch
		mov al, 0h
		int 21h
       ;show exit screen
		mov ah,09h
		mov dx,offset exit2
		int 21h
		;Press any key
		mov ah, 07h
		int 21h
		
	ret
endp
		End Start
		
