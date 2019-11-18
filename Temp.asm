#include p18f87k22.inc
	
    global  Temp_Read, Temp_setup, Temp_ReadROM, Temp_ConvertT, Temp_ReadScratchpad, Temp_ReadTimeSlots, Temp_SkipROM
acs0    udata_acs   ; named variables in access ram
Temp_cnt1   res 1   ; reserve 1 byte for variable LCD_cnt_l
Temp_cnt2   res 1 
Write1_high res 1
Write1_low  res 1    
Write0_high res 1
Write0_low  res 1

    code
   
Temp_setup	    ;reset pulse; should see a presence pulse from sensor
    clrf    TRISE
    movlw   0x00
    movwf   LATE
    movlw   high(.250) ; load 16bit number into
    movwf   Temp_cnt2 ; FR 0x10
    movlw   low(.250)
    movwf   Temp_cnt1 ; and FR 0x11
    call    bigdelay
    setf    TRISE
    call    bigdelay
    call    bigdelay
    call    bigdelay
    return 
    
Temp_Read
    call	Temp_setup
    call	Temp_SkipROM
    call	Temp_ConvertT
    call	Temp_setup
    call	Temp_SkipROM
    call	Temp_ReadScratchpad
    call	Temp_ReadTimeSlots
    return
    
Temp_ReadROM	    
    call    Write1
    call    Write1
    call    Write0
    call    Write0
    call    Write1
    call    Write1
    call    Write0
    call    Write0
    return
   
Temp_SkipROM		;skip ROM command -> go to function command
    call    Write0
    call    Write0
    call    Write1
    call    Write1
    call    Write0
    call    Write0
    call    Write1
    call    Write1
    return
    
    
Temp_ConvertT	    ;use inbuilt adc to store temp in scratchpad
    call    Write0
    call    Write0
    call    Write1
    call    Write0
    call    Write0
    call    Write0
    call    Write1
    call    Write0
    return
    
Temp_ReadScratchpad	;start reading data from scratchoad
    call    Write0
    call    Write1
    call    Write1		    
    call    Write1	        
    call    Write1		   
    call    Write1			        
    call    Write0			    
    call    Write1
    return
    
Temp_ReadTimeSlots	;generate time slots in which sensor gives 0s and 1s
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot  
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot  
    ;call    Serial_to_Parallel
    call    Temp_TimeSlot
    ;call    Serial_to_Parallel
    ;call    Temp_TimeSlot
    ;bcf     STATUS,0	;sets carry to 0
    nop
    
    return
    
Serial_to_Parallel
    movff   POSTINC0,   STATUS
    ;movff   POSTINC1, 0x90
    RLCF   0x30
    return
    
    
    
    
Temp_TimeSlot		;creates timeslot so it is over the minimum reguired length
    call    TimeSlotInit
    movlw   0x32
    movwf   0x20
    call    delay	;space out timeslots
    return
    

    
Write1
    clrf    TRISE
    movlw   0x00
    movwf   LATE
    movlw   0x01
    movwf   0x20
    call    delay
    setf    TRISE
    movlw   0x33
    movwf   0x20
    call    delay
    return
    
Write0
    clrf    TRISE
    movlw   0x00
    movwf   LATE
    movlw   0x33
    movwf   0x20
    call    delay
   ; movlw   0xA0   These extra delay make it too long 
    ;movwf   0x20
    ;call    delay
    setf    TRISE
    movlw   0x01
    movwf   0x20
    call    delay
    return
    
TimeSlotInit	    ;pulls low to start timeslot
    clrf    TRISE
    movlw   0x00
    movwf   LATE
    movlw   0x01
    movwf   0x20
    call    delay
    setf    TRISE
    setf    TRISD
    movlw   0x01	;release port E, wait before sampling state to allow voltage to rise if output is 1
    movwf   0x20
    call    delay
    bcf     STATUS,0	;sets carry to 0
    btfsc   PORTD,RD0	;if RD0 is 0, go to rotate
    bsf     STATUS,0	   ;if RD0 is 1, set carry to 1
    rrcf    0x3A,F,A	;carry-> MSB, then iterate
    
    
    ;movff   PORTD, POSTDEC2
    movlw   0x33
    movwf   0x20
    call    delay	; second delay lets sensor hold the pin low/high to receive 0/1
    return
 
delay
    decfsz  0x20, F, ACCESS
    bra	    delay
    return
    
;SPI_MasterInit ; Set Clock edge to negative
;    bcf SSP2STAT, CKE
;    ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
;    movlw (1<<SSPEN)|(1<<CKP)|(0x02)
;    movwf SSP2CON1
;    ; SDO2 output; SCK2 output
;    bcf TRISE, SDO2
;    bcf TRISE, SCK2
;    movf    SDO2, W
;    movwf   RE6
;    return
;    
;SPI_MasterTransmit ; Start transmission of data (held in W)
;    movwf SSP2BUF
;    
;Wait_Transmit ; Wait for transmission to complete
;    btfss PIR2, SSP2IF
;    bra Wait_Transmit
;    bcf PIR2, SSP2IF ; clear interrupt flag
;     return

    
bigdelay
    movlw 0x00 ; W=0
dloop 
    decf Temp_cnt1 ,f ; no carry when 0x00 -> 0xff
    subwfb Temp_cnt2,f ; no carry when 0x00 -> 0xff
    bc dloop ; if carry, then loop again
    return ; carry not set so return
	 

	 
    
    


    end