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
    LDR R2, =LED_PIN
    ADD R0, R0, R2
    LDR R2, =GPIO_BASE
    ADD R0, R0, R2

    // Sett R1 til å være addr til knapp
    LDR R1, =BUTTON_PORT
    LDR R2, =PORT_SIZE
    MUL R1, R1, R2
    LDR R2, =BUTTON_PIN
    ADD R1, R1, R2
    LDR R2, =GPIO_BASE
    ADD R1, R1, R2
   

    Loop:
        LDR R2, [R1]
        STR R2, [R0]
        B Loop


NOP // Behold denne på bunnen av fila

