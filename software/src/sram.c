
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

// blocks

//  0 - 13 header left
// 14 - 27 header right
// 28 - 41 input left
// 42 - 55 input right

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
        //~ printf( "%i\n", block_base + i );
    }
    
    sram_check_block( samples, block );
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

void sram_read_block( complex_32_t* samples, uint32_t block )
{
    uint16_t i = 0;
    
    for ( i = 0; i < 512; i++ )
    {
        samples[i] = sram_read_from_block( block, i );
    }
}

complex_32_t sram_read_from_block( uint32_t block, uint32_t i )
{
    complex_32_t c;
    
    uint32_t block_base = block * 512;
    
    //~ printf( "block_base %i\n", block_base+i );
    
    c = sram_read( block_base + i );
    
    return c;
}

void sram_clear_block( complex_32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = 0; i < 512; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

void sram_check_block( complex_32_t* ref, uint32_t block )
{
    //~ printf("checking block\n");
    
    complex_32_t read[512];
    
    sram_read_block( read, block );
    
    uint16_t i = 0;
    
    for ( i = 0; i < 512; i++ )
    {
        if (
            ( read[i].r != ref[i].r ) ||
            ( read[i].i != ref[i].i )
        )
        {
            printf("-----\n");
            printf( "check block failed r: %i: read %lx | ref %lx\n", i, read[i].r, ref[i].r );
            printf( "check block failed i: %i: read %lx | ref %lx\n", i, read[i].i, ref[i].i );
            printf("-----\n");
        }
    }
}

uint8_t sram_test()
{
    // naming:
    // c_blockindex_sampleindex
    
    complex_32_t c_00_001 = sram_read_from_block(  0,   1 );
    complex_32_t c_00_015 = sram_read_from_block(  0,  15 );
    complex_32_t c_00_255 = sram_read_from_block(  0, 255 );
    complex_32_t c_01_000 = sram_read_from_block(  1,   0 );
    complex_32_t c_01_021 = sram_read_from_block(  1,  21 );
    complex_32_t c_02_022 = sram_read_from_block(  2,  22 );
    complex_32_t c_03_022 = sram_read_from_block(  3,  22 );
    complex_32_t c_04_022 = sram_read_from_block(  4,  22 );
    complex_32_t c_05_022 = sram_read_from_block(  5,  22 );
    complex_32_t c_06_022 = sram_read_from_block(  6,  22 );
    complex_32_t c_07_022 = sram_read_from_block(  7,  22 );
    complex_32_t c_08_021 = sram_read_from_block(  8,  21 );
    complex_32_t c_09_022 = sram_read_from_block(  9,  22 );
    complex_32_t c_10_022 = sram_read_from_block( 10,  22 );
    complex_32_t c_11_022 = sram_read_from_block( 11,  22 );
    complex_32_t c_12_022 = sram_read_from_block( 12,  22 );
    complex_32_t c_13_255 = sram_read_from_block( 13, 255 );
    
    complex_32_t c_00_001_right = c_from_float_9q23( -2.54973  , -3.04959   );
    complex_32_t c_00_015_right = c_from_float_9q23( -1.1204   , -1.6117    );
    complex_32_t c_00_255_right = c_from_float_9q23(  0.0237411,  0.0038374 );
    complex_32_t c_01_000_right = c_from_float_9q23( -1.2316   ,  0         );
    complex_32_t c_01_021_right = c_from_float_9q23( -1.4315   , -3.6922    );
    complex_32_t c_02_022_right = c_from_float_9q23( -1.3793   , -1.1449    );
    complex_32_t c_03_022_right = c_from_float_9q23(  0.043728 ,  3.442955  );
    complex_32_t c_04_022_right = c_from_float_9q23( -0.30478  ,  1.27823   );
    complex_32_t c_05_022_right = c_from_float_9q23( -0.064440 , -0.450381  );
    complex_32_t c_06_022_right = c_from_float_9q23(  0.28450  , -1.20484   );
    complex_32_t c_07_022_right = c_from_float_9q23(  1.1722   , -1.5835    );
    complex_32_t c_08_021_right = c_from_float_9q23( -0.45846  ,  1.00286   );
    complex_32_t c_09_022_right = c_from_float_9q23(  0.86276  , -0.10841   );
    complex_32_t c_10_022_right = c_from_float_9q23(  0.17272  , -0.58791   );
    complex_32_t c_11_022_right = c_from_float_9q23( -0.25955  , -1.26607   );
    complex_32_t c_12_022_right = c_from_float_9q23( -0.78818  , -1.98829   );
    complex_32_t c_13_255_right = c_from_float_9q23(  0.0146159,  0.0010956 );
    
    (void) c_cmp( c_00_001, c_00_001_right );
    (void) c_cmp( c_00_015, c_00_015_right );
    (void) c_cmp( c_00_255, c_00_255_right );
    (void) c_cmp( c_01_000, c_01_000_right );
    (void) c_cmp( c_01_021, c_01_021_right );
    (void) c_cmp( c_02_022, c_02_022_right );
    (void) c_cmp( c_03_022, c_03_022_right );
    (void) c_cmp( c_04_022, c_04_022_right );
    (void) c_cmp( c_05_022, c_05_022_right );
    (void) c_cmp( c_06_022, c_06_022_right );
    (void) c_cmp( c_07_022, c_07_022_right );
    (void) c_cmp( c_08_021, c_08_021_right );
    (void) c_cmp( c_09_022, c_09_022_right );
    (void) c_cmp( c_10_022, c_10_022_right );
    (void) c_cmp( c_11_022, c_11_022_right );
    (void) c_cmp( c_12_022, c_12_022_right );
    (void) c_cmp( c_13_255, c_13_255_right );
}
