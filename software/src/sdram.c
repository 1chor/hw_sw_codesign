
#include <inttypes.h>

#include <stdio.h>

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "defines.h"


#include "sdram.h"
#include "complex.h"

#define MAC_SDRAM_RESET(b)             IOWR( b,  1, 0 )
#define MAC_SDRAM_SET_LEFT_CHANNEL(b)  IOWR( b,  3, 0 )
#define MAC_SDRAM_SET_RIGHT_CHANNEL(b) IOWR( b,  5, 0 )
#define MAC_SDRAM_START(b)             IOWR( b,  7, 0 )
#define MAC_SDRAM_READ_OUT(b)          IOWR( b,  9, 0 )
#define MAC_SDRAM_CHUNK_BLOCK_INC(b)   IOWR( b, 11, 0 )

#define MAC_SDRAM_SET_BASE_ADDR(b, addr) IOWR( b, 13, addr )

#define WAIT_UNTIL_IDLE(b) while ( 1 != IORD( b, 129 ) ) {}

// header blocks

//  0 - 13 header left
// 14 - 27 header right
// 28 - 41 input left
// 42 - 55 input right

// body blocks

// ein block hat eine bestimmte anzahl an samples.
// das ist mir jetzt aber mal wurscht

// wir brauchen immer 23 blocks

// die anzahl der samples in einem block ist die zero extended zahl an samples.
// das sind dann 

// ohne zero extending haben wir 4096 samples.
// mit zero extending haben wir 8192 samples.

// ein sample besteht aus real und imag also brauchen wir 2 eintraege bzw.
// words um das abzuspeichern.

// der ganze block ist dann also 8192*2 words gross = 16.384.

//  0 - 22 body left
// 23 - 45 body right
// 46 - 68 input left
// 69 - 91 input right

// laut ip block haben wir 33554432 words.
// das waeren 2048 blocks ( 33554432 / 16384 )

// ich werde meinen scheiss daher einfach ab block 1024 speichern

// ---------------------------------------------------------------------
// write
// ---------------------------------------------------------------------

void sdram_write( uint32_t* sdramm, complex_32_t sample, uint32_t i )
{
    //~ IOWR ( SDRAM_BASE, (2*i)  , (uint32_t)( sample.r ) );
    //~ IOWR ( SDRAM_BASE, (2*i)+1, (uint32_t)( sample.i ) );
    
    sdramm[ (2*i)   ] = (uint32_t)( sample.r );
    asm volatile("nop");
    asm volatile("nop");
    asm volatile("nop");
    sdramm[ (2*i)+1 ] = (uint32_t)( sample.i );
}

// hier schreiben wir einen ganzen block hinein.

void sdram_write_block( uint32_t* sdramm, complex_32_t* samples, uint32_t block )
{
    //~ printf( "\n" );
    //~ printf( "sdram: about to write a block\n" );
    
    if ( 1 == is_block_empty( samples ) )
    {
        printf( ">>>>>>>>>>>>>>>>>>>>>>>> ERROR (sdram.c): sdram_write_block -> block is empty\n" );
    }
    
//     uint8_t block_cnt_before = 0;
//     uint8_t block_cnt_after = 0;
    
    uint16_t i = 0;
    
    //~ uint32_t block_base = BODY_BLOCK_OFFSET + ( block * BODY_BLOCK_SIZE_ZE );
    uint32_t block_base = block * BODY_BLOCK_SIZE_ZE;
        
//     block_cnt_before = sdram_num_filled_blocks( sdramm );
    
    //~ printf( ">>>>>>>>>>>>>>>>>>>>>>>> block cnt before %i\n", block_cnt_before );
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
	asm volatile("nop");
        (void) sdram_write( sdramm, samples[i], block_base + i );
        //~ printf( "%i\n", block_base + i );
    }
    
//     block_cnt_after = sdram_num_filled_blocks( sdramm );
    
    //~ printf( ">>>>>>>>>>>>>>>>>>>>>>>> block cnt after %i\n", block_cnt_after );
    
//     if ( (block_cnt_before+1) != block_cnt_after )
//     {
//         //~ printf( ">>>>>>>>>>>>>>>>>>>>>>>> block cnt fuck up: before %i, after %i\n", block_cnt_before, block_cnt_after );
//     }
    
    sdram_check_block( sdramm, samples, block );
}

// ---------------------------------------------------------------------
// read
// ---------------------------------------------------------------------

complex_32_t sdram_read( uint32_t* sdramm, uint32_t i )
{
    //~ printf( "sram_read: %lx\n", (4*i) );
    
    //~ return;
    
    complex_32_t c;
    
    //~ c.r = IORD ( SDRAM_BASE, (2*i)   );
    //~ c.i = IORD ( SDRAM_BASE, (2*i)+1 );
    c.r = sdramm[ (2*i)   ];
    c.i = sdramm[ (2*i)+1 ];
    
    return c;
}

void sdram_read_pointer( uint32_t* sdramm, complex_32_t* c, uint32_t i )
{
    //~ (*c).r = IORD ( SDRAM_BASE, (2*i)   );
    //~ (*c).i = IORD ( SDRAM_BASE, (2*i)+1 );
    (*c).r = sdramm[ (2*i)   ];
    (*c).i = sdramm[ (2*i)+1 ];
}

complex_32_t sdram_read_from_block( uint32_t* sdramm, uint32_t block, uint32_t i )
{
    complex_32_t c;
    
    uint32_t block_base = BODY_BLOCK_OFFSET + ( block * BODY_BLOCK_SIZE_ZE );
    
    c = sdram_read( sdramm, block_base + i );
    
    return c;
}

void sdram_read_from_block_pointer( uint32_t* sdramm, complex_32_t* c, uint32_t block, uint32_t i )
{
    //~ uint32_t block_base = BODY_BLOCK_OFFSET + ( block * BODY_BLOCK_SIZE_ZE );
    uint32_t block_base = block * BODY_BLOCK_SIZE_ZE;
    
    sdram_read_pointer( sdramm, c, block_base + i );
}

void sdram_read_block( uint32_t* sdramm, complex_32_t* samples, uint32_t block )
{
    uint16_t i = 0;
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        samples[i] = sdram_read_from_block( sdramm, block, i );
    }
}

void sdram_read_block_pointer( uint32_t* sdramm, complex_32_t* samples, uint32_t block )
{
    uint16_t i = 0;
    
    // wir gehen den ganzen block durch
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        // das was in sdramm ist wollen wir in samples[i] speichern.
        
        sdram_read_from_block_pointer( sdramm, &samples[i], block, i );
    }
}

// ---------------------------------------------------------------------
// print
// ---------------------------------------------------------------------

//~ void sdram_print( uint32_t i )
//~ {
    //~ // read real part
    
    //~ uint16_t sample_r_msb = IORD ( SRAM_0_BASE, (4*i)   );
    //~ uint16_t sample_r_lsb = IORD ( SRAM_0_BASE, (4*i)+1 );
    
    //~ // read imaginary part
    
    //~ uint16_t sample_i_msb = IORD ( SRAM_0_BASE, (4*i)+2 );
    //~ uint16_t sample_i_lsb = IORD ( SRAM_0_BASE, (4*i)+3 );
    
    //~ printf( "%x\n", sample_r_msb );
    //~ printf( "%x\n", sample_r_lsb );
    //~ printf( "%x\n", sample_i_msb );
    //~ printf( "%x\n", sample_i_lsb );
//~ }

//~ void sram_print_from_block( uint32_t block, uint32_t i )
//~ {
    //~ uint32_t block_base = block * HEADER_BLOCK_SIZE_ZE;
    
    //~ sram_print( block_base + i );
//~ }

//~ void sram_print_block( uint32_t block )
//~ {
    //~ uint16_t i = 0;
    
    //~ for ( i = 0; i < HEADER_BLOCK_SIZE_ZE; i++ )
    //~ {
        //~ sram_print_from_block( block, i );
    //~ }
//~ }

// ---------------------------------------------------------------------
// other stuff
// ---------------------------------------------------------------------

void sdram_clear_block( complex_32_t* samples )
{
    uint16_t i = 0;
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

void sdram_check_block( uint32_t* sdramm, complex_32_t* ref, uint32_t block )
{
    complex_32_t read[ BODY_BLOCK_SIZE_ZE ];
    
    sdram_read_block_pointer( sdramm, read, block );
    
    uint16_t i = 0;
    
    for ( i = 0; i < BODY_BLOCK_SIZE_ZE; i++ )
    {
        if (
            ( read[i].r != ref[i].r ) ||
            ( read[i].i != ref[i].i )
        )
        {
            printf("-----\n");
            printf( "SDRAM check block failed r: %i: read %lx | ref %lx\n", i, read[i].r, ref[i].r );
            printf( "SDRAM check block failed i: %i: read %lx | ref %lx\n", i, read[i].i, ref[i].i );
            printf("-----\n");
        }
    }
}

uint8_t sdram_num_filled_blocks( uint32_t* sdramm )
{
    uint8_t cnt = 0;
    
    uint32_t i = 0;
    
    for ( i = 0; i < (4 * BODY_BLOCK_NUM); i++ )
    {
        if ( 0 == sdram_is_block_empty( sdramm, i ) )
        {
            cnt += 1;
        }
    }
    
    return cnt;
}

uint8_t sdram_is_block_empty( uint32_t* sdramm, uint32_t block )
{
    uint32_t j = 0;
    
    complex_32_t* samples = (complex_32_t*)calloc( BODY_BLOCK_SIZE_ZE, sizeof(complex_32_t) );
    
    // make sure it is empty
    
    for ( j = 0; j < BODY_BLOCK_SIZE_ZE; j++ )
    {
        samples[ j ].r = 0;
        samples[ j ].i = 0;
    }
    
    sdram_read_block_pointer( sdramm, samples, block );
    
    return is_block_empty( samples );
}

uint8_t is_block_empty( complex_32_t* samples )
{
    uint32_t j = 0;
    
    for ( j = 0; j < BODY_BLOCK_SIZE_ZE; j++ )
    {
        if (
            ( samples[ j ].r != 0 ) ||
            ( samples[ j ].i != 0 )
        )
        {
            return 0;
        }
    }
    
    return 1;
}

void sdram_testing_set_base_address(uint32_t base, uint32_t* sdramm)
{
    printf( "----------------------------------------------------------------------------\n" );
    printf( "testing set base addr\n" );
    printf( "----------------------------------------------------------------------------\n\n" );
    
    uint32_t base_addr_check = 0;
    
    printf( "setting base address to 0x%x, %d\n", sdramm, sdramm );
    
    MAC_SDRAM_SET_BASE_ADDR( base, sdramm );
    
    printf( "base address set. wait until idle.\n" );
    
    WAIT_UNTIL_IDLE(base);
    
    printf( "waiting done. flushing cache.\n" );
    
    alt_dcache_flush_all();
    
    printf( "cache flushed. read base address.\n" );
    
    base_addr_check = IORD( base, 128 );
    
    if ( base_addr_check != (uint32_t)sdramm )
    {
      printf( ">>>>>>>>>>>>>> ERROR: base address appears to be set wrong! wrong - right : %lx - %lx\n", base_addr_check, (uint32_t)sdramm );
    }
    else
    {
      printf( "base_addr set correctly\n" );
    }
    
    P_DONE;
}

void sdram_testing_read_out(uint32_t base, uint32_t* sdramm)
{
    printf( "----------------------------------------------------------------------------\n" );
    printf( "testing read out\n" );
    printf( "----------------------------------------------------------------------------\n\n" );
    
    uint32_t check = 0;
    uint32_t i = 0;
    
    // ueber c schreibe ich werte in den sdramm. diese lese ich dann ueber das mac interface
    // zurueck.
    // als erstes wird aber noch ueberprueft ob das auch von c aus wieder richtige eingelesen
    // werden kann.
    
    printf( "writing to sdram\n" );
    
    for ( i = 0; i < (2 * 4 * (BODY_BLOCK_NUM+1) * BODY_BLOCK_SIZE_ZE); i++ )
    {
      sdramm[i] = i;
    }
    
    for ( i = 0; i < (2 * 4 * (BODY_BLOCK_NUM+1) * BODY_BLOCK_SIZE_ZE); i++ )
    {
      if ( sdramm[i] != i )
      {
        printf( ">>>>>>>>>>>>>> ERROR: Writing to SDRAM failed\n" );
      }
    }
    
    MAC_SDRAM_READ_OUT(base);
    
    WAIT_UNTIL_IDLE(base);
    alt_dcache_flush_all();
    
    printf( "started read out\n" );
    
    for ( i = 0; i < 64; i++ )
    {
//         printf( "gelesen %i: %x, %d\n", i, check, check );
        
        check = IORD( base, i );
        
        if ( sdramm[i] != check )
        {
            printf( ">>>>>>>>>>>>>> ERROR: read out from SDRAM failed\n" );
        }
    }
    
    P_DONE;
}

void sdram_testing_reset(uint32_t base, uint32_t* sdramm)
{
    printf( "----------------------------------------------------------------------------\n" );
    printf( "testing reset\n" );
    printf( "----------------------------------------------------------------------------\n\n" );
    
    uint32_t check = 0;
    uint32_t i = 0;
    
    // hier testen wir den reset der acc arrays.
    // der restliche speicher wird nicht veraendert.
    
    // wenn ich jetzt etwas raus lese sollte es 0 sein.
    
    MAC_SDRAM_RESET(base);
    
    WAIT_UNTIL_IDLE(base);
    alt_dcache_flush_all();
    
    // es gibt 2 acc arrays mit je 64 elemente
    
    for ( i = 0; i < 64*2; i++ )
    {
      check = IORD( base, i );
      
      // printf( "gelesen %i: %x, %d\n", i, base_addr_check, base_addr_check );
      
      if ( 0 != check )
      {
        printf( ">>>>>>>>>>>>>> ERROR: reset of SDRAM failed at iteration: %d\n", i );
        
        return;
      }
    }
    
    P_DONE;
}

void sdram_testing_increment(uint32_t base, uint32_t* sdramm)
{
    printf( "----------------------------------------------------------------------------\n" );
    printf( "testing increment\n" );
    printf( "----------------------------------------------------------------------------\n\n" );
    
    uint32_t check = 0;
    uint32_t i = 0;
    
    // als erstes schreiben wir wieder zahlen in den sdramm und incrementieren das dann.
    // am ende wird es wieder ueber das mac interface heraus gelesen.
    // beim herauslesen wird der ganze block genommen. also alle chunks.
    
    printf( "writing to sdram\n" );
    
    for ( i = CHUNK_OFFSET; i < BODY_TOTAL_SIZE; i++ )
    {
        sdramm[i] = i;
    }
    
    for ( i = CHUNK_OFFSET; i < BODY_TOTAL_SIZE; i++ )
    {
        if ( sdramm[i] != i )
        {
            printf( ">>>>>>>>>>>>>> ERROR: Writing to SDRAM failed\n" );
        }
    }
    
    MAC_SDRAM_CHUNK_BLOCK_INC(base);
    
    WAIT_UNTIL_IDLE(base);
    alt_dcache_flush_all();
    
    int checked = 0;
    int fails = 0;
    
    // wir ueberpruefen alle bloecke und schaun ob nur der letzte
    // um 1 erhoeht wurde.
    
    for ( i = 0; i < BODY_TOTAL_SIZE; i++ )
    {
        checked += 1;
        
        check = i;
        
        if ( i >= CHUNK_OFFSET )
        {
            check += 1;
        }
        
        if ( sdramm[i] != check )
        {
            fails += 1;
            
//             printf( "ist: 0x%x\n", sdramm[i] );
//             printf( "soll: 0x%x\n", (i+1) );
//             printf( ">>>>>>>>>>>>>> ERROR: CHUNK BLOCK INC failed at 0x%x\n", i );
        }
    }
    
    printf( "\nchecked: %i\n", checked );
    printf( "number of fails: %i\n", fails );
    
    if ( fails > 0 )
    {
        printf( "####################### FAIL\n" );
    }
    
    P_DONE;
}

void sdram_reset_all( uint32_t* sdramm )
{
    printf( "sdram_reset_all\n" );
    
    uint32_t i = 0;
    
    for ( i = 0; i < BODY_TOTAL_SIZE; i++ )
    {
        sdramm[i] = 0;
    }
    
    printf( "check blocks\n" );
    
    for ( i = 0; i < BODY_TOTAL_SIZE; i++ )
    {
        if ( sdramm[i] != 0 )
        {
            printf( ">>>>>>>>>>>>>> ERROR: resetting sdramm failed\n" );
        }
    }
}

void sdram_reset_acc( uint32_t* sdramm )
{
    printf( "sdram_reset_acc\n" );
    
//     printf( "%d\n", CHUNK_OFFSET );
//     printf( "%d\n", BODY_TOTAL_SIZE );
    
    uint32_t i = 0;
    
    for ( i = CHUNK_OFFSET; i < BODY_TOTAL_SIZE; i++ )
    {
        sdramm[ i ] = 0;
    }
    
    for ( i = CHUNK_OFFSET; i < BODY_TOTAL_SIZE; i++ )
    {
        if ( sdramm[i] != 0 )
        {
            printf( ">>>>>>>>>>>>>> ERROR: resetting sdramm acc failed\n" );
//             return;
        }
    }
}
