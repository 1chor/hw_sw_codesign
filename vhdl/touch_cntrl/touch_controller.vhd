-- Module:      	Touch controller
-- Date:        	April 2011
-- Description: 	Entity description of the touch controller. This module 
--					is responsible for reading the ADC value of the touched 
--					points of the LCD and signaling the unit "input_manager".
--------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity touch_controller is
	generic (
		SYS_CLK : integer := 25000000;  -- the system clock applied to the unit
		ADC_CLK : integer := 50000   -- the desired adc clock 
	);
	port (
		clk	: in  std_logic;          -- global system clock
		res_n	: in  std_logic;        -- global reset
		
		-- connection to adc
		adc_din       :   out std_logic;      -- data signal: touch_controller -> adc
		adc_dclk      :   out std_logic;      -- adc clock signal
		adc_cs        :   out std_logic;      -- chip select for the adc
		adc_dout      :   in std_logic;       -- data signal: adc -> touch_contoller
		adc_penirq_n  :   in std_logic;       -- touch interrupt signal 

		-- internal connection
		point_data 	    : out std_logic_vector(23 downto 0);  -- xy coordinate pair
		screen_touched 	: out std_logic;                      -- high while touchsceen is being touched
		new_point_data	 : out std_logic                       -- signaling that new data is available

	);
end entity touch_controller;



architecture itWorks of touch_controller is
--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
-- SYS_CLK_EDGE_CNTR_LIMIT defines how many rising system clock edges have 
-- to occur in order to divide the system clock to generate the ADC clock 
-- signal.  
constant SYS_CLK_EDGE_CNTR_LIMIT :                integer := 
                                              SYS_CLK/ADC_CLK;

-- SYS_CLK_EDGE_CNTR_LIMIT_DCLK_LOW_TIME defines the number of rising system 
-- clock edges that have to occur to determine the time in which the ADC clock 
-- signal is low.
constant SYS_CLK_EDGE_CNTR_LIMIT_DCLK_LOW_TIME :  integer := ( SYS_CLK_EDGE_CNTR_LIMIT+1)/2;

-- SYS_CLK_EDGE_CNTR_LIMIT_DCLK_HIGH_TIME defines the number of rising system 
-- clock edges that have to occur to determine the time in which the ADC clock 
-- signal is high.                   
constant SYS_CLK_EDGE_CNTR_LIMIT_DCLK_HIGH_TIME : integer := 
                                              (SYS_CLK_EDGE_CNTR_LIMIT)/2;

-- The number of bits per coordinate component (x,y).
constant ADC_SINGLE_COORDINATE_LENGTH : integer := 12;

-- The number of DCLK cycle to generate when communicating with the ADC.
constant ADC_DCLK_CYCLES_PER_COORDINATE_CONVERSION : integer := 24;

-- The total number of DCLK cycle to generate when communicating with the ADC.
constant ADC_DCLK_CYCLES_TOTAL : integer := ADC_DCLK_CYCLES_PER_COORDINATE_CONVERSION;
         
-- The number of the DCLK cycle at which the output of the ADC can be read.
constant ADC_DCLK_CYCLE_NUMER_COOR_MSB_RELATIVE_PER_CONVERSION : integer:= 10;

-- The values for selecting and deselecting the ADC.           
constant ADC_CS_SELECT : std_logic := '1';
constant ADC_CS_DESELECT : std_logic := '0';

-- Internal macros.
constant ADC_REQUEST_X_DATA : std_logic := '0';
constant ADC_REQUEST_Y_DATA : std_logic := '1';

---------------------------------------------------------------
-- Control word structure:
---------------------------------------------------------------	
--	S		A2		A0		A1		MODE		SER/DFR_n 		PD1		PD0
---------------------------------------------------------------
--ADC_CONTROL_WORD_REQ_X 
---------------------------------------------------------------
--	1		0		0		1		0			0					1			1 	-> x93
---------------------------------------------------------------
--ADC_CONTROL_WORD_REQ_Y 
--	1		1		0		1		0			0					0			0	-> xD0

-- Control words when requesting the x and y coordinate from the ADC.
constant ADC_CONTROL_WORD_REQ_X : std_logic_vector(7 downto 0) := x"93";
constant ADC_CONTROL_WORD_REQ_Y : std_logic_vector(7 downto 0) := x"D0";

--------------------------------------------------------------------------------
-- Self-defined types
--------------------------------------------------------------------------------
-- Touch controller states.
type touch_controller_state is (  IDLE, DCLK_LOW_TIME, DCLK_RISING_EDGE,
                                  DCLK_HIGH_TIME, DCLK_FALLING_EDGE, 
                                  COMPLETE);

--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------

-- The state of the Touch Controller is stored here.
signal sig_tc_state : touch_controller_state;
signal sig_tc_state_next : touch_controller_state;

-- Counter of the rising edges of the system clock.
signal sig_clk_cntr : integer range 0 to SYS_CLK_EDGE_CNTR_LIMIT;
signal sig_clk_cntr_next : integer range 0 to SYS_CLK_EDGE_CNTR_LIMIT;

-- Signal used for outputting the DCLK.
signal sig_dclk : std_logic;
signal sig_dclk_next : std_logic;

-- DCLK cycle counter.
signal sig_dclk_cntr : integer range 0 to ADC_DCLK_CYCLES_PER_COORDINATE_CONVERSION;
signal sig_dclk_cntr_next : integer range 0 to ADC_DCLK_CYCLES_PER_COORDINATE_CONVERSION;

-- Signal used for outputting data to the ADC.
signal sig_adc_din : std_logic;
signal sig_adc_din_next : std_logic;

-- Counter to determine the length of the least three bits of an ADC control word.
signal sig_adc_acquisition_time_cntr : integer range 0 to (4 * SYS_CLK_EDGE_CNTR_LIMIT);
signal sig_adc_acquisition_time_cntr_next : integer range 0 to (4 * SYS_CLK_EDGE_CNTR_LIMIT);

-- The received coordinates are stored here.
signal sig_coor_buf : std_logic_vector(((ADC_SINGLE_COORDINATE_LENGTH*2)-1) downto 0);
signal sig_coor_buf_next : std_logic_vector(((ADC_SINGLE_COORDINATE_LENGTH*2)-1) downto 0);

-- Store which coordinate component to request (x or y).
signal sig_coor_select : std_logic;
signal sig_coor_select_next : std_logic;

--------------------------------------------------------------------------------
-- Architecture (begin)
--------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------
-- Next-state process
--------------------------------------------------------------------------------
proc_next_state : process(sig_tc_state, sig_clk_cntr, sig_dclk_cntr,
                          sig_coor_select, adc_penirq_n, sig_adc_acquisition_time_cntr)
begin
  
  -- Default assignments.
  sig_tc_state_next <= sig_tc_state;
  sig_clk_cntr_next <= sig_clk_cntr;
  sig_dclk_cntr_next <= sig_dclk_cntr;
  sig_coor_select_next <= sig_coor_select;
  sig_adc_acquisition_time_cntr_next <= sig_adc_acquisition_time_cntr;
  
  case sig_tc_state is 
--------------------------------------------------------------------------------
    when IDLE =>
		
		-- Change to the next state after a contact with the touchscreen.
      if adc_penirq_n = '0' then
			
			sig_tc_state_next <= DCLK_FALLING_EDGE;
			sig_dclk_cntr_next <= 1;
			sig_coor_select_next <= ADC_REQUEST_X_DATA;
			
    	end if;
--------------------------------------------------------------------------------
    when DCLK_LOW_TIME =>

	 
    	if sig_dclk_cntr < 6  or sig_dclk_cntr > 8 then      
			
			-- If the current DCLK cycle is not the one in which one of the 
			-- three least siginificant bits of the control word are sent to 
			-- the ADC, then increment the counter sig_clk_cntr.
			sig_clk_cntr_next <= sig_clk_cntr + 1;
			
		else
			
			-- If the current DCLK cycle is the one in which one of the 
			-- three least siginificant bits of the control word are sent to 
			-- the ADC, then increment the counter 
			-- sig_adc_acquisition_time_cntr.
			sig_adc_acquisition_time_cntr_next <= sig_adc_acquisition_time_cntr + 1;
		  	
		end if;
      
		if sig_clk_cntr = (SYS_CLK_EDGE_CNTR_LIMIT_DCLK_LOW_TIME - 1) or 
			sig_adc_acquisition_time_cntr = (4 * SYS_CLK_EDGE_CNTR_LIMIT) - 1 then
			
				-- Change to the next state when one of the counter reach the 
				-- given maximum value.
				sig_tc_state_next <= DCLK_RISING_EDGE;
				
		end if;
			
--------------------------------------------------------------------------------
    when DCLK_RISING_EDGE =>
      
	  -- Reset the counters and change to the next state.
      sig_clk_cntr_next <= 1;
      sig_tc_state_next <= DCLK_HIGH_TIME;
      sig_adc_acquisition_time_cntr_next <= 0;
		
--------------------------------------------------------------------------------
    when DCLK_HIGH_TIME =>
	
		if 	sig_dclk_cntr < 6 or sig_dclk_cntr > 8 then 
		
			-- If the current DCLK cycle is not the one in which one of the 
			-- three least siginificant bits of the control word are sent to 
			-- the ADC, then increment the counter sig_clk_cntr.
			sig_clk_cntr_next <= sig_clk_cntr + 1;

		else

			-- If the current DCLK cycle is the one in which one of the 
			-- three least siginificant bits of the control word are sent to 
			-- the ADC, then increment the counter 
			-- sig_adc_acquisition_time_cntr.
			sig_adc_acquisition_time_cntr_next <= sig_adc_acquisition_time_cntr + 1;
				
		end if; 
		
		-- Change to the next state when one of the counter reach the 
		-- given maximum value.
		if sig_clk_cntr = (SYS_CLK_EDGE_CNTR_LIMIT_DCLK_HIGH_TIME - 1) or 
			sig_adc_acquisition_time_cntr = (4 * SYS_CLK_EDGE_CNTR_LIMIT) - 1 then
			
			sig_tc_state_next <= DCLK_FALLING_EDGE;
			
			-- If this is the last DCLK cycle of the current coordinate 
			-- component, then either setup everything to request the next 
			-- coordinate component or change to the final state of this 
			-- state machine.
			if sig_dclk_cntr = (ADC_DCLK_CYCLES_TOTAL) then 
	
				if sig_coor_select = ADC_REQUEST_X_DATA then
					sig_coor_select_next <= ADC_REQUEST_Y_DATA;
					sig_dclk_cntr_next <= 1;
				else
					sig_tc_state_next <= COMPLETE;
				end if;
			else
				-- Increment the DCLK counter if the current DCLK cycle is 
				-- not the last one.
				sig_dclk_cntr_next <= sig_dclk_cntr + 1;
			end if;
			
		end if;
      
--------------------------------------------------------------------------------
    when DCLK_FALLING_EDGE =>
	
		-- Reset the counters and change to the next state.
		sig_clk_cntr_next <= 1;
      	sig_tc_state_next <= DCLK_LOW_TIME;
		sig_adc_acquisition_time_cntr_next <= 0;

--------------------------------------------------------------------------------
    when COMPLETE =>
	
		-- Reset the counters and change to the next state.
      	sig_tc_state_next <= IDLE;
      	sig_clk_cntr_next <= 0;
		sig_adc_acquisition_time_cntr_next <= 0;
		
--------------------------------------------------------------------------------		
  end case;
              
end process proc_next_state;


--------------------------------------------------------------------------------
-- Output process
--------------------------------------------------------------------------------
proc_output: process(	sig_tc_state, 
                      	sig_clk_cntr,
						sig_dclk,
						sig_dclk_cntr,
						sig_adc_din,
						sig_coor_select,
						adc_penirq_n)

  
begin
  
  	-- Default assignments.
	adc_cs <= ADC_CS_DESELECT; 
	screen_touched <= '0';
	new_point_data <= '0';
  
	sig_adc_din_next <= sig_adc_din;
  	sig_dclk_next <= sig_dclk;

	case sig_tc_state is
--------------------------------------------------------------------------------
		when IDLE =>
		
			-- If the PENIRQ occured, select/activate the ADC.
			if adc_penirq_n = '0' then
				adc_cs <= ADC_CS_SELECT;
				screen_touched <= '1';
			end if;
--------------------------------------------------------------------------------
		when DCLK_LOW_TIME =>
			
			adc_cs <= ADC_CS_SELECT; 
			-- Set the output screen_touched to indicate the LCD is being 
			-- touched.
			screen_touched <= '1';

--------------------------------------------------------------------------------
		when DCLK_RISING_EDGE =>
			adc_cs <= ADC_CS_SELECT; 
			screen_touched <= '1';
			-- In the next clock cycle (see process proc_sync): Set the output 
			-- adc_dclk to '1'.
			sig_dclk_next <= '1';
	
--------------------------------------------------------------------------------
		when DCLK_HIGH_TIME =>
			adc_cs <= ADC_CS_SELECT; 
			screen_touched <= '1';      
			      					
--------------------------------------------------------------------------------
		when DCLK_FALLING_EDGE =>
			adc_cs <= ADC_CS_SELECT; 
			screen_touched <= '1';	

			if (sig_dclk_cntr) > 0 and (sig_dclk_cntr) < 9 then
				
				-- Apply the ADC control word of the current coordinate 
				-- component in the next clock cycle (see process proc_sync) on 
				-- the output adc_din.
				-- This is only done in the first 8 DCLK cycles.
				if sig_coor_select = ADC_REQUEST_X_DATA then
					sig_adc_din_next <= ADC_CONTROL_WORD_REQ_X(8-(sig_dclk_cntr));
				else
					sig_adc_din_next <= ADC_CONTROL_WORD_REQ_Y(8-(sig_dclk_cntr));
				end if;
			else
				sig_adc_din_next <= '0';
			end if;

			sig_dclk_next <= '0';

	
--------------------------------------------------------------------------------
	when COMPLETE =>
	
		screen_touched <= '1';
		sig_dclk_next <= '0';

		if adc_penirq_n = '0' then

			-- If LCD was touched during the last reading of the coordinate 
			-- components then set the indicator output new_point_data to 
			-- '1' to indicate that a new coordinate is available.
			-- The indicator output new_point_data is not set if there was no 
			-- other contact of the touch screen during the reading of the 
			-- coordinate. This is done to reduce the number of wrong read 
			-- coordinates because the foil spanned over the LCD produces 
			-- contacts after the contact of the user with the LCD foil. 
			new_point_data <= '1';
			adc_cs <= ADC_CS_SELECT;
    	end if;
    
--------------------------------------------------------------------------------
	end case;
  
end process proc_output;



--------------------------------------------------------------------------------
-- Read ADC output process
--------------------------------------------------------------------------------
proc_read_adc : process(sig_tc_state,
						sig_dclk_cntr, 
						sig_coor_buf,
						adc_dout)
begin
  
  -- Default assignment.
  sig_coor_buf_next <= sig_coor_buf;

  case sig_tc_state is
--------------------------------------------------------------------------------

	when DCLK_RISING_EDGE =>
	    
		-- Read from the signal line of the ADC (input port adc_dout) and apply 
		-- the read bits in shift register style on the output port point_data 
		-- (see process proc_sync).
		if 	sig_dclk_cntr >= (ADC_DCLK_CYCLE_NUMER_COOR_MSB_RELATIVE_PER_CONVERSION) and 
	    	sig_dclk_cntr < (ADC_DCLK_CYCLE_NUMER_COOR_MSB_RELATIVE_PER_CONVERSION + ADC_SINGLE_COORDINATE_LENGTH) 
		then
	       
			sig_coor_buf_next <= sig_coor_buf(((ADC_SINGLE_COORDINATE_LENGTH*2)-1-1) downto 0) & adc_dout;

		end if;

--------------------------------------------------------------------------------    
	when others =>
--------------------------------------------------------------------------------    
  end case;
  
  
end process proc_read_adc;

--------------------------------------------------------------------------------
-- Sync process
--------------------------------------------------------------------------------
proc_sync: process(clk, res_n)
begin

	if res_n = '0' then 
    
		-- Assignment in case of a reset.
  		adc_din <= '0';
	
		sig_tc_state <= IDLE;
	    sig_clk_cntr <= 0;
	    sig_dclk_cntr <= 0;
    	sig_adc_din <= '0';
	 	sig_adc_acquisition_time_cntr <= 0;
			
	    point_data <= (others => '0');
	 	sig_coor_buf <= (others => '0');
	 	sig_coor_select <= ADC_REQUEST_Y_DATA;

    	sig_dclk <= '0';
    	adc_dclk <= '0';

	elsif rising_edge(clk) then
			
		-- Assignment in case of no reset and a rising edge of the clock 
		-- signal.
		sig_tc_state <= sig_tc_state_next;
		sig_clk_cntr <= sig_clk_cntr_next;
		sig_dclk_cntr <= sig_dclk_cntr_next;

		sig_adc_din <= sig_adc_din_next;
		adc_din <= sig_adc_din_next;
		 
		sig_adc_acquisition_time_cntr <= sig_adc_acquisition_time_cntr_next;

		sig_coor_buf <= sig_coor_buf_next;
		point_data <= sig_coor_buf_next;
		 
		sig_coor_select <= sig_coor_select_next;
		 
		sig_dclk <= sig_dclk_next;
		adc_dclk <= sig_dclk_next;

	end if;
		  
end process proc_sync;


end architecture itWorks;


