
#ifndef __DEFINES_H__
#define __DEFINES_H__

// Defines for setup
#define FIR_HW (1) 	// If 1 then use FIR filter hardware component
#define FFT_H_HW (1) 	// If 1 then use header FFT hardware component
#define FFT_B_HW (1) 	// If 1 then use body FFT hardware component
#define MAC_H_HW (1) 	// If 1 then use MAC hardware component
#define MAC_B_HW (1) 	// If 1 then use MAC hardware component

#define P_DONE printf(">done\n\n")
#define P_DEAC printf(">DEACTIVATED\n\n");


#define FIR_SIZE (512)

#define HEADER_BLOCK_SIZE    (256)
#define HEADER_BLOCK_SIZE_ZE (512)

#define HEADER_BLOCK_NUM    (14)
#define HEADER_IN_BLOCK_MIN (28)
#define HEADER_IN_BLOCK_MAX (41)


#define HEADER_BLOCK_ADDR_ALIGN  (4)

// 2048 bloecke
#define BODY_BLOCK_OFFSET (1900) // wtf?

#define BODY_BLOCK_SIZE    (4096)
#define BODY_BLOCK_SIZE_ZE (8192)

#define BODY_BLOCK_NUM     (23)
#define BODY_IN_BLOCK_MIN  (46)
#define BODY_IN_BLOCK_MAX  (68)

#define CHUNK_BLOCK (1)

// other stuff about blocks

#define STEREO_BLOCKS     (2)
#define IR_AND_IN_BLOCKS  (2)

#define BYTE_ADDRESSED    (4) // sollte in der sw fuer den body auf jeden fall egal sein.
#define REAL_IMAG_SAMPLES (2)

// wir haben BODY_BLOCK_NUM blocks und brauchen diese in stero und fuer in und ir.

#define TOTAL_BLOCK_NUM      ( (BODY_BLOCK_NUM * IR_AND_IN_BLOCKS * STEREO_BLOCKS) + CHUNK_BLOCK )
#define BODY_TOTAL_SIZE      ( REAL_IMAG_SAMPLES * TOTAL_BLOCK_NUM * BODY_BLOCK_SIZE_ZE )

// fuer chunk offset einfach den chunk block von der groesse abziehen.
// wir brauchen das auch 2 mal, weil wir ja real und imag abspeichern muessen. auf jeden fall glaube
// ich, dass das so gehoert.

#define CHUNK_OFFSET ( BODY_TOTAL_SIZE - ( 2 * CHUNK_BLOCK * BODY_BLOCK_SIZE_ZE ) )

#define CHUNK_BLOCK_INDEX ( ( BODY_IN_BLOCK_MAX + BODY_BLOCK_NUM ) + 1 )

// #define CHUNK_OFFSET ( 1507328 )

#define FREE_INPUT (1)
#define NOT_FREE_INPUT (0)

#define MAC_SDRAM_RESET             IOWR( BODY_MAC_0_BASE,  1, 0 )
#define MAC_SDRAM_SET_LEFT_CHANNEL  IOWR( BODY_MAC_0_BASE,  3, 0 )
#define MAC_SDRAM_SET_RIGHT_CHANNEL IOWR( BODY_MAC_0_BASE,  5, 0 )
#define MAC_SDRAM_START             IOWR( BODY_MAC_0_BASE,  7, 0 )
#define MAC_SDRAM_READ_OUT          IOWR( BODY_MAC_0_BASE,  9, 0 )
#define MAC_SDRAM_CHUNK_BLOCK_INC   IOWR( BODY_MAC_0_BASE, 11, 0 )

#define MAC_SDRAM_SET_BASE_ADDR(addr) IOWR( BODY_MAC_0_BASE, 13, addr )

#define WAIT_UNTIL_IDLE while ( 1 != IORD( BODY_MAC_0_BASE, 129 ) ) {}

#define HEADER_MAC_ADDRESS_STATE (1700)

#endif

