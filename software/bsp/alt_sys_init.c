/*
 * alt_sys_init.c - HAL initialization source
 *
 * Machine generated for CPU 'nios2' in SOPC Builder design 'reverb_template'
 * SOPC Builder design path: ../../quartus/reverb_template.sopcinfo
 *
 * Generated: Tue Aug 13 14:51:53 CEST 2019
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#include "system.h"
#include "sys/alt_irq.h"
#include "sys/alt_sys_init.h"

#include <stddef.h>

/*
 * Device headers
 */

#include "altera_nios2_gen2_irq.h"
#include "Altera_UP_SD_Card_Avalon_Interface.h"
#include "altera_avalon_fifo.h"
#include "altera_avalon_jtag_uart.h"
#include "altera_up_avalon_audio.h"
#include "altera_up_avalon_audio_and_video_config.h"

/*
 * Allocate the device storage
 */

ALTERA_NIOS2_GEN2_IRQ_INSTANCE ( NIOS2, nios2);
ALTERA_AVALON_FIFO_INSTANCE ( M2S_FIFO_FFTB, m2s_fifo_fftb);
ALTERA_AVALON_FIFO_INSTANCE ( M2S_FIFO_FFTH, m2s_fifo_ffth);
ALTERA_AVALON_FIFO_INSTANCE ( M2S_FIFO_FIR_L, m2s_fifo_fir_l);
ALTERA_AVALON_FIFO_INSTANCE ( M2S_FIFO_FIR_R, m2s_fifo_fir_r);
ALTERA_AVALON_FIFO_INSTANCE ( S2M_FIFO_FFTB, s2m_fifo_fftb);
ALTERA_AVALON_FIFO_INSTANCE ( S2M_FIFO_FFTH, s2m_fifo_ffth);
ALTERA_AVALON_FIFO_INSTANCE ( S2M_FIFO_FIR_L, s2m_fifo_fir_l);
ALTERA_AVALON_FIFO_INSTANCE ( S2M_FIFO_FIR_R, s2m_fifo_fir_r);
ALTERA_AVALON_JTAG_UART_INSTANCE ( JTAG_UART, jtag_uart);
ALTERA_UP_AVALON_AUDIO_AND_VIDEO_CONFIG_INSTANCE ( AV_CONFIG, av_config);
ALTERA_UP_AVALON_AUDIO_INSTANCE ( AUDIO, audio);
ALTERA_UP_SD_CARD_AVALON_INTERFACE_INSTANCE ( SDCARD_INTERFACE, sdcard_interface);

/*
 * Initialize the interrupt controller devices
 * and then enable interrupts in the CPU.
 * Called before alt_sys_init().
 * The "base" parameter is ignored and only
 * present for backwards-compatibility.
 */

void alt_irq_init ( const void* base )
{
    ALTERA_NIOS2_GEN2_IRQ_INIT ( NIOS2, nios2);
    alt_irq_cpu_enable_interrupts();
}

/*
 * Initialize the non-interrupt controller devices.
 * Called after alt_irq_init().
 */

void alt_sys_init( void )
{
    ALTERA_AVALON_FIFO_INIT ( M2S_FIFO_FFTB, m2s_fifo_fftb);
    ALTERA_AVALON_FIFO_INIT ( M2S_FIFO_FFTH, m2s_fifo_ffth);
    ALTERA_AVALON_FIFO_INIT ( M2S_FIFO_FIR_L, m2s_fifo_fir_l);
    ALTERA_AVALON_FIFO_INIT ( M2S_FIFO_FIR_R, m2s_fifo_fir_r);
    ALTERA_AVALON_FIFO_INIT ( S2M_FIFO_FFTB, s2m_fifo_fftb);
    ALTERA_AVALON_FIFO_INIT ( S2M_FIFO_FFTH, s2m_fifo_ffth);
    ALTERA_AVALON_FIFO_INIT ( S2M_FIFO_FIR_L, s2m_fifo_fir_l);
    ALTERA_AVALON_FIFO_INIT ( S2M_FIFO_FIR_R, s2m_fifo_fir_r);
    ALTERA_AVALON_JTAG_UART_INIT ( JTAG_UART, jtag_uart);
    ALTERA_UP_AVALON_AUDIO_AND_VIDEO_CONFIG_INIT ( AV_CONFIG, av_config);
    ALTERA_UP_AVALON_AUDIO_INIT ( AUDIO, audio);
    ALTERA_UP_SD_CARD_AVALON_INTERFACE_INIT ( SDCARD_INTERFACE, sdcard_interface);
}
