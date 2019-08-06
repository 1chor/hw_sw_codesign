#ifndef _BODY_H_
#define _BODY_H_

#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "complex.h"

#include "fir.h"
#include "fft_header.h"

#include "kiss_fft.h"
#include "fft_fp.h"

#include "fixed_point.h"
#include "sram.h"
#include "sdram.h"
#include "complex.h"

void pre_process_h_body( uint32_t*, struct wav* );
void process_body_block( uint32_t*, kiss_fft_cpx*, kiss_fft_cpx*, uint8_t, uint8_t );
void mac_body( uint32_t*, complex_32_t*, uint32_t, uint32_t );
void ifft_body( uint16_t*, uint16_t*, complex_32_t*, complex_32_t* );
void zero_extend_4096( kiss_fft_cpx* );

#endif
