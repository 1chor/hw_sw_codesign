
#ifndef _DISPLAY_H_
#define _DISPLAY_H_

#include "system.h"
#include "io.h"
#include <stdint.h>

void display_init();
void display_clear();
void display_print(char* txt);
void display_move_cursor(uint32_t x, uint32_t y);
void display_clear_line(uint32_t line);
void display_clear_lines(uint32_t start, uint32_t end);
void display_set_colors(uint8_t fg, uint8_t bg);

#endif



