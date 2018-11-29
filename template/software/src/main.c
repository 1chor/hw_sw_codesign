#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"


#include "Altera_UP_SD_Card_Avalon_Interface.h"
#include "altera_up_avalon_audio.h"

#include "fatlib/fat_filelib.h"
#include "wav.h"
#include "display.h"


#define HAL_PLATFORM_RESET() \
  NIOS2_WRITE_STATUS(0); \
  NIOS2_WRITE_IENABLE(0); \
  ((void (*) (void)) NIOS2_RESET_ADDR) ()


#define FAT_OFFSET 0

alt_up_audio_dev * audio_dev;


extern volatile char *buffer_memory;
extern bool Write_Sector_Data(int sector_index, int partition_offset);
extern bool Read_Sector_Data(int sector_index, int partition_offset);

int media_init();
int media_read(unsigned long sector, unsigned char *buffer, unsigned long sector_count);
int media_write(unsigned long sector, unsigned char *buffer, unsigned long sector_count);

void print_ui(int view);
int get_button();
void line_in_demo();
void play_file_demo();
void record_demo();

int main()
{
	display_init();
	display_set_colors(10,0);
	display_clear();
	display_print("HW/SW Co-Design Maintask Template\n");
	
	printf("Initializing SD card and file system ... ");
	
	media_init(); // Initialise media
	fl_init(); // Initialise File IO Library

	// Attach media access functions to library
	if (fl_attach_media(media_read, media_write) != FAT_INIT_OK) {
		printf("ERROR: Media attach failed\n");
	}
	printf("done\n");

	printf("SD card contents:");
	fl_listdirectory("/");  // List root directory

	printf("Initializing audio device ... ");
	// open the Audio port
	audio_dev = alt_up_audio_open_dev ("/dev/audio");
	if ( audio_dev == NULL) {
		alt_printf ("Error: could not open audio device \n");
	} else {
		alt_printf ("done\n");
	}

	print_ui(0);
	display_move_cursor(0,1);
	display_print("ready!");

	IOWR(TOUCH_CNTRL_BASE,0,-1); //reset touch srceen
	int button_idx = -1;

	while(1){
		
		//touch screen pressed?
		button_idx = get_button();
		
		switch(button_idx){
		case 0:
			line_in_demo();
			break;
		case 1:
			play_file_demo();
			break;
		case 2:
			record_demo();
			break;
		case 3:
			HAL_PLATFORM_RESET();
			break;
		}
		
		if(button_idx >= 0){
			//restore UI
			print_ui(0);
			display_clear_lines(1,5);
			display_move_cursor(0,1);
			display_print("ready!");
		}
	}
}

int media_init()
{
	alt_up_sd_card_dev *device_reference = alt_up_sd_card_open_dev(SDCARD_INTERFACE_NAME);
	if (device_reference != NULL) {
		return 1;
	}
	return 0;
}

int media_read(unsigned long sector, unsigned char *buffer, unsigned long sector_count)
{
	unsigned long i;
	for (i=0;i<sector_count;i++) {
		Read_Sector_Data((int)(sector), FAT_OFFSET);
		
		/*for(int j=0; j<512; j++) { //copy one byte at a time 
			buffer[j] = IORD_8DIRECT(buffer_memory,j); //buffer_memory[j];
		}*/
		for(int j=0; j<512; j+=4) { //copy 4 bytes at a time
			((uint32_t*)&buffer[j])[0] = IORD_32DIRECT(buffer_memory,j); //bypass data cache
		}
		
		sector ++;
		buffer += 512;
	}
	return 1;
}

int media_write(unsigned long sector, unsigned char *buffer, unsigned long sector_count)
{
	unsigned long i;
	for (i=0;i<sector_count;i++) {
		for(int j=0; j<512; j++){
			IOWR_8DIRECT(buffer_memory, j, buffer[j]);
			//buffer_memory[j] = buffer[j]; //does not bypass cache
		}
		
		Write_Sector_Data((int)(sector), FAT_OFFSET);
		
		sector ++;
		buffer += 512;
	}
	return 1;
}

void print_ui(int view)
{
	display_move_cursor(0,23);
	display_print(" +----------------+  +----------------+  +----------------+  +----------------+  +----------------+ ");
	display_print(" |                |  |                |  |                |  |                |  |                | ");
	switch(view){
	case 0:
	display_print(" |  play line-in  |  |   play file    |  |     record     |  |     reset      |  |                | ");
	break;
	case 1:
	display_print(" |                |  |                |  |                |  |                |  |      back      | ");
	break;
	}
	display_print(" |                |  |                |  |                |  |                |  |                | ");
	display_print(" +----------------+  +----------------+  +----------------+  +----------------+  +----------------+ ");
}

int get_button()
{
	int button_idx = -1;
	if( IORD(TOUCH_CNTRL_BASE, 0) ) {
		int x_raw = IORD(TOUCH_CNTRL_BASE,2);
		int y_raw = IORD(TOUCH_CNTRL_BASE,3);
		//printf("x=%x, y=%x\n", x_raw, y_raw);
		if ( y_raw < 0x300) {
			button_idx = x_raw/820;
			//printf("button %x\n", button_idx);
		}
		
		IOWR(TOUCH_CNTRL_BASE,0,-1);
	}
	return button_idx;
}

void line_in_demo()
{
	print_ui(1);
	display_clear_lines(1,5);
	display_move_cursor(0,1);
	display_print("passing through data from line-in (blue connector) ... ");
	
	uint32_t l_buf;
	uint32_t r_buf;
	
	while (1) {
		int rd_fifospace = alt_up_audio_read_fifo_avail (audio_dev, ALT_UP_AUDIO_RIGHT);
		int wr_fifospace = alt_up_audio_write_fifo_space (audio_dev, ALT_UP_AUDIO_RIGHT);
		if ( rd_fifospace > 0 && wr_fifospace > 0 ) {
			// read audio buffer
			alt_up_audio_read_fifo (audio_dev, &(r_buf), 1, ALT_UP_AUDIO_RIGHT);
			alt_up_audio_read_fifo (audio_dev, &(l_buf), 1, ALT_UP_AUDIO_LEFT);
			
			// write audio buffer
			alt_up_audio_write_fifo (audio_dev, &(r_buf), 1, ALT_UP_AUDIO_RIGHT);
			alt_up_audio_write_fifo (audio_dev, &(l_buf), 1, ALT_UP_AUDIO_LEFT);
		}
		
		if (get_button() == 4) {
			break;
		}
	}
}

void play_file_demo()
{
	print_ui(1);
	uint32_t l_buf;
	uint32_t r_buf;
	
	display_clear_lines(1,5);
	display_move_cursor(0,1);
	
	display_print("loading file ... ");
	struct wav* input = wav_read("/input.wav");
	display_print("done\n");
	display_print("playing file");
	
	uint32_t sample_counter = 0;
	uint32_t samples_in_file = wav_sample_count(input);
	
	while (1) {
		int wr_fifospace = alt_up_audio_write_fifo_space (audio_dev, ALT_UP_AUDIO_RIGHT);
		if ( wr_fifospace > 0 ) {
			l_buf = wav_get_uint16(input, 2*sample_counter)<<16;
			r_buf = wav_get_uint16(input, 2*sample_counter+1)<<16;
			sample_counter++;
			
			// write audio buffer
			alt_up_audio_write_fifo (audio_dev, &(r_buf), 1, ALT_UP_AUDIO_RIGHT);
			alt_up_audio_write_fifo (audio_dev, &(l_buf), 1, ALT_UP_AUDIO_LEFT);
		}
		
		if (get_button() == 4 || sample_counter >= samples_in_file) {
			break;
		}
	}
}

void record_demo()
{
	print_ui(1);
	uint32_t l_buf;
	uint32_t r_buf;
	
	display_clear_lines(1,5);
	display_move_cursor(0,1);
	
	display_print("recording 2s of line-in ... ");
	
	uint32_t number_samples = 48000*2; //4 seconds of data
	struct wav* output = wav_new(number_samples, 2, 48000, 16);
	uint32_t sample_counter = 0;

	while (1) {
		int rd_fifospace = alt_up_audio_read_fifo_avail (audio_dev, ALT_UP_AUDIO_RIGHT);
		if ( rd_fifospace > 0 ) {
			//sample_counter += 2;
			
			// read audio buffer
			alt_up_audio_read_fifo (audio_dev, &(r_buf), 1, ALT_UP_AUDIO_RIGHT);
			alt_up_audio_read_fifo (audio_dev, &(l_buf), 1, ALT_UP_AUDIO_LEFT);
			
			((uint16_t*)output->samples)[2*sample_counter]   = (uint16_t)(r_buf>>16);
			((uint16_t*)output->samples)[2*sample_counter+1] = (uint16_t)(l_buf>>16);
			sample_counter ++;
		}
		
		if (sample_counter >= number_samples) {
			break;
		}
		
		if (get_button() == 4) {
			return;
		}
	}
	
	display_print("done\n");
	display_print("storing file ... ");
	wav_write("/recording.wav", output);

	wav_free(output);

}


