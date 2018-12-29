
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_SIGNED.all;

entity fft_wrapper is
	generic (
		FFT_LENGTH : natural := 512; -- 8192 for body
		-- NUM_COEFFICIENTS : integer := 16; 
		-- ADDR_WIDTH       : integer := 4 
	);
	port (
		clk   : in std_logic;
		reset_n : in std_logic;

		-- streaming sink (input)
		stin_data  : in std_logic_vector(31 downto 0);
		stin_valid : in std_logic;
		stin_ready : out std_logic;

		-- streaming source (output)
		stout_data  : out std_logic_vector(31 downto 0);
		stout_valid : out std_logic;
		stout_ready : in std_logic -- back pressure from FIFO
	);
begin
end entity;

architecture arch of fft_wrapper is

	constant HEADER_LENGTH : natural := 512;
	constant BODY_LENGTH   : natural := 8192;
	
	signal	sink_valid     : std_logic;
	signal	sink_ready     : std_logic;
	signal	sink_error     : std_logic_vector(1 downto 0);
	signal	sink_sop       : std_logic;
	--signal  s_sink_sop_next  : std_logic;
	signal	sink_eop       : std_logic;
	--signal	s_sink_eop_next  : std_logic;
	signal	sink_real      : std_logic_vector(31 downto 0);
	signal	sink_imag      : std_logic_vector(31 downto 0);
	signal	inverse        : std_logic_vector(0 downto 0);
	signal	source_valid   : std_logic;
	signal	source_ready   : std_logic;
	signal	source_error   : std_logic_vector(1 downto 0);
	signal	source_sop     : std_logic;
	signal	source_eop     : std_logic;
	signal	source_real    : std_logic_vector(31 downto 0);
	signal	source_imag    : std_logic_vector(31 downto 0);
	signal	source_exp     : std_logic_vector(5 downto 0);
	
	-- Component for Header-FFT
	component fft_header is
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
	end component fft_header;
	
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
	FFT: if FFT_LENGTH = HEADER_LENGTH generate

		FFT_HEADER : component fft_header
		port map (
			clk          => clk,          
			reset_n      => reset_n,      
			sink_valid   => sink_valid,   
			sink_ready   => sink_ready,   
			sink_error   => sink_error,   	-- Indicates an error has occured in an upstream module
			sink_sop     => sink_sop,     	-- Indicates the start of the incoming FFT frame
			sink_eop     => sink_eop,		-- Indicates the end of the incoming FFT frame  
			sink_real    => sink_real,    	-- Real input data
			sink_imag    => sink_imag,    	-- Imaginary input data
			inverse      => inverse,      	-- Inverse FFT calculated if asserted
			source_valid => source_valid, 
			source_ready => source_ready, 
			source_error => source_error, 	-- Indicates an error has occured either in an upstream module or within the FFT module
			source_sop   => source_sop,  	-- Marks the start of the outgoing FFT frame
			source_eop   => source_eop,  	-- Marks the end of the outgoing FFT frame
			source_real  => source_real, 	-- Real output data
			source_imag  => source_imag, 	-- Imaginary output data
			source_exp   => source_exp
		);
		
	elsif FFT_LENGTH = BODY_LENGTH generate
	
		FFT_BODY: component fft_body
		port map (
			clk          => clk,          
			reset_n      => reset_n,      
			sink_valid   => sink_valid,   
			sink_ready   => sink_ready,   
			sink_error   => sink_error,   	-- Indicates an error has occured in an upstream module
			sink_sop     => sink_sop,     	-- Indicates the start of the incoming FFT frame
			sink_eop     => sink_eop,		-- Indicates the end of the incoming FFT frame  
			sink_real    => sink_real,    	-- Real input data
			sink_imag    => sink_imag,    	-- Imaginary input data
			inverse      => inverse,      	-- Inverse FFT calculated if asserted
			source_valid => source_valid, 
			source_ready => source_ready, 
			source_error => source_error, 	-- Indicates an error has occured either in an upstream module or within the FFT module
			source_sop   => source_sop,  	-- Marks the start of the outgoing FFT frame
			source_eop   => source_eop,  	-- Marks the end of the outgoing FFT frame
			source_real  => source_real, 	-- Real output data
			source_imag  => source_imag, 	-- Imaginary output data
			source_exp   => source_exp
		);
	
	else generate
		-- Empty 
	
	end generate FFT;

	sink_error <= (others => '0'); --"If this signal is not used in upstream modules, set to zero."
		

	
end architecture;