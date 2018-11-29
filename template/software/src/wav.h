#ifndef _WAV_H_
#define _WAV_H_

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>


struct wav_header
{
	char chunk_id[4];        /* Contains the letters "RIFF" */
	uint32_t chunk_size;
	char format[4];          /* Contains the letters "WAVE" */
	
	/*fmt chunk*/
	char fmtchunk_id[4];     /* Contains the letters "fmt " */
	uint32_t fmtchunk_size;  /* size of the fmt chunk in bytes*/
	uint16_t audio_format;   /* 1=PCM, other values not supported*/
	uint16_t num_channels;   /* 1=mono, 2=stereo*/
	uint32_t sample_rate;    /* samples per second*/
	uint32_t byte_rate;      /* bytes per second*/
	uint16_t block_align;    /* number of bytes for one sample: (num_channels * bps/8) */ 
	uint16_t bps;            /* bits per sample (8,16,...)*/
	
	/*data chunk*/
	char datachunk_id[4];    /* Contains the letters "data" */
	uint32_t datachunk_size; /* size of following data in bytes: sample_count * num_channels * bps/8 */
};

struct wav
{
	struct wav_header *header;
	uint8_t *samples; 
};

#define wav_get_int16(wav,index)  (((int16_t*)wav->samples)[(index)])
#define wav_get_uint16(wav,index) (((uint16_t*)wav->samples)[(index)])
#define wav_get_int32(wav,index)  (((int32_t*)wav->samples)[(index)])
#define wav_get_uint32(wav,index) (((uint32_t*)wav->samples)[(index)])

#define wav_set_int16(wav,index,value)  (((int16_t*)wav->samples)[(index)])=value

//#define NIOS2

#if defined(NIOS2)
	#include "fatlib/fat_filelib.h"
	#define _FOPEN_   fl_fopen
	#define _FCLOSE_  fl_fclose
	#define _FILE_    FL_FILE
	#define _FREAD_   fl_fread
	#define _FWRITE_  fl_fwrite
#else
	#define _FOPEN_   fopen
	#define _FCLOSE_  fclose
	#define _FILE_    FILE
	#define _FREAD_   fread
	#define _FWRITE_  fwrite
#endif


struct wav * wav_read(char *file_name);
struct wav * wav_new(uint32_t sample_number, uint16_t num_channels, uint32_t sample_rate, uint8_t bps);
void wav_free(struct wav *w);
uint32_t wav_write(char *file_name, struct wav *w);
uint32_t wav_sample_count(struct wav* w);
void wav_print_info(struct wav * w);


#endif

