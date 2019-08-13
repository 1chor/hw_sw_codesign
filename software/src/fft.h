
#ifndef __FFT_H__
#define __FFT_H__

#include <stdint.h>
#include "structs.h"
#include "complex.h"
#include "defines.h"

void fft_h_setup_hw();
void fft_b_setup_hw();

// damit werden die FFTs ausgefuehrt

void pre_process_h_header_hw( struct wav* );
void pre_process_h_body_hw( uint32_t*, struct wav* );

void process_header_block_hw
( 
	 int32_t*
	,int32_t*
	,uint8_t
	,uint8_t 
);
void process_body_block_hw
( 
	uint32_t* sdramm 
	,int32_t*
	,int32_t* 
	,uint8_t block 
	,uint8_t free_input 
);

void ifft_header_hw
( 
	 int32_t* 
	,int32_t* 
	,complex_i32_t* 
	,complex_i32_t*  
);
void ifft_body_hw
( 
	int32_t* 
	,int32_t* 
	,complex_i32_t* 
	,complex_i32_t*
);

void zero_extend_256_hw( int32_t* );
void zero_extend_4096_hw( int32_t* );

void test_header_fft( int32_t*, int32_t* );
void test_body_fft( int32_t*, int32_t* );

#endif


