	#include p18f87k22.inc

	CONFIG  XINST = OFF           ; Extended Instruction Set (Disabled)
    extern  Temp_Read, Temp_setup, Temp_ReadROM, Temp_ConvertT 
    extern  Temp_ReadScratchpad, Temp_ReadTimeSlots, Temp_SkipROM, LCD_Setup
    extern  LCD_Write_Message, LCD_Write_Dec, LCD_1, LCD_.5, LCD_Send_Byte_D
    extern  LCD_Clear, Temp_Write, Write1, Write0,  Temp_ReadTHTL, Temp_LoadTHTL	
    extern  Temp_SaveTHTL	
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
Char1	res 1
Char2	res 1
	
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "T = \n"
	constant    myTable_l=.5	; length of data
myTabl3 data	    ".5°C\n"
	constant    myTable_2 = .5
myTabl4 data	    ".0°C\n"
	constant    myTable_3 = .5
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory
	call	LCD_Setup	; setup LCD
	bsf	EECON1, EEPGD 	; access Flash program memory
	goto	start
	
	; ******* Main programme ****************************************
start
;	call	Temp_Write	;get ready to write to the scratchpad
;	
;	call    Write1		   ;Input TH
;	call    Write1
;	call    Write1
;	call    Write1
;	call    Write1
;	call    Write1
;	call    Write1
;	call    Write1
;	
;	call    Write0		    ;Input TL
;	call    Write0
;	call    Write0
;	call    Write0
;	call    Write0
;	call    Write0
;	call    Write0
;	call    Write0
;	
;	
	;call	Temp_LoadTHTL
	;call	Temp_ReadTHTL
	call	Temp_Read
	lfsr    FSR2, 0x17
	lfsr	FSR0, 0x3A
	call	LCD_Clear
	call	LCD_Write_Dec
	movff	0x35, Char1
	movff	0x36, Char2
	;*******start of LCD code*******
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
	addwf	Char1, W
	call	LCD_Send_Byte_D	
	movlw	0x30
	addwf	Char2, W
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
	
	
	
	goto	start
stop	
	bra	stop
	end
	
	