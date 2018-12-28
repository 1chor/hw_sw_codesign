#ifndef _SRAM_H_
#define _SRAM_H_

#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

// TODO - move struct in a seperate file

typedef struct {
    
    uint32_t r;
    uint32_t i;
    
} complex_32_t;

void         sram_write( complex_32_t, uint32_t );
complex_32_t sram_read( uint32_t );

void         sram_write_block( complex_32_t*, uint32_t );

uint8_t      sram_test();

#endif
