library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.STD_LOGIC_SIGNED.all;

entity fft_wrapper_header is
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
		stout_ready : in std_logic; -- back pressure from FIFO
				
		inverse     : in std_logic_vector(0 downto 0) -- pio(0) is used for fft header
	);
begin
end entity;

architecture arch of fft_wrapper_header is

	constant OUTPUT_FORMAT_UP   : natural := 23;
	constant OUTPUT_FORMAT_DOWN : natural := 8;
	constant FFT_LENGTH  : natural := 512;
	
	signal	si_valid     : std_logic;
	signal	si_ready  	 : std_logic;
	signal	si_error  	 : std_logic_vector(1 downto 0);
	signal	si_sop     	 : std_logic;
	signal  si_sop_next  : std_logic;
	signal	si_eop		 : std_logic;
	signal	si_eop_next	 : std_logic;
	-- signal	si_real		 : std_logic_vector(15 downto 0);
	-- signal	si_imag   	 : std_logic_vector(15 downto 0);
	
	signal	src_valid 	 : std_logic;
	signal	src_error 	 : std_logic_vector(1 downto 0);
	signal	src_sop   	 : std_logic;
	signal	src_eop   	 : std_logic;
	signal	src_real  	 : std_logic_vector(15 downto 0);
	signal	src_imag  	 : std_logic_vector(15 downto 0);
	signal	src_exp   	 : std_logic_vector(5 downto 0);
	
	signal index 		 : natural range 0 to FFT_LENGTH := 0; -- one more than needed

	type state_type is (
		TRANSFER_TO_FFT,
		LATENCY_FFT,
		OUTPUT_DATA
	);
	signal state, state_next : state_type := TRANSFER_TO_FFT;
	
	type transfer_state_type is (
		STATE_IDLE, 
		TRANSFER_DATA
	);
	signal transfer_state, transfer_state_next: transfer_state_type := STATE_IDLE;
	
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
			sink_real    : in  std_logic_vector(15 downto 0) := (others => 'X'); -- sink_real
			sink_imag    : in  std_logic_vector(15 downto 0) := (others => 'X'); -- sink_imag
			inverse      : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- inverse
			source_valid : out std_logic;                                        -- source_valid
			source_ready : in  std_logic                     := 'X';             -- source_ready
			source_error : out std_logic_vector(1 downto 0);                     -- source_error
			source_sop   : out std_logic;                                        -- source_sop
			source_eop   : out std_logic;                                        -- source_eop
			source_real  : out std_logic_vector(15 downto 0);                    -- source_real
			source_imag  : out std_logic_vector(15 downto 0);                    -- source_imag
			source_exp   : out std_logic_vector(5 downto 0)                      -- source_exp
		);
	end component fft_header;
	
begin

	-- Implement FFT Unit
	FFT_H : component fft_header
	port map (
		clk          => clk,          
		reset_n      => reset_n,      
		sink_valid   => si_valid,   
		sink_ready   => si_ready,   
		sink_error   => si_error,   	 -- Indicates an error has occured in an upstream module
		sink_sop     => si_sop,     	 -- Indicates the start of the incoming FFT frame
		sink_eop     => si_eop,		 	 -- Indicates the end of the incoming FFT frame  
		sink_real    => stin_data(31 downto 16), -- Real input data
		sink_imag    => stin_data(15 downto  0), -- Imaginary input data
		inverse      => inverse, 		 -- Inverse FFT calculated if asserted
		source_valid => src_valid, 
		source_ready => stout_ready, 
		source_error => src_error, 	 	 -- Indicates an error has occured either in an upstream module or within the FFT module
		source_sop   => src_sop, 	  	 -- Marks the start of the outgoing FFT frame
		source_eop   => src_eop,  	 	 -- Marks the end of the outgoing FFT frame
		source_real  => src_real,	  	 -- Real output data
		source_imag  => src_imag, 	 	 -- Imaginary output data
		source_exp   => src_exp			 -- Output exponent
	);
	
	fft_proc: process (state, index, src_sop, src_valid, src_eop)
	begin
		-- default values to prevent latches
		state_next <= state;
		
		case state is
			
			when TRANSFER_TO_FFT =>
				if index = FFT_LENGTH then -- only FFT_LENGTH-1 was sent
					state_next <= LATENCY_FFT;
				end if;
			
			when LATENCY_FFT =>
				if (src_sop = '1') and (src_valid = '1') then
					state_next <= OUTPUT_DATA;
			end if;
			
			when OUTPUT_DATA =>
				if (src_eop = '1') and (src_valid = '1') then
					state_next <= TRANSFER_TO_FFT;
				end if;	
			
			when others =>
				state_next <= TRANSFER_TO_FFT;				
		end case;
		
	end process fft_proc;
	
	sync_state_proc: process (reset_n, clk)
	begin
		if reset_n = '0' then -- Reset signals
			state <= TRANSFER_TO_FFT;
			transfer_state <= STATE_IDLE;
			
			si_valid <= '0';
			si_sop <= '0';
			si_eop <= '0';
			index <= 0;	
					
		elsif rising_edge(clk) then
			state <= state_next;
			transfer_state <= transfer_state_next;
			
			si_valid <= '0';
			si_sop <= si_sop_next;
			si_eop <= si_eop_next;
			
			if (si_ready = '1') and (stin_valid = '1') and (transfer_state_next = TRANSFER_DATA) then 
				-- increase index and feed new input;
				index <= index + 1;
				si_valid <= '1';
			elsif not (transfer_state_next = TRANSFER_DATA) then
				index <= 0; -- reset counter
			end if;
		end if;
			
	end process sync_state_proc;
	
	send_proc : process(transfer_state, state_next, si_ready, stin_valid, index)
	begin
		-- default values to prevent latches
		transfer_state_next <= transfer_state;
		
		si_sop_next <= '0';
		si_eop_next <= '0';
		
		if (state_next = TRANSFER_TO_FFT) and (si_ready = '1') then  -- forward back pressure
			stin_ready <= '1';
		else
			stin_ready <= '0'; -- signal to input FIFO
		end if;
		
		case transfer_state is
		
			when STATE_IDLE =>
				if (si_ready = '1') and (stin_valid = '1') and (state_next = TRANSFER_TO_FFT) then
					stin_ready <= '0'; -- Activate for simulation
					transfer_state_next <= TRANSFER_DATA;
					si_sop_next <= '1';
				end if;
				
			when TRANSFER_DATA =>
				if (si_ready = '1') and (stin_valid = '1') then
					if index = FFT_LENGTH-1 then
						stin_ready <= '0';
						si_eop_next <= '1';
					end if;
				end if;
				
				if index = FFT_LENGTH then -- independent of valid signals
					transfer_state_next <= STATE_IDLE;
					stin_ready <= '0';
				end if;
			
			when others =>
				transfer_state_next <= STATE_IDLE;				
		end case;				
		
	end process send_proc;
			
	output_proc : process(stout_ready, state_next, state, src_valid, src_exp, src_imag, src_real) is
	variable exponent 	  : integer range -15 to 15 := 0;
	variable exponent_abs : natural range   0 to 15 := 0;
	begin
		stout_data(15 downto 0) <= (others => '-');
		stout_data(31 downto 16) <= (others => '-');
		stout_valid <= '0';
		
		if (stout_ready = '1') and ((state_next = OUTPUT_DATA) or (state = OUTPUT_DATA)) then
			stout_valid <= src_valid;
			
			-- Calculate exponent
			exponent := - to_integer(signed(src_exp));
			exponent_abs := to_integer(abs(to_signed(exponent,5))); -- nicht 6???
			
			-- Output-Format nach FFT ist 9Q23
			-- TODO: Ausgabe überprüfen!!
			
			if exponent < 0 then -- right shift		
				-- Ausgabe-Format 2Q14
				stout_data(15 downto 0) <= std_logic_vector(shift_right(signed(src_imag), exponent_abs)); -- (OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				stout_data(31 downto 16) <= std_logic_vector(shift_right(signed(src_real), exponent_abs)); -- (OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				
			elsif exponent >= 0 then -- left shift
				-- Ausgabe-Format 2Q14
				stout_data(15 downto 0) <= std_logic_vector(shift_left(signed(src_imag), exponent_abs)); -- (OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
				stout_data(31 downto 16) <= std_logic_vector(shift_left(signed(src_real), exponent_abs)); -- (OUTPUT_FORMAT_UP downto OUTPUT_FORMAT_DOWN);
			end if;
		end if;
		
	end process output_proc;
	
	si_error <= (others => '0'); -- "If this signal is not used in upstream modules, set to zero."
	
end architecture;
