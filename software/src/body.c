
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

#include "complex.h"

#include "defines.h"

#include "kiss_fft.h"
#include "fft_fp.h"

#include "fixed_point.h"
#include "sdram.h"

#include "body.h"

// =====================================================================
// 
// pre_process_h_body
// 
// =====================================================================

void pre_process_h_body( uint32_t* sdramm, struct wav* ir )
{
    uint16_t l_buf;
    uint16_t r_buf;
    
    uint32_t i = 0;
    uint32_t j = 0;
    
    uint16_t body_blocks_h_i = 0;
    
    for ( body_blocks_h_i = 0; body_blocks_h_i < BODY_BLOCK_NUM; body_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", body_blocks_h_i, BODY_BLOCK_NUM + body_blocks_h_i );
        
        kiss_fft_cpx* cin_1 = (kiss_fft_cpx*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(kiss_fft_cpx) );
        kiss_fft_cpx* cin_2 = (kiss_fft_cpx*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(kiss_fft_cpx) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = FIR_SIZE + ( HEADER_BLOCK_NUM * HEADER_BLOCK_SIZE ) + ( body_blocks_h_i * BODY_BLOCK_SIZE );
        
        //~ printf( "reading samples\n" );
        
        // wir nehmen nur 4096 da das ja zero extended sein soll.
        
        for ( i = 0; i < BODY_BLOCK_SIZE; i++ )
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
        
        process_body_block( sdramm, cin_1, cin_2, body_blocks_h_i, 1 );
        
        for ( j = 0; j < 20; j++ )
        {
            printf( "sdram: %ld\n", sdramm[j] );
        }
        
        if ( body_blocks_h_i == 1 )
        {
            return;
        }
    }
}

// =====================================================================
// 
// process_body_block
// 
// =====================================================================

// // hier mach ich die fft.

void process_body_block( uint32_t* sdramm, kiss_fft_cpx* in_1, kiss_fft_cpx* in_2, uint8_t block, uint8_t free_input )
{
    uint32_t i = 0;
    
    kiss_fft_cfg kiss_cfg = kiss_fft_alloc( BODY_BLOCK_SIZE_ZE, 0, 0, 0 );
    
    // in out wird das fft ergebnis gespeichert
    
    kiss_fft_cpx* out_1 = (kiss_fft_cpx*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(kiss_fft_cpx) );
    kiss_fft_cpx* out_2 = (kiss_fft_cpx*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(kiss_fft_cpx) );
    
    zero_extend_4096( in_1 );
    zero_extend_4096( in_2 );
    
    kiss_fft( kiss_cfg, in_1, out_1 );
    kiss_fft( kiss_cfg, in_2, out_2 );
    
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
    
    free( kiss_cfg );
    
    complex_32_t* samples_1 = (complex_32_t*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(complex_32_t) );
    complex_32_t* samples_2 = (complex_32_t*)malloc( BODY_BLOCK_SIZE_ZE * sizeof(complex_32_t) );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        samples_1[i].r = convert_to_fixed_9q23( out_1[i].r );
        samples_1[i].i = convert_to_fixed_9q23( out_1[i].i );
        
        samples_2[i].r = convert_to_fixed_9q23( out_2[i].r );
        samples_2[i].i = convert_to_fixed_9q23( out_2[i].i );
    }
    
    // 1. durchlauf PASST (ir)
    // 2. durchlauf PASST (ir)
    
    // 1. durchlauf PASST (in)
    // 2. durchlauf PASST (in)
    
    //~ for ( i = 0; i < 20; i++ )
    //~ {
        //~ printf( "%i %f %f i\n", i, out_2[i].r, out_2[i].i );
    //~ }
    
    if ( free_input == 0 )
    {
        printf( "---------------------- das will ich testen -----------------\n" );
        
        for ( i = 0; i < 20; i++ )
        {
            printf( "%ld %f %f i\n", i, out_1[i].r, out_1[i].i );
            printf( "%ld %ld %ld i\n", i, samples_1[i].r, samples_1[i].i );
        }
    }
    
    // da waren die floats nach der fft drinnen. die brauchen wir nicht mehr.
    
    free( out_1 );
    free( out_2 );
    
    // der block wird gespeichert
    // TODO - in der finalen version wird das gemacht waehrend
    // die MAC im freq bereich laeuft. vll sollte das hier auch
    // schon irgendwie dargestellt werden.
    
    printf( "\nwriting block to %i | %i\n", block, BODY_BLOCK_NUM + block );
    
    (void) sdram_write_block( sdramm, samples_1, block );
    (void) sdram_write_block( sdramm, samples_2, BODY_BLOCK_NUM + block );
    
    if ( free_input == 0 )
    {
//         printf( "---------------------- das will ich haben -----------------\n" );
        
        //~ for ( i = 0; i < 20; i++ )
        //~ {
            //~ printf( "%i %f %f i\n", i, out_2[i].r, out_2[i].i );
        //~ }
        
        //for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
        //{
            //printf( "%lx\n", samples_1[i].r );
            //printf( "%lx\n", samples_1[i].i );
        //}
    }
    
    //~ return;
    
    free( samples_1 );
    free( samples_2 );
}
 
// =====================================================================
// 
// mac_body
// 
// =====================================================================

void mac_body( uint32_t* sdramm, complex_32_t* output_buffer, uint32_t in_pointer, uint32_t ir_pointer )
{
    //~ printf( "\n\nmac_body: ir_pointer = %i, in_pointer = %i\n\n", ir_pointer, in_pointer );
    
    // get ir and in blocks from sram
    
    complex_32_t mul_temp;
    
    complex_32_t* in_block = (complex_32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_32_t) );
    complex_32_t* ir_block = (complex_32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_32_t) );
    
    uint32_t i = 0;
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        if (
            ( in_block[i].r != 0 ) ||
            ( in_block[i].i != 0 ) ||
            ( ir_block[i].r != 0 ) ||
            ( ir_block[i].i != 0 )
        )
        {
            printf( ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR: mac allocated block is not empty!\n" );
        }
    }
    
    // overflow is ignored.
    
    printf( "in_pointer: %ld\n", in_pointer );
    printf( "ir_pointer: %ld\n", ir_pointer );
    
    printf( "\n" );
    
    (void) sdram_read_block_pointer( sdramm, in_block, in_pointer );
    (void) sdram_read_block_pointer( sdramm, ir_block, ir_pointer );
    
    //~ print_c_block_9q23( ir_block, 5, 5 );
    //~ printf("---------------------------------------\n");
    //~ print_c_block_9q23( in_block, 5, 5 );
    
    uint16_t k = 0;
        
    for ( k = 0; k < BODY_BLOCK_SIZE_ZE; k++ )
    {
        mul_temp = c_mul( in_block[k], ir_block[k] );

//         return;
//         if ( ( in_block[k].r != 0 ) && ( ir_block[k].r != 0 ) )
//         {
//             printf( "%d - %d\n", in_block[k].r, ir_block[k].r );
//         }
//         
//         if ( mul_temp.r != 0 )
//         {
//             printf( "%d\n", mul_temp.r );
//         }
        
        output_buffer[k].r += (int64_t)(mul_temp.r);
        output_buffer[k].i += (int64_t)(mul_temp.i);
    }
    
    //~ print_c_block_9q23( output_buffer, 5, 5 );
    
    free( in_block );
    free( ir_block );
}

// =====================================================================
// 
// ifft_body
// 
// =====================================================================

// also convert values

void ifft_body( uint16_t* mac_buffer_16_1, uint16_t* mac_buffer_16_2, complex_32_t* mac_buffer_1, complex_32_t* mac_buffer_2 )
{
    printf( "im ifft_body\n" );
    
    uint16_t i = 0;
    
    complex_float_t* f_1 = (complex_float_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_float_t) );
    complex_float_t* f_2 = (complex_float_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_float_t) );
    
    // convert to float and store in malloc array
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        float mac_buffer_r_1_f;
        float mac_buffer_i_1_f;
        
        float mac_buffer_r_2_f;
        float mac_buffer_i_2_f;
        
        convert_9q23_pointer( &mac_buffer_r_1_f, mac_buffer_1[i].r );
        convert_9q23_pointer( &mac_buffer_i_1_f, mac_buffer_1[i].i );
        
        convert_9q23_pointer( &mac_buffer_r_2_f, mac_buffer_2[i].r );
        convert_9q23_pointer( &mac_buffer_i_2_f, mac_buffer_2[i].i );
        
        f_1[i].real = mac_buffer_r_1_f;
        f_1[i].imag = mac_buffer_i_1_f;
        
        f_2[i].real = mac_buffer_r_2_f;
        f_2[i].imag = mac_buffer_i_2_f;
    }
    
    // 1. durchlauf PASST
    // 2. durchlauf PASST (index 5 ist falsch: ist 5: -237.707184, sollte 2.7429e+02 sein)
    
    //~ for ( i = 0; i < 10; i++ )
    //~ {
        //~ printf( "%i: %f\n", i, f_1[i].real );
    //~ }
    
    //~ printf( "^^^^^^^^^\n" );
    //~ printf( "das letzte sollte noch passen\n" );
    
    free( mac_buffer_1 );
    free( mac_buffer_2 );
    
    (void) fft_cfp( f_1, 13, 1 );
    (void) fft_cfp( f_2, 13, 1 );
    
    // 1. durchlauf PASST NICHT
    
    for ( i = 0; i < 10; i++ )
    {
        printf( "%i: %f\n", i, f_1[i].real );
    }
    
    // ---------------------------------------------------------
    // C O N V E R T   T O   1 6   B I T   F I X E D
    // ---------------------------------------------------------
    
    // versuchen die floats auf 1q15 zu bekommen.
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        mac_buffer_16_1[i] = convert_to_fixed_1q15( f_1[i].real );
        mac_buffer_16_2[i] = convert_to_fixed_1q15( f_2[i].real );
    }
    
    free( f_1 );
    free( f_2 );
}

// =====================================================================
// 
// zero_extend_4096
// 
// =====================================================================

void zero_extend_4096( kiss_fft_cpx* samples )
{
    uint16_t i = 0;
    
    for ( i = BODY_BLOCK_SIZE; i < BODY_BLOCK_SIZE_ZE; i++ ) { samples[i].r = 0; samples[i].i = 0; }
}