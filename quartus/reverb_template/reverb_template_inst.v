	reverb_template u0 (
		.audio_ADCDAT                                    (<connected-to-audio_ADCDAT>),                                    //                                    audio.ADCDAT
		.audio_ADCLRCK                                   (<connected-to-audio_ADCLRCK>),                                   //                                         .ADCLRCK
		.audio_BCLK                                      (<connected-to-audio_BCLK>),                                      //                                         .BCLK
		.audio_DACDAT                                    (<connected-to-audio_DACDAT>),                                    //                                         .DACDAT
		.audio_DACLRCK                                   (<connected-to-audio_DACLRCK>),                                   //                                         .DACLRCK
		.audio_clk_clk                                   (<connected-to-audio_clk_clk>),                                   //                                audio_clk.clk
		.audio_config_SDAT                               (<connected-to-audio_config_SDAT>),                               //                             audio_config.SDAT
		.audio_config_SCLK                               (<connected-to-audio_config_SCLK>),                               //                                         .SCLK
		.clk_clk                                         (<connected-to-clk_clk>),                                         //                                      clk.clk
		.clk_125_clk                                     (<connected-to-clk_125_clk>),                                     //                                  clk_125.clk
		.clk_25_clk                                      (<connected-to-clk_25_clk>),                                      //                                   clk_25.clk
		.clk_2p5_clk                                     (<connected-to-clk_2p5_clk>),                                     //                                  clk_2p5.clk
		.fft_wrapper_header_0_external_connection_export (<connected-to-fft_wrapper_header_0_external_connection_export>), // fft_wrapper_header_0_external_connection.export
		.pio_0_external_connection_export                (<connected-to-pio_0_external_connection_export>),                //                pio_0_external_connection.export
		.reset_reset_n                                   (<connected-to-reset_reset_n>),                                   //                                    reset.reset_n
		.sdcard_b_SD_cmd                                 (<connected-to-sdcard_b_SD_cmd>),                                 //                                   sdcard.b_SD_cmd
		.sdcard_b_SD_dat                                 (<connected-to-sdcard_b_SD_dat>),                                 //                                         .b_SD_dat
		.sdcard_b_SD_dat3                                (<connected-to-sdcard_b_SD_dat3>),                                //                                         .b_SD_dat3
		.sdcard_o_SD_clock                               (<connected-to-sdcard_o_SD_clock>),                               //                                         .o_SD_clock
		.sdram_addr                                      (<connected-to-sdram_addr>),                                      //                                    sdram.addr
		.sdram_ba                                        (<connected-to-sdram_ba>),                                        //                                         .ba
		.sdram_cas_n                                     (<connected-to-sdram_cas_n>),                                     //                                         .cas_n
		.sdram_cke                                       (<connected-to-sdram_cke>),                                       //                                         .cke
		.sdram_cs_n                                      (<connected-to-sdram_cs_n>),                                      //                                         .cs_n
		.sdram_dq                                        (<connected-to-sdram_dq>),                                        //                                         .dq
		.sdram_dqm                                       (<connected-to-sdram_dqm>),                                       //                                         .dqm
		.sdram_ras_n                                     (<connected-to-sdram_ras_n>),                                     //                                         .ras_n
		.sdram_we_n                                      (<connected-to-sdram_we_n>),                                      //                                         .we_n
		.sdram_clk_clk                                   (<connected-to-sdram_clk_clk>),                                   //                                sdram_clk.clk
		.sram_DQ                                         (<connected-to-sram_DQ>),                                         //                                     sram.DQ
		.sram_ADDR                                       (<connected-to-sram_ADDR>),                                       //                                         .ADDR
		.sram_LB_N                                       (<connected-to-sram_LB_N>),                                       //                                         .LB_N
		.sram_UB_N                                       (<connected-to-sram_UB_N>),                                       //                                         .UB_N
		.sram_CE_N                                       (<connected-to-sram_CE_N>),                                       //                                         .CE_N
		.sram_OE_N                                       (<connected-to-sram_OE_N>),                                       //                                         .OE_N
		.sram_WE_N                                       (<connected-to-sram_WE_N>),                                       //                                         .WE_N
		.textmode_b                                      (<connected-to-textmode_b>),                                      //                                 textmode.b
		.textmode_den                                    (<connected-to-textmode_den>),                                    //                                         .den
		.textmode_g                                      (<connected-to-textmode_g>),                                      //                                         .g
		.textmode_hd                                     (<connected-to-textmode_hd>),                                     //                                         .hd
		.textmode_r                                      (<connected-to-textmode_r>),                                      //                                         .r
		.textmode_vd                                     (<connected-to-textmode_vd>),                                     //                                         .vd
		.textmode_grest                                  (<connected-to-textmode_grest>),                                  //                                         .grest
		.touch_cntrl_ext_adc_cs                          (<connected-to-touch_cntrl_ext_adc_cs>),                          //                          touch_cntrl_ext.adc_cs
		.touch_cntrl_ext_adc_dclk                        (<connected-to-touch_cntrl_ext_adc_dclk>),                        //                                         .adc_dclk
		.touch_cntrl_ext_adc_din                         (<connected-to-touch_cntrl_ext_adc_din>),                         //                                         .adc_din
		.touch_cntrl_ext_adc_dout                        (<connected-to-touch_cntrl_ext_adc_dout>),                        //                                         .adc_dout
		.touch_cntrl_ext_adc_penirq_n                    (<connected-to-touch_cntrl_ext_adc_penirq_n>)                     //                                         .adc_penirq_n
	);

