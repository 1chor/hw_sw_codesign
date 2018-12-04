
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;

entity fir is
	generic (
		NUM_COEFFICIENTS : integer := 16; 
		ADDR_WIDTH       : integer := 4 
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		-- streaming sink (input)
		stin_data  : in std_logic_vector(31 downto 0);
		stin_valid : in std_logic;
		stin_ready : out std_logic;
		
		-- streaming source (output)
		stout_data   : out std_logic_vector(15 downto 0);
		stout_valid  : out std_logic;
		
		-- memory mapped slave (coefficients)
		address      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		write        : in  std_logic;
		read         : in  std_logic;
		writedata    : in  std_logic_vector(15 downto 0);
		readdata     : out std_logic_vector(15 downto 0)
	);
begin
	assert (log2c(NUM_COEFFICIENTS) = ADDR_WIDTH) report "Address space is not large enough to hold all coefficients!" severity failure;
end entity;

architecture arch of fir is
	
	type array_type is array (NUM_COEFFICIENTS-1 downto 0) of std_logic_vector(15 downto 0);
	signal coefficients		 : coeff_type := (others => (others => '0'));
	signal coefficients_mult : coeff_type := (others => (others => '0'));
	
	signal x_n 		: array_type := (others => (others => '0'));	
	signal x_n_mult : array_type := (others => (others => '0'));	
	
	type mult_type is array (NUM_COEFFICIENTS-1 downto 0) of std_logic_vector(31 downto 0);
	signal result_mult  : mult_type := (others => (others => '0'));
	
	type sum_type is array (NUM_COEFFICIENTS-2 downto 0) of std_logic_vector(31 downto 0);
	signal sum_a		: sum_type := (others => (others => '0'));
	signal sum_b		: sum_type := (others => (others => '0'));
	signal sum_result	: sum_type := (others => (others => '0'));
	
	type state_type is (
		STATE_IDLE,
		STATE_MULT,
		STATE_ADD,
		STATE_OUTPUT
	);
	signal state, state_next : state_type := STATE_IDLE;

	-- Component for multiplier
	component mult
		port
		(
			dataa		: in std_logic_vector (15 downto 0);
			datab		: in std_logic_vector (15 downto 0);
			result		: out std_logic_vector (31 downto 0)
		);
	end component;
	
	-- Component for adder
	component add
		port
		(
			dataa		: in std_logic_vector (31 downto 0);
			datab		: in std_logic_vector (31 downto 0);
			result		: out std_logic_vector (31 downto 0)
		);
	end component;
	
begin
	-- generate multiplier
	gen_mult:
	for i in 0 to NUM_COEFFICIENTS-1 generate
		mult: mult
		port map (
			x_n_mult(i),
			coefficients_mult(i),
			result_mult(i)
		);
	end generate gen_mult;
	
	-- generate adder
	gen_add:
	for i in 0 to NUM_COEFFICIENTS-2 generate
		add: add
		port map (
			sum_a(i),
			sum_b(i),
			sum_result(i)
		);
	end generate gen_add;
			
	sync_state_proc: process (res_n, clk)
	begin
		if res_n = '0' then -- Reset signals
			state <= STATE_IDLE;
			x_n <= (others => (others => '0'));	
			
		elsif rising_edge(clk) then
			state <= state_next;	
			
			--Shift Values
			if(stin_valid = '1') then
				x_n(NUM_COEFFICIENTS-1 downto 1) <= x_n(NUM_COEFFICIENTS-2 downto 0);
				x_n(0) <= stin_data;
			end if;
		end if;
			
	end process sync_state_proc;
	
	fir_proc: process (state, stin_valid, x_n, coefficients, result_mult, sum_result)
	begin
		state_next <= state;
		
		stin_ready <= '0';		
		stout_valid <= '0';
		
		case state is
		
			when STATE_IDLE =>
				stin_ready <= '1'; --Ready for Input
								
				if stin_valid = '1' then
					--stin_ready <= '0'; --Activate for simulation
					state_next <= STATE_MULT;
				end if;
						
			when STATE_MULT =>
				--Multiply
				--Übergibt die Werte an die Multiplizierer
				for i in 0 to NUM_COEFFICIENTS-1 loop
					x_n_mult(i) <= x_n(i);
					coefficients_mult(i) <= coefficients(i);
				end loop;
				
				state_next <= STATE_ADD;
				
			when STATE_ADD =>
				--Add
				--Übergibt die Werte an die Addierer
				sum_a(0) <= result_mult(0);
				sum_b(0) <= result_mult(1);
				
				for i in 1 to NUM_COEFFICIENTS-2 loop
					sum_a(i) <= sum_result(i-1);
					sum_b(i) <= result_mult(i+1);
				end loop;
				
				state_next <= STATE_OUTPUT;
				
			when STATE_OUTPUT =>
				--Set Output
				stout_valid <= '1';
				stout_data <= sum_result(NUM_COEFFICIENTS-2)(23 downto 8);
				
				state_next <= STATE_IDLE;
				
			when others =>
				state_next <= STATE_IDLE;				
		end case;
			
	end process fir_proc;
	
	coefficient_proc: process (res_n, clk, write, writedata, read, coefficients)
	begin
		if res_n = '0' then -- Reset signals
			coefficients <= (others => (others => '0'));
			readdata <= (others => '0');
			
		elsif rising_edge(clk) then
			if write = '1' then
				coefficients(to_integer(unsigned(address))) <= writedata;
			
			elsif read = '1' then
				readdata <= coefficients(to_integer(unsigned(address)));
			
			end if;	
		end if;
			
	end process coefficient_proc;
	
end architecture;

