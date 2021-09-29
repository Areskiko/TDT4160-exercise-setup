.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO

.text
	.global Start
	
Start:

    // R0 er addr til led lys
    // R1 er addr til knapp
    // R2 er hjelpe reg

    // Sett R0 til å være addr til led lys
    LDR R0, =LED_PORT
    LDR R2, =PORT_SIZE
    MUL R0, R0, R2
    LDR R2, =GPIO_BASE
    ADD R0, R0, R2
    LDR R2, =GPIO_PORT_DOUT // Bruk av DOUT burde bety at når vi skriver 0b0000000 så resettes det
    ADD R0, R0, R2

    // Sett R1 til å være addr til knapp
    LDR R1, =BUTTON_PORT
    LDR R2, =PORT_SIZE
    MUL R1, R1, R2
    LDR R2, =GPIO_BASE
    ADD R1, R1, R2
    LDR R2, =GPIO_PORT_DIN
    ADD R1, R1, R2  

    Loop:
        LDR R2, [R1] // Last inn verdi fra PE2

        LDR R3, =BUTTON_PIN
        LDR R4, =LED_PIN
        SUB R3, R3, R4 // Beregn distanse fra BUTTON_PIN og LED_PIN

        LSR R2, R2, R3 // Shift for å gå fra input pin (9) til output pin (2)

        LDR R3, =0b1111111 // Invertering av bit, uten funker det ikke, kanskje
        EOR R2, R2, R3     // knappen er normally closed? 

        STR R2, [R0] // Skriv verdien til PB9
        B Loop // Gå til toppen av loopen


NOP // Behold denne på bunnen av fila

