#ifndef _COMPLEX_H_
#define _COMPLEX_H_

#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

typedef struct {
    
    uint32_t r;
    uint32_t i;
    
} complex_32_t;

uint8_t cmp_complex( complex_32_t, complex_32_t );

complex_32_t complex_from_float_9q23( float, float );

#endif