
#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "wav.h"

#include "fixed_point.h"

void fir_filter_setup_sw( uint16_t* fir_h_1, uint16_t* fir_h_2, struct wav* ir )
{
    uint16_t l_buf;
    uint16_t r_buf;
    
    uint16_t i = 0;
    
    // collect ir samples
    
    for ( i = 0; i < 512; i++ )
    {
        l_buf = wav_get_uint16( ir, 2*i );
        r_buf = wav_get_uint16( ir, 2*i+1 );
        
        fir_h_1[i] = l_buf;
        fir_h_2[i] = r_buf;
    }
}

void fir_filter_sample_sw
(
     int32_t* sample_result_1
    ,int32_t* sample_result_2
    ,uint16_t* i_samples_1
    ,uint16_t* i_samples_2
    ,uint16_t* h_samples_1
    ,uint16_t* h_samples_2
)
{
    int16_t kk = 0;
    
    int16_t hh = 0;
    int16_t ii = 0;
    
    int32_t temp_32 = 0;
    
    int32_t temp_result_1 = 0;
    int32_t temp_result_2 = 0;
    
    for ( kk = 0; kk < 512; kk++ )
    {
        // fixed point version
        
        // left channel
        
        hh = (int16_t)h_samples_1[kk];
        ii = (int16_t)i_samples_1[511-kk];
        
        temp_32 = ( (int32_t)hh * (int32_t)ii );
        temp_result_1 += temp_32;
        
        // right channel
        
        hh = (int16_t)h_samples_2[kk];
        ii = (int16_t)i_samples_2[511-kk];
        
        temp_32 = ( (int32_t)hh * (int32_t)ii );
        temp_result_2 += temp_32;
        
        // float version
        
        //~ float h = (float)convert_1q15( fir_h_1[kk] );
        //~ float f = (float)convert_1q15( fir_i_1[n-kk] );
        
        //~ fir_output[n] += h * f;
    }
    
    *sample_result_1 = temp_result_1;
    *sample_result_2 = temp_result_2;
}
