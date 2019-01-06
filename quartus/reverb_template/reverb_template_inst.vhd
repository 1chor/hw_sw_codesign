	component reverb_template is
		port (
			audio_ADCDAT                                    : in    std_logic                     := 'X';             -- ADCDAT
			audio_ADCLRCK                                   : in    std_logic                     := 'X';             -- ADCLRCK
			audio_BCLK                                      : in    std_logic                     := 'X';             -- BCLK
			audio_DACDAT                                    : out   std_logic;                                        -- DACDAT
			audio_DACLRCK                                   : in    std_logic                     := 'X';             -- DACLRCK
			audio_clk_clk                                   : out   std_logic;                                        -- clk
			audio_config_SDAT                               : inout std_logic                     := 'X';             -- SDAT
			audio_config_SCLK                               : out   std_logic;                                        -- SCLK
			clk_clk                                         : in    std_logic                     := 'X';             -- clk
			clk_125_clk                                     : out   std_logic;                                        -- clk
			clk_25_clk                                      : out   std_logic;                                        -- clk
			clk_2p5_clk                                     : out   std_logic;                                        -- clk
			reset_reset_n                                   : in    std_logic                     := 'X';             -- reset_n
			sdcard_b_SD_cmd                                 : inout std_logic                     := 'X';             -- b_SD_cmd
			sdcard_b_SD_dat                                 : inout std_logic                     := 'X';             -- b_SD_dat
			sdcard_b_SD_dat3                                : inout std_logic                     := 'X';             -- b_SD_dat3
			sdcard_o_SD_clock                               : out   std_logic;                                        -- o_SD_clock
			sdram_addr                                      : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba                                        : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n                                     : out   std_logic;                                        -- cas_n
			sdram_cke                                       : out   std_logic;                                        -- cke
			sdram_cs_n                                      : out   std_logic;                                        -- cs_n
			sdram_dq                                        : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			sdram_dqm                                       : out   std_logic_vector(3 downto 0);                     -- dqm
			sdram_ras_n                                     : out   std_logic;                                        -- ras_n
			sdram_we_n                                      : out   std_logic;                                        -- we_n
			sdram_clk_clk                                   : out   std_logic;                                        -- clk
			sram_DQ                                         : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DQ
			sram_ADDR                                       : out   std_logic_vector(19 downto 0);                    -- ADDR
			sram_LB_N                                       : out   std_logic;                                        -- LB_N
			sram_UB_N                                       : out   std_logic;                                        -- UB_N
			sram_CE_N                                       : out   std_logic;                                        -- CE_N
			sram_OE_N                                       : out   std_logic;                                        -- OE_N
			sram_WE_N                                       : out   std_logic;                                        -- WE_N
			textmode_b                                      : out   std_logic_vector(7 downto 0);                     -- b
			textmode_den                                    : out   std_logic;                                        -- den
			textmode_g                                      : out   std_logic_vector(7 downto 0);                     -- g
			textmode_hd                                     : out   std_logic;                                        -- hd
			textmode_r                                      : out   std_logic_vector(7 downto 0);                     -- r
			textmode_vd                                     : out   std_logic;                                        -- vd
			textmode_grest                                  : out   std_logic;                                        -- grest
			touch_cntrl_ext_adc_cs                          : out   std_logic;                                        -- adc_cs
			touch_cntrl_ext_adc_dclk                        : out   std_logic;                                        -- adc_dclk
			touch_cntrl_ext_adc_din                         : out   std_logic;                                        -- adc_din
			touch_cntrl_ext_adc_dout                        : in    std_logic                     := 'X';             -- adc_dout
			touch_cntrl_ext_adc_penirq_n                    : in    std_logic                     := 'X'              -- adc_penirq_n
			fft_wrapper_body_0_external_connection_export   : in    std_logic_vector(0 downto 0)  := (others => 'X'); 								  -- export
			fft_wrapper_header_0_external_connection_export : in    std_logic_vector(0 downto 0)  := (others => 'X'); 								  -- export
			pio_0_external_connection_export                : out   std_logic_vector(1 downto 0);                     -- export
		);
	end component reverb_template;

	u0 : component reverb_template
		port map (
			audio_ADCDAT                                    => CONNECTED_TO_audio_ADCDAT,                                    --                                    audio.ADCDAT
			audio_ADCLRCK                                   => CONNECTED_TO_audio_ADCLRCK,                                   --                                         .ADCLRCK
			audio_BCLK                                      => CONNECTED_TO_audio_BCLK,                                      --                                         .BCLK
			audio_DACDAT                                    => CONNECTED_TO_audio_DACDAT,                                    --                                         .DACDAT
			audio_DACLRCK                                   => CONNECTED_TO_audio_DACLRCK,                                   --                                         .DACLRCK
			audio_clk_clk                                   => CONNECTED_TO_audio_clk_clk,                                   --                                audio_clk.clk
			audio_config_SDAT                               => CONNECTED_TO_audio_config_SDAT,                               --                             audio_config.SDAT
			audio_config_SCLK                               => CONNECTED_TO_audio_config_SCLK,                               --                                         .SCLK
			clk_clk                                         => CONNECTED_TO_clk_clk,                                         --                                      clk.clk
			clk_125_clk                                     => CONNECTED_TO_clk_125_clk,                                     --                                  clk_125.clk
			clk_25_clk                                      => CONNECTED_TO_clk_25_clk,                                      --                                   clk_25.clk
			clk_2p5_clk                                     => CONNECTED_TO_clk_2p5_clk,                                     --                                  clk_2p5.clk
			reset_reset_n                                   => CONNECTED_TO_reset_reset_n,                                   --                                    reset.reset_n
			sdcard_b_SD_cmd                                 => CONNECTED_TO_sdcard_b_SD_cmd,                                 --                                   sdcard.b_SD_cmd
			sdcard_b_SD_dat                                 => CONNECTED_TO_sdcard_b_SD_dat,                                 --                                         .b_SD_dat
			sdcard_b_SD_dat3                                => CONNECTED_TO_sdcard_b_SD_dat3,                                --                                         .b_SD_dat3
			sdcard_o_SD_clock                               => CONNECTED_TO_sdcard_o_SD_clock,                               --                                         .o_SD_clock
			sdram_addr                                      => CONNECTED_TO_sdram_addr,                                      --                                    sdram.addr
			sdram_ba                                        => CONNECTED_TO_sdram_ba,                                        --                                         .ba
			sdram_cas_n                                     => CONNECTED_TO_sdram_cas_n,                                     --                                         .cas_n
			sdram_cke                                       => CONNECTED_TO_sdram_cke,                                       --                                         .cke
			sdram_cs_n                                      => CONNECTED_TO_sdram_cs_n,                                      --                                         .cs_n
			sdram_dq                                        => CONNECTED_TO_sdram_dq,                                        --                                         .dq
			sdram_dqm                                       => CONNECTED_TO_sdram_dqm,                                       --                                         .dqm
			sdram_ras_n                                     => CONNECTED_TO_sdram_ras_n,                                     --                                         .ras_n
			sdram_we_n                                      => CONNECTED_TO_sdram_we_n,                                      --                                         .we_n
			sdram_clk_clk                                   => CONNECTED_TO_sdram_clk_clk,                                   --                                sdram_clk.clk
			sram_DQ                                         => CONNECTED_TO_sram_DQ,                                         --                                     sram.DQ
			sram_ADDR                                       => CONNECTED_TO_sram_ADDR,                                       --                                         .ADDR
			sram_LB_N                                       => CONNECTED_TO_sram_LB_N,                                       --                                         .LB_N
			sram_UB_N                                       => CONNECTED_TO_sram_UB_N,                                       --                                         .UB_N
			sram_CE_N                                       => CONNECTED_TO_sram_CE_N,                                       --                                         .CE_N
			sram_OE_N                                       => CONNECTED_TO_sram_OE_N,                                       --                                         .OE_N
			sram_WE_N                                       => CONNECTED_TO_sram_WE_N,                                       --                                         .WE_N
			textmode_b                                      => CONNECTED_TO_textmode_b,                                      --                                 textmode.b
			textmode_den                                    => CONNECTED_TO_textmode_den,                                    --                                         .den
			textmode_g                                      => CONNECTED_TO_textmode_g,                                      --                                         .g
			textmode_hd                                     => CONNECTED_TO_textmode_hd,                                     --                                         .hd
			textmode_r                                      => CONNECTED_TO_textmode_r,                                      --                                         .r
			textmode_vd                                     => CONNECTED_TO_textmode_vd,                                     --                                         .vd
			textmode_grest                                  => CONNECTED_TO_textmode_grest,                                  --                                         .grest
			touch_cntrl_ext_adc_cs                          => CONNECTED_TO_touch_cntrl_ext_adc_cs,                          --                          touch_cntrl_ext.adc_cs
			touch_cntrl_ext_adc_dclk                        => CONNECTED_TO_touch_cntrl_ext_adc_dclk,                        --                                         .adc_dclk
			touch_cntrl_ext_adc_din                         => CONNECTED_TO_touch_cntrl_ext_adc_din,                         --                                         .adc_din
			touch_cntrl_ext_adc_dout                        => CONNECTED_TO_touch_cntrl_ext_adc_dout,                        --                                         .adc_dout
			touch_cntrl_ext_adc_penirq_n                    => CONNECTED_TO_touch_cntrl_ext_adc_penirq_n                     --                                         .adc_penirq_n
			fft_wrapper_body_0_external_connection_export   => CONNECTED_TO_fft_wrapper_body_0_external_connection_export,   --   fft_wrapper_body_0_external_connection.export
			fft_wrapper_header_0_external_connection_export => CONNECTED_TO_fft_wrapper_header_0_external_connection_export, -- fft_wrapper_header_0_external_connection.export
			pio_0_external_connection_export                => CONNECTED_TO_pio_0_external_connection_export,                --                pio_0_external_connection.export
		);

