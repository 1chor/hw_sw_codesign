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

	constant FFT_LENGTH 	  : natural := 512;
	constant DIV_N			  : integer := -9; -- 1/512 is equivalent to 2^-9 and 9 right shifts
	
	signal	si_valid    	  : std_logic;
	signal	si_ready  	 	  : std_logic;
	signal	si_error  		  : std_logic_vector(1 downto 0);
	signal	si_sop     		  : std_logic;
	signal  si_sop_next 	  : std_logic;
	signal	si_eop			  : std_logic;
	signal	si_eop_next		  : std_logic;
	signal	si_real			  : std_logic_vector(31 downto 0);
	signal	si_imag   		  : std_logic_vector(31 downto 0);
	
	signal	src_valid 		  : std_logic;
	signal	src_ready  	 	  : std_logic;
	signal	src_error 		  : std_logic_vector(1 downto 0);
	signal	src_sop   		  : std_logic;
	signal	src_eop   		  : std_logic;
	signal	src_real  		  : std_logic_vector(31 downto 0);
	signal	src_imag  		  : std_logic_vector(31 downto 0);
	signal	src_exp   	 	  : std_logic_vector(5 downto 0);
	
	signal temp_in		 	  : std_logic_vector(31 downto 0) := (others => '0');
	signal temp_out		 	  : std_logic_vector(31 downto 0) := (others => '0');
	signal temp_out_next	  : std_logic_vector(31 downto 0) := (others => '0');
	
	signal index 		 	  : natural range 0 to FFT_LENGTH := 0; -- one more than needed
	signal index_next	 	  : natural range 0 to FFT_LENGTH := 0; -- one more than needed
	
	signal receive_index 	  : natural range 0 to FFT_LENGTH := 0; -- one more than needed 
	signal receive_index_next : natural range 0 to FFT_LENGTH := 0; -- one more than needed 
	
	type state_type is (
		TRANSFER_TO_FFT,
		LATENCY_FFT,
		OUTPUT_DATA
	);
	signal state, state_next : state_type := TRANSFER_TO_FFT;

	type input_state_type is (
		STATE_INPUT_REAL,
		STATE_INPUT_IMAG
	);
	signal input_state, input_state_next: input_state_type := STATE_INPUT_REAL;
	
	type output_state_type is (
		STATE_OUTPUT_REAL,
		STATE_OUTPUT_IMAG,
		STATE_OUTPUT_INVERSE
	);
	signal output_state, output_state_next: output_state_type := STATE_OUTPUT_REAL;
	
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
		sink_real    => si_real, 		 -- Real input data
		sink_imag    => si_imag,		 -- Imaginary input data
		inverse      => inverse, 		 -- Inverse FFT calculated if asserted
		source_valid => src_valid, 
		source_ready => src_ready, 
		source_error => src_error, 	 	 -- Indicates an error has occured either in an upstream module or within the FFT module
		source_sop   => src_sop, 	  	 -- Marks the start of the outgoing FFT frame
		source_eop   => src_eop,  	 	 -- Marks the end of the outgoing FFT frame
		source_real  => src_real,	  	 -- Real output data
		source_imag  => src_imag, 	 	 -- Imaginary output data
		source_exp   => src_exp			 -- Output exponent
	);
		
	--------------------------------------------------------------------
	
	sync_state_proc: process (reset_n, clk)
	begin
		if reset_n = '0' then -- Reset signals
			state        <= TRANSFER_TO_FFT;
			input_state  <= STATE_INPUT_REAL;
			output_state <= STATE_OUTPUT_REAL;
			
			si_sop <= '0';
			si_eop <= '0';	
			index  <= 0;
			receive_index <= 0;
			temp_out <= (others => '0');
								
		elsif rising_edge(clk) then
			state        <= state_next;
			input_state  <= input_state_next;
			output_state <= output_state_next;
			
			si_sop  	  <= si_sop_next;
			si_eop  	  <= si_eop_next;
			index  		  <= index_next;
			receive_index <= receive_index_next;
			temp_out	  <= temp_out_next;		
		end if;
			
	end process sync_state_proc;
	
	--------------------------------------------------------------------
	
	input_proc: process (input_state, index, si_ready, stin_valid, state_next, stin_data, temp_in)
	begin
		-- default values to prevent latches
		input_state_next <= input_state;
		index_next <= index;
		si_valid <= '0';
		si_sop_next <= '0';
		si_eop_next <= '0';
			
		si_real <= (others => '0');
		si_imag <= (others => '0');
		
		if (state_next = TRANSFER_TO_FFT) and (si_ready = '1') then  -- forward back pressure
			stin_ready <= '1';
		else
			stin_ready <= '0';
		end if;

		case input_state is

			when STATE_INPUT_REAL =>
				if (si_ready = '1') and (stin_valid = '1') and (state_next = TRANSFER_TO_FFT) then
					temp_in <= stin_data; -- Real input data
					
					input_state_next <= STATE_INPUT_IMAG;
					
					if index = 0 then
						si_sop_next <= '1'; -- set sop flag at next clock
					elsif index = FFT_LENGTH-1 then
						stin_ready <= '0';
						si_eop_next <= '1'; -- set sop flag at next clock
					end if;
				elsif index = FFT_LENGTH then -- independent of valid signals
					index_next <= 0; -- reset counter
				end if;
								
			when STATE_INPUT_IMAG =>
				if (si_ready = '1') and (stin_valid = '1') and (state_next = TRANSFER_TO_FFT) then
					si_real <= temp_in;	  -- Real input data
					si_imag <= stin_data; -- Imaginary input data
					
					input_state_next <= STATE_INPUT_REAL;	
					
					-- increase index and feed new input;
					index_next <= index + 1;
					si_valid <= '1';
				end if;
							
			when others =>
				input_state_next <= STATE_INPUT_REAL;				
		end case;

	end process input_proc;
	
	--------------------------------------------------------------------
	
	fft_proc: process (state, index, src_sop, src_valid, receive_index, output_state)
	begin
		-- default values to prevent latches
		state_next <= state;
		
		case state is
			
			when TRANSFER_TO_FFT =>
				if index = FFT_LENGTH then 
					--~ state_next <= LATENCY_FFT;
					state_next <= OUTPUT_DATA;
				end if;
			
			when LATENCY_FFT =>
				if (src_sop = '1') and (src_valid = '1') then
					state_next <= OUTPUT_DATA;
			end if;
			
			when OUTPUT_DATA =>
				if (receive_index = FFT_LENGTH) and ((output_state = STATE_OUTPUT_REAL) or (output_state = STATE_OUTPUT_INVERSE)) then
					state_next <= TRANSFER_TO_FFT;
				end if;
				
			when others =>
				state_next <= TRANSFER_TO_FFT;				
		end case;
		
	end process fft_proc;
		
	--------------------------------------------------------------------
			
	output_proc : process(output_state, receive_index, temp_out, stout_ready, src_valid, state_next, state, inverse, src_exp, src_real, src_imag) is
		variable exponent 	  : integer range -13 to 13 := 0;
		variable exponent_abs : natural range  0 to 13 := 0;
	begin
		-- default values to prevent latches
		output_state_next <= output_state;
		stout_data <= (others => '0');
		receive_index_next <= receive_index;
		temp_out_next <= temp_out;
		stout_valid <= '0';
		src_ready <= stout_ready;
		
		if inverse = "1" then
			output_state_next <= STATE_OUTPUT_INVERSE;
		end if;
		
		case output_state is

			when STATE_OUTPUT_REAL =>
				if receive_index = FFT_LENGTH then -- independent of valid signals
					receive_index_next <= 0; -- reset counter
					temp_out_next <= (others => '0');
				elsif (stout_ready = '1') and (src_valid = '1') and ((state_next = OUTPUT_DATA) or (state = OUTPUT_DATA)) and not (receive_index = FFT_LENGTH) then
					stout_valid <= '1';
					
					-- Calculate exponent, FFT operation
					exponent := -to_integer(signed(src_exp));
					exponent_abs := to_integer(abs(to_signed(exponent,src_exp'length)));
					
					if receive_index = 0 then -- for first transmission
						if exponent < 0 then -- right shift
							stout_data <= std_logic_vector(shift_right(signed(src_real), exponent_abs));
						elsif exponent >= 0 then -- left shift
							stout_data <= std_logic_vector(shift_left(signed(src_real), exponent_abs));
						end if;
					else
						if exponent < 0 then -- right shift
							stout_data <= std_logic_vector(shift_right(signed(temp_out), exponent_abs));
						elsif exponent >= 0 then -- left shift
							stout_data <= std_logic_vector(shift_left(signed(temp_out), exponent_abs));
						end if;
					end if;
					
					output_state_next <= STATE_OUTPUT_IMAG;
					temp_out_next <= src_imag;
				end if;
								
			when STATE_OUTPUT_IMAG =>
				if (stout_ready = '1') and (src_valid = '1') and ((state_next = OUTPUT_DATA) or (state = OUTPUT_DATA)) then
					stout_valid <= '1';
					src_ready <= '0';
					
					if exponent < 0 then -- right shift
						stout_data <= std_logic_vector(shift_right(signed(temp_out), exponent_abs));
					elsif exponent >= 0 then -- left shift
						stout_data <= std_logic_vector(shift_left(signed(temp_out), exponent_abs));
					end if;
					
					output_state_next <= STATE_OUTPUT_REAL;
					
					--~ if receive_index = FFT_LENGTH-1 then
						--~ temp_out_next <= (others => '0');
					--~ else
						--~ temp_out_next <= src_real;
					--~ end if;
					
					receive_index_next <= receive_index + 1;	
				elsif receive_index = FFT_LENGTH-1 then -- for last imaginary value
					stout_valid <= '1';
					src_ready <= '0';
					
					if exponent < 0 then -- right shift
						stout_data <= std_logic_vector(shift_right(signed(temp_out), exponent_abs));
					elsif exponent >= 0 then -- left shift
						stout_data <= std_logic_vector(shift_left(signed(temp_out), exponent_abs));
					end if;
					
					output_state_next <= STATE_OUTPUT_REAL;
					temp_out_next <= (others => '0');	
					receive_index_next <= receive_index + 1;				
				end if;
				
			when STATE_OUTPUT_INVERSE =>
				if inverse = "0" then
					output_state_next <= STATE_OUTPUT_REAL;
				elsif receive_index = FFT_LENGTH then -- independent of valid signals
					receive_index_next <= 0; -- reset counter
					output_state_next <= STATE_OUTPUT_REAL;
				elsif (stout_ready = '1') and (src_valid = '1') and ((state_next = OUTPUT_DATA) or (state = OUTPUT_DATA)) and not (receive_index = FFT_LENGTH) then
					stout_valid <= '1';
					
					-- Calculate exponent, IFFT operation
					exponent := -to_integer(signed(src_exp)) + DIV_N;
					exponent_abs := to_integer(abs(to_signed(exponent,src_exp'length)));
					
					if exponent < 0 then -- right shift
						stout_data <= std_logic_vector(shift_right(signed(src_real), exponent_abs));
					elsif exponent >= 0 then -- left shift
						stout_data <= std_logic_vector(shift_left(signed(src_real), exponent_abs));
					end if;		
					
					receive_index_next <= receive_index + 1;
				end if;
				
			when others =>
				output_state_next <= STATE_OUTPUT_REAL;				
		end case;
			
	end process output_proc;
				
	si_error <= (others => '0'); -- "If this signal is not used in upstream modules, set to zero."
	
end architecture;
