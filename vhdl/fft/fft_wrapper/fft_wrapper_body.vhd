
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_SIGNED.all;

entity fft_wrapper_body is
	port (
		clk   : in std_logic;
		reset_n : in std_logic;

		-- streaming sink (input)
		stin_data  : in std_logic_vector(31 downto 0);
		stin_valid : in std_logic;
		stin_ready : out std_logic;
		stin_sop   : in std_logic;
		stin_eop   : in std_logic;
		stin_empty : in std_logic_vector(1 downto 0); -- not used
		stin_error : in std_logic_vector(1 downto 0);

		-- streaming source (output)
		stout_data  : out std_logic_vector(31 downto 0);
		stout_valid : out std_logic;
		stout_ready : in std_logic; -- back pressure from FIFO
		stout_sop   : out std_logic;
		stout_eop   : out std_logic;
		stout_empty : out std_logic_vector(1 downto 0); -- not used
		stout_error : out std_logic_vector(1 downto 0);
		
		inverse     : in std_logic_vector(0 downto 0) -- pio(1) is used for fft body
	);
begin
end entity;

architecture arch of fft_wrapper_body is

	constant OUTPUT_FORMAT_UP   : natural := 24;
	constant OUTPUT_FORMAT_DOWN : natural := 7;

	signal src_valid : std_logic;
	signal source_real  : std_logic_vector(31 downto 0);
	signal source_imag  : std_logic_vector(31 downto 0);
	signal source_exp   : std_logic_vector(5 downto 0);
	
	-- Component for Body-FFT
	component fft_body is
		port (
			clk          : in  std_logic                     := 'X';             -- clk
			reset_n      : in  std_logic                     := 'X';             -- reset_n
			sink_valid   : in  std_logic                     := 'X';             -- sink_valid
			sink_ready   : out std_logic;                                        -- sink_ready
			sink_error   : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- sink_error
			sink_sop     : in  std_logic                     := 'X';             -- sink_sop
			sink_eop     : in  std_logic                     := 'X';             -- sink_eop
			sink_real    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- sink_real
			sink_imag    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- sink_imag
			inverse      : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- inverse
			source_valid : out std_logic;                                        -- source_valid
			source_ready : in  std_logic                     := 'X';             -- source_ready
			source_error : out std_logic_vector(1 downto 0);                     -- source_error
			source_sop   : out std_logic;                                        -- source_sop
			source_eop   : out std_logic;                                        -- source_eop
			source_real  : out std_logic_vector(31 downto 0);                    -- source_real
			source_imag  : out std_logic_vector(31 downto 0);                    -- source_imag
			source_exp   : out std_logic_vector(5 downto 0)                      -- source_exp
		);
	end component fft_body;
	
begin

	-- Generate FFT Unit
	FFT_B: component fft_body
	port map (
		clk          => clk,          
		reset_n      => reset_n,      
		sink_valid   => stin_valid,   
		sink_ready   => stin_ready,   
		sink_error   => stin_error,   	 -- Indicates an error has occured in an upstream module
		sink_sop     => stin_sop,     	 -- Indicates the start of the incoming FFT frame
		sink_eop     => stin_eop,		 -- Indicates the end of the incoming FFT frame  
		sink_real    => stin_data,    	 -- Real input data
		sink_imag    => (others => '0'), -- Imaginary input data
		inverse      => inverse,      	 -- Inverse FFT calculated if asserted
		source_valid => src_valid, 
		source_ready => stout_ready, 
		source_error => stout_error, 	 -- Indicates an error has occured either in an upstream module or within the FFT module
		source_sop   => stout_sop,  	 -- Marks the start of the outgoing FFT frame
		source_eop   => stout_eop,  	 -- Marks the end of the outgoing FFT frame
		source_real  => source_real, 	 -- Real output data
		source_imag  => source_imag, 	 -- Imaginary output data
		source_exp   => source_exp		 -- Output exponent
	);
		
	output_proc : process(stout_ready, src_valid, source_exp, source_imag, source_real) is
	variable exponent 	  : integer range -15 to 15 := 0;
	variable exponent_abs : natural range   0 to 15 := 0;
	begin
		stout_data(15 downto 0) <= (others => '-');
		stout_data(31 downto 16) <= (others => '-');
		stout_valid <= '0';
		
		if (stout_ready = '1') then
			stout_valid <= src_valid;
			
			-- Calculate exponent
			exponent := - to_integer(signed(source_exp));
			exponent_abs := to_integer(abs(to_signed(exponent,5))); -- nicht 6???
			
			-- Output-Format nach FFT ist 9Q23
			-- TODO: Ausgabe überprüfen!!
			
			if exponent < 0 then -- right shift		
				-- Ausgabe-Format 2Q14
				stout_data(15 downto 0) <= std_logic_vector(shift_right(signed(source_imag), exponent_abs))(OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				stout_data(31 downto 16) <= std_logic_vector(shift_right(signed(source_real), exponent_abs))(OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				
			elsif exponent >= 0 then -- left shift
				-- Ausgabe-Format 2Q14
				stout_data(15 downto 0) <= std_logic_vector(shift_left(signed(source_imag), exponent_abs))(OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				stout_data(31 downto 16) <= std_logic_vector(shift_left(signed(source_real), exponent_abs))(OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
			end if;
		end if;
		
	end process output_proc;
	
end architecture;
