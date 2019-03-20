
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

// #include "kiss_fft.h"
// #include "fft_fp.h"
#include "fft.h"

#include "fixed_point.h"
#include "sram.h"
#include "complex.h"

// For FIFO commands
#include "altera_avalon_fifo_util.h"

// For PIO commands
#include "altera_avalon_pio_regs.h"

void fft_h_setup_hw()
{
	uint16_t i = 0;
	
	// Clear Bit 0 from PIO, configures normal FFT operation
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS( PIO_0_BASE, 0 );
	
	for ( i = 0; i < 512; i++ )
	{
		// init Input FIFOs 
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)0 );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)0 );
	}
	
	for ( i = 0; i < 512; i++ )
	{
		// init Output FIFOs 
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	}
}

void fft_b_setup_hw()
{
	// uint16_t i = 0;
	
	// Clear Bit 1 from PIO, configures normal FFT operation
	// IOWR_ALTERA_AVALON_PIO_CLEAR_BITS( PIO_0_BASE, 1);
		
	// for ( i = 0; i < 512; i++ )
	// {	
		// init Input FIFOs 
		//ToDo: Adresse überprüfen!!
		// IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)0x00000000 );
		
		// init Output FIFOs 
		//ToDo: Adresse überprüfen!!
		// (void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	// }
}

void pre_process_h_header_hw( struct wav* ir )
{
	int32_t l_buf;
    int32_t r_buf;
    
    uint16_t i = 0;
    
    uint8_t header_blocks_h_i = 0;
    
    for ( header_blocks_h_i = 0; header_blocks_h_i < 14; header_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", header_blocks_h_i, 14+header_blocks_h_i );
        
        complex_i32_t* cin_1 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
        complex_i32_t* cin_2 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = 512 + ( header_blocks_h_i * 256 );
        
        // wir nehmen nur 256 da das ja zero extended sein soll.
        
        for ( i = 0; i < 256; i++ )
        {
            l_buf = (int32_t)wav_get_int16( ir, 2*sample_counter_ir   );
            r_buf = (int32_t)wav_get_int16( ir, 2*sample_counter_ir+1 );
            
			cin_1[i].r = l_buf;
            
			cin_2[i].r = r_buf;
            
            sample_counter_ir += 1;
            
            //printf( "l_buf[%d]: %lx\n", i, l_buf );
            //printf( "r_buf[%d]: %lx\n", i, r_buf );
        }
        
        // cin_X will be freed in func
        
        //if ( header_blocks_h_i == 0 )
	//		test_fft( cin_1, cin_2 );
                
        process_header_block_hw( cin_1, cin_2, header_blocks_h_i, 1 );
    }
}

void process_header_block_hw( complex_i32_t* in_1, complex_i32_t* in_2, uint8_t block, uint8_t free_input )
{
    uint16_t i = 0;
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
    
    zero_extend_256_hw( in_1 );
    zero_extend_256_hw( in_2 );
	
	// Clear Bit 0 from PIO, configures normal FFT operation
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS( PIO_0_BASE, 0 );
       
    //~ printf("Write sample to FIFO\n");
    
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// Both channels are calculated at the same time
		// First transmission is real data from left channel
		// Second transmission is real data from right channel
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i].r );
		//~ printf( "l_buf[%d]: %lx\n", i, in_1[i].r  );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i].r );
		
		printf( "r_buf[%d]: %lx\n", i, in_2[i].r  );
	}
	
	printf( "done\n" );
	//~ printf( "Read result from FIFO\n" );
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// First transmission is transformed real data from left channel
		// Second transmission is transformed imaginary data from right channel
		//printf( "%d\n", i );
		out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
		out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
		
		printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
		//~ printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
	}
    
    //~ printf( "done\n" );
    //~ printf( "Get back both transformed channels\n" );
    
	// Get back both transformed channels
	for ( i = 1; i < 512/2; i++ )
	{
		// imaginary parts of X[f] and X[-f]
		out_1[i].i = ( out_2[i].r - out_2[512-i].r ) >> 1;
		out_1[512-i].i = - out_1[i].i;
		
		// imaginary parts of Y[f] and Y[-f]
		out_2[i].i = - ( ( out_1[i].r - out_1[512-i].r ) >> 1 );
		out_2[512-i].i = - out_2[i].i;
		
		// real parts of X[f] and X[-f]
		out_1[i].r = ( out_1[i].r + out_1[512-i].r ) >> 1;
		out_1[512-i].r = out_1[i].r;
		
		// real parts of Y[f] and Y[-f]
		out_2[i].r = ( out_2[i].r + out_2[512-i].r ) >> 1;
		out_2[512-i].r = out_2[i].r;
	}
	
	//~ printf("done\n");
		
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
        
	// ToDo: Alloc für samples kann man löschen
	// Cast direkt im sram.c
    complex_32_t* samples_1 = (complex_32_t*)calloc( 512, sizeof(complex_32_t) );
    complex_32_t* samples_2 = (complex_32_t*)calloc( 512, sizeof(complex_32_t) );
    
    for ( i = 0; i < 512; i++ )
    {
		samples_1[i].r = (uint32_t)out_1[i].r;
		samples_1[i].i = (uint32_t)out_1[i].i;
		
		samples_2[i].r = (uint32_t)out_2[i].r;
		samples_2[i].i = (uint32_t)out_2[i].i;
    }
    
    free( out_1 );
    free( out_2 );
    
    // der block wird gespeichert
    // TODO - in der finalen version wird das gemacht waehrend
    // die MAC im freq bereich laeuft. vll sollte das hier auch
    // schon irgendwie dargestellt werden.
    
    printf( "writing block to %i | %i\n", block, 14 + block );
    
    (void) sram_write_block( samples_1, block );
    (void) sram_write_block( samples_2, 14 + block );
    
    free( samples_1 );
    free( samples_2 );
}

void ifft_on_mac_buffer_hw( int32_t* mac_buffer_16_1, int32_t* mac_buffer_16_2, complex_32_t* mac_buffer_1, complex_32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
	// Set Bit 0 from PIO, configures inverse FFT operation
	IOWR_ALTERA_AVALON_PIO_SET_BITS( PIO_0_BASE, 0 );
        
	// left channel
	
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// First transmission is real data 
		// Second transmission is imaginary data
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_1[i].r );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_1[i].i );
	}
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// Transmission is real data 
		mac_buffer_16_1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	}
	
	// right channel
	
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// First transmission is real data 
		// Second transmission is imaginary data
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_2[i].r );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_2[i].i );
	}
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// Transmission is real data 
		mac_buffer_16_2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	}
    	
    free( mac_buffer_1 );
    free( mac_buffer_2 );
}

void zero_extend_256_hw( complex_i32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = 256; i < 512; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

void test_fft( complex_i32_t* in_1, complex_i32_t* in_2 )
{
	uint16_t i = 0;
	int32_t* res1 = (int32_t*)calloc( 512, sizeof(int32_t) );
	int32_t* res2 = (int32_t*)calloc( 512, sizeof(int32_t) );
	
	// FFT-Operation
	printf( "FFT-Operation\n" );
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( 512, sizeof(complex_i32_t) );
    
    zero_extend_256_hw( in_1 );
    zero_extend_256_hw( in_2 );
	
	// Clear Bit 0 from PIO, configures normal FFT operation
	IOWR_ALTERA_AVALON_PIO_CLEAR_BITS( PIO_0_BASE, 0 );
       
    printf( "Write sample to FIFO\n" );
    
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// Both channels are calculated at the same time
		// First transmission is real data from left channel
		// Second transmission is real data from right channel
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i].r );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i].r );
	}
	
	printf( "done\n" );
	printf( "Read result from FIFO\n" );
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// First transmission is transformed real data from left channel
		// Second transmission is transformed imaginary data from right channel
		out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
		out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
		
		//~ printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
		//~ printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
	}
    
    printf( "done\n" );
    
    printf( "Get back both transformed channels\n" );
    out_1[0].i = 0;
    out_1[512/2].i = 0;
    out_2[0].i = 0;
    out_2[512/2].i = 0;
    
	// Get back both transformed channels
	for ( i = 1; i < 512/2; i++ )
	{
		// imaginary parts of X[f] and X[-f]
		out_1[i].i = ( out_2[i].r - out_2[512-i].r ) >> 1;
		out_1[512-i].i = - out_1[i].i;
		
		// imaginary parts of Y[f] and Y[-f]
		out_2[i].i = - ( ( out_1[i].r - out_1[512-i].r ) >> 1 );
		out_2[512-i].i = - out_2[i].i;
		
		// real parts of X[f] and X[-f]
		out_1[i].r = ( out_1[i].r + out_1[512-i].r ) >> 1;
		out_1[512-i].r = out_1[i].r;
		
		// real parts of Y[f] and Y[-f]
		out_2[i].r = ( out_2[i].r + out_2[512-i].r ) >> 1;
		out_2[512-i].r = out_2[i].r;
	}
	
	printf( "done\n" );
	
	//~ printf( "Check FFT Results - Left Channel:\n" );
    //~ printf( "i\t|\tREAL\t\t|\tIMAG\n" );
    //~ for ( i = 0; i < 512; i++ )
	//~ { 
		//~ printf( "%d\t|\t%lx\t|\t%lx\n", i, out_1[i].r, out_1[i].i );
		//~ printf( "%d\t|\t%f\t|\t%f\n", i, convert_1q15(out_1[i].r), convert_1q15(out_1[i].i) );
    //~ }
		
	// IFFT-Operation
	printf( "IFFT-Operation\n" );
        
	// Set Bit 0 from PIO, configures inverse FFT operation
	IOWR_ALTERA_AVALON_PIO_SET_BITS( PIO_0_BASE, 0 );
        
	// left channel
	
	printf("Write sample to FIFO\n");
	
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// First transmission is real data 
		// Second transmission is imaginary data
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_1[i].r );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_1[i].i );
	}
	
	printf( "done\n" );
	printf( "Read result from FIFO\n" );
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// Transmission is real data 
		res1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	}
	
	printf( "done\n" );
	
	// right channel
	
	printf("Write sample to FIFO\n");
	
	for ( i = 0; i < 512; i++ )
	{
		// Write sample to FIFO
		// First transmission is real data 
		// Second transmission is imaginary data
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_2[i].r );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_2[i].i );
	}
	
	printf("done\n");
	printf("Read result from FIFO\n");
	
	for ( i = 0; i < 512; i++ )
	{
		// Read result from FIFO
		// Transmission is real data 
		res2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	}
        
    printf( "done\n" );
    
    free( out_1 );
    free( out_2 );
    
    printf( "Check Results - Left Channel:\n" );
    printf( "i\t|\tSOLL\t|\tIST\n" );
    for ( i = 0; i < 512; i++ )
	{ 
		printf( "%d\t|\t%lx\t|\t%lx\n", i, in_1[i].r, res1[i] );
    }
    
    printf( "\n\n" );
    printf( "Check Results - Right Channel:\n" );
    printf( "i\t|\tSOLL\t|\tIST\n" );
    for ( i = 0; i < 512; i++ )
	{ 
		printf( "%d\t|\t%lx\t|\t%lx\n", i, in_2[i].r, res2[i] );
    }
    printf( "\n\n" );
    
    free( res1 );
    free( res2 );
}
