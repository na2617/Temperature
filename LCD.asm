#include p18f87k22.inc

    global  LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear, LCD_Write_Dec, LCD_1, LCD_.5, LCD_Send_Byte_D	

acs0    udata_acs   ; named variables in access ram
LCD_cnt_l   res 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h   res 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms  res 1   ; reserve 1 byte for ms counter
LCD_tmp	    res 1   ; reserve 1 byte for temporary use
LCD_counter res 1   ; reserve 1 byte for counting through nessage
LCD_k	    res 2
acs_ovr	access_ovr
LCD_hex_tmp res 1   ; reserve 1 byte for variable LCD_hex_tmp	
Temp_Half   res 1   ;use as carry bit to output 0.5 degree increments
LCD_counter2 res 1   ; reserve 1 byte for counting through nessage
LCD_len	    res 1
	constant    LCD_E=5	; LCD enable bit
    	constant    LCD_RS=4	; LCD register select bit

LCD	code
    
LCD_Setup
	clrf    LATB
	movlw   b'11000000'	    ; RB0:5 all outputs
	movwf	TRISB
	movlw   .40
	call	LCD_delay_ms	; wait 40ms for LCD to start up properly
	movlw	b'00110000'	; Function set 4-bit
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	movlw	b'00101000'	; 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	movlw	b'00101000'	; repeat, 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	movlw	b'00001111'	; display on, cursor on, blinking on
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	movlw	b'00000001'	; display clear
	call	LCD_Send_Byte_I
	movlw	.2		; wait 2ms
	call	LCD_delay_ms
	movlw	b'00000110'	; entry mode incr by 1 no shift
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	return

LCD_Write_Dec

	clrf	0x10
	clrf	0x11
	clrf	0x20
	clrf	0x21
	clrf	0x30
	clrf	0x31
	clrf	0x40
	clrf	0x41
	clrf	0x55
	clrf	0x56
	clrf	0x50
	clrf	0x51
	
	movlw	0x41
	movwf	0x10
	movlw	0x8A
	movwf	0x11	;moving constant 0x418a to 0x10, 0x11 location
	movlw	0x0
	movwf	0x20
	;movff	ADRESH, 0x20
	clrf	STATUS
	rrcf	0x3A, F,A	
	movff	0x3A, 0x21	;moving voltage in hex to 0x20, 0x21 location
	btfsc	STATUS, 0
	bsf	Temp_Half, 0
	;movlw	0x04		;using fixed values of voltage for testing
	;movwf	0x20
	;movlw	0xD2
	;movwf	0x21
	
	movf	0x21, W
	mulwf	0x11
	movff	PRODL, 0x31
	movff	PRODH, 0x30
	mulwf	0x10
	movff	PRODL, 0x41	;multiplying and storing each byte separately
	movff	PRODH, 0x40
	movf	0x20, W
	mulwf	0x11
	movff	PRODL, 0x51
	movff	PRODH, 0x50
	mulwf	0x10
	movff	PRODL, 0x56
	movff	PRODH, 0x55
	movff	0x31, 0x13
	
	clrf	STATUS
	movf	0x30, W
	addwf	0x41, W		    ;adding and storing results in conescutive FRs
	addwf	0x51, W 
	movwf	0x12
	movf	0x40, W
	addwf	0x50, W
	addwf	0x56, W
	movwf	0x11
	movff	0x55, 0x10
	movf	0x10, W
	andlw	0x0F
	movwf	0x33
	
	;second multiplication
	call	LCD_Multi
	movf	0x10, W
	andlw	0x0F
	movwf	0x34
	;third
	call	LCD_Multi
	movf	0x10, W
	andlw	0x0F
	movwf	0x35
	;fourth
	call	LCD_Multi
	movf	0x10, W
	andlw	0x0F
	movwf	0x36
	
	return
	
LCD_Multi
	movlw	0x0A
	mulwf	0x13
	movff	PRODL, 0x31
	movff	PRODH, 0x30
	mulwf	0x12
	movff	PRODL, 0x41	;multiplying and storing each byte separately
	movff	PRODH, 0x40
	mulwf	0x11
	movff	PRODL, 0x51	
	movff	PRODH, 0x50
	movff	0x31, 0x13
	
	clrf	STATUS
	movf	0x30, W
	addwf	0x41, W		    ;adding and storing results in conescutive FRs 
	movwf	0x12
	movf	0x40, W
	addwf	0x51, W
	movwf	0x11
	movff	0x50, 0x10

	return
	
LCD_.5
	;bsf	Temp_Half, 0
	;clrf	Temp_Half
	btfsc   Temp_Half, 0	;if 0th bit was 1, output an extra 0.5 degrees
	call	LCD_Write_Message
	return
	
LCD_1
	;bsf	Temp_Half, 0
	;clrf	Temp_Half
	btfsc   Temp_Half, 0	;if 0th bit was 1, output an extra 0.5 degrees
	return
	call	LCD_Write_Message
	return
	
LCD_Write_Hex	    ; Writes byte stored in W as hex
	movwf	LCD_hex_tmp
	swapf	LCD_hex_tmp,W	; high nibble first
	call	LCD_Hex_Nib
	movf	LCD_hex_tmp,W	; then low nibble
LCD_Hex_Nib	    ; writes low nibble as hex character
	andlw	0x0F
	movwf	LCD_tmp
	movlw	0x0A
	cpfslt	LCD_tmp
	addlw	0x07	; number is greater than 9 
	addlw	0x26
	addwf	LCD_tmp,W
 	call	LCD_Send_Byte_D ; write out ascii
	return
	
LCD_Write_Message	    ; Message stored at FSR2, length stored in W
	movwf	LCD_len
	movlw	0x10
	movwf   LCD_counter
	movwf	LCD_counter2
LCD_Loop_message
	movf    POSTINC2, W
	call    LCD_Send_Byte_D
	decfsz  LCD_len
	bra	LCD_Loop_message
;	movlw	b'11000000'
;	call	LCD_Send_Byte_I
;	call	LCD_delay_ms
	return
;LCD_Loop_message2
;	movf    POSTINC2, W
;	call    LCD_Send_Byte_D
;	decfsz  LCD_counter2
;	bra	LCD_Loop_message2
;	return
;	
	
LCD_Clear
	movlw	b'00000001'	; display clear
	call	LCD_Send_Byte_I
	movlw	.2		; wait 2ms
	call	LCD_delay_ms
	return

LCD_Send_Byte_I		    ; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS	; Instruction write clear RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS    ; Instruction write clear RS bit
        call    LCD_Enable  ; Pulse enable Bit 
	return

LCD_Send_Byte_D		    ; Transmits byte stored in W to data reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS	; Data write set RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS    ; Data write set RS bit	    
        call    LCD_Enable  ; Pulse enable Bit 
	movlw	.10	    ; delay 40us
	call	LCD_delay_x4us
	return

LCD_Enable	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	    LATB, LCD_E	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	    LATB, LCD_E	    ; Writes data to LCD
	return
    
; ** a few delay routines below here as LCD timing can be quite critical ****
LCD_delay_ms		    ; delay given in ms in W
	movwf	LCD_cnt_ms
lcdlp2	movlw	.250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms
	bra	lcdlp2
	return
    
LCD_delay_x4us		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l   ; now need to multiply by 16
	swapf   LCD_cnt_l,F ; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l,W ; move low nibble to W
	movwf	LCD_cnt_h   ; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l,F ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1	decf 	LCD_cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return


    end


