
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ram_pkg.all;

entity mac_sram is
    port (
        clk   : in std_logic;
        res_n : in std_logic;
        
        -- memory mapped slave
        s_address   : in  std_logic_vector(15 downto 0);
        s_write     : in  std_logic;
        s_read      : in  std_logic;
        s_writedata : in  std_logic_vector(31 downto 0);
        s_readdata  : out std_logic_vector(31 downto 0);
                
        -- memory mapped master
        m_address   : out  std_logic_vector(19 downto 0);
        m_write     : out  std_logic;
        m_read      : out  std_logic;
        m_writedata : out  std_logic_vector(15 downto 0);
        m_readdata  : in std_logic_vector(15 downto 0);
        m_readdatavalid : in std_logic;
                
        sel : out std_logic
    );
begin
    
end entity;

architecture arch of mac_sram is

constant ADDR_WIDTH : integer := 9;
constant DATA_WIDTH : integer := 64;

-- BLOCKS

-- 0 - 13 header left
-- 14 - 27 header right
-- 28 - 41 input left
-- 42 - 55 input right

-- header left

constant IR_BLOCK_1_MIN : integer := 0;
constant IR_BLOCK_1_MAX : integer := 13;

-- header right

constant IR_BLOCK_2_MIN : integer := 14;
constant IR_BLOCK_2_MAX : integer := 27;

-- input left

constant IN_BLOCK_1_MIN : integer := 28;
constant IN_BLOCK_1_MAX : integer := 41;

-- input right

constant IN_BLOCK_2_MIN : integer := 42;
constant IN_BLOCK_2_MAX : integer := 55;

-- block size

constant BLOCK_SIZE : integer := 512;

-- Address where the actual state is written

constant ADDRESS_STATE : integer := 1700;

-- block signals

signal ir_block_min : integer range 0 to 55 := IR_BLOCK_1_MIN;
signal ir_block_min_next : integer range 0 to 55 := IR_BLOCK_1_MIN;
signal ir_block_max : integer range 0 to 55 := IR_BLOCK_1_MAX;
signal ir_block_max_next : integer range 0 to 55 := IR_BLOCK_1_MAX;

signal in_block_min : integer range 0 to 55 := IN_BLOCK_1_MIN;
signal in_block_min_next : integer range 0 to 55 := IN_BLOCK_1_MIN;
signal in_block_max : integer range 0 to 55 := IN_BLOCK_1_MAX;
signal in_block_max_next : integer range 0 to 55 := IN_BLOCK_1_MAX;

signal reset : std_logic := '0';
signal reset_next : std_logic := '0';
signal start : std_logic := '0';
signal start_next : std_logic := '0';

-- wir beginnen eigentlich bei 41, aber wenn das zum ersten mal
-- aufgerufen wird, dann wird das gleich erhoeht.

signal latest_in_block : integer range 0 to 55 := 40; -- TODO - kann kleiner sein
signal latest_in_block_next : integer range 0 to 55 := 40; -- TODO - kann kleiner sein
signal latest_in_block_1 : integer range 0 to 55 := (IN_BLOCK_1_MAX - 1);
signal latest_in_block_1_next : integer range 0 to 55 := (IN_BLOCK_1_MAX - 1);
signal latest_in_block_2 : integer range 0 to 55 := (IN_BLOCK_2_MAX - 1);
signal latest_in_block_2_next : integer range 0 to 55 := (IN_BLOCK_2_MAX - 1);

-- 0 - left channel
-- 1 - right channel
signal channel : std_logic;
signal channel_next : std_logic;

signal output_addr : integer;
signal output_addr_next : integer;
signal output_value : std_logic_vector( 63 downto 0 );
signal output_value_next : std_logic_vector( 63 downto 0 );

------------------------------------------------------------------------

type state_mode_type is (
    STATE_IDLE,
    STATE_START,
    STATE_RESET,
    STATE_RUN,
    STATE_RUN2,
    STATE_RUN3,
    
    STATE_A_H_PRE,
    STATE_A_H,
    STATE_A_H_POST,
    
    STATE_A_L_PRE,
    STATE_A_L,
    STATE_A_L_POST,
    
    STATE_C_H_PRE,
    STATE_C_H,
    STATE_C_H_POST,
    
    STATE_C_L_PRE,
    STATE_C_L,
    STATE_C_L_POST,
    
    STATE_D_H_PRE,
    STATE_D_H,
    STATE_D_H_POST,
    
    STATE_D_L_PRE,
    STATE_D_L,
    STATE_D_L_POST,
    
    STATE_B_H_PRE,
    STATE_B_H,
        
    STATE_B_L,    
    STATE_B_L_CONTINUE,    
    STATE_NEXT_BLOCK,
    STATE_NEXT_BLOCK2,
    STATE_EX_A_L
);
signal state_mode : state_mode_type;
signal state_mode_next : state_mode_type;

signal a : std_logic_vector( 31 downto 0 );
signal a_next : std_logic_vector( 31 downto 0 );
signal b : std_logic_vector( 31 downto 0 );
signal b_next : std_logic_vector( 31 downto 0 );
signal c : std_logic_vector( 31 downto 0 );
signal c_next : std_logic_vector( 31 downto 0 );
signal d : std_logic_vector( 31 downto 0 );
signal d_next : std_logic_vector( 31 downto 0 );

signal a_mul_c : signed( 63 downto 0 );
signal a_mul_c_next : signed( 63 downto 0 );
signal b_mul_c : signed( 63 downto 0 );
signal b_mul_c_next : signed( 63 downto 0 );
signal b_mul_d : signed( 63 downto 0 );
signal b_mul_d_next : signed( 63 downto 0 );
signal a_mul_d : signed( 63 downto 0 );
signal a_mul_d_next : signed( 63 downto 0 );

signal new_r : signed( 63 downto 0 );
signal new_r_next : signed( 63 downto 0 );
signal new_i : signed( 63 downto 0 );
signal new_i_next : signed( 63 downto 0 );

signal i : integer range 0 to BLOCK_SIZE;
signal i_next : integer range 0 to BLOCK_SIZE;
signal i_prev : integer range 0 to BLOCK_SIZE;
signal i_prev_next : integer range 0 to BLOCK_SIZE;

-- array type ist um 1 zu gross.
-- das ist wegen der pipeline so.
-- TODO - das sollte nicht mehr noetig sein.

signal acc_r_temp : signed( 63 downto 0 );
signal acc_r_temp_next : signed( 63 downto 0 );
signal acc_i_temp : signed( 63 downto 0 );
signal acc_i_temp_next : signed( 63 downto 0 );

signal in_pointer : integer range 0 to 55; -- TODO - kann kleiner sein.
signal in_pointer_next : integer range 0 to 55;

signal ir_pointer : integer range 0 to 55;
signal ir_pointer_next : integer range 0 to 55;

signal in_addr : unsigned( 19 downto 0 );
signal in_addr_next : unsigned( 19 downto 0 );

signal ir_addr : unsigned( 19 downto 0 );
signal ir_addr_next : unsigned( 19 downto 0 );

------------------------------------------------------------------------

-- Signals for RAMs
signal ram_r_rd_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal ram_r_rd_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
signal ram_r_rd : std_logic;

signal ram_r_wr_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal ram_r_wr_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
signal ram_r_wr : std_logic;

signal ram_i_rd_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal ram_i_rd_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
signal ram_i_rd : std_logic;

signal ram_i_wr_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal ram_i_wr_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
signal ram_i_wr : std_logic;
	
------------------------------------------------------------------------

type read_state_type is (
    STATE_IDLE,
    STATE_ADDRESS,
    STATE_ARRAY,
    STATE_DUMMY,
    STATE_ARRAY_I,
    STATE_ARRAY_R,
    STATE_OUTPUT
);
signal read_state : read_state_type;
signal read_state_next : read_state_type;
	
------------------------------------------------------------------------

-- Signals for sync outputs
signal s_readdata_s : std_logic_vector(31 downto 0);
signal s_readdata_next : std_logic_vector(31 downto 0);

signal m_address_s : std_logic_vector(19 downto 0);
signal m_address_next : std_logic_vector(19 downto 0);
signal m_write_s : std_logic := '0';
signal m_read_s : std_logic;
signal m_read_next : std_logic;
signal m_writedata_s : std_logic_vector(15 downto 0);
signal m_writedata_next : std_logic_vector(15 downto 0);

signal sel_s :std_logic;
signal sel_next : std_logic;

-- signals for simulation
-- signal skip : std_logic := '1';
-- signal skip_next : std_logic := '1';

begin

-- RAM block for acc_r
ram_acc_r: dp_ram_1c1r1w 
generic map (
	ADDR_WIDTH => ADDR_WIDTH, -- Address bus width
	DATA_WIDTH => DATA_WIDTH  -- Data bus width
)
port map (
	clk => clk, -- Connection for the clock signal.
	
	-- read port
	rd_addr => ram_r_rd_addr, -- The address bus for a reader of the dual port RAM.
	rd_data => ram_r_rd_data, -- The data bus for a reader of the dual port RAM.
	rd      => ram_r_rd, -- The indicator signal for a reader of the dual port RAM (must  be set high in order to be able to read).
	
	-- write port
	wr_addr => ram_r_wr_addr, -- The address bus for a writer of the dual port RAM.
	wr_data => ram_r_wr_data, -- The data bus for a writer of the dual port RAM.
	wr      => ram_r_wr -- The indicator signal for a writer of the dual port RAM (must be set high in order to be able to write).
);

-- RAM block for acc_i
ram_acc_i: dp_ram_1c1r1w 
generic map (
	ADDR_WIDTH => ADDR_WIDTH, -- Address bus width
	DATA_WIDTH => DATA_WIDTH  -- Data bus width
)
port map (
	clk => clk, -- Connection for the clock signal.
	
	-- read port
	rd_addr => ram_i_rd_addr, -- The address bus for a reader of the dual port RAM.
	rd_data => ram_i_rd_data, -- The data bus for a reader of the dual port RAM.
	rd      => ram_i_rd, -- The indicator signal for a reader of the dual port RAM (must  be set high in order to be able to read).
	
	-- write port
	wr_addr => ram_i_wr_addr, -- The address bus for a writer of the dual port RAM.
	wr_data => ram_i_wr_data, -- The data bus for a writer of the dual port RAM.
	wr      => ram_i_wr -- The indicator signal for a writer of the dual port RAM (must be set high in order to be able to write).
);

------------------------------------------------------------------------
-- sync output signals
------------------------------------------------------------------------

s_readdata <= s_readdata_s;

m_address <= m_address_s;
m_write <= m_write_s;
m_read <= m_read_s;
m_writedata <= m_writedata_s;

sel <= sel_s;

------------------------------------------------------------------------
-- sync_state_proc
------------------------------------------------------------------------

sync_state_proc : process (clk, res_n)

begin

	if res_n = '0' then
        
		state_mode <= STATE_IDLE;
		read_state <= STATE_IDLE;

		a <= (others=>'0');
		b <= (others=>'0');
		c <= (others=>'0');
		d <= (others=>'0');
		
		i      <= 0;
		i_prev <= 0;
				
		ir_pointer <= 0;
		in_pointer <= 0;
		ir_addr <= (others=>'0');
		in_addr <= (others=>'0');
		
		a_mul_c <= (others=>'0');
		b_mul_c <= (others=>'0');
		b_mul_d <= (others=>'0');
		a_mul_d <= (others=>'0');
		
		new_r 	   <= (others=>'0');
		new_i 	   <= (others=>'0');
		acc_r_temp <= (others=>'0');
		acc_i_temp <= (others=>'0');

		reset <= '0';
		start <= '0';
		
		output_addr <= 0;
		output_value <= (others => '0');
		
		latest_in_block   <= 40;
		latest_in_block_1 <= (IN_BLOCK_1_MAX - 1);
		latest_in_block_2 <= (IN_BLOCK_2_MAX - 1);
		
		ir_block_min <= IR_BLOCK_1_MIN;
		ir_block_max <= IR_BLOCK_1_MAX;
		
		in_block_min <= IN_BLOCK_1_MIN;
		in_block_max <= IN_BLOCK_1_MAX;
		
		channel <= '0';
		
		s_readdata_s <= (others => '0');
		m_address_s <= (others => '0');
		m_read_s <= '0';
		m_writedata_s <= (others => '0');
		sel_s <= '0';
		
		-- signal for simulation
-- 		skip <= '1';
		
    elsif rising_edge(clk) then
		
		state_mode <= state_mode_next;
		read_state <= read_state_next;
		
		a <= a_next;
		b <= b_next;
		c <= c_next;
		d <= d_next;
		
		i      <= i_next;
		i_prev <= i_prev_next;
						
		ir_pointer <= ir_pointer_next;
		in_pointer <= in_pointer_next;
		ir_addr <= ir_addr_next;
		in_addr <= in_addr_next;
		
		a_mul_c <= a_mul_c_next;
		b_mul_c <= b_mul_c_next;
		b_mul_d <= b_mul_d_next;
		a_mul_d <= a_mul_d_next;
		
		new_r 	   <= new_r_next;
		new_i 	   <= new_i_next;
		acc_r_temp <= acc_r_temp_next;
		acc_i_temp <= acc_i_temp_next;
	
		reset <= reset_next;
		start <= start_next;
		
		output_addr  <= output_addr_next;
		output_value <= output_value_next;
		
		latest_in_block	  <= latest_in_block_next;
		latest_in_block_1 <= latest_in_block_1_next;
		latest_in_block_2 <= latest_in_block_2_next;
		
		ir_block_min <= ir_block_min_next;
		ir_block_max <= ir_block_max_next;
		
		in_block_min <= in_block_min_next;
		in_block_max <= in_block_max_next;
		
		channel <= channel_next;
		
		s_readdata_s <= s_readdata_next;
		m_address_s <= m_address_next;
		m_read_s <= m_read_next;
		m_writedata_s <= m_writedata_next;
		sel_s <= sel_next;
		
		-- signal for simulation
-- 		skip <= skip_next;
		
	end if;
	
end process sync_state_proc;

------------------------------------------------------------------------
-- proc
------------------------------------------------------------------------

proc : process (state_mode, read_state, s_readdata_s, m_address_s, m_writedata_s, a, i, i_prev, ir_pointer, in_pointer, ir_addr, in_addr, a_mul_c, b_mul_c, b_mul_d, a_mul_d, new_r, new_i, acc_r_temp, acc_i_temp, reset, start, output_addr, output_value, latest_in_block, latest_in_block_1, latest_in_block_2, ir_block_min, ir_block_max, in_block_min, in_block_max, channel, s_write, s_writedata, s_address, s_read, m_readdata, b, c, d, ram_r_rd_data, ram_i_rd_data)

begin
    
    -- default values to prevent latches
	state_mode_next <= state_mode;
	read_state_next <= read_state;
		
	a_next <= a;
	b_next <= b;
	c_next <= c;
	d_next <= d;
	
	i_next 	   <= i;
	i_prev_next <= i_prev;
			
	ir_pointer_next <= ir_pointer;
	in_pointer_next <= in_pointer;
	ir_addr_next <= ir_addr;
	in_addr_next <= in_addr;
	
	a_mul_c_next <= a_mul_c;
	b_mul_c_next <= b_mul_c;
	b_mul_d_next <= b_mul_d;
	a_mul_d_next <= a_mul_d;
	
	new_r_next	    <= new_r;
	new_i_next 	    <= new_i;
	acc_r_temp_next <= acc_r_temp;
	acc_i_temp_next <= acc_i_temp;
	
	reset_next <= reset;
	start_next <= start;
	
	output_addr_next  <= output_addr;
	output_value_next <= output_value;
	
	latest_in_block_next   <= latest_in_block;
	latest_in_block_1_next <= latest_in_block_1;
	latest_in_block_2_next <= latest_in_block_2;
	
	ir_block_min_next <= ir_block_min;
	ir_block_max_next <= ir_block_max;
	
	in_block_min_next <= in_block_min;
	in_block_max_next <= in_block_max;
	
	channel_next <= channel;
		
	ram_r_rd_addr <= (others=>'0');
	ram_r_rd <= '0';

	ram_r_wr_addr <= (others=>'0');
	ram_r_wr_data <= (others=>'0');
	ram_r_wr <= '0';

	ram_i_rd_addr <= (others=>'0');
	ram_i_rd <= '0';

	ram_i_wr_addr <= (others=>'0');
	ram_i_wr_data <= (others=>'0');
	ram_i_wr <= '0';
	
	s_readdata_next <= s_readdata_s;
	m_address_next <= m_address_s;
	m_read_next <= m_read_s;
	m_writedata_next <= m_writedata_s;
	
	sel_next <= '0'; -- default, MAC has access to SRAM
		
	-- signal for simulation
-- 	skip_next <= skip;
		
	-- die signale die vom slave interface kommen sollten hier gespeichert werden.
	-- TODO warum?
	
	-- for simulation
-- 	if skip = '1' then
-- 	    skip_next <= '0';
-- 	else
-- 	    skip_next <= '1';
	
	case state_mode is
        
        when STATE_IDLE =>
	    sel_next <= '1'; -- NIOS has access to SRAM
	    
	    m_read_next <= '0';
	    
            if reset = '1' then
                
                reset_next <= '0';
                i_next <= 0;
                state_mode_next <= STATE_RESET;
                
            elsif start = '1' then
                
                start_next <= '0';
                i_next <= 0;
                state_mode_next <= STATE_START;
                
            else
                                
                ------------------------------------------------------------
		-- write
		------------------------------------------------------------
		
		-- jedes mal wenn der mac aktiviert wird wurde ein neuer block
		-- von dem input abgespeichert. daher weiss ich hier, dass sich
		-- der i_pointer wie er in c heisst erhoeht haben muss.
		
		if s_write = '1' then
			
			-- reset
			if ( s_writedata( 1 downto 0 ) = "01" ) and ( s_address( 1 downto 0 ) = "10" ) then
				
				reset_next <= '1';
				
				state_mode_next <= STATE_IDLE;
				
				output_addr_next  <= 0;
				output_value_next <= (others=>'0');
				
				latest_in_block_1_next <= ( IN_BLOCK_1_MAX - 1 );
				latest_in_block_2_next <= ( IN_BLOCK_2_MAX - 1 );
			
			-- start
			elsif ( s_writedata( 1 downto 0 ) = "10" ) and ( s_address( 1 downto 0 ) = "01" ) then
				
				start_next <= '1';
				
				if channel = '0' then -- left channel
				  
				    if latest_in_block_1 = in_block_max then
					  latest_in_block_1_next <= in_block_min;
					  latest_in_block_next <= in_block_min;
				    else
					  latest_in_block_1_next <= latest_in_block_1  + 1;
					  latest_in_block_next <= latest_in_block_1  + 1;
				    end if;
				  
				else
				
				    if latest_in_block_2 = in_block_max then
					  latest_in_block_2_next <= in_block_min;
					  latest_in_block_next <= in_block_min;
				    else
					  latest_in_block_2_next <= latest_in_block_2  + 1;
					  latest_in_block_next <= latest_in_block_2  + 1;
				    end if;
				
				end if;
							
			-- set left channel
			elsif ( s_writedata( 1 downto 0 ) = "01" ) and ( s_address( 1 downto 0 ) = "11" ) then
				
				ir_block_min_next <= IR_BLOCK_1_MIN;
				ir_block_max_next <= IR_BLOCK_1_MAX;
				
				in_block_min_next <= IN_BLOCK_1_MIN;
				in_block_max_next <= IN_BLOCK_1_MAX;
				
				channel_next <= '0';
			
			-- set right channel
			elsif ( s_writedata( 1 downto 0 ) = "10" ) and ( s_address( 1 downto 0 ) = "11" ) then
				
				ir_block_min_next <= IR_BLOCK_2_MIN;
				ir_block_max_next <= IR_BLOCK_2_MAX;
				
				in_block_min_next <= IN_BLOCK_2_MIN;
				in_block_max_next <= IN_BLOCK_2_MAX;
				
				channel_next <= '1';
				
			end if;	
		end if;
                
            end if;
            
        when STATE_START => -- starting
	    
	    ram_r_wr_addr <= std_logic_vector( to_unsigned( i, ram_r_wr_addr'length ));
	    ram_r_wr_data <= (others => '0');
	    ram_r_wr <= '1';
	    
	    ram_i_wr_addr <= std_logic_vector( to_unsigned( i, ram_i_wr_addr'length ));
	    ram_i_wr_data <= (others => '0');
	    ram_i_wr <= '1';
            
            if i = ( BLOCK_SIZE - 1 ) then
                state_mode_next <= STATE_RUN;
            else
                i_next <= i + 1;
            end if;
            
        when STATE_RESET => -- resetting
               
	    ram_r_wr_addr <= std_logic_vector( to_unsigned( i, ram_r_wr_addr'length ));
	    ram_r_wr_data <= (others => '0');
	    ram_r_wr <= '1';
	    
	    ram_i_wr_addr <= std_logic_vector( to_unsigned( i, ram_i_wr_addr'length ));
	    ram_i_wr_data <= (others => '0');
	    ram_i_wr <= '1';
            
            if i = ( BLOCK_SIZE - 1 ) then
                state_mode_next <= STATE_IDLE;
            else
                i_next <= i + 1;
            end if;
            
        when STATE_RUN => -- running
            		
		  -- wenn ich hier bin mach ich ganz neue bloecke.
		  -- also eine ganz neue fft berechnung.
		  		  
		  i_next <= 0;
		  i_prev_next <= 0;
		  
		  in_pointer_next <= latest_in_block;
		  ir_pointer_next <= ir_block_min;
		  
		  state_mode_next <= STATE_RUN2;
				
	when STATE_RUN2 => -- running continue
            						
		--~ ir_addr_next <= x"00000000";
		ir_addr_next <= to_unsigned( ir_pointer * BLOCK_SIZE * 4 * 2, ir_addr_next'length );
		in_addr_next <= to_unsigned( in_pointer * BLOCK_SIZE * 4 * 2, in_addr_next'length ); --~ in_addr_next <= x"00029000";
		
		state_mode_next <= STATE_RUN3;
			
	when STATE_RUN3 => -- running continue
            				    
		m_read_next <= '1'; -- wir lesen immer
		
		m_address_next <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
				
		state_mode_next <= STATE_A_H_PRE;
		
	--------------------------------------------------------
	-- 
	-- a_h
	-- 
	--------------------------------------------------------
	
	-- prev b*c
	-- prev r_i
	
	-- curr a_h
	
	-- addr c_h
                
        when STATE_A_H_PRE => -- a_h available
             
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			m_address_next <= std_logic_vector( ir_addr + ( 2 * 1 ) ); -- a_l
			
			a_next( 31 downto 16 ) <= m_readdata; -- a_h
			
			state_mode_next <= STATE_A_L_PRE;
		end if;
		
	when STATE_A_H => -- a_h available
             
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
		      m_read_next <= '1'; -- wir lesen immer
		      
		      m_address_next <= std_logic_vector( ir_addr + ( 2 * 1 ) ); -- a_l
		      
		      a_next( 31 downto 16 ) <= m_readdata; -- a_h
					      
		      b_mul_c_next <= signed( b ) * signed( c ); -- prev b*c
		      acc_i_temp_next <= signed(ram_i_rd_data); -- prev r_i
		      
		      ram_r_rd_addr <= std_logic_vector( to_unsigned( i_prev, ram_r_rd_addr'length ));
		      ram_r_rd <= '1';
		      
		      state_mode_next <= STATE_A_L;
			
		end if;
		
	when STATE_A_H_POST => -- a_h available
             
		b_mul_c_next <= signed( b ) * signed( c ); -- prev b*c
		acc_i_temp_next <= signed(ram_i_rd_data); -- prev r_i
		
		ram_r_rd_addr <= std_logic_vector( to_unsigned( i_prev, ram_r_rd_addr'length ));
		ram_r_rd <= '1';
		
		state_mode_next <= STATE_A_L_POST;
		
	--------------------------------------------------------
	-- 
	-- a_l
	-- 
	--------------------------------------------------------
	
	-- prev a*d + b*c
	-- prev r_r
	
	-- curr a_l
	
	-- addr c_h X
	-- addr c_l
                
	when STATE_A_L_PRE => -- a_l available
		
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 0 ) ); -- c_h
			
			a_next( 15 downto  0 ) <= m_readdata; -- curr read a_l
			
			state_mode_next <= STATE_C_H_PRE;
		end if;
				
	when STATE_A_L => -- a_l available
		
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 0 ) ); -- c_h
			
			a_next( 15 downto  0 ) <= m_readdata; -- curr read a_l
			
			new_i_next <= a_mul_d + b_mul_c; -- prev a*d + b*c
			acc_r_temp_next <= signed(ram_r_rd_data); -- prev r_r
			
			state_mode_next <= STATE_C_H;
		end if;
		
	when STATE_A_L_POST => -- a_l available
		
		new_i_next <= a_mul_d + b_mul_c; -- prev a*d + b*c
		acc_r_temp_next <= signed(ram_r_rd_data); -- prev r_r
				
		state_mode_next <= STATE_C_H_POST;
			
	--------------------------------------------------------
	-- 
	-- c_h
	-- 
	--------------------------------------------------------
	
	-- prev b*d
	-- prev acc_i
	
	-- curr c_h
	
	-- addr c_l X
	-- addr d_h
                
        when STATE_C_H_PRE => -- c_h available
             
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 1 ) ); -- c_l
			
			c_next( 31 downto 16 ) <= m_readdata; -- curr read c_h
			
			state_mode_next <= STATE_C_L_PRE;
		end if;
					
	when STATE_C_H => -- c_h available
             
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
		      m_read_next <= '1'; -- wir lesen immer
		      
		      m_address_next <= std_logic_vector( in_addr + ( 2 * 1 ) ); -- c_l
		      
		      c_next( 31 downto 16 ) <= m_readdata; -- curr read c_h
		      
		      
		      b_mul_d_next <= signed( b ) * signed( d ); -- prev b*d
		      acc_i_temp_next <= acc_i_temp + new_i; -- prev acc_i
		      
		      state_mode_next <= STATE_C_L;
		end if;
		
	when STATE_C_H_POST => -- c_h available
             		
		b_mul_d_next <= signed( b ) * signed( d ); -- prev b*d
		acc_i_temp_next <= acc_i_temp + new_i; -- prev acc_i
	
		state_mode_next <= STATE_C_L_POST;
			
	--------------------------------------------------------
	-- 
	-- c_l
	-- 
	--------------------------------------------------------
	
	-- prev a*c-b*d
	-- prev w_i
	
	-- curr c_l
	
	-- addr d_h X
	-- addr d_l
	
	when STATE_C_L_PRE => -- c_l available
	  
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
		
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 2 ) ); -- d_h
			
			c_next( 15 downto  0 ) <= m_readdata; -- curr read c_l
			
			state_mode_next <= STATE_D_H_PRE;
		end if;
				
	when STATE_C_L => -- c_l available
	  
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
		
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 2 ) ); -- d_h
			
			c_next( 15 downto  0 ) <= m_readdata; -- curr read c_l
							
			new_r_next <= a_mul_c - b_mul_d; -- prev a*c-b*d
			
			ram_i_wr_addr <= std_logic_vector( to_unsigned( i_prev, ram_i_wr_addr'length ));
			ram_i_wr_data <= std_logic_vector( acc_i_temp ); -- prev w_i
			ram_i_wr <= '1';
			
			state_mode_next <= STATE_D_H;
		end if;
		
	when STATE_C_L_POST => -- c_l available
	  		
		new_r_next <= a_mul_c - b_mul_d; -- prev a*c-b*d
		
		ram_i_wr_addr <= std_logic_vector( to_unsigned( i_prev, ram_i_wr_addr'length ));
		ram_i_wr_data <= std_logic_vector( acc_i_temp ); -- prev w_i
		ram_i_wr <= '1';
				
		state_mode_next <= STATE_D_H_POST;
                
	--------------------------------------------------------
	-- 
	-- d_h
	-- 
	--------------------------------------------------------
	
	-- prev acc_r
	
	-- curr d_h
	-- curr a*c
	
	-- addr d_l X
	-- addr b_h
	
	when STATE_D_H_PRE => -- d_h available
	    
		 m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		 
		if (m_readdatavalid = '1') then
		
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 3 ) ); -- d_l
			
			d_next( 31 downto 16 ) <= m_readdata; -- curr read d_h
			a_mul_c_next <= signed( a ) * signed( c ); -- curr a*c
			
			state_mode_next <= STATE_D_L_PRE;
		end if;
				
	when STATE_D_H => -- d_h available
	    
		 m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		 
		if (m_readdatavalid = '1') then
		
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( in_addr + ( 2 * 3 ) ); -- d_l
			
			d_next( 31 downto 16 ) <= m_readdata; -- curr read d_h
			a_mul_c_next <= signed( a ) * signed( c ); -- curr a*c
			
			
			acc_r_temp_next <= acc_r_temp + new_r; -- prev acc_r
		
			state_mode_next <= STATE_D_L;
		end if;
		
	when STATE_D_H_POST => -- d_h available
	    
		acc_r_temp_next <= acc_r_temp + new_r; -- prev acc_r
	
		state_mode_next <= STATE_D_L_POST;
			            
	--------------------------------------------------------
	-- 
	-- d_l
	-- 
	--------------------------------------------------------
	
	-- prev w_r
	
	-- curr d_l
	
	-- addr b_h X
	-- addr b_l
        
	when STATE_D_L_PRE => -- d_l available
		
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
		      m_read_next <= '1'; -- wir lesen immer
		      
		      m_address_next <= std_logic_vector( ir_addr + ( 2 * 2 ) ); -- b_h
		      
		      d_next( 15 downto  0 ) <= m_readdata; -- curr read d_l
		      
		      state_mode_next <= STATE_B_H_PRE;
		end if;
				
	when STATE_D_L => -- d_l available
		
		 m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
	
		if (m_readdatavalid = '1') then
		
			m_read_next <= '1'; -- wir lesen immer
			
			m_address_next <= std_logic_vector( ir_addr + ( 2 * 2 ) ); -- b_h
			
			d_next( 15 downto  0 ) <= m_readdata; -- curr read d_l
			
			ram_r_wr_addr <= std_logic_vector( to_unsigned( i_prev, ram_r_wr_addr'length ));
			ram_r_wr_data <= std_logic_vector( acc_r_temp ); -- prev w_r
			ram_r_wr <= '1';
						
			state_mode_next <= STATE_B_H;
		end if;
		
	when STATE_D_L_POST => -- d_l available
		
		ram_r_wr_addr <= std_logic_vector( to_unsigned( i_prev, ram_r_wr_addr'length ));
		ram_r_wr_data <= std_logic_vector( acc_r_temp ); -- prev w_r
		ram_r_wr <= '1';
		
		state_mode_next <= STATE_B_L;
			                
	--------------------------------------------------------
	-- 
	-- b_h
	-- 
	--------------------------------------------------------
	
	-- curr b_h
	-- curr a*d
	
	-- addr b_l X
	-- addr a_h
                
	when STATE_B_H_PRE => -- b_h available
            
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			
			b_next( 31 downto 16 ) <= m_readdata; -- curr read b_h
			a_mul_d_next <= signed( a ) * signed( d ); -- curr a*d
			
			m_address_next <= std_logic_vector( ir_addr + ( 2 * 3 ) ); -- b_l
			
			state_mode_next <= STATE_B_L;
		end if;
		
	when STATE_B_H => -- b_h available
            
		m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		
		if (m_readdatavalid = '1') then
			
			m_read_next <= '1'; -- wir lesen immer
			
			b_next( 31 downto 16 ) <= m_readdata; -- curr read b_h
			a_mul_d_next <= signed( a ) * signed( d ); -- curr a*d
				
			m_address_next <= std_logic_vector( ir_addr + ( 2 * 3 ) ); -- b_l
		
			state_mode_next <= STATE_B_L;
		end if;
	
	--------------------------------------------------------
	-- 
	-- b_l
	-- 
	--------------------------------------------------------
	
	-- curr b_l
	
	-- addr a_h X
	-- addr a_l
		
	when STATE_B_L => -- b_l available
            
		  m_read_next <= '0'; -- lesen beendet, warten auf gültige Daten
		  
		if (m_readdatavalid = '1') then
		
			b_next( 15 downto  0 ) <= m_readdata; -- curr read b_l
						
			if i = ( BLOCK_SIZE - 1 ) then
				
				-- nach 511 beginnt die post pipeline,
				-- sonst gehen wir einfach weiter
				
				-- hier wollen wir keine neuen werte mehr lesen.
				-- in diesem state wird noch b_l gelesen.
				
				i_prev_next <= i;
				i_next <= i + 1;
				
				ram_i_rd_addr <= std_logic_vector( to_unsigned( i, ram_i_rd_addr'length ));
				ram_i_rd <= '1';
		
				state_mode_next <= STATE_A_H_POST;
				
			else
				
				-- wir gehen lokal, in einem block weiter.
				
				ir_addr_next <= ir_addr + ( 2 * 4 );
				in_addr_next <= in_addr + ( 2 * 4 );
								
				state_mode_next <= STATE_B_L_CONTINUE;
				
			end if;  
			
		elsif i = BLOCK_SIZE then
			
			-- hier nehme ich den naechsten block oder beende das ganze,
			-- wenn ich beim block index = 13 bin.
			
			state_mode_next <= STATE_NEXT_BLOCK;
		end if;
		
	when STATE_B_L_CONTINUE => -- b_l continue
             
		m_read_next <= '1'; -- wir lesen immer
		
		m_address_next <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
		
		i_prev_next <= i;
		i_next <= i + 1;
		
		ram_i_rd_addr <= std_logic_vector( to_unsigned( i, ram_i_rd_addr'length ));
		ram_i_rd <= '1';
		
		state_mode_next <= STATE_A_H;
		
	--------------------------------------------------------
	-- 
	-- next block
	-- 
	--------------------------------------------------------
        
	when STATE_NEXT_BLOCK => -- b_l available
              		
		state_mode_next <= STATE_NEXT_BLOCK2;
		
		-- wenn alle ir bloecke fertig sind, wird das beendet
		
		if ir_pointer = ir_block_max then
			state_mode_next <= STATE_IDLE;
		else
			ir_pointer_next <= ir_pointer + 1;
		end if;
		
		if in_pointer = in_block_min then
			in_pointer_next <= in_block_max;
		else
			in_pointer_next <= in_pointer - 1;
		end if;
         
	when STATE_NEXT_BLOCK2 => -- continue
             		
		-- zur sicherheit wird der beginn des neuen blocks immer
		-- berechnet. fuer ir ist er eigentlich schon gesetzt.
		
		ir_addr_next <= to_unsigned( ir_pointer * BLOCK_SIZE * 4 * 2, ir_addr_next'length );
		in_addr_next <= to_unsigned( in_pointer * BLOCK_SIZE * 4 * 2, in_addr_next'length );
		
		i_prev_next <= i;
		i_next <= 0;
		
		state_mode_next <= STATE_EX_A_L;
				
	when STATE_EX_A_L => -- explizit a_l anlegen
                           
		m_read_next <= '1'; -- wir lesen immer      
	    
		m_address_next <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
		
		state_mode_next <= STATE_A_H_PRE;
					                            
        when others =>
		
		state_mode_next <= STATE_IDLE;
        
    end case;
    
    -- for simulation
    -- end if;
    
    case read_state is
        
        when STATE_IDLE =>
	  
		if s_read = '1' then
			
			read_state_next <= STATE_ADDRESS;
			
		end if;
		
	when STATE_ADDRESS =>
		
		output_addr_next <= to_integer(unsigned(s_address));
		read_state_next <= STATE_ARRAY;
	
	when STATE_ARRAY =>
		
		-- fuer 512 -> 512 - 512 = 0 -> index 0 im acc_i_array wird gelesen
		
		if output_addr = ADDRESS_STATE then
			if state_mode = STATE_IDLE then
			    output_value_next <= (others => '0');
			else
			    output_value_next <= (others => '1');
			end if;
			read_state_next <= STATE_DUMMY;
			
		elsif output_addr > (BLOCK_SIZE - 1) then
			ram_i_rd_addr <= std_logic_vector( to_unsigned( output_addr - BLOCK_SIZE, ram_i_rd_addr'length ));
			ram_i_rd <= '1';
			read_state_next <= STATE_ARRAY_I;
		else
			ram_r_rd_addr <= std_logic_vector( to_unsigned( output_addr, ram_r_rd_addr'length ));
			ram_r_rd <= '1';
			read_state_next <= STATE_ARRAY_R;
		end if;
	
	when STATE_DUMMY =>
		read_state_next <= STATE_OUTPUT;
		
	when STATE_ARRAY_I =>
		
		output_value_next <= ram_i_rd_data;
		read_state_next <= STATE_OUTPUT;
		
	when STATE_ARRAY_R =>
		
		output_value_next <= ram_r_rd_data;
		read_state_next <= STATE_OUTPUT;

	when STATE_OUTPUT =>
		s_readdata_next <= output_value(54 downto 23);
		
		read_state_next <= STATE_IDLE;
                            
        when others =>
		
		read_state_next <= STATE_IDLE;
		
	end case;
	
end process proc;

end architecture;
