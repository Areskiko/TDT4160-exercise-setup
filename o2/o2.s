.thumb
.syntax unified

.include "gpio_constants.s"     // Register-adresser og konstanter for GPIO
.include "sys-tick_constants.s" // Register-adresser og konstanter for SysTick

.text
	.global Start
	

Start:

    // R0 bestemmer om klokken går
    // R1 er tiendedels-tellevariabel
    // R2 er sekunder-tellevariabel
    // R3 er minutt-tellevariabel
    // R4 er addr til led lys
    // R5 og R6 er hjelpe registre
    // R7 er xor bit
    // R8 er register for innlasting av verdier

    LDR R0, =0b0
    LDR R7, =0b1
    LDR R1, =#0
    LDR R2, =#0
    LDR R3, =#0

    // Sett R4 til å være addr til led lys
    LDR R4, =LED_PORT
    LDR R5, =PORT_SIZE
    MUL R4, R4, R5
    LDR R5, =GPIO_BASE
    ADD R4, R4, R5
    LDR R5, =GPIO_PORT_DOUTTGL // Bruk av DOUTTGL burde bety at jeg alltid kan bare skrive 1
    ADD R4, R4, R5

    //Sett opp klokke
    LDR R5, =SYSTICK_BASE
    LDR R6, =SYSTICK_CTRL
    ADD R5, R5, R6
    LDR R6, =0b110
    STR R6, [R5]

    LDR R6, =SYSTICK_CTRL
    SUB R5, R5, R6

    LDR R6, =SYSTICK_LOAD
    ADD R5, R5, R6
    LDR R6, =#1400000 //Klarer ikke å dele på 10 eller gange med 0.1 så hardkoder tiendedels klokkefrekvens middlertidig 
    //LDR R6, =FREQUENCY
    //LDR R8, =#0.1
    //MUL R6, R6, R8 // Get ticks per tenth of a second
    STR R6, [R5]

    // Sett opp knapp interupt
    // Set EXTIPSELH
    LDR R5, =0b1111
    LSL R5, R5, #4
    MVN R5, R5
    LDR R6, =GPIO_EXTIPSELH
    LDR R8, =GPIO_BASE
    ADD R6, R6, R8
    LDR R6, [R6]
    AND R5, R5, R6
    LDR R6, =BUTTON_PORT
    LSL R6, R6, #4
    ORR R5, R5, R6
    LDR R6, =GPIO_EXTIPSELH
    LDR R8, =GPIO_BASE
    ADD R6, R6, R8
    STR R5, [R6]
    // Sett EXTIFALL
    LDR R5, =GPIO_BASE
    LDR R6, =GPIO_EXTIFALL
    ADD R5, R5, R6
    LDR R6, [R5]
    LDR R8, =0b1
    LSL R8, R8, #9
    ORR R6, R6, R8
    STR R6, [R5]
    // Clear IF
    LDR R5, =GPIO_BASE
    LDR R6, =GPIO_IFC
    ADD R5, R5, R6
    LDR R6, [R5]
    LDR R8, =0b1
    LSL R8, R8, #9
    STR R8, [R5]
    // Set IEN
    LDR R5, =GPIO_BASE
    LDR R6, =GPIO_IEN
    ADD R5, R5, R6
    LDR R6, [R5]
    LDR R8, =0b1
    LSL R8, R8, #9
    ORR R6, R6, R8
    STR R6, [R5]

    //LDR R5, =GPIO_BASE
    //LDR R6, =GPIO_IFC
    //ADD R5, R5, R6
    //LDR R6, =0b1
    //LSL R6, R6, #8
    //STR R6, [R5]
    B Loop

// Keep cpu busy
Loop:
    NOP
    B Loop



// Flip R0 når knappen trykkes
.global GPIO_ODD_IRQHandler
.thumb_func
GPIO_ODD_IRQHandler:

    //Flipp av klokke
    LDR R5, =SYSTICK_BASE
    LDR R6, =SYSTICK_CTRL
    ADD R5, R5, R6
    LDR R6, [R5]
    EOR R6, R6, R7
    STR R6, [R5]

    // Clear IF
    LDR R5, =GPIO_BASE
    LDR R6, =GPIO_IFC
    ADD R5, R5, R6
    //LDR R6, [R5]
    LDR R8, =0b1
    LSL R8, R8, #9
    STR R8, [R5]

    BX LR // Go back?

// Tell dersom R0 er på
.global SysTick_Handler
.thumb_func
SysTick_Handler:
    B Inc_ten

    BX LR

Inc_ten:

    LDR R5, =tenths
    LDR R1, [R5]
    LDR R6, =1
    ADD R1, R1, R6
    STR R1, [R5]

    CMP R1, #10
    BEQ Inc_sec

    

    BX LR

Inc_sec:

    LDR R1, =#0
    LDR R5, =tenths
    STR R1, [R5]

    LDR R6, =#1
    LSL R6, R6, #LED_PIN
    STR R6, [R4]

    LDR R5, =seconds
    LDR R2, [R5]
    LDR R6, =#1
    ADD R2, R2, R6
    STR R2, [R5]

    CMP R2, 60
    BEQ Inc_min

    BX LR

Inc_min:
    LDR R2, =#0

    ADD R3, R3, #1
    LDR R5, =minutes
    STR R3, [R5]

    BX LR

debug:
    // Debug
    LDR R5, =GPIO_BASE
    LDR R6, =GPIO_IFS
    ADD R5, R5, R6
    //LDR R6, [R5]
    LDR R8, =0b1
    //LSL R8, R8, #9
    STR R8, [R5]
    // EndDebug
    BX LR


NOP // Behold denne på bunnen av fila

