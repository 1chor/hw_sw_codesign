
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

