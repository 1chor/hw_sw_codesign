
module reverb_template (
	audio_ADCDAT,
	audio_ADCLRCK,
	audio_BCLK,
	audio_DACDAT,
	audio_DACLRCK,
	audio_clk_clk,
	audio_config_SDAT,
	audio_config_SCLK,
	clk_clk,
	clk_125_clk,
	clk_25_clk,
	clk_2p5_clk,
	reset_reset_n,
	sdcard_b_SD_cmd,
	sdcard_b_SD_dat,
	sdcard_b_SD_dat3,
	sdcard_o_SD_clock,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk,
	textmode_b,
	textmode_den,
	textmode_g,
	textmode_hd,
	textmode_r,
	textmode_vd,
	textmode_grest,
	touch_cntrl_ext_adc_cs,
	touch_cntrl_ext_adc_dclk,
	touch_cntrl_ext_adc_din,
	touch_cntrl_ext_adc_dout,
	touch_cntrl_ext_adc_penirq_n);	

	input		audio_ADCDAT;
	input		audio_ADCLRCK;
	input		audio_BCLK;
	output		audio_DACDAT;
	input		audio_DACLRCK;
	output		audio_clk_clk;
	inout		audio_config_SDAT;
	output		audio_config_SCLK;
	input		clk_clk;
	output		clk_125_clk;
	output		clk_25_clk;
	output		clk_2p5_clk;
	input		reset_reset_n;
	inout		sdcard_b_SD_cmd;
	inout		sdcard_b_SD_dat;
	inout		sdcard_b_SD_dat3;
	output		sdcard_o_SD_clock;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[31:0]	sdram_dq;
	output	[3:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
	output	[7:0]	textmode_b;
	output		textmode_den;
	output	[7:0]	textmode_g;
	output		textmode_hd;
	output	[7:0]	textmode_r;
	output		textmode_vd;
	output		textmode_grest;
	output		touch_cntrl_ext_adc_cs;
	output		touch_cntrl_ext_adc_dclk;
	output		touch_cntrl_ext_adc_din;
	input		touch_cntrl_ext_adc_dout;
	input		touch_cntrl_ext_adc_penirq_n;
endmodule
