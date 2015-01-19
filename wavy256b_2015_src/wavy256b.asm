; wavy256b.asm
; Silly Venture 2k14, By F#READY

; revision history
; 2015-01-16 : saved 9 bytes, now 253 including 6 for run address
; 2014-12-05 : 256 bytes SV release. replaced sound by small credits header
; 2014-12-04 : tnx to JAC! who shaved off some bytes. now including "musix"
; 2014-12-04 : 256 bytes! build complete DL in vblank, saved DL init. loop
; 2014-12-03 : still 32 bytes too large, 256 bytes + 32 bytes :-(
; 2014-12-03 : much to big! 386 bytes :-(

myfont		= $2800
dl_content	= display_list+6
screen_mem	= $4000		; tm $57FF, each line 256 bytes, 24 * 256 = 6 KB

font_vec	= $f0
screen_vec	= $f0
pixel		= $f4
offset		= $f5
wave_ypos	= $f6
dl_zp		= $f8

		org $8000

start

; other init. stuff

		dec 559			;34 TO 33

		lda #<display_list
		sta $230
		sta dl_zp
		
		lda #>myfont
		sta font_vec+1

; x = char. number, y = position in char.
		lda #128
		sta pixel
;		lda #>display_list
		sta $231		; must be at $80xx
		sta dl_zp+1
				
		asl
		sta 710
		sta font_vec
;		sta screen_vec

next_pixel:
		ldy #0
store_pixel:	lda pixel
		sta (font_vec),y
		
		lda #8
		clc
		adc font_vec
		sta font_vec
		scc			;Skip Carry Clear
		inc font_vec+1
						
		iny
		cpy #8
		bne store_pixel

		lsr pixel
		bne next_pixel

; font_vec is now 0, screen_vec = font_vec 

; screen filler
fill_with_offset:		
		ldy #0
		sty offset
fill_all:
		ldx #8
		lda #>screen_mem
		sta screen_vec+1
wave_filler:
		lda wave,y
		clc
		adc offset
		sta (screen_vec),y
		inc screen_vec+1
		
		lda #8
		clc
		adc offset
		sta offset
				
		dex
		bne wave_filler
		stx offset

		iny
		cpy #32
		bne fill_all	

;		ldy #0

		lda screen_vec
		clc
		adc #32
		sta screen_vec
		bcc fill_with_offset

; some fx :-)

next_frame
		ldx $14
same_frame
		lda $d40b
		cmp #20
		bne no_switch
		lda #>myfont
		sta $d409
no_switch
		asl
		ora #$d0
		sta $d40a
		sta $d016
		cpx $14
		beq same_frame

; some fx
		inc wave_ypos
		lda wave_ypos
		and #31
		sta wave_ypos
		tax

		ldy #6
		
move_it:		
		lda #$42
		sta (dl_zp),y	; dl_content,y 
		iny

		lda (dl_zp),y	; dl_content,y
		clc
		adc #1
		and #31
		sta (dl_zp),y	; dl_content,y
no_restart:
		iny
		
		lda wave,x
		clc
		adc #>screen_mem
		sta (dl_zp),y	; dl_content,y

		inx
		txa
		and #31
		tax

		iny
		cpy #3*24
		bne move_it
		
		lda #$41		;Z=0
		sta (dl_zp),y		;dl_content,y
		iny
		lda dl_zp		;#<display_list
		sta (dl_zp),y		;dl_content+1,y
		iny
		lda dl_zp+1		;#>display_list
		sta (dl_zp),y		;dl_content+2,y
		bne next_frame		;Z=0

credits
	dta d'F',$03,d'READY'
	dta d'  SV2K14'				

wave:
        dta $01,$01,$02,$02
	dta $03,$04,$04,$05
        dta $05,$06,$06,$06
        
        dta $07,$06,$06,$06
        dta $05,$05,$04,$04
        
        dta $03,$02,$02,$01,$01
        dta $00,$00,$00,$00,$00,$00,$00

display_list:
	dta $70,$70
	dta $46,a(credits)
	dta $70
	
        ORG $02e0
        dta a(start)
