
#include <inttypes.h>

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "sram.h"
#include "complex.h"

void sram_write( complex_32_t sample, uint32_t i )
{
    // write real part
    
    IOWR ( SRAM_0_BASE, (4*i)  , (uint16_t)( sample.r >> 16) );
    IOWR ( SRAM_0_BASE, (4*i)+1, (uint16_t)( sample.r      ) );
    
    // write imaginary part
    
    IOWR ( SRAM_0_BASE, (4*i)+2, (uint16_t)( sample.i >> 16) );
    IOWR ( SRAM_0_BASE, (4*i)+3, (uint16_t)( sample.i      ) );
}

void sram_write_block( complex_32_t* samples, uint32_t block )
{
    uint16_t i = 0;
    
    uint32_t block_base = block * 512;
    
    for ( i = 0; i < 512; i++ )
    {
        (void) sram_write( samples[i], block_base + i );
    }
}

complex_32_t sram_read( uint32_t i )
{
    complex_32_t c;
    
    // read real part
    
    uint16_t sample_r_msb = IORD ( SRAM_0_BASE, (4*i)   );
    uint16_t sample_r_lsb = IORD ( SRAM_0_BASE, (4*i)+1 );
    
    c.r = ( sample_r_msb << 16 ) | sample_r_lsb;
    
    // read imaginary part
    
    uint16_t sample_i_msb = IORD ( SRAM_0_BASE, (4*i)+2 );
    uint16_t sample_i_lsb = IORD ( SRAM_0_BASE, (4*i)+3 );
    
    c.i = ( sample_i_msb << 16 ) | sample_i_lsb;
    
    return c;
}

complex_32_t sram_read_from_block( uint32_t block, uint32_t i )
{
    complex_32_t c;
    
    uint32_t block_base = block * 512;
    
    c = sram_read( block_base + i );
    
    return c;
}

uint8_t sram_test_cmp()
{
    complex_32_t c_001 = sram_read_from_block( 0,   1 );
    complex_32_t c_015 = sram_read_from_block( 0,  15 );
    complex_32_t c_255 = sram_read_from_block( 0, 255 );
    
    complex_32_t c_001_right = complex_from_float_9q23( -2.54973  , -3.04959   );
    complex_32_t c_015_right = complex_from_float_9q23( -1.1204   , -1.6117    );
    complex_32_t c_255_right = complex_from_float_9q23(  0.0237411,  0.0038374 );
    
    (void) cmp_complex( c_001, c_001_right );
    (void) cmp_complex( c_015, c_015_right );
    (void) cmp_complex( c_255, c_255_right );
}

uint8_t sram_test()
{
    printf( ">SRAM test\n" );
    
    uint8_t ret = 0;
    
    complex_32_t c_001 = sram_read_from_block( 0,   1 );
    complex_32_t c_015 = sram_read_from_block( 0,  15 );
    complex_32_t c_255 = sram_read_from_block( 0, 255 );
    
    float c_001_r;
    float c_001_i;
    float c_015_r;
    float c_015_i;
    float c_255_r;
    float c_255_i;
    
    // hier muss ich das pointer zeugs verwenden
    // sonst funktioniert es nicht.
    
    (void) convert_9q23_pointer( &c_001_r, c_001.r);
    (void) convert_9q23_pointer( &c_001_i, c_001.i);
    (void) convert_9q23_pointer( &c_015_r, c_015.r);
    (void) convert_9q23_pointer( &c_015_i, c_015.i);
    (void) convert_9q23_pointer( &c_255_r, c_255.r);
    (void) convert_9q23_pointer( &c_255_i, c_255.i);
    
    // -2.54973 - 3.04959i
    // -1.1204 - 1.6117i
    //  0.0237411 + 0.0038374i
    
    float c_001_r_right = -2.54973;
    float c_001_i_right = -3.04959;
    
    float c_015_r_right = -1.1204;
    float c_015_i_right = -1.6117;
    
    float c_255_r_right = 0.0237411;
    float c_255_i_right = 0.0038374;
    
    if (
        ( (c_001_r - c_001_r_right) > 0.5 ) ||
        ( (c_001_i - c_001_i_right) > 0.5 )
    )
    {
        printf(">failed for 001\n");
        ret = 1;
    }
    
    if (
        ( (c_015_r - c_015_r_right) > 0.5 ) ||
        ( (c_015_i - c_015_i_right) > 0.5 )
    )
    {
        printf(">failed for 015\n");
        ret = 1;
    }
    
    if (
        ( (c_255_r - c_255_r_right) > 0.5 ) ||
        ( (c_255_i - c_255_i_right) > 0.5 )
    )
    {
        printf(">failed for 255\n");
        ret = 1;
    }
    
    if ( ret != 0 ) { printf( ">>failed!\n"  ); }
    else            { printf( ">>success!\n" ); }
    
    return ret;
}
