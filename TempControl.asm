	#include p18f87k22.inc

	CONFIG  XINST = OFF           ; Extended Instruction Set (Disabled)
	extern	Temp_setup, Temp_ReadROM
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, da.................................................ta in programme memory, and its length *****
myTable data	    "8==============D8==============D\n"
	constant    myTable_l=.32	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	goto	start
	
	; ******* Main programme ****************************************
start	   


	call	Temp_setup
	call	Temp_ReadROM
	bra	start
	end
	
	