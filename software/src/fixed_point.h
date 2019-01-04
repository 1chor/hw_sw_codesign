#ifndef _FIXED_POINT_H_
#define _FIXED_POINT_H_

#include <inttypes.h>

// read from wav file

float convert_1q15( uint16_t );
uint16_t convert_to_fixed_1q15( float );

// returned from kiss_fft

float convert_9q23( uint32_t );
void convert_9q23_pointer( float*, uint32_t );
uint32_t convert_to_fixed_9q23( float );

// used in fit

void convert_2q30_pointer( float*, uint32_t );

#endif
