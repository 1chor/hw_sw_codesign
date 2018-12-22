library ieee;
use ieee.std_logic_1164.all; 
use work.sync_pkg.all;

entity top is 
	port (
		CLOCK_50      : in std_logic;
		KEY           : in std_logic_vector(0 downto 0);
		
		-- LTM
		LTM_CLK       : out   std_logic;                        -- clk
		LTM_GREST     : out   std_logic;                        -- grest
		LTM_DEN       : out   std_logic;                        -- den
		LTM_HD        : out   std_logic;                        -- hd
		LTM_VD        : out   std_logic;                        -- vd 
		LTM_R         : out   std_logic_vector(7 downto 0);     -- r
		LTM_G         : out   std_logic_vector(7 downto 0);     -- g
		LTM_B         : out   std_logic_vector(7 downto 0);     -- b
		
		DRAM_ADDR     : out std_logic_vector(12 downto 0);
		DRAM_BA       : out std_logic_vector(1 downto 0);
		DRAM_CAS_N    : out std_logic;
		DRAM_CKE      : out std_logic;
		DRAM_CS_N     : out std_logic;
		DRAM_DQ       : inout std_logic_vector(31 downto 0) := (others => 'X');
		DRAM_DQM      : out std_logic_vector (3 downto 0);
		DRAM_RAS_N    : out std_logic;
		DRAM_WE_N     : out std_logic;
		DRAM_CLK      : out std_logic;
		
		SRAM_DQ                      : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DQ
		SRAM_ADDR                    : out   std_logic_vector(19 downto 0);                    -- ADDR
		SRAM_LB_N                    : out   std_logic;                                        -- LB_N
		SRAM_UB_N                    : out   std_logic;                                        -- UB_N
		SRAM_CE_N                    : out   std_logic;                                        -- CE_N
		SRAM_OE_N                    : out   std_logic;                                        -- OE_N
		SRAM_WE_N                    : out   std_logic;                                        -- WE_N
		
	
		I2C_SDAT      : inout std_logic;
		I2C_SCLK      : out std_logic;
		
		
		AUD_ADCDAT    : in    std_logic;
		AUD_ADCLRCK   : in    std_logic;
		AUD_BCLK      : in    std_logic  := 'X'; 
		AUD_DACDAT    : out   std_logic; 
		AUD_DACLRCK   : in    std_logic  := 'X';
		AUD_XCK       : out   std_logic;
		
		SD_CMD        : inout std_logic                     := 'X';           
		SD_DAT        : inout std_logic_vector(3 downto 0);
		SD_CLK        : out   std_logic;

		ADC_CS        : out   std_logic; 
		ADC_DCLK      : out   std_logic; 
		ADC_DIN       : out   std_logic; 
		ADC_DOUT      : in   std_logic; 
		ADC_PENIRQ_N  : in   std_logic
);
end entity;



architecture arch of top is
	signal sys_clk, clk_125, clk_25, clk_2p5, tx_clk : std_logic;
	signal res_n : std_logic;
	
	        component reverb_template is
        port (
            audio_ADCDAT                 : in    std_logic                     := 'X';             -- ADCDAT
            audio_ADCLRCK                : in    std_logic                     := 'X';             -- ADCLRCK
            audio_BCLK                   : in    std_logic                     := 'X';             -- BCLK
            audio_DACDAT                 : out   std_logic;                                        -- DACDAT
            audio_DACLRCK                : in    std_logic                     := 'X';             -- DACLRCK
            audio_clk_clk                : out   std_logic;                                        -- clk
            audio_config_SDAT            : inout std_logic                     := 'X';             -- SDAT
            audio_config_SCLK            : out   std_logic;                                        -- SCLK
            clk_clk                      : in    std_logic                     := 'X';             -- clk
            clk_125_clk                  : out   std_logic;                                        -- clk
            clk_25_clk                   : out   std_logic;                                        -- clk
            clk_2p5_clk                  : out   std_logic;                                        -- clk
            reset_reset_n                : in    std_logic                     := 'X';             -- reset_n
            sdcard_b_SD_cmd              : inout std_logic                     := 'X';             -- b_SD_cmd
            sdcard_b_SD_dat              : inout std_logic                     := 'X';             -- b_SD_dat
            sdcard_b_SD_dat3             : inout std_logic                     := 'X';             -- b_SD_dat3
            sdcard_o_SD_clock            : out   std_logic;                                        -- o_SD_clock
            sdram_addr                   : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_ba                     : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n                  : out   std_logic;                                        -- cas_n
            sdram_cke                    : out   std_logic;                                        -- cke
            sdram_cs_n                   : out   std_logic;                                        -- cs_n
            sdram_dq                     : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
            sdram_dqm                    : out   std_logic_vector(3 downto 0);                     -- dqm
            sdram_ras_n                  : out   std_logic;                                        -- ras_n
            sdram_we_n                   : out   std_logic;                                        -- we_n
            sdram_clk_clk                : out   std_logic;                                        -- clk
            
				sram_DQ                      : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DQ
            sram_ADDR                    : out   std_logic_vector(19 downto 0);                    -- ADDR
            sram_LB_N                    : out   std_logic;                                        -- LB_N
            sram_UB_N                    : out   std_logic;                                        -- UB_N
            sram_CE_N                    : out   std_logic;                                        -- CE_N
            sram_OE_N                    : out   std_logic;                                        -- OE_N
            sram_WE_N                    : out   std_logic;                                        -- WE_N
				
				textmode_b                   : out   std_logic_vector(7 downto 0);                     -- b
            textmode_den                 : out   std_logic;                                        -- den
            textmode_g                   : out   std_logic_vector(7 downto 0);                     -- g
            textmode_hd                  : out   std_logic;                                        -- hd
            textmode_r                   : out   std_logic_vector(7 downto 0);                     -- r
            textmode_vd                  : out   std_logic;                                        -- vd
            textmode_grest               : out   std_logic;                                        -- grest
            touch_cntrl_ext_adc_cs       : out   std_logic;                                        -- adc_cs
            touch_cntrl_ext_adc_dclk     : out   std_logic;                                        -- adc_dclk
            touch_cntrl_ext_adc_din      : out   std_logic;                                        -- adc_din
            touch_cntrl_ext_adc_dout     : in    std_logic                     := 'X';             -- adc_dout
            touch_cntrl_ext_adc_penirq_n : in    std_logic                     := 'X'              -- adc_penirq_n
        );
    end component reverb_template;
			
begin

	--key_n <= not KEY(0);

	sync_inst : sync
		generic map (
			SYNC_STAGES => 2,
			RESET_VALUE => '0'
		)
		port map (
			sys_clk   => CLOCK_50,
			sys_res_n => '1',
			data_in   => KEY(0),
			data_out  => res_n
		);
		
	u0 : reverb_template
		port map (
			clk_clk                             => CLOCK_50,
			clk_125_clk                         => open,
         clk_25_clk                          => clk_25, 
         clk_2p5_clk                         => open,
			reset_reset_n                       => res_n,
			
			textmode_grest                      => LTM_GREST,
			textmode_vd                         => LTM_VD,
			textmode_hd                         => LTM_HD,
			textmode_den                        => LTM_DEN,
			textmode_r                          => LTM_R,
			textmode_g                          => LTM_G,
			textmode_b                          => LTM_B,
			
			sdram_addr                          => DRAM_ADDR,
			sdram_ba                            => DRAM_BA,
			sdram_cas_n                         => DRAM_CAS_N,
			sdram_cke                           => DRAM_CKE,
			sdram_cs_n                          => DRAM_CS_N,
			sdram_dq                            => DRAM_DQ,
			sdram_dqm                           => DRAM_DQM,
			sdram_ras_n                         => DRAM_RAS_N,
			sdram_we_n         						=> DRAM_WE_N,
			sdram_clk_clk                       => DRAM_CLK,
			
			sram_DQ                      => SRAM_DQ,                      --            sram.DQ
			sram_ADDR                    => SRAM_ADDR,                    --                .ADDR
			sram_LB_N                    => SRAM_LB_N,                    --                .LB_N
			sram_UB_N                    => SRAM_UB_N,                    --                .UB_N
			sram_CE_N                    => SRAM_CE_N,                    --                .CE_N
			sram_OE_N                    => SRAM_OE_N,                    --                .OE_N
			sram_WE_N                    => SRAM_WE_N,                    --                .WE_N
			
			
			audio_config_SDAT                   => I2C_SDAT,
			audio_config_SCLK                   => I2C_SCLK,
			
			audio_ADCDAT                        => AUD_ADCDAT,
         audio_ADCLRCK                       => AUD_ADCLRCK,
			audio_BCLK                          => AUD_BCLK,
			audio_DACDAT                        => AUD_DACDAT,
			audio_DACLRCK                       => AUD_DACLRCK,
			audio_clk_clk                       => AUD_XCK,
			
			sdcard_b_SD_cmd   => SD_CMD,   
			sdcard_b_SD_dat   => SD_DAT(0),   
			sdcard_b_SD_dat3  => SD_DAT(3),  
			sdcard_o_SD_clock => SD_CLK,
			
			
			touch_cntrl_ext_adc_cs       => ADC_CS,
			touch_cntrl_ext_adc_dclk     => ADC_DCLK,
			touch_cntrl_ext_adc_din      => ADC_DIN,
			touch_cntrl_ext_adc_dout     => ADC_DOUT,
			touch_cntrl_ext_adc_penirq_n => ADC_PENIRQ_N
		);
		
		LTM_CLK <= clk_25;

end architecture;

