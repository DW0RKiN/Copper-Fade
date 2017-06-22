; ZX Spectrum Compo #10 (After the deadline)
; ver 1.3
; command line: pasmo -d copper_fade.asm copper_fade.bin

copy_image	equ	0
enable_int	equ	1

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


START:
	xor	A
up_line:
	inc	A
	ret	z
	
	push	AF
	ld	HL, $581F
	ld	B, A
make_stack:
	ld	A, H
	dec	H
	and	$07
	jr	nz, in_char
	
	ld	A, L
	sub	$20
	ld	L, A
	jr	nc, in_screen
	
	ld	C, H
in_screen:
	ld	H, C
in_char:
	push	HL
	djnz	make_stack
	
; -------------------------
if enable_int
	ei
endif
	halt
draw_line:
	pop	HL
	pop	AF
	jr	nc, up_line
	push	AF
	pop	DE
	push	DE

	ld	C, $20

	bit	6, H
	jr	nz, no_clear
	ld	H, D
	ld	L, C
	ld	[HL], B		; [$4020] = $00 or write to ROM
no_clear:
	lddr			; [DE--] = [HL--]
	jr	draw_line
