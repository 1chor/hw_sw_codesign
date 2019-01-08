
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

void pre_process_h_header_hw( struct wav* ir )
{
	uint16_t l_buf;
    uint16_t r_buf;
    
    uint16_t i = 0;
    
    uint8_t header_blocks_h_i = 0;
    
    for ( header_blocks_h_i = 0; header_blocks_h_i < 14; header_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", header_blocks_h_i, 14+header_blocks_h_i );
        
        kiss_fft_cpx* cin_1 = (kiss_fft_cpx*)malloc( 512 * sizeof(kiss_fft_cpx) );
        kiss_fft_cpx* cin_2 = (kiss_fft_cpx*)malloc( 512 * sizeof(kiss_fft_cpx) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = 512 + ( header_blocks_h_i * 256 );
        
        // wir nehmen nur 256 da das ja zero extended sein soll.
        
        for ( i = 0; i < 256; i++ )
        {
            l_buf = wav_get_uint16( ir, 2*sample_counter_ir );
            r_buf = wav_get_uint16( ir, 2*sample_counter_ir+1 );
            
            // convert the binary value to float
            
            cin_1[i].r = convert_1q15(l_buf);
            cin_1[i].i = 0;
            
            cin_2[i].r = convert_1q15(r_buf);
            cin_2[i].i = 0;
            
            sample_counter_ir += 1;
        }
        
        // cin_X will be freed in func
        
        process_header_block( cin_1, cin_2, header_blocks_h_i, 1 );
    }
}

void fft_h_sample_hw
(
    
)
{
	
}

void fft_b_sample_hw
(
     
)
{
	
}