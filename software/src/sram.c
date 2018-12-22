
#include <inttypes.h>

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "sram.h"

void sram_write( complex_32_t sample, uint32_t i )
{
    // write real part
    
    IOWR ( SRAM_0_BASE, i  , (uint16_t)( sample.r >> 16) );
    IOWR ( SRAM_0_BASE, i+1, (uint16_t)( sample.r      ) );
    
    // write imaginary part
    
    IOWR ( SRAM_0_BASE, i+2, (uint16_t)( sample.i >> 16) );
    IOWR ( SRAM_0_BASE, i+3, (uint16_t)( sample.i      ) );
}

complex_32_t sram_read( uint32_t i )
{
    complex_32_t c;
    
    // read real part
    
    uint16_t sample_r_msb = IORD ( SRAM_0_BASE, i   );
    uint16_t sample_r_lsb = IORD ( SRAM_0_BASE, i+1 );
    
    c.r = ( sample_r_msb << 16 ) | sample_r_lsb;
    
    // read imaginary part
    
    uint16_t sample_i_msb = IORD ( SRAM_0_BASE, i+2 );
    uint16_t sample_i_lsb = IORD ( SRAM_0_BASE, i+3 );
    
    c.i = ( sample_i_msb << 16 ) | sample_i_lsb;
    
    return c;
}
