#include p18f87k22.inc
	
    global  Temp_setup
acs0    udata_acs   ; named variables in access ram
Temp_cnt1   res 1   ; reserve 1 byte for variable LCD_cnt_l
Temp_cnt2   res 1 
Write1_high res 1
Write1_low  res 1    
Write0_high res 1
Write0_low  res 1

    code
   
Temp_setup
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
    
;Temp_ReadROM  
;    call    Write1
;    call    Write1
;    call    Write0
;    call    Write0
;    call    Write1
;    call    Write1
;    call    Write0
;    call    Write0
;    return
;    
;    
;Write1
;    movlw   0x00
;    movwf   RE6
;    movlw   0x19
;    movwf   0x20
;    call    delay
;    return
;    
;Write0
;    movlw   0x00
;    movwf   RE6
;    movlw   0xFF
;    movwf   0x20
;    call    delay
;    movlw   0x40
;    movwf   0x20
;    call    delay
;    return
;    
;delay
;    decfsz  0x20, F, ACCESS
;    bra	    delay
;    return
;    
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