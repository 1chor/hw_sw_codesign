
#include "display.h"


#define INSTR_CFG         0x4
#define INSTR_MOVE_CURSOR 0x3
#define INSTR_CLEAR       0x2
#define INSTR_PUT_CHAR    0x1


uint32_t color_config = 0x30 << 16;

void display_init()
{
	// wait while textmode controller is busy
	while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
	// INSTR_CFG (0x04) cursor blink, auto scroll, auto increment cursor, cursor color 3
	IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x00033300 | INSTR_CFG);
	// wait while textmode controller is busy
	while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
}

void display_clear()
{
	display_move_cursor(0,0);
	// wait while textmode controller is busy
	while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
	IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE, 0, INSTR_CLEAR | (0<<8) | color_config);
}

void display_print(char* txt)
{
	int i;
	char s;

	i = 0;
	s = txt[i++];
	while (s != '\0') {
		// wait while textmode controller is busy
		while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);

		if (s == '\n') {
			IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE,0,0x7 | color_config);
		} else {
			IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE, 0, INSTR_PUT_CHAR | (s<<8) | color_config);
		}
		s = txt[i++];
	}
}

void display_move_cursor(uint32_t x, uint32_t y)
{
	while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
	// INSTR_CFG (0x04) cursor blink, auto scroll, auto increment cursor, cursor color 3
	IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE, 0, INSTR_MOVE_CURSOR | (x<<16) | (y<<8));
}

void display_clear_line(uint32_t line)
{
	display_move_cursor(0,line);
	for(int i=0; i<99; i++){
		while (IORD_32DIRECT(TEXTMODE_CONTROLLER_BASE,0) == 0x01);
		IOWR_32DIRECT(TEXTMODE_CONTROLLER_BASE, 0, INSTR_PUT_CHAR | (' '<<8) | (color_config));
	}
}

void display_clear_lines(uint32_t start, uint32_t end)
{
	for (;start < end; start++ ){
		display_clear_line(start);
	}
}


void display_set_colors(uint8_t fg, uint8_t bg)
{
	color_config = (((fg & 0xf)<<4) | (bg & 0xf)) << 16;
}

