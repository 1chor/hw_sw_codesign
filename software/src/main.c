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
#include "kiss_fft.h"

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
    
    //~ printf("ich bin ein test\n");
    
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


void test()
{
    printf("=========================\n");
    printf("test started\n");
    printf("=========================\n");
    printf("\n");
    
    uint32_t l_buf;
    uint32_t r_buf;
    
    printf("loading ir file\n");
    struct wav* ir = wav_read("/ir_short.wav");
    printf(">done\n\n");
    
    kiss_fft_cfg kiss_cfg = kiss_fft_alloc( 512, 0, 0, 0 );
    
    kiss_fft_cpx cin[512];
    kiss_fft_cpx cout[512];
    
    uint32_t i = 0;
    
    // ich werde mal versuchen nur die linken samples zu verarbeiten.
    
    //~ uint32_t sample_counter_ir = 512;
    uint32_t sample_counter_ir = 0;
    
    // wir nehmen nur 256 da das ja zero extended sein soll.
    
    for ( i = 0; i < 256; i++ )
    {
        // wenn ich das ganze ohne den 16 left shit einlese bekomme ich
        // das aus ich auch mit hexdump aus der datei gelesen habe.
        
        //~ l_buf = wav_get_uint16( ir, 2*sample_counter_ir )<<16;
        l_buf = wav_get_uint16( ir, 2*sample_counter_ir );
        
        //~ cin[i].r = (int16_t)l_buf;
        cin[i].r = (uint16_t)l_buf;
        cin[i].i = 0x0;
        
        sample_counter_ir += 1;
    }
    
    // zero extension
    
    // wenn ich das nicht mit 0 fuelle, dann kann auch nan drinnen stehen.
    
    for ( i = 256; i < 512; i++ )
    {
        cin[i].r = 0x0;
        cin[i].i = 0x0;
    }
    
    kiss_fft( kiss_cfg, cin, cout );
    
    /* kiss fft test.
     * 
     * =====
     * float
     * -----
     * %f
     * (float)
     * =====
     * 
     * werte die ich als input verwende.
     * 
     * aus matlab:    aus c:
     *     0.00006    cin: 131072.000000
     *    -0.00003    cin: 4294901760.000000
     *     0.00000    cin: 0.000000
     *    -0.00003    cin: 4294901760.000000
     *    -0.00012    cin: 4294705152.000000
     *     0.00003    cin: 65536.000000
     *    -0.00006    cin: 4294836224.000000
     *    -0.00006    cin: 4294836224.000000
     * 
     * es sieht auf jeden fall so aus als haetten wir einen konsitenz bei dem
     * shit.
     * 
     * das heisst, dass der offset den ich gewaehlt habe mit den 512 richtig
     * zu sein scheint.
     * 
     * sehen wir uns einmal den output dazu an.
     * 
     *  aus matlab:                  aus c:
     *     4.60498 + 0.00000i         cout:  542465064960.000000 + 0.000000i
     *    -2.54973 - 3.04959i         cout: -10923509760.000000  - 353808220160.000000i
     *    -0.44168 + 2.25434i         cout: -16339774464.000000  + 7348365824.000000i
     *     0.13616 + 0.00749i         cout: -11477932032.000000  - 114444189696.000000i
     *     1.80491 + 0.65703i         cout: -25481361408.000000  + 22640885760.000000i
     *    -0.87179 - 3.18312i         cout:  3491680256.000000   - 42400972800.000000i
     *    -2.48987 + 2.89965i         cout: -4009669120.000000   + 26507876352.000000i
     *     3.51965 + 0.52373i         cout:  20267790336.000000  - 18661820416.000000i
     * 
     * jetzt wird es schwerer die zahlen zu vergleichen, da zahlen jetzt eher selten den gleichen
     * wert haben werden.
     * 
     * das erste imag ist auf jeden fall 0 was erfreulich ist.
     * 
     * warum muss das immer so ein clusterfuck sein.
     * 
     * ich werde mir mal die werte von cin in unterschliedlichen formaten anzeigen lassen.
     * 
     * %f (double) ist das gleiche
     * 
    **/
    
    /* 
     * hexdump der ir_short datei
     * 
     * 0000000 4952 4646 dc24 0005 4157 4556 6d66 2074 header
     * 0000010 0010 0000 0001 0002 bb80 0000 ee00 0002
     * 0000020 0004 0010 6164 6174 dc00 0005/-----------------
     * ------------------------------------/ 0001 0000 data
     * 0000030 fffb 0005 ffff 0005 fffa 0003 ffff fffd
     * 0000040 0002 ffff 0002 fffe 0003 fffd 0003 fffa
     * 0000050 0001 0001 0004 ffff fffc ffff 0003 0005
     * 0000060 fffc fffe fffd 0005 0004 fffb fffe 0002
     * 0000070 0002 0002 fff8 0005 0000 0003 fff9 0002
     * 0000080 0002 0000 fffc 0002 0002 fffc 0004 fffe
     * 0000090 0004 fffa 0005 fffc 0002 0000 ffff 0002
     * 00000a0 fffb 0004 0001 ffff 0000 ffff 0001 0000
     * 00000b0 fffe 0001 0000 0001 ffff fffe 0003 0000
     * 00000c0 fffd 0002 0002 fffc 0001 0002 0001 ffff
     * 00000d0 ffff 0001 fffe 0001 fffe 0002 ffff 0001
     * 00000e0 0000 fffe 0000 0000 0001 0002 ffff 0001
     * 00000f0 fffe ffff 0001 fffd 0003 0001 0000 0001
     * 0000100 fffd 0002 fffe 0004 fffb 0000 0001 0003
     * 0000110 0001 fffe ffff 0001 ffff 0000 0000 0003
     * 0000120 fffa 0003 0000 0003 fffc 0004 fffc 0002
     * 0000130 fffe 0002 ffff fffe 0000 0002 0006 fff8
     * 0000140 0000 0000 0006 fffe fffe fffd 0002 0004
     * 0000150 fffe fffc 0003 0003 fffd fffd 0006 fffd
     * 0000160 0002 fffe ffff 0002 0003 0000 fffa ffff
     * 
     * left channel:
     * 
     * 0001
     * fffb
     * ffff
     * fffa
     * ffff
     * 0002
     * 0002
     * 0003 <- bis hier ueberprueft
     * 0003
     * 0001
     * 0004
     * fffc
     * 0003
     * fffc
     * fffd
     * 0004
     * fffe
     * 0002
     * fff8
     * 0000
     * fff9
     * 0002
     * 
     * wenn ich das beim einlesen nicht um 16 schifte, dann bekomme ich
     * auf jeden fall die richtigen hex zahlen.
     * 
     * bei:
     * %x (int16_t)
     * 
    **/
    
    printf( "cin: %x + i*%x\n", (int16_t)cin[0].r, (int16_t)cin[0].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[1].r, (int16_t)cin[1].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[2].r, (int16_t)cin[2].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[3].r, (int16_t)cin[3].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[4].r, (int16_t)cin[4].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[5].r, (int16_t)cin[5].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[6].r, (int16_t)cin[6].i );
    printf( "cin: %x + i*%x\n", (int16_t)cin[7].r, (int16_t)cin[7].i );
    
    return;
    
    printf("loading input file\n");
    struct wav* input = wav_read("/input.wav");
    printf(">done\n\n");
    
    
    
    uint32_t sample_counter = 0;
    uint32_t samples_in_file = wav_sample_count(input);
    
    printf("preparing output file\n");
    struct wav* output = wav_new( samples_in_file, 2, input->header->sample_rate, input->header->bps);
    printf(">done\n\n");
    
    printf("processing starting\n");
    
    while (1)
    {
        l_buf = wav_get_uint16(input, 2*sample_counter)<<16;
        r_buf = wav_get_uint16(input, 2*sample_counter+1)<<16;
        
        ((uint16_t*)output->samples)[2*sample_counter]   = (uint16_t)(l_buf>>16);
        ((uint16_t*)output->samples)[2*sample_counter+1] = (uint16_t)(r_buf>>16);
        
        sample_counter += 1;
        
        if ( sample_counter >= samples_in_file )
        {
            printf(">done\n\n");
            
            break;
        }
    }
    
    printf("storing file\n");
    wav_write("/recording.wav", output);
    printf(">done\n\n");
    
    wav_free(output);
    
    printf("===\n");
    printf("end\n");
    printf("===\n");
    
}

