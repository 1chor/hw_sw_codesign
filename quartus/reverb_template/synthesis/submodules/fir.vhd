
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;
use work.ram_pkg.all;

entity fir is
	generic (
		NUM_COEFFICIENTS : positive := 512; 
		DATA_WIDTH		 : positive := 32;
		ADDR_WIDTH       : positive := 9 
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		-- streaming sink (input)
		stin_data  : in std_logic_vector(DATA_WIDTH-1 downto 0);
		stin_valid : in std_logic;
		stin_ready : out std_logic;
		
		-- streaming source (output)
		stout_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);
		stout_valid  : out std_logic;
		stout_ready : in	std_logic; --only needed with backpressure enabled
		
		-- memory mapped slave (coefficients)
		mm_address      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		mm_write        : in  std_logic;
		mm_read         : in  std_logic; --not used
		mm_writedata    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		mm_readdata     : out std_logic_vector(DATA_WIDTH-1 downto 0) --not used, coefficients can not be read
	);
begin
	assert (log2c(NUM_COEFFICIENTS) = ADDR_WIDTH) report "Address space is not large enough to hold all coefficients!" severity failure;
end entity;

architecture arch of fir is
	
	subtype coeff_cnt is integer range 0 to (NUM_COEFFICIENTS-1);
	signal mul_cnt 			  	 : coeff_cnt;
    signal mul_cnt_next 	  	 : coeff_cnt;
	signal data_addr_oldest 	 : coeff_cnt;
	signal data_addr_oldest_next : coeff_cnt;
	
	signal coeff_dout 	 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal data_dout 	 : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal coeff_read	 : std_logic;
	signal data_write	 : std_logic;
	signal data_read	 : std_logic;
	
	signal temp 		 : signed(2*DATA_WIDTH-1 downto 0);
	signal temp_next	 : signed(2*DATA_WIDTH-1 downto 0);
	
	signal coeff_rd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal data_wr_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal data_rd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
	
	type state_type is (
		STATE_IDLE,
		STATE_MULT,
		STATE_OUTPUT
	);
	signal state, state_next : state_type := STATE_IDLE;
	
begin

	mm_readdata <= (others => '0'); --default value, not used
	
	--RAM block for coefficients
	ram_coeff: dp_ram_1c1r1w 
	generic map (
		ADDR_WIDTH => ADDR_WIDTH, -- Address bus width
		DATA_WIDTH => DATA_WIDTH  -- Data bus width
	)
	port map (
		clk => clk, -- Connection for the clock signal.
		
		-- read port
		rd_addr => coeff_rd_addr, -- The address bus for a reader of the dual port RAM.
		rd_data => coeff_dout, -- The data bus for a reader of the dual port RAM.
		rd      => coeff_read, -- The indicator signal for a reader of the dual port RAM (must  be set high in order to be able to read).
		
		-- write port
		wr_addr => mm_address, -- The address bus for a writer of the dual port RAM.
		wr_data => mm_writedata, -- The data bus for a writer of the dual port RAM.
		wr      => mm_write -- The indicator signal for a writer of the dual port RAM (must be set high in order to be able to write).
	);
	
	--need to use mul_cnt_next because of one latency cycle inside the RAM
	coeff_rd_addr <= std_logic_vector(to_unsigned(mul_cnt_next + 1, ADDR_WIDTH));
	
	--RAM block for data
	ram_data: dp_ram_1c1r1w 
	generic map (
		ADDR_WIDTH => ADDR_WIDTH,
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		clk => clk,
		
		-- read port
		rd_addr => data_rd_addr, 
		rd_data => data_dout, 
		rd      => data_read, 
		
		-- write port
		wr_addr => data_wr_addr, 
		wr_data => stin_data, 
		wr      => data_write 
	);
	
	--need to use mul_cnt_next because of one latency cycle inside the RAM
    data_wr_addr <= std_logic_vector(to_unsigned(data_addr_oldest, ADDR_WIDTH));
	data_rd_addr <= std_logic_vector(to_unsigned(data_addr_oldest + mul_cnt_next + 1, ADDR_WIDTH));
			
	sync_state_proc: process (res_n, clk)
	begin
		if res_n = '0' then -- Reset signals
			state <= STATE_IDLE;
			mul_cnt <= 0;
			temp <= (others => '0');
			data_addr_oldest <= 0;
			
		elsif rising_edge(clk) then
			state <= state_next;	
			mul_cnt <= mul_cnt_next;
			temp <= temp_next;
			data_addr_oldest <= data_addr_oldest_next;
		end if;
			
	end process sync_state_proc;
	
	fir_proc: process (state, data_addr_oldest, temp, stin_valid, coeff_dout, data_dout, mul_cnt, stout_ready)
	begin
		-- default values to prevent latches
		state_next <= state;
		
		data_addr_oldest_next <= data_addr_oldest;
		mul_cnt_next <= 0;
		temp_next <= temp;
		
		stin_ready <= '0';		
		stout_valid <= '0';
		coeff_read <= '0';
		data_write <= '0';
		data_read <= '0';
		stout_data <= (others => '0');
		
		case state is
		
			when STATE_IDLE =>
				stin_ready <= '1'; -- Ready for Input
								
				if stin_valid = '1' then
					data_write <= '1';
					
					coeff_read <= '1';
                    data_read <= '1';
					state_next <= STATE_MULT;
				end if;
						
			when STATE_MULT =>
				temp_next <= temp + signed(coeff_dout) * signed(data_dout);
				
				if mul_cnt = NUM_COEFFICIENTS-1 then -- catch overflow
					state_next <= STATE_OUTPUT;
				else
					mul_cnt_next <= mul_cnt + 1;
					coeff_read <= '1';
                    data_read <= '1';
				end if;
				
			when STATE_OUTPUT =>
				if stout_ready = '1' then
					-- Set Output
					--stout_data <= std_logic_vector(temp(47 downto 16)); -- 16Q16 Format for Simulation
					stout_data <= std_logic_vector(temp(62 downto 31)); -- 2Q30 Format
					stout_valid <= '1';
					
					temp_next <= (others => '0');
					
					if data_addr_oldest = 0 then
						data_addr_oldest_next <= NUM_COEFFICIENTS - 1;
					else
						data_addr_oldest_next <= data_addr_oldest - 1;
					end if;
					
					state_next <= STATE_IDLE;
				end if;
				
			when others =>
				state_next <= STATE_IDLE;				
		end case;
			
	end process fir_proc;
	
	-- coefficient_proc: process (res_n, clk)
	-- begin
		-- if res_n = '0' then -- Reset signals
			-- coefficients <= (others => (others => '0'));
			-- readdata <= (others => '0');
			
		-- elsif rising_edge(clk) then
			-- if write = '1' then
				-- coefficients(to_integer(unsigned(address))) <= writedata;
			
			-- elsif read = '1' then
				-- readdata <= coefficients(to_integer(unsigned(address)));
			
			-- end if;	
		-- end if;
			
	-- end process coefficient_proc;
	
end architecture;

