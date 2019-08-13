library ieee;
library fft_ii_0;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_SIGNED.all;

use fft_ii_0.all; 

-- the following must only accept values if both, stout_ready and stout_valid are high

entity fft_convolution is
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
		stout_ready : in std_logic); -- back pressure from FIFO
begin
end entity fft_convolution;

architecture rtl of fft_convolution is

constant FFT_LENGTH : natural := 1024;
constant FFT_LENGTH_REZIPROK_EQUIVALENT : integer := -10; --1/1024 is equivalent to 2^-10 and 10 right shifts
constant EXPONENT_LENGTH : natural := 6;
constant RESET_ACTIVE : std_logic := '0';

signal	sink_valid_o     : std_logic                     ;
signal	sink_ready_i     : std_logic                    ;
signal	sink_error_o     : std_logic_vector(1 downto 0)  ;
signal	sink_sop_o       : std_logic                     ;
signal  s_sink_sop_next  : std_logic ;
signal	sink_eop_o       : std_logic                     ;
signal	s_sink_eop_next  : std_logic                     ;
signal	sink_real_o      : std_logic_vector(15 downto 0) ;
signal	sink_imag_o      : std_logic_vector(15 downto 0) ;
signal	inverse_o        : std_logic_vector(0 downto 0)  ;
signal	source_valid_i   : std_logic                    ;
signal	source_ready_o   : std_logic                     ;
signal	source_error_i   : std_logic_vector(1 downto 0)  ;
signal	source_sop_i     : std_logic                    ;
signal	source_eop_i     : std_logic                    ;
signal	source_real_i    : std_logic_vector(15 downto 0) ;
signal	source_imag_i    : std_logic_vector(15 downto 0) ;
signal	source_exp_i     : std_logic_vector(5 downto 0)  ;

type type_fft_mux is (INPUT_TO_FFT, INTERNAL_TO_IFFT);
signal s_fft_input_mux_select : type_fft_mux;

signal s_mux_sink_valid : std_logic;

signal s_sink_real  : std_logic_vector(15 downto 0) ;
signal s_sink_imag  : std_logic_vector(15 downto 0) ;
signal var_exponent: integer range -15 to 15;

signal s_receive_index : natural range 0 to FFT_LENGTH := 0; -- one more than needed to avoid overflow
signal s_index : natural range 0 to FFT_LENGTH := 0; -- one more than needed


signal s_exponent_reg  : std_logic_vector(EXPONENT_LENGTH - 1 downto 0); -- 1 exponent values should be stored
signal next_exponent_FFT  : std_logic_vector(EXPONENT_LENGTH - 1 downto 0); 

type state_type is (TRANSFER_TO_FFT, LATENCY_FFT, RECEIVE_FFT_TRANSFER_IFFT, LATENCY_IFFT, OUTPUT_DATA);
signal	state: state_type;
signal	next_state: state_type;

type	transfer_state_type is (IDLE, TRANSFER_DATA);
signal	transfer_state: transfer_state_type;
signal	next_transfer_state: transfer_state_type;

type	receive_state_type is (IDLE, RECEIVE_DATA);
signal	receive_state: receive_state_type;
signal	next_receive_state: receive_state_type;


component fft_1024 is
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
end component fft_1024;

begin

-- ## Control Part ##
-- Control FSM
-- Hier werden nur die Signale zwischen FFT/IFFT umgeroutet
fsm_combinatoric: process ( s_index, source_sop_i, state, s_exponent_reg, source_exp_i, source_valid_i, source_eop_i ) is
begin


-- ## default assignements ##
next_state <= state;
inverse_o <= (others => '0');
s_fft_input_mux_select <= INPUT_TO_FFT;
next_exponent_FFT <= s_exponent_reg;
-- ## default assignements ##	
	case state is
		when TRANSFER_TO_FFT =>				
			
			case s_index is
					when FFT_LENGTH-2 =>
					when FFT_LENGTH-1 =>
					when FFT_LENGTH => -- just FFT_LENGTH-1 was sent
						next_state <= LATENCY_FFT;
					when others => 
						NULL;
				end case;

		when LATENCY_FFT =>
			s_fft_input_mux_select <= INTERNAL_TO_IFFT;
			if ( source_sop_i = '1' ) and (source_valid_i = '1') then
				next_state <= RECEIVE_FFT_TRANSFER_IFFT;
				next_exponent_FFT <= source_exp_i;
			end if;
						
						
		when RECEIVE_FFT_TRANSFER_IFFT =>
			
			case s_index is
					when FFT_LENGTH-1 =>
						next_state <= LATENCY_IFFT;
					when others => 
						NULL;
				end case;
			
			s_fft_input_mux_select <= INTERNAL_TO_IFFT;
			inverse_o <= (others => '1');

			
		when LATENCY_IFFT =>
			
			if ( source_sop_i = '1' ) and (source_valid_i = '1') then
				
				next_state <= OUTPUT_DATA;

			end if;			
			inverse_o <= (others => '1');
		when OUTPUT_DATA =>
		
			if ( source_eop_i = '1' ) and (source_valid_i = '1')  then
				
				next_state <= TRANSFER_TO_FFT;

			end if;	
			
		when others => 
			next_state <= TRANSFER_TO_FFT;
	end case;

end process; 

-- ## Control Part MUX##
-- Hier werden die Daten vom FIFO oder der FFT geroutet
mux_FFT_input: process(s_fft_input_mux_select, source_imag_i, source_real_i, stin_valid, stin_data, source_valid_i) is
begin
	s_mux_sink_valid <= '0';
	case s_fft_input_mux_select is
		when INPUT_TO_FFT => 
			s_sink_imag <= stin_data(15 downto 0);
			s_sink_real <= stin_data(31 downto 16);
			s_mux_sink_valid <= stin_valid;
		when INTERNAL_TO_IFFT => 
			s_sink_imag <= source_imag_i; -- needs to be multiplied with filter
			s_sink_real <= source_real_i;
			s_mux_sink_valid <= source_valid_i;
		when others =>
			s_sink_imag <= (others => '-');
			s_sink_real <= (others => '-');	
	end case;
	
end process;

 
--## Transfer Part ##  
-- Send FSM
-- Hier werden die Daten vom FIFO zur FFT geladen
fsm_send_combinatoric: process (transfer_state, sink_ready_i,s_index, next_state, s_mux_sink_valid) is
begin
-- ## default assignements ##
	next_transfer_state <= transfer_state;

	s_sink_sop_next <= '0';
	s_sink_eop_next <= '0';
	
	if next_state = TRANSFER_TO_FFT and sink_ready_i='1' then  -- forward back pressure
		stin_ready <= '1';
	else
		stin_ready <= '0'; -- signal to input FIFO
	end if;
-- ## default assignements ##	


case transfer_state is
		when IDLE =>					
			if (sink_ready_i = '1') and (s_mux_sink_valid='1') and (next_state = RECEIVE_FFT_TRANSFER_IFFT or next_state = TRANSFER_TO_FFT) then
				next_transfer_state <= TRANSFER_DATA;
				s_sink_sop_next <= '1';
			end if;
		when TRANSFER_DATA =>	
			if (sink_ready_i = '1') and (s_mux_sink_valid='1') then
				if s_index = FFT_LENGTH-1 then
						stin_ready <= '0';
						s_sink_eop_next <= '1';	
				end if;
			end if;
			
			if s_index = FFT_LENGTH then -- independent of valid signals
				next_transfer_state <= IDLE;
				stin_ready <= '0';
			end if;
		when others => 
			next_transfer_state <= IDLE;
end case;

end process;	 
    
  
--## Transfer Part ##    
--! Data and Control is sent to the FFT  
output_reg : process(reset_n,clk)
begin
if reset_n = RESET_ACTIVE then
	sink_sop_o <= '0';
	sink_valid_o <= '0';
	s_index <= 0;
	sink_eop_o <= '0';
elsif (rising_edge(clk)) then 

	sink_valid_o <= '0';
	sink_sop_o <= s_sink_sop_next;
	sink_eop_o <= s_sink_eop_next;
	if (sink_ready_i = '1') and (next_transfer_state = TRANSFER_DATA) and (s_mux_sink_valid='1') then		-- increase index and feed new input;
		sink_imag_o <= s_sink_imag;
		sink_real_o <= s_sink_real;
		s_index <= s_index +1;
		sink_valid_o <= '1';
	elsif not (next_transfer_state = TRANSFER_DATA) then
		s_index <= 0;
	end if;
		
end if;
end process;


--## Receive Part ##
--! Data from the FFT is stored
input_reg : process(reset_n,clk)
begin
if reset_n = RESET_ACTIVE then
	
	s_exponent_reg <= (others=>'0');
	s_receive_index <= 0;
elsif (rising_edge(clk)) then
	s_exponent_reg <= next_exponent_FFT;


	
	if(source_valid_i = '1') and (source_ready_o = '1')  then -- for debugging purpose
		s_receive_index <= s_receive_index +1; 
	end if;
	
	if s_receive_index >= FFT_LENGTH-1 THEN
	s_receive_index <= 0;
	end if;
		
end if;
end process;  

--## Receive Part ##
-- Reseive FSM
fsm_receive_combinatoric: process (receive_state, source_sop_i, source_eop_i, source_valid_i, stout_ready, next_state) is
	begin
-- ## default assignements ##
	if (next_state = OUTPUT_DATA) or (next_state = LATENCY_IFFT) then -- are we able to receive data from FFT
		source_ready_o <= stout_ready; -- output is directed to FIFO
	else
		source_ready_o <= '1'; -- output is routed back to FFT
	end if;
	
	next_receive_state <= receive_state;
-- ## default assignements ##	
	case receive_state is
		when IDLE =>
			if source_sop_i = '1' and source_valid_i = '1' then
				next_receive_state <= RECEIVE_DATA;
			end if;
		when RECEIVE_DATA =>
			if source_eop_i = '1' and source_valid_i = '1' then
				next_receive_state <= IDLE;
			end if;
		when others => 
			next_receive_state <= IDLE;
	end case;
end process;	
  
-- next transfer_state logic
reg_proc : process (reset_n,clk) is
begin
	if reset_n = RESET_ACTIVE then
		state <= TRANSFER_TO_FFT;
		transfer_state <= IDLE;
		receive_state <= IDLE;
	elsif rising_edge(clk) then
		state <= next_state;
		transfer_state <= next_transfer_state;
		receive_state <= next_receive_state;
	end if;
end process;

u0 : component fft_1024 
	port map (
		clk          	=> clk,          --    clk.clk
		reset_n      	=> reset_n,      --    rst.reset_n
		sink_valid   	=> sink_valid_o,   --   sink.sink_valid
		sink_ready   	=> sink_ready_i,   --       .sink_ready
		sink_error   	=> sink_error_o,   --       .sink_error
		sink_sop     	=> sink_sop_o,     --       .sink_sop
		sink_eop     	=> sink_eop_o,     --       .sink_eop_o
		sink_real    	=> sink_real_o,    --       .sink_real
		sink_imag    	=> sink_imag_o,    --       .sink_imag
		inverse      	=> inverse_o,      --       .inverse
		source_valid 	=> source_valid_i, -- source.source_valid
		source_ready 	=> source_ready_o, --       .source_ready
		source_error 	=> source_error_i, --       .source_error
		source_sop   	=> source_sop_i,   --       .source_sop
		source_eop   	=> source_eop_i,   --       .source_eop
		source_real  	=> source_real_i,  --       .source_real
		source_imag  	=> source_imag_i,  --       .source_imag
		source_exp   	=> source_exp_i    --       .source_exp
	);


output_proc : process(s_exponent_reg, stout_ready, source_valid_i, next_state, source_imag_i, source_real_i, source_exp_i,state) is
	variable var_exponent : integer range -15 to 15 := 0;
	variable var_exponent_abs : natural range 0 to 15 := 0;
begin
		
		stout_data(15 downto 0) <= (others => '-');
		stout_data(31 downto 16) <= (others => '-');
		stout_valid <= '0';
		
		if (stout_ready = '1') and ((next_state = OUTPUT_DATA) or (state = OUTPUT_DATA))  then
			stout_valid <= source_valid_i;
			var_exponent := -to_integer(signed(s_exponent_reg)) - to_integer(signed(source_exp_i)) + FFT_LENGTH_REZIPROK_EQUIVALENT;
			var_exponent_abs := to_integer(abs(to_signed(var_exponent,5)));
			if var_exponent < 0 then --right shift		
				stout_data(15 downto 0) <= std_logic_vector(shift_right(signed(source_imag_i),var_exponent_abs));
				stout_data(31 downto 16) <= std_logic_vector(shift_right(signed(source_real_i),var_exponent_abs));
			elsif var_exponent >= 0 then --left shift
				stout_data(15 downto 0) <= std_logic_vector(shift_left(signed(source_imag_i),var_exponent_abs));
				stout_data(31 downto 16) <= std_logic_vector(shift_left(signed(source_real_i),var_exponent_abs));
			end if;
		end if;
end process;

sink_error_o <= (others => '0'); --"If this signal is not used in upstream modules,set to zero."
end architecture rtl;


