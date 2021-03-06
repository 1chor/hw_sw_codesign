/*
 * system.h - SOPC Builder system and BSP software package information
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

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x08280820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1c
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00000020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 2048
#define ALT_CPU_INST_ADDR_WIDTH 0x1c
#define ALT_CPU_NAME "nios2"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x08280820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1c
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00000020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 2048
#define NIOS2_INST_ADDR_WIDTH 0x1c
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_FIFO
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_UP_AVALON_AUDIO
#define __ALTERA_UP_AVALON_AUDIO_AND_VIDEO_CONFIG
#define __ALTERA_UP_SD_CARD_AVALON_INTERFACE
#define __ALTPLL
#define __AVALON_TOUCH_CNTRL
#define __BODY_MAC
#define __FIR
#define __HEADER_MAC
#define __MULTIPLEXER_SRAM
#define __TEXTMODE_CONTROLLER


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_IRQ_BASE NULL
#define ALT_LEGACY_INTERRUPT_API_PRESENT
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x82824f0
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x82824f0
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x82824f0
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "reverb_template"


/*
 * altpll configuration
 *
 */

#define ALTPLL_BASE 0x8282460
#define ALTPLL_IRQ -1
#define ALTPLL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALTPLL_NAME "/dev/altpll"
#define ALTPLL_SPAN 16
#define ALTPLL_TYPE "altpll"
#define ALT_MODULE_CLASS_altpll altpll


/*
 * altpll_sram configuration
 *
 */

#define ALTPLL_SRAM_BASE 0x8282470
#define ALTPLL_SRAM_IRQ -1
#define ALTPLL_SRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALTPLL_SRAM_NAME "/dev/altpll_sram"
#define ALTPLL_SRAM_SPAN 16
#define ALTPLL_SRAM_TYPE "altpll"
#define ALT_MODULE_CLASS_altpll_sram altpll


/*
 * audio configuration
 *
 */

#define ALT_MODULE_CLASS_audio altera_up_avalon_audio
#define AUDIO_BASE 0x82824a0
#define AUDIO_IRQ 2
#define AUDIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define AUDIO_NAME "/dev/audio"
#define AUDIO_SPAN 16
#define AUDIO_TYPE "altera_up_avalon_audio"


/*
 * av_config configuration
 *
 */

#define ALT_MODULE_CLASS_av_config altera_up_avalon_audio_and_video_config
#define AV_CONFIG_BASE 0x8282490
#define AV_CONFIG_IRQ -1
#define AV_CONFIG_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AV_CONFIG_NAME "/dev/av_config"
#define AV_CONFIG_SPAN 16
#define AV_CONFIG_TYPE "altera_up_avalon_audio_and_video_config"


/*
 * body_mac_0 configuration
 *
 */

#define ALT_MODULE_CLASS_body_mac_0 body_mac
#define BODY_MAC_0_BASE 0x8200000
#define BODY_MAC_0_IRQ -1
#define BODY_MAC_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BODY_MAC_0_NAME "/dev/body_mac_0"
#define BODY_MAC_0_SPAN 262144
#define BODY_MAC_0_TYPE "body_mac"


/*
 * fir_l configuration
 *
 */

#define ALT_MODULE_CLASS_fir_l fir
#define FIR_L_BASE 0x8281800
#define FIR_L_IRQ -1
#define FIR_L_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FIR_L_NAME "/dev/fir_l"
#define FIR_L_SPAN 2048
#define FIR_L_TYPE "fir"


/*
 * fir_r configuration
 *
 */

#define ALT_MODULE_CLASS_fir_r fir
#define FIR_R_BASE 0x8281000
#define FIR_R_IRQ -1
#define FIR_R_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FIR_R_NAME "/dev/fir_r"
#define FIR_R_SPAN 2048
#define FIR_R_TYPE "fir"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * header_mac_0 configuration
 *
 */

#define ALT_MODULE_CLASS_header_mac_0 header_mac
#define HEADER_MAC_0_BASE 0x8240000
#define HEADER_MAC_0_IRQ -1
#define HEADER_MAC_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define HEADER_MAC_0_NAME "/dev/header_mac_0"
#define HEADER_MAC_0_SPAN 262144
#define HEADER_MAC_0_TYPE "header_mac"


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x82824f0
#define JTAG_UART_IRQ 4
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * m2s_fifo_fftb configuration
 *
 */

#define ALT_MODULE_CLASS_m2s_fifo_fftb altera_avalon_fifo
#define M2S_FIFO_FFTB_AVALONMM_AVALONMM_DATA_WIDTH 32
#define M2S_FIFO_FFTB_AVALONMM_AVALONST_DATA_WIDTH 32
#define M2S_FIFO_FFTB_BASE 0x82824b8
#define M2S_FIFO_FFTB_BITS_PER_SYMBOL 32
#define M2S_FIFO_FFTB_CHANNEL_WIDTH 0
#define M2S_FIFO_FFTB_ERROR_WIDTH 0
#define M2S_FIFO_FFTB_FIFO_DEPTH 64
#define M2S_FIFO_FFTB_IRQ -1
#define M2S_FIFO_FFTB_IRQ_INTERRUPT_CONTROLLER_ID -1
#define M2S_FIFO_FFTB_NAME "/dev/m2s_fifo_fftb"
#define M2S_FIFO_FFTB_SINGLE_CLOCK_MODE 1
#define M2S_FIFO_FFTB_SPAN 8
#define M2S_FIFO_FFTB_SYMBOLS_PER_BEAT 1
#define M2S_FIFO_FFTB_TYPE "altera_avalon_fifo"
#define M2S_FIFO_FFTB_USE_AVALONMM_READ_SLAVE 0
#define M2S_FIFO_FFTB_USE_AVALONMM_WRITE_SLAVE 1
#define M2S_FIFO_FFTB_USE_AVALONST_SINK 0
#define M2S_FIFO_FFTB_USE_AVALONST_SOURCE 1
#define M2S_FIFO_FFTB_USE_BACKPRESSURE 1
#define M2S_FIFO_FFTB_USE_IRQ 0
#define M2S_FIFO_FFTB_USE_PACKET 0
#define M2S_FIFO_FFTB_USE_READ_CONTROL 0
#define M2S_FIFO_FFTB_USE_REGISTER 1
#define M2S_FIFO_FFTB_USE_WRITE_CONTROL 0


/*
 * m2s_fifo_ffth configuration
 *
 */

#define ALT_MODULE_CLASS_m2s_fifo_ffth altera_avalon_fifo
#define M2S_FIFO_FFTH_AVALONMM_AVALONMM_DATA_WIDTH 32
#define M2S_FIFO_FFTH_AVALONMM_AVALONST_DATA_WIDTH 32
#define M2S_FIFO_FFTH_BASE 0x82824e8
#define M2S_FIFO_FFTH_BITS_PER_SYMBOL 32
#define M2S_FIFO_FFTH_CHANNEL_WIDTH 0
#define M2S_FIFO_FFTH_ERROR_WIDTH 0
#define M2S_FIFO_FFTH_FIFO_DEPTH 64
#define M2S_FIFO_FFTH_IRQ -1
#define M2S_FIFO_FFTH_IRQ_INTERRUPT_CONTROLLER_ID -1
#define M2S_FIFO_FFTH_NAME "/dev/m2s_fifo_ffth"
#define M2S_FIFO_FFTH_SINGLE_CLOCK_MODE 1
#define M2S_FIFO_FFTH_SPAN 8
#define M2S_FIFO_FFTH_SYMBOLS_PER_BEAT 1
#define M2S_FIFO_FFTH_TYPE "altera_avalon_fifo"
#define M2S_FIFO_FFTH_USE_AVALONMM_READ_SLAVE 0
#define M2S_FIFO_FFTH_USE_AVALONMM_WRITE_SLAVE 1
#define M2S_FIFO_FFTH_USE_AVALONST_SINK 0
#define M2S_FIFO_FFTH_USE_AVALONST_SOURCE 1
#define M2S_FIFO_FFTH_USE_BACKPRESSURE 1
#define M2S_FIFO_FFTH_USE_IRQ 0
#define M2S_FIFO_FFTH_USE_PACKET 0
#define M2S_FIFO_FFTH_USE_READ_CONTROL 0
#define M2S_FIFO_FFTH_USE_REGISTER 1
#define M2S_FIFO_FFTH_USE_WRITE_CONTROL 0


/*
 * m2s_fifo_fir_l configuration
 *
 */

#define ALT_MODULE_CLASS_m2s_fifo_fir_l altera_avalon_fifo
#define M2S_FIFO_FIR_L_AVALONMM_AVALONMM_DATA_WIDTH 32
#define M2S_FIFO_FIR_L_AVALONMM_AVALONST_DATA_WIDTH 32
#define M2S_FIFO_FIR_L_BASE 0x82824e0
#define M2S_FIFO_FIR_L_BITS_PER_SYMBOL 32
#define M2S_FIFO_FIR_L_CHANNEL_WIDTH 0
#define M2S_FIFO_FIR_L_ERROR_WIDTH 0
#define M2S_FIFO_FIR_L_FIFO_DEPTH 32
#define M2S_FIFO_FIR_L_IRQ -1
#define M2S_FIFO_FIR_L_IRQ_INTERRUPT_CONTROLLER_ID -1
#define M2S_FIFO_FIR_L_NAME "/dev/m2s_fifo_fir_l"
#define M2S_FIFO_FIR_L_SINGLE_CLOCK_MODE 1
#define M2S_FIFO_FIR_L_SPAN 8
#define M2S_FIFO_FIR_L_SYMBOLS_PER_BEAT 1
#define M2S_FIFO_FIR_L_TYPE "altera_avalon_fifo"
#define M2S_FIFO_FIR_L_USE_AVALONMM_READ_SLAVE 0
#define M2S_FIFO_FIR_L_USE_AVALONMM_WRITE_SLAVE 1
#define M2S_FIFO_FIR_L_USE_AVALONST_SINK 0
#define M2S_FIFO_FIR_L_USE_AVALONST_SOURCE 1
#define M2S_FIFO_FIR_L_USE_BACKPRESSURE 1
#define M2S_FIFO_FIR_L_USE_IRQ 0
#define M2S_FIFO_FIR_L_USE_PACKET 0
#define M2S_FIFO_FIR_L_USE_READ_CONTROL 0
#define M2S_FIFO_FIR_L_USE_REGISTER 1
#define M2S_FIFO_FIR_L_USE_WRITE_CONTROL 0


/*
 * m2s_fifo_fir_r configuration
 *
 */

#define ALT_MODULE_CLASS_m2s_fifo_fir_r altera_avalon_fifo
#define M2S_FIFO_FIR_R_AVALONMM_AVALONMM_DATA_WIDTH 32
#define M2S_FIFO_FIR_R_AVALONMM_AVALONST_DATA_WIDTH 32
#define M2S_FIFO_FIR_R_BASE 0x82824d8
#define M2S_FIFO_FIR_R_BITS_PER_SYMBOL 32
#define M2S_FIFO_FIR_R_CHANNEL_WIDTH 0
#define M2S_FIFO_FIR_R_ERROR_WIDTH 0
#define M2S_FIFO_FIR_R_FIFO_DEPTH 32
#define M2S_FIFO_FIR_R_IRQ -1
#define M2S_FIFO_FIR_R_IRQ_INTERRUPT_CONTROLLER_ID -1
#define M2S_FIFO_FIR_R_NAME "/dev/m2s_fifo_fir_r"
#define M2S_FIFO_FIR_R_SINGLE_CLOCK_MODE 1
#define M2S_FIFO_FIR_R_SPAN 8
#define M2S_FIFO_FIR_R_SYMBOLS_PER_BEAT 1
#define M2S_FIFO_FIR_R_TYPE "altera_avalon_fifo"
#define M2S_FIFO_FIR_R_USE_AVALONMM_READ_SLAVE 0
#define M2S_FIFO_FIR_R_USE_AVALONMM_WRITE_SLAVE 1
#define M2S_FIFO_FIR_R_USE_AVALONST_SINK 0
#define M2S_FIFO_FIR_R_USE_AVALONST_SOURCE 1
#define M2S_FIFO_FIR_R_USE_BACKPRESSURE 1
#define M2S_FIFO_FIR_R_USE_IRQ 0
#define M2S_FIFO_FIR_R_USE_PACKET 0
#define M2S_FIFO_FIR_R_USE_READ_CONTROL 0
#define M2S_FIFO_FIR_R_USE_REGISTER 1
#define M2S_FIFO_FIR_R_USE_WRITE_CONTROL 0


/*
 * multiplexer_sram_0 configuration
 *
 */

#define ALT_MODULE_CLASS_multiplexer_sram_0 multiplexer_sram
#define MULTIPLEXER_SRAM_0_BASE 0x8000000
#define MULTIPLEXER_SRAM_0_IRQ -1
#define MULTIPLEXER_SRAM_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MULTIPLEXER_SRAM_0_NAME "/dev/multiplexer_sram_0"
#define MULTIPLEXER_SRAM_0_SPAN 2097152
#define MULTIPLEXER_SRAM_0_TYPE "multiplexer_sram"


/*
 * pio_b configuration
 *
 */

#define ALT_MODULE_CLASS_pio_b altera_avalon_pio
#define PIO_B_BASE 0x8282440
#define PIO_B_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_B_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_B_CAPTURE 0
#define PIO_B_DATA_WIDTH 1
#define PIO_B_DO_TEST_BENCH_WIRING 0
#define PIO_B_DRIVEN_SIM_VALUE 0
#define PIO_B_EDGE_TYPE "NONE"
#define PIO_B_FREQ 100000000
#define PIO_B_HAS_IN 0
#define PIO_B_HAS_OUT 1
#define PIO_B_HAS_TRI 0
#define PIO_B_IRQ -1
#define PIO_B_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_B_IRQ_TYPE "NONE"
#define PIO_B_NAME "/dev/pio_b"
#define PIO_B_RESET_VALUE 0
#define PIO_B_SPAN 16
#define PIO_B_TYPE "altera_avalon_pio"


/*
 * pio_h configuration
 *
 */

#define ALT_MODULE_CLASS_pio_h altera_avalon_pio
#define PIO_H_BASE 0x8282450
#define PIO_H_BIT_CLEARING_EDGE_REGISTER 0
#define PIO_H_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PIO_H_CAPTURE 0
#define PIO_H_DATA_WIDTH 1
#define PIO_H_DO_TEST_BENCH_WIRING 0
#define PIO_H_DRIVEN_SIM_VALUE 0
#define PIO_H_EDGE_TYPE "NONE"
#define PIO_H_FREQ 100000000
#define PIO_H_HAS_IN 0
#define PIO_H_HAS_OUT 1
#define PIO_H_HAS_TRI 0
#define PIO_H_IRQ -1
#define PIO_H_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PIO_H_IRQ_TYPE "NONE"
#define PIO_H_NAME "/dev/pio_h"
#define PIO_H_RESET_VALUE 0
#define PIO_H_SPAN 16
#define PIO_H_TYPE "altera_avalon_pio"


/*
 * s2m_fifo_fftb configuration
 *
 */

#define ALT_MODULE_CLASS_s2m_fifo_fftb altera_avalon_fifo
#define S2M_FIFO_FFTB_AVALONMM_AVALONMM_DATA_WIDTH 32
#define S2M_FIFO_FFTB_AVALONMM_AVALONST_DATA_WIDTH 32
#define S2M_FIFO_FFTB_BASE 0x82824b0
#define S2M_FIFO_FFTB_BITS_PER_SYMBOL 32
#define S2M_FIFO_FFTB_CHANNEL_WIDTH 0
#define S2M_FIFO_FFTB_ERROR_WIDTH 0
#define S2M_FIFO_FFTB_FIFO_DEPTH 64
#define S2M_FIFO_FFTB_IRQ -1
#define S2M_FIFO_FFTB_IRQ_INTERRUPT_CONTROLLER_ID -1
#define S2M_FIFO_FFTB_NAME "/dev/s2m_fifo_fftb"
#define S2M_FIFO_FFTB_SINGLE_CLOCK_MODE 1
#define S2M_FIFO_FFTB_SPAN 8
#define S2M_FIFO_FFTB_SYMBOLS_PER_BEAT 1
#define S2M_FIFO_FFTB_TYPE "altera_avalon_fifo"
#define S2M_FIFO_FFTB_USE_AVALONMM_READ_SLAVE 1
#define S2M_FIFO_FFTB_USE_AVALONMM_WRITE_SLAVE 0
#define S2M_FIFO_FFTB_USE_AVALONST_SINK 1
#define S2M_FIFO_FFTB_USE_AVALONST_SOURCE 0
#define S2M_FIFO_FFTB_USE_BACKPRESSURE 1
#define S2M_FIFO_FFTB_USE_IRQ 0
#define S2M_FIFO_FFTB_USE_PACKET 0
#define S2M_FIFO_FFTB_USE_READ_CONTROL 0
#define S2M_FIFO_FFTB_USE_REGISTER 1
#define S2M_FIFO_FFTB_USE_WRITE_CONTROL 0


/*
 * s2m_fifo_ffth configuration
 *
 */

#define ALT_MODULE_CLASS_s2m_fifo_ffth altera_avalon_fifo
#define S2M_FIFO_FFTH_AVALONMM_AVALONMM_DATA_WIDTH 32
#define S2M_FIFO_FFTH_AVALONMM_AVALONST_DATA_WIDTH 32
#define S2M_FIFO_FFTH_BASE 0x82824d0
#define S2M_FIFO_FFTH_BITS_PER_SYMBOL 32
#define S2M_FIFO_FFTH_CHANNEL_WIDTH 0
#define S2M_FIFO_FFTH_ERROR_WIDTH 0
#define S2M_FIFO_FFTH_FIFO_DEPTH 64
#define S2M_FIFO_FFTH_IRQ -1
#define S2M_FIFO_FFTH_IRQ_INTERRUPT_CONTROLLER_ID -1
#define S2M_FIFO_FFTH_NAME "/dev/s2m_fifo_ffth"
#define S2M_FIFO_FFTH_SINGLE_CLOCK_MODE 1
#define S2M_FIFO_FFTH_SPAN 8
#define S2M_FIFO_FFTH_SYMBOLS_PER_BEAT 1
#define S2M_FIFO_FFTH_TYPE "altera_avalon_fifo"
#define S2M_FIFO_FFTH_USE_AVALONMM_READ_SLAVE 1
#define S2M_FIFO_FFTH_USE_AVALONMM_WRITE_SLAVE 0
#define S2M_FIFO_FFTH_USE_AVALONST_SINK 1
#define S2M_FIFO_FFTH_USE_AVALONST_SOURCE 0
#define S2M_FIFO_FFTH_USE_BACKPRESSURE 1
#define S2M_FIFO_FFTH_USE_IRQ 0
#define S2M_FIFO_FFTH_USE_PACKET 0
#define S2M_FIFO_FFTH_USE_READ_CONTROL 0
#define S2M_FIFO_FFTH_USE_REGISTER 1
#define S2M_FIFO_FFTH_USE_WRITE_CONTROL 0


/*
 * s2m_fifo_fir_l configuration
 *
 */

#define ALT_MODULE_CLASS_s2m_fifo_fir_l altera_avalon_fifo
#define S2M_FIFO_FIR_L_AVALONMM_AVALONMM_DATA_WIDTH 32
#define S2M_FIFO_FIR_L_AVALONMM_AVALONST_DATA_WIDTH 32
#define S2M_FIFO_FIR_L_BASE 0x82824c8
#define S2M_FIFO_FIR_L_BITS_PER_SYMBOL 32
#define S2M_FIFO_FIR_L_CHANNEL_WIDTH 0
#define S2M_FIFO_FIR_L_ERROR_WIDTH 0
#define S2M_FIFO_FIR_L_FIFO_DEPTH 32
#define S2M_FIFO_FIR_L_IRQ -1
#define S2M_FIFO_FIR_L_IRQ_INTERRUPT_CONTROLLER_ID -1
#define S2M_FIFO_FIR_L_NAME "/dev/s2m_fifo_fir_l"
#define S2M_FIFO_FIR_L_SINGLE_CLOCK_MODE 1
#define S2M_FIFO_FIR_L_SPAN 8
#define S2M_FIFO_FIR_L_SYMBOLS_PER_BEAT 1
#define S2M_FIFO_FIR_L_TYPE "altera_avalon_fifo"
#define S2M_FIFO_FIR_L_USE_AVALONMM_READ_SLAVE 1
#define S2M_FIFO_FIR_L_USE_AVALONMM_WRITE_SLAVE 0
#define S2M_FIFO_FIR_L_USE_AVALONST_SINK 1
#define S2M_FIFO_FIR_L_USE_AVALONST_SOURCE 0
#define S2M_FIFO_FIR_L_USE_BACKPRESSURE 1
#define S2M_FIFO_FIR_L_USE_IRQ 0
#define S2M_FIFO_FIR_L_USE_PACKET 0
#define S2M_FIFO_FIR_L_USE_READ_CONTROL 0
#define S2M_FIFO_FIR_L_USE_REGISTER 1
#define S2M_FIFO_FIR_L_USE_WRITE_CONTROL 0


/*
 * s2m_fifo_fir_r configuration
 *
 */

#define ALT_MODULE_CLASS_s2m_fifo_fir_r altera_avalon_fifo
#define S2M_FIFO_FIR_R_AVALONMM_AVALONMM_DATA_WIDTH 32
#define S2M_FIFO_FIR_R_AVALONMM_AVALONST_DATA_WIDTH 32
#define S2M_FIFO_FIR_R_BASE 0x82824c0
#define S2M_FIFO_FIR_R_BITS_PER_SYMBOL 32
#define S2M_FIFO_FIR_R_CHANNEL_WIDTH 0
#define S2M_FIFO_FIR_R_ERROR_WIDTH 0
#define S2M_FIFO_FIR_R_FIFO_DEPTH 32
#define S2M_FIFO_FIR_R_IRQ -1
#define S2M_FIFO_FIR_R_IRQ_INTERRUPT_CONTROLLER_ID -1
#define S2M_FIFO_FIR_R_NAME "/dev/s2m_fifo_fir_r"
#define S2M_FIFO_FIR_R_SINGLE_CLOCK_MODE 1
#define S2M_FIFO_FIR_R_SPAN 8
#define S2M_FIFO_FIR_R_SYMBOLS_PER_BEAT 1
#define S2M_FIFO_FIR_R_TYPE "altera_avalon_fifo"
#define S2M_FIFO_FIR_R_USE_AVALONMM_READ_SLAVE 1
#define S2M_FIFO_FIR_R_USE_AVALONMM_WRITE_SLAVE 0
#define S2M_FIFO_FIR_R_USE_AVALONST_SINK 1
#define S2M_FIFO_FIR_R_USE_AVALONST_SOURCE 0
#define S2M_FIFO_FIR_R_USE_BACKPRESSURE 1
#define S2M_FIFO_FIR_R_USE_IRQ 0
#define S2M_FIFO_FIR_R_USE_PACKET 0
#define S2M_FIFO_FIR_R_USE_READ_CONTROL 0
#define S2M_FIFO_FIR_R_USE_REGISTER 1
#define S2M_FIFO_FIR_R_USE_WRITE_CONTROL 0


/*
 * sdcard_interface configuration
 *
 */

#define ALT_MODULE_CLASS_sdcard_interface Altera_UP_SD_Card_Avalon_Interface
#define SDCARD_INTERFACE_BASE 0x8282000
#define SDCARD_INTERFACE_IRQ -1
#define SDCARD_INTERFACE_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDCARD_INTERFACE_NAME "/dev/sdcard_interface"
#define SDCARD_INTERFACE_SPAN 1024
#define SDCARD_INTERFACE_TYPE "Altera_UP_SD_Card_Avalon_Interface"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x0
#define SDRAM_CAS_LATENCY 3
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 100.0
#define SDRAM_REFRESH_PERIOD 15.625
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x19
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 10
#define SDRAM_SDRAM_DATA_WIDTH 32
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 1
#define SDRAM_SPAN 134217728
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 5.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 20.0
#define SDRAM_T_RFC 70.0
#define SDRAM_T_RP 20.0
#define SDRAM_T_WR 14.0


/*
 * textmode_controller configuration
 *
 */

#define ALT_MODULE_CLASS_textmode_controller textmode_controller
#define TEXTMODE_CONTROLLER_BASE 0x8282400
#define TEXTMODE_CONTROLLER_IRQ -1
#define TEXTMODE_CONTROLLER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TEXTMODE_CONTROLLER_NAME "/dev/textmode_controller"
#define TEXTMODE_CONTROLLER_SPAN 64
#define TEXTMODE_CONTROLLER_TYPE "textmode_controller"


/*
 * touch_cntrl configuration
 *
 */

#define ALT_MODULE_CLASS_touch_cntrl avalon_touch_cntrl
#define TOUCH_CNTRL_BASE 0x8282480
#define TOUCH_CNTRL_IRQ -1
#define TOUCH_CNTRL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TOUCH_CNTRL_NAME "/dev/touch_cntrl"
#define TOUCH_CNTRL_SPAN 16
#define TOUCH_CNTRL_TYPE "avalon_touch_cntrl"

#endif /* __SYSTEM_H_ */
