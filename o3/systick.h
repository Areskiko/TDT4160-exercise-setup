#ifndef SYSTICK_H
#define SYSTICK_H

// Sys-Tick adresse
#define SYSTICK_BASE 0xE000E010

// Antall klokkesignaler per sekund
#define FREQUENCY 14000000 

// CTRL-register-masker
#define SysTick_CTRL_CLKSOURCE_Msk  0b100
#define SysTick_CTRL_TICKINT_Msk    0b010
#define SysTick_CTRL_ENABLE_Msk     0b001

// Egenlagde Sys-Tick offsets
#define SysTick_CTRL   0
#define SysTick_LOAD   4
#define SysTick_VAL    8
#define SysTick_CALIB 12


#endif
