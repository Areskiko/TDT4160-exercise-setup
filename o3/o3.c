#include "o3.h"
#include "gpio.h"
#include "systick.h"

typedef struct {
    volatile word CTRL;
    volatile word MODEL;
    volatile word MODEH;
    volatile word DOUT;
    volatile word DOUTSET;
    volatile word DOUTCLR;
    volatile word DOUTTGL;
    volatile word DIN;
    volatile word PINLOCKN;

} gpio_port_map_t;

typedef struct {
    volatile gpio_port_map_t ports[6];
    volatile word unused_space[10];
    volatile word EXTIPSELL;
    volatile word EXTIPSELH;
    volatile word EXTIRISE;
    volatile word EXTIFALL;
    volatile word IEN;
    volatile word IF;
    volatile word IFS;
    volatile word IFC;
    volatile word ROUTE;
    volatile word INSENSE;
    volatile word LOCK;
    volatile word CTRL;
    volatile word CMD;
    volatile word EM4WUEN;
    volatile word EM4WUPOL;
    volatile word EM4WUCAUSE;

} gpio_map_t;

typedef struct {
    volatile word CTRL;
    volatile word LOAD;
    volatile word VAL;
    volatile word CALIB;

} systic_map_t;

int stage;
int seconds;
int minutes;
int hours;
char* timestamp;

// Setup port-pins
port_pin_t b0 = {GPIO_PORT_B, 9};
port_pin_t b1 = {GPIO_PORT_B, 10};
port_pin_t led = {GPIO_PORT_E, 2};

// Create maps
gpio_map_t* memory_map = (gpio_map_t*) GPIO_BASE;
systic_map_t* systic_map = (systic_map_t*) SYSTICK_BASE;

/**************************************************************************//**
 * @brief Konverterer nummer til string 
 * Konverterer et nummer mellom 0 og 99 til string
 *****************************************************************************/
void int_to_string(char *timestamp, unsigned int offset, int i) {
    if (i > 99) {
        timestamp[offset]   = '9';
        timestamp[offset+1] = '9';
        return;
    }

    while (i > 0) {
	    if (i >= 10) {
		    i -= 10;
		    timestamp[offset]++;
		
	    } else {
		    timestamp[offset+1] = '0' + i;
		    i=0;
	    }
    }
}

/**************************************************************************//**
 * @brief Konverterer 3 tall til en timestamp-string
 * timestamp-argumentet må være et array med plass til (minst) 7 elementer.
 * Det kan deklareres i funksjonen som kaller som "char timestamp[7];"
 * Kallet blir dermed:
 * char timestamp[7];
 * time_to_string(timestamp, h, m, s);
 *****************************************************************************/
void time_to_string(char *timestamp, int h, int m, int s) {
    timestamp[0] = '0';
    timestamp[1] = '0';
    timestamp[2] = '0';
    timestamp[3] = '0';
    timestamp[4] = '0';
    timestamp[5] = '0';
    timestamp[6] = '\0';

    int_to_string(timestamp, 0, h);
    int_to_string(timestamp, 2, m);
    int_to_string(timestamp, 4, s);
}

void flip_light(int yes) {
    if (yes) {
        memory_map->ports[led.port].DOUTSET = 0b100;
    } else {
        memory_map->ports[led.port].DOUTCLR = 0b100; 
    }
}


void GPIO_ODD_IRQHandler(void) {
    if (stage == 0) {
        seconds++;
    } else if (stage == 1)
    {
        minutes++;
    } else if (stage == 2)
    {
        hours++;
    }
    
    
    time_to_string(timestamp, hours, minutes, seconds);
    lcd_write(timestamp);

    memory_map->IFC = (0b1 << b0.pin);
}

void GPIO_EVEN_IRQHandler(void) {
    if (stage < 4) {
        stage++;
    } else if (stage == 4) {
        flip_light(0);
        stage = 0;
    }
    if (stage == 3) {
        systic_map->CTRL = 0b0111;
    }
    memory_map->IFC = (0b1 << b1.pin);
}

void SysTick_Handler(void) {
    seconds--;
    if (seconds == 0) {
        flip_light(1);
        seconds = 59;
        minutes--;
        if (minutes == 0) {
            minutes = 59;
            hours--;
        }
    }
    if (seconds <= 0 && minutes <= 0 && hours <= 0) {
        flip_light(1);
        stage = 4;
        systic_map->CTRL = 0b0110;
    } 
}


int main(void) {
    init();

    // Set up clock like in o2
    //byte msk = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_TICKINT_Msk;
    systic_map->CTRL = 0b0110;
    systic_map->LOAD = FREQUENCY; // Interupt every second

    // Setup GPIO pins
    memory_map->ports[b0.port].DOUT = 0b00 << b0.pin;
    memory_map->ports[b0.port].MODEH = (0b0001 << 4) | (0b0001 << 8);
//    memory_map->ports[b0.port].MODEH = ((~(0b11111111 << 4)) & memory_map->ports[b0.port].MODEH ) | ((GPIO_MODE_INPUT << 4) | GPIO_MODE_INPUT);
    
    memory_map->ports[led.port].DOUT = 0b0 << led.pin;
    memory_map->ports[led.port].MODEL = (0b0100 << 8);
    //memory_map->ports[led.port].MODEL = ((~(0b1111 << 4*led.pin)) & memory_map->ports[led.port].MODEL) | ((GPIO_MODE_OUTPUT << 4*led.pin));

    memory_map->EXTIPSELH = (0b0001 << 4) | (0b0001 << 8);
    //memory_map->EXTIPSELH = (0b1111 << 4 & memory_map->EXTIPSELH) | b0.port << 4;
    //memory_map->EXTIPSELH = (0b1111 << 8 & memory_map->EXTIPSELH) | b1.port << 8;

    memory_map->EXTIFALL = (0b1 << b0.pin | memory_map->EXTIFALL);
    memory_map->EXTIFALL = (0b1 << b1.pin | memory_map->EXTIFALL);
    
    memory_map->IFC = (0b1 << b0.pin);
    memory_map->IFC = (0b1 << b1.pin);

    memory_map->IEN = (0b1 << b0.pin | memory_map->IEN);
    memory_map->IEN = (0b1 << b1.pin | memory_map->IEN);

    while (true) {
        // NOP
    }
    
    return 0;
}

