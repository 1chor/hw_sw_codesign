
#ifndef __FFT_H__
#define __FFT_H__

#include <stdint.h>
#include "structs.h"

void fft_cfp(complex_float_t *f, int16_t m, int16_t inverse);

#endif


