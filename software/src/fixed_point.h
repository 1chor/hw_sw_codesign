#ifndef _FIXED_POINT_H_
#define _FIXED_POINT_H_

#include <inttypes.h>

float convert_1q15( uint16_t );

void print_1q15( uint16_t );
void print_9q23( uint32_t );

#endif
