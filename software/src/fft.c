
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
#include "sdram.h"
#include "complex.h"
#include "defines.h"

// For FIFO commands
#include "altera_avalon_fifo_util.h"

// For PIO commands
#include "altera_avalon_pio_regs.h"

// ---------------------------------------------------------
// FFT setup
// ---------------------------------------------------------

#if ( FFT_H_HW )

void fft_h_setup_hw()
{
    uint16_t i = 0;
        
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// init Input FIFOs 
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)0 );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)0 );
    }
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// init Output FIFOs 
	(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
    }
}

#endif

#if ( FFT_B_HW )

void fft_b_setup_hw()
{
	uint16_t i = 0;
			
	for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
	{	
		// init Input FIFOs 
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)0 );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)0 );
	}

	for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
	{	
		// init Output FIFOs 
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	}
}

#endif

// ---------------------------------------------------------
// pre-processing blocks (H)
// ---------------------------------------------------------

#if ( FFT_H_HW )

void pre_process_h_header_hw( struct wav* ir )
{    
    uint16_t i = 0;
    
    uint8_t header_blocks_h_i = 0;
    
    for ( header_blocks_h_i = 0; header_blocks_h_i < HEADER_BLOCK_NUM; header_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", header_blocks_h_i, HEADER_BLOCK_NUM + header_blocks_h_i );
        
        int32_t* cin_1 = (int32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(int32_t) );
        int32_t* cin_2 = (int32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(int32_t) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = FIR_SIZE + ( header_blocks_h_i * HEADER_BLOCK_SIZE );
        
        // wir nehmen nur 256 da das ja zero extended sein soll.
        
        for ( i = 0; i < HEADER_BLOCK_SIZE; i++ )
        {
            cin_1[i] = (int32_t)wav_get_int16( ir, 2*sample_counter_ir   );
            cin_2[i] = (int32_t)wav_get_int16( ir, 2*sample_counter_ir+1 );
                        
            sample_counter_ir += 1;
            
            //printf( "cin_1[%d]: %lx\n", i, cin_1[i] );
            //printf( "cin_2[%d]: %lx\n", i, cin_2[i] );
        }
        
	// cin_X will be freed in func
      
//      if ( header_blocks_h_i == 0 )
// 	    test_header_fft( cin_1, cin_2 );
                
        process_header_block_hw( cin_1, cin_2, header_blocks_h_i, FREE_INPUT );
    }
}


#endif

#if ( FFT_B_HW )

void pre_process_h_body_hw( uint32_t* sdramm, struct wav* ir )
{    
    uint32_t i = 0;
    
    uint16_t body_blocks_h_i = 0;
    
    for ( body_blocks_h_i = 0; body_blocks_h_i < BODY_BLOCK_NUM; body_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", body_blocks_h_i, BODY_BLOCK_NUM + body_blocks_h_i );
        
        int32_t* cin_1 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
	if (cin_1 == NULL) 
	    printf( "error calloc\n");
	
	printf( "calloc 1\n");
        int32_t* cin_2 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
//         printf( "calloc 2\n");
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = FIR_SIZE + ( HEADER_BLOCK_NUM * HEADER_BLOCK_SIZE ) + ( body_blocks_h_i * BODY_BLOCK_SIZE );
        
        // wir nehmen nur 4096 da das ja zero extended sein soll.
//         printf( "read\n");
        for ( i = 0; i < BODY_BLOCK_SIZE; i++ )
        {
            cin_1[i] = (int32_t)wav_get_int16( ir, 2*sample_counter_ir   );
            cin_2[i] = (int32_t)wav_get_int16( ir, 2*sample_counter_ir+1 );
                        
            sample_counter_ir += 1;
            	
            //printf( "cin_1[%d]: %lx\n", i, cin_1[i] );
            //printf( "cin_2[%d]: %lx\n", i, cin_2[i] );
        }
        
        // cin_X will be freed in func
        
// 	if ( body_blocks_h_i == 0 )
// 	    test_body_fft( cin_1, cin_2 );
                
        process_body_block_hw( sdramm, cin_1, cin_2, body_blocks_h_i, FREE_INPUT );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
    }
}

#endif

// ---------------------------------------------------------
// FFT operation
// ---------------------------------------------------------

#if ( FFT_H_HW )

void process_header_block_hw( int32_t* in_1, int32_t* in_2, uint8_t block, uint8_t free_input )
{
    printf( "enter process_header_block_hw func\n" );
    
    // Nach der FFT haben die Werte ein 17Q15 Format!!
  
    uint16_t i = 0;
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    
    zero_extend_256_hw( in_1 );
    zero_extend_256_hw( in_2 );
    
    // Clear Bit 0 from PIO, configures normal FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_H_BASE, 0 );
     
    printf("performing header fft\n"); // printf is needed for delay operation
    
    // printf("Write sample to FIFO\n");
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// Both channels are calculated at the same time
	// First transmission is real data from left channel
	// Second transmission is real data from right channel
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i] );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	// printf( "l_buf[%d]: %lx\n", i, in_1[i]  );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i] );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	// printf( "r_buf[%d]: %lx\n", i, in_2[i]  );
    }
    
    // printf( "done\n" );
    // printf( "Read result from FIFO\n" );
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// First transmission is transformed real data from left channel
	// Second transmission is transformed imaginary data from right channel
	// printf( "%d\n", i );
	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	// printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
	// printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
    }
    
    // printf( "done\n" );
    printf( "Get back both transformed channels\n" );
    
    // Get back both transformed channels
    for ( i = 1; i < HEADER_BLOCK_SIZE_ZE/2; i++ )
    {
	// imaginary parts of X[f] and X[-f]
	out_1[i].i = ( out_2[i].r - out_2[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_1[HEADER_BLOCK_SIZE_ZE-i].i = - out_1[i].i;
	
	// imaginary parts of Y[f] and Y[-f]
	out_2[i].i = - ( ( out_1[i].r - out_1[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1 );
	out_2[HEADER_BLOCK_SIZE_ZE-i].i = - out_2[i].i;
	
	// real parts of X[f] and X[-f]
	out_1[i].r = ( out_1[i].r + out_1[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_1[HEADER_BLOCK_SIZE_ZE-i].r = out_1[i].r;
	
	// real parts of Y[f] and Y[-f]
	out_2[i].r = ( out_2[i].r + out_2[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_2[HEADER_BLOCK_SIZE_ZE-i].r = out_2[i].r;
    }
    
    // printf("done\n");
	    
    // der block wird gespeichert
    // TODO - in der finalen version wird das gemacht waehrend
    // die MAC im freq bereich laeuft. vll sollte das hier auch
    // schon irgendwie dargestellt werden.
    
    printf( "writing block to %i | %i\n", block, HEADER_BLOCK_NUM + block );
    
    (void) sram_write_block( out_1, block );
    (void) sram_write_block( out_2, HEADER_BLOCK_NUM + block );
         
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
    
    free( out_1 );
    free( out_2 );
}

#endif

#if ( FFT_B_HW )

void process_body_block_hw( uint32_t* sdramm, int32_t* in_1, int32_t* in_2, uint8_t block, uint8_t free_input )
{
    printf( "enter process_body_block_hw func\n" );
    
    // Nach der FFT haben die Werte ein 17Q15 Format!!
  
    uint32_t i = 0;
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    
    zero_extend_4096_hw( in_1 );
    zero_extend_4096_hw( in_2 );
    
    // Clear Bit 0 from PIO, configures normal FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_B_BASE, 0 );
     
    printf("performing body fft\n"); // printf is needed for delay operation
    
    // printf("Write sample to FIFO\n");
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// Both channels are calculated at the same time
	// First transmission is real data from left channel
	// Second transmission is real data from right channel
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_1[i] );
// 	printf( "l_buf[%d]: %lx\n", i, in_1[i]  );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_2[i] );
	// printf( "r_buf[%d]: %lx\n", i, in_2[i]  );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
    }
    
    // printf( "done\n" );
    // printf( "Read result from FIFO\n" );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// First transmission is transformed real data from left channel
	// Second transmission is transformed imaginary data from right channel
	// printf( "%d\n", i );
	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	
	// printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
 	// printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
    }
    
    // printf( "done\n" );
    // printf( "Get back both transformed channels\n" );
    
    // Get back both transformed channels
    for ( i = 1; i < BODY_BLOCK_SIZE_ZE/2; i++ )
    {
	// imaginary parts of X[f] and X[-f]
	out_1[i].i = ( out_2[i].r - out_2[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_1[BODY_BLOCK_SIZE_ZE-i].i = - out_1[i].i;
	
	// imaginary parts of Y[f] and Y[-f]
	out_2[i].i = - ( ( out_1[i].r - out_1[BODY_BLOCK_SIZE_ZE-i].r ) >> 1 );
	out_2[BODY_BLOCK_SIZE_ZE-i].i = - out_2[i].i;
	
	// real parts of X[f] and X[-f]
	out_1[i].r = ( out_1[i].r + out_1[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_1[BODY_BLOCK_SIZE_ZE-i].r = out_1[i].r;
	
	// real parts of Y[f] and Y[-f]
	out_2[i].r = ( out_2[i].r + out_2[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
	out_2[BODY_BLOCK_SIZE_ZE-i].r = out_2[i].r;
    }
    
    // printf("done\n");
	    
    // der block wird gespeichert
    // TODO - in der finalen version wird das gemacht waehrend
    // die MAC im freq bereich laeuft. vll sollte das hier auch
    // schon irgendwie dargestellt werden.
    
    printf( "writing block to %i | %i\n", block, BODY_BLOCK_NUM + block );
    
    (void) sdram_write_block( sdramm, out_1, block );
    (void) sdram_write_block( sdramm, out_2, BODY_BLOCK_NUM + block );
   
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
    
    free( out_1 );
    free( out_2 );
}

#endif

// ---------------------------------------------------------
// IFFT operation
// ---------------------------------------------------------

#if ( FFT_H_HW )

void ifft_header_hw( int32_t* mac_buffer_16_1, int32_t* mac_buffer_16_2, complex_i32_t* mac_buffer_1, complex_i32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
    // Set Bit 0 from PIO, configures inverse FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_H_BASE, 1 );
    
    // left channel
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(mac_buffer_1[i].r >> 8) );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(mac_buffer_1[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_1[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_1[i].i );
    }
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	mac_buffer_16_1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
    }
    
    // right channel
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(mac_buffer_2[i].r >> 8) );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(mac_buffer_2[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_2[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)mac_buffer_2[i].i );
    }
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	mac_buffer_16_2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
    }
    	
    free( mac_buffer_1 );
    free( mac_buffer_2 );
}

#endif

#if ( FFT_B_HW )

void ifft_body_hw( int32_t* mac_buffer_16_1, int32_t* mac_buffer_16_2, complex_i32_t* mac_buffer_1, complex_i32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
    // Set Bit 0 from PIO, configures inverse FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_B_BASE, 1 );
    
    // left channel
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_1[i].r >> 8) );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_1[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_1[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_1[i].i );
    }
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	mac_buffer_16_1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
    
    // right channel
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_2[i].r >> 8) );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_2[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_2[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_2[i].i );
    }
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	mac_buffer_16_2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
    	
    free( mac_buffer_1 );
    free( mac_buffer_2 );
}

#endif

// ---------------------------------------------------------
// zero extend functions
// ---------------------------------------------------------

#if ( FFT_H_HW )

void zero_extend_256_hw( int32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = HEADER_BLOCK_SIZE; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
        samples[i] = 0;
    }
}

#endif

#if ( FFT_B_HW )

void zero_extend_4096_hw( int32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = BODY_BLOCK_SIZE; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        samples[i] = 0;
    }
}

#endif

// ---------------------------------------------------------
// FFT test functions
// ---------------------------------------------------------

// #if ( FFT_H_HW )

// void test_header_fft( int32_t* in_1, int32_t* in_2 )
// {
//     uint16_t i = 0;
//     int32_t* res1 = (int32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(int32_t) );
//     int32_t* res2 = (int32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(int32_t) );
//     
//     // FFT-Operation
//     printf( "FFT-Operation\n" );
//     
//     complex_i32_t* out_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
//     complex_i32_t* out_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
//     
//     zero_extend_256_hw( in_1 );
//     zero_extend_256_hw( in_2 );
//       
//     // Clear Bit 0 from PIO, configures normal FFT operation
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_H_BASE, 0 );
//        
//     printf( "Write sample to FIFO\n" );
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// Both channels are calculated at the same time
// 	// First transmission is real data from left channel
// 	// Second transmission is real data from right channel
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i] );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i] );
//     }
//     
//     printf( "done\n" );
//     printf( "Read result from FIFO\n" );
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// First transmission is transformed real data from left channel
// 	// Second transmission is transformed imaginary data from right channel
// 	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
// 	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
// 	
// 	//~ printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
// 	//~ printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
//     }
//     
//     printf( "done\n" );
//     
//     printf( "Get back both transformed channels\n" );
//     out_1[0].i = 0;
//     out_1[HEADER_BLOCK_SIZE_ZE/2].i = 0;
//     out_2[0].i = 0;
//     out_2[HEADER_BLOCK_SIZE_ZE/2].i = 0;
//     
//     // Get back both transformed channels
//     for ( i = 1; i < HEADER_BLOCK_SIZE_ZE/2; i++ )
//     {
// 	// imaginary parts of X[f] and X[-f]
// 	out_1[i].i = ( out_2[i].r - out_2[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_1[HEADER_BLOCK_SIZE_ZE-i].i = - out_1[i].i;
// 	
// 	// imaginary parts of Y[f] and Y[-f]
// 	out_2[i].i = - ( ( out_1[i].r - out_1[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1 );
// 	out_2[HEADER_BLOCK_SIZE_ZE-i].i = - out_2[i].i;
// 	
// 	// real parts of X[f] and X[-f]
// 	out_1[i].r = ( out_1[i].r + out_1[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_1[HEADER_BLOCK_SIZE_ZE-i].r = out_1[i].r;
// 	
// 	// real parts of Y[f] and Y[-f]
// 	out_2[i].r = ( out_2[i].r + out_2[HEADER_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_2[HEADER_BLOCK_SIZE_ZE-i].r = out_2[i].r;
//     }
//     
//     printf( "done\n" );
//     
// //     printf( "Check FFT Results - Left Channel:\n" );
// //     printf( "i\t|\tREAL\t\t|\tIMAG\n" );
// //     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
// //     { 
// // 	printf( "%d\t|\t%lx\t|\t%lx\n", i, out_1[i].r, out_1[i].i );
// // 	printf( "%d\t|\t%f\t|\t%f\n", i, convert_1q15(out_1[i].r), convert_1q15(out_1[i].i) );
// //     }
// 	    
//     // IFFT-Operation
//     printf( "IFFT-Operation\n" );
//     
//     // Set Bit 0 from PIO, configures inverse FFT operation
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_H_BASE, 1 );
//     
//     // left channel
//     
//     printf("Write sample to FIFO\n");
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// First transmission is real data 
// 	// Second transmission is imaginary data
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(out_1[i].r >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(out_1[i].i >> 8) );
//     }
//     
//     printf( "done\n" );
//     printf( "Read result from FIFO\n" );
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// Transmission is real data 
// 	res1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
//     }
//     
//     printf( "done\n" );
//     
//     // right channel
//     
//     printf("Write sample to FIFO\n");
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// First transmission is real data 
// 	// Second transmission is imaginary data
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(out_2[i].r >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)(out_2[i].i >> 8) );
//     }
//     
//     printf("done\n");
//     printf("Read result from FIFO\n");
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// Transmission is real data 
// 	res2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
//     }
//         
//     printf( "done\n" );
//     
//     free( out_1 );
//     free( out_2 );
//     
//     printf( "Check Results - Left Channel:\n" );
//     printf( "i\t|\tSOLL\t|\tIST\n" );
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_1[i], res1[i] );
//     }
//     
//     printf( "\n\n" );
//     printf( "Check Results - Right Channel:\n" );
//     printf( "i\t|\tSOLL\t|\tIST\n" );
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_2[i], res2[i] );
//     }
//     printf( "\n\n" );
//     
//     free( res1 );
//     free( res2 );
// }
// 
// #endif
// 
// #if ( FFT_B_HW )
// 
// void test_body_fft( int32_t* in_1, int32_t* in_2 )
// {
//     uint16_t i = 0;
//     int32_t* res1 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
//     int32_t* res2 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
//     
//     // FFT-Operation
//     printf( "FFT-Operation\n" );
//     
//     complex_i32_t* out_1 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
//     complex_i32_t* out_2 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
//     
//     zero_extend_4096_hw( in_1 );
//     zero_extend_4096_hw( in_2 );
//       
//     // Clear Bit 0 from PIO, configures normal FFT operation
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_B_BASE, 0 );
//        
//     printf( "Write sample to FIFO\n" );
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// Both channels are calculated at the same time
// 	// First transmission is real data from left channel
// 	// Second transmission is real data from right channel
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_1[i] );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_2[i] );
// 	
// 	printf( "Real data[%d]:      %lx\n", i, in_1[i] );
//     }
//     
//     printf( "done\n" );
//     printf( "Read result from FIFO\n" );
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// First transmission is transformed real data from left channel
// 	// Second transmission is transformed imaginary data from right channel
// 	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
// 	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
// 	
// 	printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
// 	printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
//     }
//     
//     printf( "done\n" );
//     
//     printf( "Get back both transformed channels\n" );
//     out_1[0].i = 0;
//     out_1[BODY_BLOCK_SIZE_ZE/2].i = 0;
//     out_2[0].i = 0;
//     out_2[BODY_BLOCK_SIZE_ZE/2].i = 0;
//     
//     // Get back both transformed channels
//     for ( i = 1; i < BODY_BLOCK_SIZE_ZE/2; i++ )
//     {
// 	// imaginary parts of X[f] and X[-f]
// 	out_1[i].i = ( out_2[i].r - out_2[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_1[BODY_BLOCK_SIZE_ZE-i].i = - out_1[i].i;
// 	
// 	// imaginary parts of Y[f] and Y[-f]
// 	out_2[i].i = - ( ( out_1[i].r - out_1[BODY_BLOCK_SIZE_ZE-i].r ) >> 1 );
// 	out_2[BODY_BLOCK_SIZE_ZE-i].i = - out_2[i].i;
// 	
// 	// real parts of X[f] and X[-f]
// 	out_1[i].r = ( out_1[i].r + out_1[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_1[BODY_BLOCK_SIZE_ZE-i].r = out_1[i].r;
// 	
// 	// real parts of Y[f] and Y[-f]
// 	out_2[i].r = ( out_2[i].r + out_2[BODY_BLOCK_SIZE_ZE-i].r ) >> 1;
// 	out_2[BODY_BLOCK_SIZE_ZE-i].r = out_2[i].r;
//     }
//     
//     printf( "done\n" );
//     
// //     printf( "Check FFT Results - Left Channel:\n" );
// //     printf( "i\t|\tREAL\t\t|\tIMAG\n" );
// //     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
// //     { 
// // 	printf( "%d\t|\t%lx\t|\t%lx\n", i, out_1[i].r, out_1[i].i );
// // 	printf( "%d\t|\t%f\t|\t%f\n", i, convert_1q15(out_1[i].r), convert_1q15(out_1[i].i) );
// //     }
// 	    
//     // IFFT-Operation
//     printf( "IFFT-Operation\n" );
//     
//     // Set Bit 0 from PIO, configures inverse FFT operation
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_B_BASE, 1 );
//     
//     // left channel
//     
//     printf("Write sample to FIFO\n");
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// First transmission is real data 
// 	// Second transmission is imaginary data
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_1[i].r >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_1[i].i >> 8) );
//     }
//     
//     printf( "done\n" );
//     printf( "Read result from FIFO\n" );
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// Transmission is real data 
// 	res1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
//     }
//     
//     printf( "done\n" );
//     
//     // right channel
//     
//     printf("Write sample to FIFO\n");
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// First transmission is real data 
// 	// Second transmission is imaginary data
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_2[i].r >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_2[i].i >> 8) );
//     }
//     
//     printf("done\n");
//     printf("Read result from FIFO\n");
//     
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Read result from FIFO
// 	// Transmission is real data 
// 	res2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
//     }
//         
//     printf( "done\n" );
//     
//     free( out_1 );
//     free( out_2 );
//     
//     printf( "Check Results - Left Channel:\n" );
//     printf( "i\t|\tSOLL\t|\tIST\n" );
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_1[i], res1[i] );
//     }
//     
//     printf( "\n\n" );
//     printf( "Check Results - Right Channel:\n" );
//     printf( "i\t|\tSOLL\t|\tIST\n" );
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_2[i], res2[i] );
//     }
//     printf( "\n\n" );
//     
//     free( res1 );
//     free( res2 );
// }
// 
// #endif