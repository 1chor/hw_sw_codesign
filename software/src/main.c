#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include <math.h>

#include "Altera_UP_SD_Card_Avalon_Interface.h"
#include "altera_up_avalon_audio.h"

#include "fatlib/fat_filelib.h"
#include "wav.h"
#include "display.h"

#include "fir.h"

#include "kiss_fft.h"
#include "fft_fp.h"

#include "fixed_point.h"
#include "sram.h"
#include "complex.h"

#define FIR_HW (0) 	 // If 1 then use FIR filter Hardware component
#define FFT_H_HW (0) // If 1 then use header FFT Hardware component
#define FFT_B_HW (0) // If 1 then use body FFT Hardware component

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

void pre_process_h_header( struct wav* );
void process_header_block( kiss_fft_cpx*, kiss_fft_cpx*, uint8_t, uint8_t );
void ifft_on_mac_buffer( uint16_t*, uint16_t*, complex_32_t*, complex_32_t* );

void freq_mac_blocks( complex_32_t*, uint32_t, uint32_t );
void print_c_block_9q23( complex_32_t*, uint16_t, uint16_t );

void zero_extend_256( kiss_fft_cpx* );

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
    
    test();

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
            //~ line_in_demo();
            test();
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
    
    while (1)
    {
        int wr_fifospace = alt_up_audio_write_fifo_space (audio_dev, ALT_UP_AUDIO_RIGHT);
        
        if ( wr_fifospace > 0 )
        {
            l_buf = wav_get_uint16(input, 2*sample_counter)<<16;
            r_buf = wav_get_uint16(input, 2*sample_counter+1)<<16;
            
            sample_counter++;
            
            //~ printf("0x%x\n", l_buf);
            
            // write audio buffer
            
            alt_up_audio_write_fifo (audio_dev, &(r_buf), 1, ALT_UP_AUDIO_RIGHT);
            alt_up_audio_write_fifo (audio_dev, &(l_buf), 1, ALT_UP_AUDIO_LEFT);
        }
        
        if (get_button() == 4 || sample_counter >= samples_in_file)
        {
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

void pre_process_h_header( struct wav* ir )
{
    uint16_t l_buf;
    uint16_t r_buf;
    
    uint16_t i = 0;
    
    uint8_t header_blocks_h_i = 0;
    
    for ( header_blocks_h_i = 0; header_blocks_h_i < 14; header_blocks_h_i ++ )
    {
        printf( "pre-processing block: %i | %i\n", header_blocks_h_i, 14+header_blocks_h_i );
        
        kiss_fft_cpx* cin_1 = (kiss_fft_cpx*)calloc( 512, sizeof(kiss_fft_cpx) );
        kiss_fft_cpx* cin_2 = (kiss_fft_cpx*)calloc( 512, sizeof(kiss_fft_cpx) );
        
        // ich muss hier bei 512 anfange, da die geraden indices immer
        // die linken samples beinhalten
        
        uint32_t sample_counter_ir = 512 + ( header_blocks_h_i * 256 );
        
        // wir nehmen nur 256 da das ja zero extended sein soll.
        
        for ( i = 0; i < 256; i++ )
        {
            l_buf = wav_get_uint16( ir, 2*sample_counter_ir );
            r_buf = wav_get_uint16( ir, 2*sample_counter_ir+1 );
            
            // convert the binary value to float
            
            //~ printf( "l_buf[%d]: %lx\n", 512+( header_blocks_h_i * 256 )+i, l_buf );
            //~ printf( "r_buf[%d]: %lx\n", 512+( header_blocks_h_i * 256 )+i, r_buf );
            
            cin_1[i].r = convert_1q15(l_buf);
            cin_1[i].i = 0;
            
            cin_2[i].r = convert_1q15(r_buf);
            cin_2[i].i = 0;
            
            sample_counter_ir += 1;
        }
        
        // cin_X will be freed in func
        
        process_header_block( cin_1, cin_2, header_blocks_h_i, 1 );
    }
}

void process_header_block( kiss_fft_cpx* in_1, kiss_fft_cpx* in_2, uint8_t block, uint8_t free_input )
{
    uint16_t i = 0;
    
    kiss_fft_cfg kiss_cfg = kiss_fft_alloc( 512, 0, 0, 0 );
    
    kiss_fft_cpx* out_1 = (kiss_fft_cpx*)calloc( 512, sizeof(kiss_fft_cpx) );
    kiss_fft_cpx* out_2 = (kiss_fft_cpx*)calloc( 512, sizeof(kiss_fft_cpx) );
    
    zero_extend_256( in_1 );
    zero_extend_256( in_2 );
    
    kiss_fft( kiss_cfg, in_1, out_1 );
    kiss_fft( kiss_cfg, in_2, out_2 );
    
    if ( free_input == 1 )
    {
        free( in_1 );
        free( in_2 );
    }
    
    free( kiss_cfg );
    
    complex_32_t* samples_1 = (complex_32_t*)calloc( 512, sizeof(complex_32_t) );
    complex_32_t* samples_2 = (complex_32_t*)calloc( 512, sizeof(complex_32_t) );
    
    for ( i = 0; i < 512; i++ )
    {
        samples_1[i].r = convert_to_fixed_9q23( out_1[i].r );
        samples_1[i].i = convert_to_fixed_9q23( out_1[i].i );
        
        
        //~ print_c_block_9q23( samples_1, i, i );
        
        samples_2[i].r = convert_to_fixed_9q23( out_2[i].r );
        samples_2[i].i = convert_to_fixed_9q23( out_2[i].i );
        printf( "%lx %lx i\n", samples_2[i].r, samples_2[i].i );
    }
    
    free( out_1 );
    free( out_2 );
    
    // der block wird gespeichert
    // TODO - in der finalen version wird das gemacht waehrend
    // die MAC im freq bereich laeuft. vll sollte das hier auch
    // schon irgendwie dargestellt werden.
    
    printf( "writing block to %i | %i\n", block, 14 + block );
    
    (void) sram_write_block( samples_1, block );
    (void) sram_write_block( samples_2, 14 + block );
    
    free( samples_1 );
    free( samples_2 );
}

void ifft_on_mac_buffer( uint16_t* mac_buffer_16_1, uint16_t* mac_buffer_16_2, complex_32_t* mac_buffer_1, complex_32_t* mac_buffer_2 )
{
    uint16_t i = 0;
    
    complex_float_t* f_1 = (complex_float_t*)malloc( 512 * sizeof(complex_float_t) );
    complex_float_t* f_2 = (complex_float_t*)malloc( 512 * sizeof(complex_float_t) );
    
    for ( i = 0; i < 512; i++ )
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
    
    free( mac_buffer_1 );
    free( mac_buffer_2 );
    
    (void) fft_cfp( f_1, 9, 1 );
    (void) fft_cfp( f_2, 9, 1 );
    
    // ---------------------------------------------------------
    // C O N V E R T   T O   1 6   B I T   F I X E D
    // ---------------------------------------------------------
    
    // versuchen die floats auf 1q15 zu bekommen.
    
    for ( i = 0; i < 512; i++ )
    {
        mac_buffer_16_1[i] = convert_to_fixed_1q15( f_1[i].real );
        mac_buffer_16_2[i] = convert_to_fixed_1q15( f_2[i].real );
    }
    
    free( f_1 );
    free( f_2 );
}



void test()
{
    printf("=========================\n");
    printf("test started\n");
    printf("=========================\n");
    printf("\n");
    
    uint16_t l_buf;
    uint16_t r_buf;
    
    printf("loading ir file\n");
    struct wav* ir = wav_read("/ir_short.wav");
    printf(">done\n\n");
    
    // das 2. argument gibt an ob es eine inverse fft ist
    
    kiss_fft_cfg kiss_cfg = kiss_fft_alloc( 512, 0, 0, 0 );
    
    uint32_t i = 0;
    uint32_t j = 0;
    uint32_t k = 0;
    
    printf( "pre-processing header blocks (H)\n" );
	
	#if ( FFT_H_HW ) // Hardware Header-FFT 
	
		pre_process_h_header_hw( ir );
	
	#else // Software Header-FFT
	
		pre_process_h_header( ir );
	
	#endif
    
    //~ complex_32_t test_samples[512];
    //~ sram_read_block(test_samples, 2);
    //~ print_c_block_9q23( test_samples, 10, 20 );
    
    //~ printf("-----------\n");
    
    //~ complex_32_t test_samples_2[512];
    //~ sram_read_block(test_samples_2, 14 + 2);
    //~ print_c_block_9q23( test_samples_2, 10, 20 );
    
    //~ return;
    
    printf(">done\n\n");
    
    //~ printf( "SRAM test\n" );
    //~ (void) sram_test();
    //~ printf(">done\n\n");
    
    printf( "clearing SRAM for input data\n" );
    complex_32_t* dummy_samples = (complex_32_t*)malloc(512 * sizeof(complex_32_t));
    sram_clear_block( dummy_samples );
    
    // 28 - 41 input left
    // 42 - 55 input right
    
    for ( i = 28; i < 56; i++ )
    {
        sram_write_block( dummy_samples, i );
    }
    free( dummy_samples );
    printf(">done\n\n");
    
    printf("loading input file\n");
    //~ struct wav* input = wav_read("/input.wav");
    struct wav* input = wav_read("/ir_cave.wav");
    printf(">done\n\n");
    
    // =========================================================
    // F I R
    // =========================================================
    
    printf( "fir\n" );
    
    #if ( FIR_HW ) // Hardware FIR
		
		fir_filter_setup_hw( ir, 0 ); // init FIR filter for left channel
		fir_filter_setup_hw( ir, 1 ); // init FIR filter for right channel
    
    #else // Software FIR
		
		// wird fuer das setup benoetigt.
		
		uint16_t* fir_h_1 = (uint16_t*)calloc( 512, sizeof(uint16_t) );
		uint16_t* fir_h_2 = (uint16_t*)calloc( 512, sizeof(uint16_t) );
		
		// wird unten bei dem endless loop als shift reg verwendet.
		
		uint16_t* fir_i_1 = (uint16_t*)calloc( 512, sizeof(uint16_t) );
		uint16_t* fir_i_2 = (uint16_t*)calloc( 512, sizeof(uint16_t) );
		
		fir_filter_setup_sw( fir_h_1, fir_h_2, ir );
    
    #endif
    
    // wird auch bei dem endless loop verwendet.
    
    int32_t sample_result_1 = 0;
    int32_t sample_result_2 = 0;
    
    printf(">done\n\n");
    
    // wir brauchen das ir file ab hier nicht mehr.
    
    wav_free( ir );
    
    // =========================================================
    // F F T
    // =========================================================
    
    uint32_t samples_in_file = wav_sample_count(input);
    
    //~ printf("preparing output file\n");
    //~ struct wav* output = wav_new( samples_in_file, 2, input->header->sample_rate, input->header->bps);
    //~ printf(">done\n\n");
    
    uint16_t output_buffer_header_1[2048];
    uint16_t output_buffer_header_2[2048];
    
    for ( i = 0; i < 2048; i++ )
    {
        output_buffer_header_1[i] = 0;
        output_buffer_header_2[i] = 0;
    }
    
    // das sollte jetzt zwar ungenau, aber immer noch richtig abgespeichert geworden sein.
    
    printf( "das haben wir jetzt im output buffer\n" );
    
    //~ for ( i = 10; i < 20; i++ )
    //~ {
        //~ float fuck_me;
        //~ convert_2q30_pointer( &fuck_me, (uint32_t)fir_output_32_1[i] );
        //~ printf( "%f bzw.: %f\n", fuck_me, convert_1q15(output_buffer_header_1[i]) );
    //~ }
    
    //~ for ( i = 740; i < 760; i++ )
    //~ {
        //~ printf( "%f\n", convert_1q15(output_buffer_header_1[i]) );
    //~ }
    
    //~ printf( "%f\n", convert_1q15( output_buffer_header[240] ) );
    
    
    uint32_t sample_counter = 0;
    uint32_t sample_counter_local = 0;
    
    //~ kiss_fft_cpx i_in_1[512];
    //~ kiss_fft_cpx i_in_2[512];
    
    // freed at the end of the endless loop
    
     #if ( FFT_H_HW ) // Hardware Header-FFT
     
		complex_16_t* i_in_1 = (complex_16_t*)malloc( 512 * sizeof(complex_16_t) );
		complex_16_t* i_in_2 = (complex_16_t*)malloc( 512 * sizeof(complex_16_t) );
    
    #else // Software Header-FFT
    
		kiss_fft_cpx* i_in_1 = (kiss_fft_cpx*)malloc( 512 * sizeof(kiss_fft_cpx) );
		kiss_fft_cpx* i_in_2 = (kiss_fft_cpx*)malloc( 512 * sizeof(kiss_fft_cpx) );
    
    #endif
    
    // der input block wird dort gespeichert
    
    uint8_t i_pointer = 41;
    uint8_t ibi = 41;
    
    uint32_t i_h = 0;
    
    uint8_t asdf = 0;
    
    // ---------------------------------------------------------
    // R E A D I N G   I   S A M P L E S
    // ---------------------------------------------------------
    
    //~ int32_t sample_result_1 = 0;
    //~ int32_t sample_result_2 = 0;
    
    while (1)
    {
        l_buf = wav_get_uint16(input, 2*sample_counter);
        r_buf = wav_get_uint16(input, 2*sample_counter+1);
        
        #if ( FFT_H_HW ) // Hardware Header-FFT 
			
			i_in_1[sample_counter_local].r = l_buf;
			i_in_1[sample_counter_local].i = 0;
			
			i_in_2[sample_counter_local].r = r_buf;
			i_in_2[sample_counter_local].i = 0;
		
		#else // Software Header-FFT

			i_in_1[sample_counter_local].r = convert_1q15(l_buf);
			i_in_1[sample_counter_local].i = 0;
			
			i_in_2[sample_counter_local].r = convert_1q15(r_buf);
			i_in_2[sample_counter_local].i = 0;
		
		#endif
                
        sample_counter_local += 1;
        
        // fir
        
        
        
		#if ( FIR_HW ) // Hardware FIR
        
			// zur sicherheit werden die sample results auf 0 gesetzt.
			
			sample_result_1 = 0;
			sample_result_2 = 0;
			
			// die neuen results werden berechnet.

			fir_filter_sample_hw
			(
				 &sample_result_1
				,&sample_result_2
				,l_buf
				,r_buf
			);
			
         #else // Software FIR
			
			// wie ein shiftregister werden die samples weiter geschoben
			// und das neue hinten dran gehaengt.
        
			for ( j = 1; j < 512; j++ )
			{
				fir_i_1[j-1] = fir_i_1[j];
				fir_i_2[j-1] = fir_i_2[j];
			}
			
			fir_i_1[511] = l_buf;
			fir_i_2[511] = r_buf;
			
			// zur sicherheit werden die sample results auf 0 gesetzt.
			
			sample_result_1 = 0;
			sample_result_2 = 0;
			
			// die neuen results werden berechnet.
			// da es keinen bestimmten speicher fuer den fir gibt wird alles
			// als pointer uebergeben.
			
			fir_filter_sample_sw
			(
				 &sample_result_1
				,&sample_result_2
				,fir_i_1
				,fir_i_2
				,fir_h_1
				,fir_h_2
			);
			
        #endif
        
        // Ausgabe linker Channel
        //~ float f;
        //~ convert_2q30_pointer( &f, sample_result_1);
        //~ printf( "Sample %d: %f\n", sample_counter_local, f );
        //~ printf( "l_buf[%d]: %lx\n", sample_counter_local, l_buf );
        //~ printf( "l_buf_32[%d]: %lx\n", sample_counter_local, (uint32_t)l_buf );
        //~ printf( "Sample %d: %lx\n", sample_counter_local, sample_result_1 );
        
        //--------------------------------------------------------------
        //
        //	
        //	Casts überprüfen, wenn uint16 auf int32 gecastet wird ist der Wert falsch!
        //	Richtig (int32)((int16)(val_uint16))
        //
        //
        //--------------------------------------------------------------
                
        // die neuen fir filter samples werden an den output addiert.
        // das ganze casten dient zur vermeidung von fehlern und ist
        // wahrscheinlich nicht noetig.
        
        int16_t sample_result_16_1 = (int16_t)(sample_result_1>>15);
        int16_t sample_result_16_2 = (int16_t)(sample_result_2>>15);
        
        output_buffer_header_1[sample_counter] = (int16_t)output_buffer_header_1[sample_counter] + sample_result_16_1;
        output_buffer_header_2[sample_counter] = (int16_t)output_buffer_header_2[sample_counter] + sample_result_16_2;
        
        // wir haben einen ganzen block
        
        if (
            ( ((sample_counter+1) % 256) == 0 ) &&
            ( sample_counter > 0 )
        )
        {
            // ---------------------------------------------------------
            // P R O C E S S I N G   I   B L O C K
            // ---------------------------------------------------------
            
            sample_counter_local = 0;
            
            printf( "full header I block collected\n" );
            
            // fft and save block
			
			#if ( FFT_H_HW ) // Hardware Header-FFT 
			
				process_header_block_hw( i_in_1, i_in_2, i_pointer, 0 );
			
			#else // Software Header-FFT
	
				process_header_block( i_in_1, i_in_2, i_pointer, 0 );
			
			#endif
            
            // ---------------------------------------------------------
            // F R E Q U E N C Y   M A C
            // ---------------------------------------------------------
            
            // clear output buffer nachdem er angelegt wurde
            // behebt dinge die eigentlich durch timig shit verursacht werden
            
            // freed in ifft_on_mac_buffer func
            
            complex_32_t* mac_buffer_1 = (complex_32_t*)malloc( 512 * sizeof(complex_32_t) );
            complex_32_t* mac_buffer_2 = (complex_32_t*)malloc( 512 * sizeof(complex_32_t) );
            
            sram_clear_block( mac_buffer_1 );
            sram_clear_block( mac_buffer_2 );
            
            // index der I bloecke.
            // wir beginnen mit dem neusten, also nehmen wir die addr
            // wo gerade der block gespeichert wurde.
            
            ibi = i_pointer;
            
            // wir gehen alle ir blocks durch
            
            printf( "performing mac\n" );
            
            for ( j = 0; j < 14; j++ )
            {
                freq_mac_blocks( mac_buffer_1, ibi, j );
                freq_mac_blocks( mac_buffer_2, 14 + ibi, 14 + j );
                
                // der naechste i block der geholt wird.
                // die i bloecke werden in einem ringbuffer abgespeichert
                // den wir von der akteullen position nach hinten
                // durchlaufen.
                // wenn der neue I block auf 42 gespeichert wurde, dann
                // ist der vorige auf addr 41 und der davor auf 28.
                // anmerkung: wir speichern genau so viele I bloecke
                // wie H bloecke.
                
                //~ print_c_block_9q23( output_buffer_2, 10, 20 );
                //~ return;
                
                if ( ibi == 28 ) { ibi = 41; }
                else             { ibi -= 1; }
            }
            
            // ---------------------------------------------------------
            // I F F T
            // ---------------------------------------------------------
            
            // jetzt ist die ganze mac fertig und wir koennen einen ifft
            // machen.
            
            printf( "performing ifft\n" );
            
            uint16_t* mac_buffer_16_1 = (uint16_t*)malloc( 512 * sizeof(uint16_t) );
            uint16_t* mac_buffer_16_2 = (uint16_t*)malloc( 512 * sizeof(uint16_t) );
            
            ifft_on_mac_buffer( mac_buffer_16_1, mac_buffer_16_2, mac_buffer_1, mac_buffer_2 );
            
            // beim vergleich mit octave sieht es bei den ersten samples so
            // aus als waeren diese falsch. das stimmt nicht, in c werden sie
            // einfach nur mehr als 0 wahrgenommen waehrend in octave noch
            // ein wert angezeigt werden kann. z.b. groessenordnung e-09
            
            //~ printf( "%i - %i\n", 512 + (i_h*256), 512 + ((i_h+2)*256) );
            
            printf( "das habe wir im output buffer:\n\n" );
            
            printf( "bevor die neuen fft werte addiert werden\n" );
            
            for ( i = 740; i < 760; i++ )
            {
                printf( "%f\n", convert_1q15(output_buffer_header_1[i]) );
            }
            
            uint16_t ii = 0;
            
            //~ for ( i = (i_h*256); i < ((i_h+2)*256); i++ )
            for ( i = 512 + (i_h*256); i < 512 + ((i_h+2)*256); i++ )
            {
                output_buffer_header_1[i] = (int16_t)output_buffer_header_1[i] + (int16_t)mac_buffer_16_1[ii];
                output_buffer_header_2[i] = (int16_t)output_buffer_header_2[i] + (int16_t)mac_buffer_16_2[ii];
                
                ii += 1;
            }
            
            printf("----------------\nnachdem die neuen fft werte addiert wurden.\n");
            
            for ( i = 740; i < 760; i++ )
            {
                printf( "%f\n", convert_1q15(output_buffer_header_1[i]) );
            }
            
            free( mac_buffer_16_1 );
            free( mac_buffer_16_2 );
            
            i_h += 1;
            
            // das ist die block addr wo der naechste i block
            // abgespeichert wird.
            // die bloecke befinden sich in einem ringbuffer.
            // daher wird die addr auf 28 gesetzt wenn man am ende (41)
            // angekommen ist.
            
            if ( i_pointer == 41 ) { i_pointer = 28; }
            else                   { i_pointer += 1; }
            
            asdf += 1;
            
            if ( asdf == 3 )
            {
                printf( "======\n" );
                printf( "fertig\n" );
                printf( "======\n\n" );
                
                printf( "der 740. wert sollte 0.388245 sein!\n" );
                
                float test_value = convert_1q15( output_buffer_header_1[740] );
                
                float diff = test_value - 0.388245;
                
                if ( diff < 0 )
                {
                    diff *= -1;
                }
                
                if ( diff < 0.000001 )
                {
                    printf( "PASST\n" );
                }
                else
                {
                    printf( "PASST NICHT! der wert ist: %f\n", test_value );
                }
                
                //~ for ( i = 740; i < 760; i++ )
                //~ {
                    //~ printf( "%f\n", convert_1q15( output_buffer_header_1[i] ) );
                //~ }
                return;
            }
            
            printf( ">done\n\n" );
        }
        
        if ( sample_counter >= samples_in_file )
        {
            printf(">done done\n\n");
            
            break;
        }
        
        sample_counter += 1;
    }
    
    free( i_in_1 );
    free( i_in_2 );
    
    return;
    
    //~ uint32_t sample_counter = 0;
    //~ uint32_t samples_in_file = wav_sample_count(input);
    
    //~ printf("preparing output file\n");
    //~ struct wav* output = wav_new( samples_in_file, 2, input->header->sample_rate, input->header->bps);
    //~ printf(">done\n\n");
    
    //~ printf("processing starting\n");
    
    //~ while (1)
    //~ {
        //~ l_buf = wav_get_uint16(input, 2*sample_counter)<<16;
        //~ r_buf = wav_get_uint16(input, 2*sample_counter+1)<<16;
        
        //~ ((uint16_t*)output->samples)[2*sample_counter]   = (uint16_t)(l_buf>>16);
        //~ ((uint16_t*)output->samples)[2*sample_counter+1] = (uint16_t)(r_buf>>16);
        
        //~ sample_counter += 1;
        
        //~ if ( sample_counter >= samples_in_file )
        //~ {
            //~ printf(">done\n\n");
            
            //~ break;
        //~ }
    //~ }
    
    //~ printf("storing file\n");
    //~ wav_write("/recording.wav", output);
    //~ printf(">done\n\n");
    
    //~ wav_free(output);
    
    //~ printf("===\n");
    //~ printf("end\n");
    //~ printf("===\n");
    
}

void freq_mac_blocks( complex_32_t* output_buffer, uint32_t ibi, uint32_t j )
{
    //~ printf("%i / 13 | ", j);
    //~ printf( "in_block %i | ir_block %i\n", ibi, j );
    
    // get ir and in blocks from sram
    
    complex_32_t mul_temp;
    //~ complex_32_t in_block[512];
    //~ complex_32_t ir_block[512];
    
    complex_32_t* in_block = (complex_32_t*)malloc( 512 * sizeof(complex_32_t) );
    complex_32_t* ir_block = (complex_32_t*)malloc( 512 * sizeof(complex_32_t) );
    
    (void) sram_read_block( in_block, ibi );
    (void) sram_read_block( ir_block,   j );
    
    // perform mul for each sample
    
    //~ complex_32_t a;
    //~ complex_32_t b;
    
    uint16_t k = 0;
    
    for ( k = 0; k < 512; k++ )
    {
        //~ a = sram_read_from_block( ibi, k );
        //~ b = sram_read_from_block(   j, k );
        
        mul_temp = c_mul( in_block[k], ir_block[k] );
        //~ mul_temp = c_mul( a, b );
        
        output_buffer[k].r += mul_temp.r;
        output_buffer[k].i += mul_temp.i;
    }
    
    free( in_block );
    free( ir_block );
}

void print_c_block_9q23( complex_32_t* samples, uint16_t start, uint16_t end )
{
    uint16_t i = 0;
    
    for ( i = start; i < end+1; i++ )
    {
        float temp_r;
        float temp_i;
        
        convert_9q23_pointer( &temp_r, samples[i].r );
        convert_9q23_pointer( &temp_i, samples[i].i );
        
        printf( "%f %f i\n", temp_r, temp_i );
    }
}

void zero_extend_256( kiss_fft_cpx* samples )
{
    uint16_t i = 0;
    
    for ( i = 256; i < 512; i++ )
    {
        samples[i].r = 0;
        samples[i].i = 0;
    }
}

