; ZX Spectrum Compo #10 
; ver 1.2
; command line: pasmo -d copper_fade.asm copper_fade.bin

copy_image	equ	0

progStart  	equ	$C400	; 50176
screenStart  	equ	$C500

if copy_image

org screenStart

INCBIN z80asm.bin

endif

org	progStart

if copy_image
	; copy image on screen
	LD	BC,192*32	; 3 6144
	LD	DE,$4000	; 3
	LD	HL,screenStart	; 3
	LDIR			; 2
	call	START		; 3
	ret			; 1
endif


; ----------------------------------------------


copy_line:
	push	AF
	pop	DE
	push	DE
	
	bit	6, H		; $3F = zero flag
	jr	nz, no_clear		
				; clear screen
				;    HL = $3FFF, DE = $401F, BC = $0020
				; or HL = $3?20, DE = $3???, B = $08..$01, C = $3F
	ld	H, D
	ld	L, C
	ld	[HL], B		; [$4020] = $00
no_clear:
	lddr			; [DE--] = [HL--]; first HL = DE, BC = ????; other BC = $0020 
	ld	C, $20		; BC = $0020		
	pop	HL
draw:
	halt
	pop	AF
	jr	c, copy_line
	db	$01		; LD BC, xxxxx
START:
	ei
	xor	A

; make_stack ---------------
	inc	A		; plus line
	ret	z
	push	AF		; save A and not carry is stopper
	ld	E, A		; number of created line addresses from the bottom of the stack
	ld	HL, $57FF	; last address
up_screen:
	ld	C, H
up_char:
	ld	H, C
	ld	B, $08
up_in_char:
	push	HL	
	dec	E
	jr	z, draw
	dec	H
	djnz	up_in_char
	
	ld	A, L
	sub	$20
	ld	L, A
	jr	nc, up_char
	jr	up_screen
