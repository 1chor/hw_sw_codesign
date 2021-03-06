
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

// For FIFO commands
#include "altera_avalon_fifo_util.h"

#include "defines.h"

#if ( FIR_HW )

void fir_filter_setup_hw( struct wav* ir, uint16_t channel )
{
	uint16_t i = 0;
			
	switch ( channel )
	{
		case 0: // left channel
			for ( i = 0; i < FIR_SIZE; i++ )
			{
				// Set Coefficients
				IOWR( FIR_L_BASE, i, (int32_t)wav_get_int16( ir, 2*i ) );
			}
			
			for ( i = 0; i < FIR_SIZE; i++ )
			{	
				// init Input FIFOs 
				IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FIR_L_BASE, (int32_t)0x00000000 );
				
				// init Output FIFOs 
				(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FIR_L_BASE );
			}
			break;
			
		case 1: // right channel
			for ( i = 0; i < FIR_SIZE; i++ )
			{
				// Set Coefficients
				IOWR( FIR_R_BASE, i, (int32_t)wav_get_int16( ir, 2*i+1 ) );
			}
			
			for ( i = 0; i < FIR_SIZE; i++ )
			{	
				// init Input FIFOs
				IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FIR_R_BASE, (int32_t)0x00000000 );
				
				// init Output FIFOs 
				(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FIR_R_BASE );
			}
			break;
			
		default: printf("Channel Index error\n"); exit(1);
	}
}

#else

void fir_filter_setup_sw( uint16_t* fir_h_1, uint16_t* fir_h_2, struct wav* ir )
{
    uint16_t l_buf;
    uint16_t r_buf;
    
    uint16_t i = 0;
    
    // collect ir samples
    
    for ( i = 0; i < FIR_SIZE; i++ )
    {
        l_buf = wav_get_uint16( ir, 2*i );
        r_buf = wav_get_uint16( ir, 2*i+1 );
        
        fir_h_1[i] = l_buf;
        fir_h_2[i] = r_buf;
    }
}

#endif

#if ( FIR_HW )

void fir_filter_sample_hw
(
     int32_t* sample_result_1
    ,int32_t* sample_result_2
    ,uint16_t new_sample_1
    ,uint16_t new_sample_2
)
{     
    int16_t sample_1 = (int16_t)new_sample_1;
    int16_t sample_2 = (int16_t)new_sample_2;
    
    // left channel
    
    // Write sample to FIFO
    IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FIR_L_BASE, (int32_t)sample_1 );
    
    // Read result from FIFO
    *sample_result_1 = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FIR_L_BASE );
    //~ *sample_result_1 = IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FIR_L_BASE );
    
    // right channel
    
    // Write sample to FIFO
    IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FIR_R_BASE, (int32_t)sample_2 );
    
    // Read result from FIFO
    *sample_result_2 = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FIR_R_BASE );
}

#else

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
    
    for ( kk = 0; kk < FIR_SIZE; kk++ )
    {
        // fixed point version
        
        // left channel
        
        hh = (int16_t)h_samples_1[kk];
        ii = (int16_t)i_samples_1[FIR_SIZE-1-kk];
        
        temp_32 = ( (int32_t)hh * (int32_t)ii );
        temp_result_1 += temp_32;
        
        // right channel
        
        hh = (int16_t)h_samples_2[kk];
        ii = (int16_t)i_samples_2[FIR_SIZE-1-kk];
        
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

#endif