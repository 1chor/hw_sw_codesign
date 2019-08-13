#ifndef _SDRAM_H_
#define _SDRAM_H_

#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "complex.h"

void         sdram_write( uint32_t*, complex_32_t, uint32_t );
void         sdram_write_block( uint32_t*, complex_32_t*, uint32_t );

complex_32_t sdram_read( uint32_t*, uint32_t );
void         sdram_read_pointer( uint32_t*, complex_32_t*, uint32_t );

complex_32_t sdram_read_from_block( uint32_t*, uint32_t, uint32_t );
void         sdram_read_from_block_pointer( uint32_t*, complex_32_t*, uint32_t, uint32_t );

void         sdram_read_block( uint32_t*, complex_32_t*, uint32_t );
void         sdram_read_block_pointer( uint32_t*, complex_32_t*, uint32_t );


//~ void         sram_print( uint32_t );
//~ void         sram_print_from_block( uint32_t, uint32_t );
//~ void         sram_print_block( uint32_t );

void         sdram_clear_block( complex_32_t* );

void         sdram_check_block( uint32_t*, complex_32_t*, uint32_t );

uint8_t      sdram_num_filled_blocks( uint32_t* );
uint8_t      sdram_is_block_empty( uint32_t*, uint32_t );
uint8_t      is_block_empty( complex_32_t* );

void sdram_testing_set_base_address( uint32_t, uint32_t* );
void sdram_testing_read_out( uint32_t, uint32_t* );
void sdram_testing_reset( uint32_t, uint32_t* );
void sdram_testing_increment( uint32_t, uint32_t* );

void sdram_reset_all( uint32_t* );
void sdram_reset_acc( uint32_t* );

#endif
