
#ifndef __FFT_H__
#define __FFT_H__

#include <stdint.h>
#include "structs.h"
#include "complex.h"

void fft_h_setup_hw();
void fft_b_setup_hw();

// damit werden die FFTs ausgefuehrt

void pre_process_h_header_hw( struct wav* );

void process_header_block_hw
( 
	 complex_i32_t*
	,complex_i32_t*
	,uint8_t
	,uint8_t 
);

void ifft_on_mac_buffer_hw
( 
	 int32_t* 
	,int32_t* 
	,complex_i32_t* 
	,complex_i32_t*  
);

void zero_extend_256_hw( complex_i32_t* );

void test_fft( complex_i32_t*, complex_i32_t* );

#endif


