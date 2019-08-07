
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
#include "defines.h"

// For FIFO commands
#include "altera_avalon_fifo_util.h"

// For PIO commands
#include "altera_avalon_pio_regs.h"

// ---------------------------------------------------------
// FFT setup
// ---------------------------------------------------------
	
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

void fft_b_setup_hw()
{
	uint16_t i = 0;
			
	for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
	{	
		// init Input FIFOs 
		// TODO: Adresse überprüfen!!
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)0 );
		IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)0 );
	}

	for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
	{	
		// init Output FIFOs 
		// TODO: Adresse überprüfen!!
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
		(void)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	}
}

// ---------------------------------------------------------
// pre-processing blocks (H)
// ---------------------------------------------------------

void pre_process_h_header_hw( struct wav* ir )
{
    int32_t l_buf;
    int32_t r_buf;
    
    uint16_t i = 0;
    
    uint8_t header_blocks_h_i = 0;
    
    for ( header_blocks_h_i = 0; header_blocks_h_i < HEADER_BLOCK_NUM; header_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", header_blocks_h_i, HEADER_BLOCK_NUM + header_blocks_h_i );
        
        complex_i32_t* cin_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
        complex_i32_t* cin_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = FIR_SIZE + ( header_blocks_h_i * HEADER_BLOCK_SIZE );
        
        // wir nehmen nur 256 da das ja zero extended sein soll.
        
        for ( i = 0; i < HEADER_BLOCK_SIZE; i++ )
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
        
//          if ( header_blocks_h_i == 0 )
// 	  	test_header_fft( cin_1, cin_2 );
                
        process_header_block_hw( cin_1, cin_2, header_blocks_h_i, 1 );
    }
}

void pre_process_h_body_hw( uint32_t* sdramm, struct wav* ir )
{
    int32_t l_buf;
    int32_t r_buf;
    
    uint32_t i = 0;
	uint32_t j = 0;
    
    uint16_t body_blocks_h_i = 0;
    
    for ( body_blocks_h_i = 0; body_blocks_h_i < BODY_BLOCK_NUM; body_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", body_blocks_h_i, BODY_BLOCK_NUM + body_blocks_h_i );
        
        complex_i32_t* cin_1 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
        complex_i32_t* cin_2 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = FIR_SIZE + ( HEADER_BLOCK_NUM * HEADER_BLOCK_SIZE ) + ( body_blocks_h_i * BODY_BLOCK_SIZE );
        
        // wir nehmen nur 4096 da das ja zero extended sein soll.
        
        for ( i = 0; i < BODY_BLOCK_SIZE; i++ )
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
        
        if ( body_blocks_h_i == 0 )
			test_body_fft( cin_1, cin_2 );
                
        process_body_block_hw( sdramm, cin_1, cin_2, body_blocks_h_i, 1 );
    }
}

// ---------------------------------------------------------
// FFT operation
// ---------------------------------------------------------

void process_header_block_hw( complex_i32_t* in_1, complex_i32_t* in_2, uint8_t block, uint8_t free_input )
{
    // Nach der FFT haben die Werte ein 17Q15 Format!!
  
    uint16_t i = 0;
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    
    zero_extend_256_hw( in_1 );
    zero_extend_256_hw( in_2 );
    
    // Clear Bit 0 from PIO, configures normal FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 0 );
     
    printf("performing header fft\n"); // printf is needed for delay operation
    
    // printf("Write sample to FIFO\n");
    
    for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// Both channels are calculated at the same time
	// First transmission is real data from left channel
	// Second transmission is real data from right channel
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i].r );
	// printf( "l_buf[%d]: %lx\n", i, in_1[i].r  );
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i].r );
	// printf( "r_buf[%d]: %lx\n", i, in_2[i].r  );
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
	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTH_BASE );
	
	// printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
	// printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
    }
    
    // printf( "done\n" );
    // printf( "Get back both transformed channels\n" );
    
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

void process_body_block_hw( uint32_t* sdramm, complex_i32_t* in_1, complex_i32_t* in_2, uint8_t block, uint8_t free_input )
{
    // Nach der FFT haben die Werte ein 17Q15 Format!!
  
    uint32_t i = 0;
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( HEADER_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    
    zero_extend_4096_hw( in_1 );
    zero_extend_4096_hw( in_2 );
    
    // Clear Bit 0 from PIO, configures normal FFT operation	
	// TODO: Adresse überprüfen!!
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 0 );
     
    printf("performing body fft\n"); // printf is needed for delay operation
    
    // printf("Write sample to FIFO\n");
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// Both channels are calculated at the same time
	// First transmission is real data from left channel
	// Second transmission is real data from right channel
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_1[i].r );
	// printf( "l_buf[%d]: %lx\n", i, in_1[i].r  );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTV_BASE, (int32_t)in_2[i].r );
	// printf( "r_buf[%d]: %lx\n", i, in_2[i].r  );
    }
    
    // printf( "done\n" );
    // printf( "Read result from FIFO\n" );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// First transmission is transformed real data from left channel
	// Second transmission is transformed imaginary data from right channel
	// printf( "%d\n", i );
	// TODO: Adresse überprüfen!!
	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	// TODO: Adresse überprüfen!!
	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	
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
	         
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
    
    free( out_1 );
    free( out_2 );
}

// ---------------------------------------------------------
// IFFT operation
// ---------------------------------------------------------

void ifft_header_hw( int32_t* mac_buffer_16_1, int32_t* mac_buffer_16_2, complex_i32_t* mac_buffer_1, complex_i32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
    // Set Bit 0 from PIO, configures inverse FFT operation
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 1 );
    
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

void ifft_body_hw( int32_t* mac_buffer_16_1, int32_t* mac_buffer_16_2, complex_i32_t* mac_buffer_1, complex_i32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
    // Set Bit 0 from PIO, configures inverse FFT operation
	// TODO: Adresse überprüfen!!
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 1 );
    
    // left channel
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_1[i].r >> 8) );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_1[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_1[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_1[i].i );
    }
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	// TODO: Adresse überprüfen!!
	mac_buffer_16_1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
    
    // right channel
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_2[i].r >> 8) );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(mac_buffer_2[i].i >> 8) );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_2[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)mac_buffer_2[i].i );
    }
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	// TODO: Adresse überprüfen!!
	mac_buffer_16_2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
    	
    free( mac_buffer_1 );
    free( mac_buffer_2 );
}

// ---------------------------------------------------------
// zero extend functions
// ---------------------------------------------------------

void zero_extend_256_hw( complex_i32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = HEADER_BLOCK_SIZE; i < HEADER_BLOCK_SIZE_ZE; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

void zero_extend_4096_hw( complex_i32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = BODY_BLOCK_SIZE; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

// ---------------------------------------------------------
// FFT test functions
// ---------------------------------------------------------

// void test_header_fft( complex_i32_t* in_1, complex_i32_t* in_2 )
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
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 0 );
//        
//     printf( "Write sample to FIFO\n" );
//     
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     {
// 	// Write sample to FIFO
// 	// Both channels are calculated at the same time
// 	// First transmission is real data from left channel
// 	// Second transmission is real data from right channel
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_1[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)in_2[i].r );
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
//     IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 1 );
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
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_2[i].r );
// 	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTH_BASE, (int32_t)out_2[i].i );
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
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_1[i].r, res1[i] );
//     }
//     
//     printf( "\n\n" );
//     printf( "Check Results - Right Channel:\n" );
//     printf( "i\t|\tSOLL\t|\tIST\n" );
//     for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_2[i].r, res2[i] );
//     }
//     printf( "\n\n" );
//     
//     free( res1 );
//     free( res2 );
// }

void test_body_fft( complex_i32_t* in_1, complex_i32_t* in_2 )
{
    uint16_t i = 0;
    int32_t* res1 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
    int32_t* res2 = (int32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(int32_t) );
    
    // FFT-Operation
    printf( "FFT-Operation\n" );
    
    complex_i32_t* out_1 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    complex_i32_t* out_2 = (complex_i32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_i32_t) );
    
    zero_extend_4096_hw( in_1 );
    zero_extend_4096_hw( in_2 );
      
    // Clear Bit 0 from PIO, configures normal FFT operation
	// TODO: Adresse überprüfen!!
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 0 );
       
    printf( "Write sample to FIFO\n" );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// Both channels are calculated at the same time
	// First transmission is real data from left channel
	// Second transmission is real data from right channel
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_1[i].r );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)in_2[i].r );
    }
    
    printf( "done\n" );
    printf( "Read result from FIFO\n" );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// First transmission is transformed real data from left channel
	// Second transmission is transformed imaginary data from right channel
	// TODO: Adresse überprüfen!!
	out_1[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	// TODO: Adresse überprüfen!!
	out_2[i].r = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
	
	//~ printf( "Real data[%d]:      %lx\n", i, out_1[i].r );
	//~ printf( "Imaginary data[%d]: %lx\n", i, out_2[i].r );
    }
    
    printf( "done\n" );
    
    printf( "Get back both transformed channels\n" );
    out_1[0].i = 0;
    out_1[BODY_BLOCK_SIZE_ZE/2].i = 0;
    out_2[0].i = 0;
    out_2[BODY_BLOCK_SIZE_ZE/2].i = 0;
    
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
    
    printf( "done\n" );
    
//     printf( "Check FFT Results - Left Channel:\n" );
//     printf( "i\t|\tREAL\t\t|\tIMAG\n" );
//     for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
//     { 
// 	printf( "%d\t|\t%lx\t|\t%lx\n", i, out_1[i].r, out_1[i].i );
// 	printf( "%d\t|\t%f\t|\t%f\n", i, convert_1q15(out_1[i].r), convert_1q15(out_1[i].i) );
//     }
	    
    // IFFT-Operation
    printf( "IFFT-Operation\n" );
    
    // Set Bit 0 from PIO, configures inverse FFT operation
	// TODO: Adresse überprüfen!!
    IOWR_ALTERA_AVALON_PIO_DATA( PIO_0_BASE, 1 );
    
    // left channel
    
    printf("Write sample to FIFO\n");
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_1[i].r >> 8) );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)(out_1[i].i >> 8) );
    }
    
    printf( "done\n" );
    printf( "Read result from FIFO\n" );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	// TODO: Adresse überprüfen!!
	res1[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
    
    printf( "done\n" );
    
    // right channel
    
    printf("Write sample to FIFO\n");
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Write sample to FIFO
	// First transmission is real data 
	// Second transmission is imaginary data
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)out_2[i].r );
	// TODO: Adresse überprüfen!!
	IOWR_ALTERA_AVALON_FIFO_DATA( M2S_FIFO_FFTB_BASE, (int32_t)out_2[i].i );
    }
    
    printf("done\n");
    printf("Read result from FIFO\n");
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	// Read result from FIFO
	// Transmission is real data 
	// TODO: Adresse überprüfen!!
	res2[i] = (int32_t)IORD_ALTERA_AVALON_FIFO_DATA( S2M_FIFO_FFTB_BASE );
    }
        
    printf( "done\n" );
    
    free( out_1 );
    free( out_2 );
    
    printf( "Check Results - Left Channel:\n" );
    printf( "i\t|\tSOLL\t|\tIST\n" );
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    { 
	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_1[i].r, res1[i] );
    }
    
    printf( "\n\n" );
    printf( "Check Results - Right Channel:\n" );
    printf( "i\t|\tSOLL\t|\tIST\n" );
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    { 
	printf( "%d\t|\t%lx\t|\t%lx\n", i, in_2[i].r, res2[i] );
    }
    printf( "\n\n" );
    
    free( res1 );
    free( res2 );
}
