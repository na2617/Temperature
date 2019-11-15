	#include p18f87k22.inc

	CONFIG  XINST = OFF           ; Extended Instruction Set (Disabled)
	    extern	Temp_setup, Temp_ReadROM, Temp_ConvertT, Temp_ReadScratchpad, Temp_ReadTimeSlots, Temp_SkipROM, LCD_Setup, LCD_Write_Message, LCD_Write_Dec, LCD_1, LCD_.5, LCD_Send_Byte_D	
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, da.................................................ta in programme memory, and its length *****
myTable data	    "T = \n"
	constant    myTable_l=.5	; length of data
myTabl3 data	    ".5�C\n"
	constant    myTable_2 = .5
myTabl4 data	    ".0�C\n"
	constant    myTable_3 = .5
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory
	call	LCD_Setup	; setup LCD
	bsf	EECON1, EEPGD 	; access Flash program memory
	goto	start
	
	; ******* Main programme ****************************************
start
	call	Temp_setup
	call	Temp_SkipROM
	call	Temp_ConvertT
	call	Temp_setup
	call	Temp_SkipROM
	call	Temp_ReadScratchpad
	call	Temp_ReadTimeSlots
	lfsr    FSR2, 0x17
	lfsr	FSR0, 0x3A
	;clrf	TRISJ
	;movlw	0x31
	;movwf	PORTJ
	call	LCD_Write_Dec
	;start of LCD code
	; Output T =
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message   
	
	movlw	0x30
	addwf	0x35, W
	call	LCD_Send_Byte_D	
	movlw	0x30
	addwf	0x36, W
	call	LCD_Send_Byte_D	
	
	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTabl4)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTabl4)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTabl4)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_3	; bytes to read
	movwf 	counter		; our counter register
loop2 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop2		; keep going until finished
	
	movlw	myTable_3-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_1
	
	
	
	
	;output .5 degreesC
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTabl3)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTabl3)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTabl3)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_2	; bytes to read
	movwf 	counter		; our counter register
loop1 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop1		; keep going until finished
	
	movlw	myTable_2-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_.5
	
	
	
	
	
;SPI_MasterInit ; Set Clock edge to negative
;	bcf SSP2STAT, CKE
;	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
;	movlw (1<<SSPEN)|(1<<CKP)|(0x02)
;	movwf SSP2CON1
;	; SDO2 output; SCK2 output
;	bcf TRISD, SDO2
;	bcf TRISD, SCK2
;	return
;SPI_MasterTransmit ; Start transmission of data (held in W)
;	movwf SSP2BUF
;	Wait_Transmit ; Wait for transmission to complete
;	btfss PIR2, SSP2IF
;	bra Wait_Transmit
;	bcf PIR2, SSP2IF ; clear interrupt flag
;	return
	
stop	
	bra	stop
	end
	
	