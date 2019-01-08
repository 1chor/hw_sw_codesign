
#ifndef __FFT_H__
#define __FFT_H__

#include <stdint.h>
#include "structs.h"

void fft_h_setup_hw(  );
void fft_b_setup_hw(  );

// damit werden die FFTs ausgefuehrt

void pre_process_h_header( struct wav* );

void fft_h_sample_hw
(
    
);

void fft_b_sample_hw
(
     
);

#endif


