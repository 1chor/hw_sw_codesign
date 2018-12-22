#ifndef _FIXED_POINT_H_
#define _FIXED_POINT_H_

#include <inttypes.h>

// read from wav file

float convert_1q15( uint16_t );

// returned from kiss_fft

float convert_9q23( uint32_t );

#endif
