
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        s_readdatavalid : out std_logic;
        s_waitrequest   : out std_logic;
        
        -- memory mapped master
        m_address   : out  std_logic_vector(31 downto 0);
        m_write     : out  std_logic;
        m_read      : out  std_logic;
        m_writedata : out  std_logic_vector(15 downto 0);
        m_readdata  : in std_logic_vector(15 downto 0);
        m_waitrequest : in std_logic
    );
begin
    
end entity;

architecture arch of mac_sram is

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

-- block signals

signal ir_block_min : integer range 0 to 55 := IR_BLOCK_1_MIN;
signal ir_block_max : integer range 0 to 55 := IR_BLOCK_1_MAX;

signal in_block_min : integer range 0 to 55 := IN_BLOCK_1_MIN;
signal in_block_max : integer range 0 to 55 := IN_BLOCK_1_MAX;

-- array type ist um 1 zu gross.
-- das ist wegen der pipeline so.
-- TODO - das sollte nicht mehr noetig sein.

type acc_array_type is array( 512 downto 0 ) of signed( 63 downto 0 );
signal acc_r_array : acc_array_type;
signal acc_i_array : acc_array_type;

--~ type fake_output_array_type is array( 512 downto 0 ) of signed( 31 downto 0 );
--~ signal fake_output_array : fake_output_array_type;

signal fucking_reset : std_logic := '0';
signal fucking_start : std_logic := '0';

signal pre_pipeline : std_logic := '1';
signal post_pipeline : std_logic := '0';

signal a : std_logic_vector( 31 downto 0 );
signal b : std_logic_vector( 31 downto 0 );
signal c : std_logic_vector( 31 downto 0 );
signal d : std_logic_vector( 31 downto 0 );

signal a_mul_c : signed( 63 downto 0 );
signal b_mul_c : signed( 63 downto 0 );
signal b_mul_d : signed( 63 downto 0 );
signal a_mul_d : signed( 63 downto 0 );

signal new_r : signed( 63 downto 0 );
signal new_i : signed( 63 downto 0 );

type output_state_type is (
    STATE_00,
    STATE_01,
    STATE_10,
    STATE_temp,
    STATE_11
);
signal output_state : output_state_type;
--signal output_state : std_logic_vector( 2 downto 0 );

type proc_state_type is (
    MODE_00,
    MODE_01,
    MODE_10,
    MODE_11,
    MODE_0001,
    MODE_0010,
    MODE_0011,
    MODE_0100,
    MODE_0101,
    MODE_0110,
    MODE_0111,
    MODE_1000,
    MODE_1001,
    MODE_1010
);
signal proc_state : proc_state_type;

-- wir beginnen eigentlich bei 41, aber wenn das zum ersten mal
-- aufgerufen wird, dann wird das gleich erhoeht.

signal latest_in_block : integer range 0 to 55 := 40; -- TODO - kann kleiner sein

signal busy : std_logic;
--signal resetting : std_logic;

signal trigger : std_logic := '0';

signal output_addr : integer;
signal output_value : std_logic_vector( 63 downto 0 );
signal temp : signed( 63 downto 0 );

attribute keep : string;
attribute keep of trigger : signal is "true";

begin

-- default signal declarations
-- not used in design

m_write <= '0';
m_writedata <= (others => '0');

------------------------------------------------------------------------
-- memory mapped slave
------------------------------------------------------------------------

output_addr <= to_integer(unsigned(s_address));

mms : process ( clk, res_n )

--variable output_addr : integer;
--variable output_value : std_logic_vector( 63 downto 0 );

variable latest_in_block_1 : integer range 0 to 55 := 40;
variable latest_in_block_2 : integer range 0 to 55 := 54;

variable latest_in_block_tmp : integer range 0 to 55;

-- 0 - left channel
-- 1 - right channel

variable channel : std_logic;

begin
    
    if res_n = '0' then
        
        -- ich muss nur die output state setzen, da der rest eh
        -- ueberschrieben wird.
        
        output_state <= STATE_00;
        
        fucking_reset <= '0';
        fucking_start <= '0';
        
        latest_in_block_1 := 40;
        latest_in_block_2 := 54;
        
    elsif (clk'event and clk='1') then
        
        s_readdatavalid <= '0'; -- das read ist nicht valid
        s_waitrequest <= '1'; -- ich bin nicht bereit
        
        fucking_reset <= '0';
        fucking_start <= '0';
        
        if busy = '0' then
            
            ------------------------------------------------------------
            -- output
            --------------------mode----------------------------------------
            
            if output_state = STATE_00 then
                
                s_waitrequest <= '0'; -- wenn der idle state, dann bin ich bereit
                
            elsif output_state = STATE_01 then
                
                -- output_addr <= to_integer(unsigned(s_address));
                output_state <= STATE_10;
                
            elsif output_state = STATE_10 then
                
                -- fuer 512 -> 512 - 512 = 0 -> index 0 im acc_i_array wird gelesen
                
                if output_addr > ( BLOCK_SIZE - 1 ) then
                    temp <= acc_i_array( output_addr - BLOCK_SIZE );
                else
                    temp <= acc_r_array( output_addr );
                end if;
                
                output_state <= STATE_temp;
                
            elsif output_state = STATE_temp then
		
		output_value <= std_logic_vector( temp );
		output_state <= STATE_11;
		
            elsif output_state = STATE_11 then
                
                s_readdatavalid <= '1'; -- jetzt ist das read valid
                s_readdata <= output_value( 54 downto 23 );
                
                output_state <= STATE_00;
                
            end if;
            
            ------------------------------------------------------------
            -- write
            ------------------------------------------------------------
            
            -- jedes mal wenn der mac aktiviert wird wurde ein neuer block
            -- von dem input abgespeichert. daher weiss ich hier, dass sich
            -- der i_pointer wie er in c heisst erhoeht haben muss.
            
            if s_write = '1' then
                
                -- reset
                
                if ( s_writedata( 1 downto 0 ) = "01" ) and ( s_address( 1 downto 0 ) = "10" ) then
                    
                    fucking_reset <= '1';
                    
                    output_state <= STATE_00;
                    
                    -- output_addr  <= 0;
                    -- output_value <= (others=>'0');
                    
                    latest_in_block_1 := ( IN_BLOCK_1_MAX - 1 );
                    latest_in_block_2 := ( IN_BLOCK_2_MAX - 1 );
                
                -- start
                
                elsif ( s_writedata( 1 downto 0 ) = "10" ) and ( s_address( 1 downto 0 ) = "01" ) then
                    
                    fucking_start <= '1';
                    
                    if channel = '0' then latest_in_block_tmp := latest_in_block_1;
                    else                  latest_in_block_tmp := latest_in_block_2;
                    end if;
                    
                    if latest_in_block_tmp = in_block_max then
                        latest_in_block_tmp := in_block_min;
                    else
                        latest_in_block_tmp := latest_in_block_tmp + 1;
                    end if;
                    
                    latest_in_block <= latest_in_block_tmp;
                    
                    if channel = '0' then latest_in_block_1 := latest_in_block_tmp;
                    else                  latest_in_block_2 := latest_in_block_tmp;
                    end if;
                
                -- set left channel
                
                elsif ( s_writedata( 1 downto 0 ) = "01" ) and ( s_address( 1 downto 0 ) = "11" ) then
                    
                    ir_block_min <= IR_BLOCK_1_MIN;
                    ir_block_max <= IR_BLOCK_1_MAX;
                    
                    in_block_min <= IN_BLOCK_1_MIN;
                    in_block_max <= IN_BLOCK_1_MAX;
                    
                    channel := '0';
                
                -- set right channel
                
                elsif ( s_writedata( 1 downto 0 ) = "10" ) and ( s_address( 1 downto 0 ) = "11" ) then
                    
                    ir_block_min <= IR_BLOCK_2_MIN;
                    ir_block_max <= IR_BLOCK_2_MAX;
                    
                    in_block_min <= IN_BLOCK_2_MIN;
                    in_block_max <= IN_BLOCK_2_MAX;
                    
                    channel := '1';
                    
                end if;
                
            elsif s_read = '1' then
                
                if output_state = STATE_00 then
                    output_state <= STATE_01;
                end if;
                
            end if;
        end if;
    end if;
    
end process;

------------------------------------------------------------------------
-- proc
------------------------------------------------------------------------

-- ich kann m_readdata im signal tap nicht finden.

proc : process ( clk, res_n )

variable i : integer range 0 to BLOCK_SIZE;
variable i_prev : integer range 0 to BLOCK_SIZE;

variable ibi : integer range 0 to 55; -- TODO - kann kleiner sein.

variable ir_pointer : integer range 0 to 55; -- TODO - kann kleiner sein.
variable in_pointer : integer range 0 to 55;

variable acc_r_temp : signed( 63 downto 0 );
variable acc_i_temp : signed( 63 downto 0 );

variable ir_addr : unsigned( 31 downto 0 );
variable in_addr : unsigned( 31 downto 0 );

--variable mode : std_logic_vector( 1 downto 0 );
--variable state : std_logic_vector( 3 downto 0 );

--variable skip : std_logic;

variable ram_readout : signed( 63 downto 0 );
variable result_test : std_logic_vector( 31 downto 0 );

begin
    
    if res_n = '0' then
        
        proc_state <= MODE_00;
        a <= (others=>'0');
        m_read <= '0';
        
    elsif (clk'event and clk='1') then
        
        -- die signale die vom slave interface kommen sollten hier gespeichert werden.
        -- TODO warum?
        
        busy <= '1';
        --resetting <= '0';
        
        case proc_state is
		
	    when MODE_00 => -- idle
		if fucking_reset = '1' then
		    
		    i := 0;
		    proc_state <= MODE_10;
		    
		elsif fucking_start = '1' then
		    
		    i := 0;
		    proc_state <= MODE_01;
		    
		else
		    
		    busy <= '0';
		    proc_state <= MODE_00;
		    
		end if;
            
            when MODE_01 => -- starting
        	acc_r_array( i ) <= (others => '0');
		acc_i_array( i ) <= (others => '0');
		
		if i = ( BLOCK_SIZE - 1 ) then
		    proc_state <= MODE_11;
		else
		    i := i + 1;
		end if;
            
            when MODE_10 => -- resetting
		acc_r_array( i ) <= (others => '0');
		acc_i_array( i ) <= (others => '0');
		
		if i = ( BLOCK_SIZE - 1 ) then
		    proc_state <= MODE_00;
		else
		    i := i + 1;
		end if;
            
	    when MODE_11 => -- running
            
		-- wenn ich nichts lesen kann bringt mir das ganze eh nichts
		
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
		    
		    -- die ersten beiden states werden nur beim start des macs ausgefuehrt.
                
		    -- if state = "0000" then
                    
                    -- wenn ich hier bin mach ich ganz neue bloecke.
                    -- also eine ganz neue fft berechnung.
                    
                    pre_pipeline  <= '1';
                    post_pipeline <= '0';
                    
                    i             := 0;
                    i_prev        := 0;
                    
                    in_pointer    := latest_in_block;
                    ir_pointer    := ir_block_min;
                    
                    --~ ir_addr := x"00000000";
                    ir_addr := to_unsigned( ir_pointer * BLOCK_SIZE * 4 * 2, in_addr'length );
                    in_addr := to_unsigned( in_pointer * BLOCK_SIZE * 4 * 2, in_addr'length ); --~ in_addr := x"00029000";
                    
                    --~ m_address <= x"00000000"; -- a_h
                    -- TODO - hier koennte ich eingetlich 0 schreiben.
                    m_address <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
                                        
                    proc_state <= MODE_0001;
                    
                end if;
                
                --------------------------------------------------------
                -- 
                -- a_h
                -- 
                --------------------------------------------------------
                
                -- prev b*c
                -- prev r_i
                
                -- curr a_h
                
                -- addr c_h
                
            when MODE_0001 => -- a_h available 
                
                if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"00000008"; -- c_h
                        --~ m_address <= std_logic_vector( in_addr + ( 2 * 0 ) ); -- c_h
                        m_address <= std_logic_vector( ir_addr + ( 2 * 1 ) ); -- a_l
                        
                        a( 31 downto 16 ) <= m_readdata; -- a_h
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        b_mul_c <= signed( b ) * signed( c ); -- prev b*c
                        acc_i_temp := acc_i_array( i_prev ); -- prev r_i
                        
                    end if;
                    
                    proc_state <= MODE_0010;
                    
		end if;
                                   
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
                
	    when MODE_0010 => -- a_l available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"0000000a"; -- c_l
                        --~ m_address <= std_logic_vector( in_addr + ( 2 * 1 ) ); -- c_l
                        m_address <= std_logic_vector( in_addr + ( 2 * 0 ) ); -- c_h
                        
                        a( 15 downto  0 ) <= m_readdata; -- curr read a_l
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        new_i <= a_mul_d + b_mul_c; -- prev a*d + b*c
                        acc_r_temp := acc_r_array( i_prev ); -- prev r_r
                        
                    end if;
                    
                    proc_state <= MODE_0011;
                    
		end if;
                
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
                
	    when MODE_0011 => -- c_h available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                   
                    -- c_h ist das von dem in wert
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"0000000c"; -- d_h
                        --~ m_address <= std_logic_vector( in_addr + ( 2 * 2 ) ); -- d_h
                        m_address <= std_logic_vector( in_addr + ( 2 * 1 ) ); -- c_l
                        
                        c( 31 downto 16 ) <= m_readdata; -- curr read c_h
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        b_mul_d <= signed( b ) * signed( d ); -- prev b*d
                        acc_i_temp := acc_i_temp + new_i; -- prev acc_i
                        
                    end if;
                    
                    proc_state <= MODE_0100;
                    
		end if;
                
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
                
	    when MODE_0100 => -- c_l available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"0000000e"; -- d_l
                        --~ m_address <= std_logic_vector( in_addr + ( 2 * 3 ) ); -- d_l
                        m_address <= std_logic_vector( in_addr + ( 2 * 2 ) ); -- d_h
                        
                        c( 15 downto  0 ) <= m_readdata; -- curr read c_l
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        new_r <= a_mul_c - b_mul_d; -- prev a*c-b*d
                        acc_i_array( i_prev ) <= acc_i_temp; -- prev w_i
                        
                    end if;
                    
                    proc_state <= MODE_0101;
                    
		end if;
                
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
                
	    when MODE_0101 => -- d_h available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"00000004"; -- b_h
                        --~ m_address <= std_logic_vector( ir_addr + ( 2 * 2 ) ); -- b_h
                        m_address <= std_logic_vector( in_addr + ( 2 * 3 ) ); -- d_l
                        
                        d( 31 downto 16 ) <= m_readdata; -- curr read d_h
                        a_mul_c <= signed( a ) * signed( c ); -- curr a*c
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        acc_r_temp := acc_r_temp + new_r; -- prev acc_r
                        
                    end if;
                    
                    proc_state <= MODE_0110;
                    
		end if;
                
                --------------------------------------------------------
                -- 
                -- d_l
                -- 
                --------------------------------------------------------
                
                -- prev w_r
                
                -- curr d_l
                
                -- addr b_h X
                -- addr b_l
                
	    when MODE_0110 => -- b_l available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= x"00000006"; -- b_l
                        --~ m_address <= std_logic_vector( ir_addr + ( 2 * 3 ) ); -- b_l
                        m_address <= std_logic_vector( ir_addr + ( 2 * 2 ) ); -- b_h
                        
                        d( 15 downto  0 ) <= m_readdata; -- curr read d_l
                        
                    end if;
                    
                    if pre_pipeline = '0' then
                        
                        acc_r_array( i_prev ) <= acc_r_temp; -- prev w_r
                        --~ fake_output_array( i_prev ) <= acc_r_temp( 54 downto 23 );
                        
                    end if;
                    
                    proc_state <= MODE_0111;
                    
		end if;
                
                --------------------------------------------------------
                -- 
                -- b_h
                -- 
                --------------------------------------------------------
                
                -- curr b_h
                -- curr a*d
                
                -- addr b_l X
                -- addr a_h
                
	    when MODE_0111 => -- d_h available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    -- auch wenn ich in der post pipeline stage bin moechte ich,
                    -- dass hier a_h anliegt.
                    
                    -- DERWEIL WIEDER RAUS GENOMMEN.
                    
                    --~ m_address <= std_logic_vector( ir_addr + ( 2 * 4 ) ); -- a_h
                    
                    if post_pipeline = '0' then
                        
                        --~ m_address <= std_logic_vector( ir_addr + ( 2 * 4 ) ); -- a_h
                        m_address <= std_logic_vector( ir_addr + ( 2 * 3 ) ); -- b_l
                        
                    end if;
                    
                    if post_pipeline = '0' then
                        
                        b( 31 downto 16 ) <= m_readdata; -- curr read b_h
                        a_mul_d <= signed( a ) * signed( d ); -- curr a*d
                        
                    end if;
                    
                    proc_state <= MODE_1000;
                    
		end if;
                
                --------------------------------------------------------
                -- 
                -- b_l
                -- 
                --------------------------------------------------------
                
                -- curr b_l
                
                -- addr a_h X
                -- addr a_l
                
	    when MODE_1000 => -- d_l available
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    -- ich gehe hier beim ersten mal rein und wenn ich
                    -- den state ein zweites mal aufrufe, dann bin ich
                    -- im else zweig und nehme den nächsten state.
                    
                    -- pre pipeline wird sofort ausgeschaltet
                    
                    if pre_pipeline = '1' then
                        pre_pipeline <= '0';
                    end if;
                    
                    if post_pipeline = '0' then
                        b( 15 downto  0 ) <= m_readdata; -- curr read b_l
                    end if;
                    
                    if i = ( BLOCK_SIZE - 1 ) then
                        
                        -- nach 511 beginnt die post pipeline,
                        -- sonst gehen wir einfach weiter
                        
                        -- hier wollen wir keine neuen werte mehr lesen.
                        -- in diesem state wird noch b_l gelesen.
                        
                        post_pipeline <= '1';
                        
                        i_prev := i;
                        i := i + 1;
                        
                        proc_state <= MODE_0001;
                        
                    elsif i = BLOCK_SIZE then
                        
                        -- hier nehme ich den naechsten block oder beende das ganze,
                        -- wenn ich beim block index = 13 bin.
                        
                        proc_state <= MODE_1001;
                        
                    else
                        
                        -- wir gehen lokal, in einem block weiter.
                        
                        ir_addr := ir_addr + ( 2 * 4 );
                        in_addr := in_addr + ( 2 * 4 );
                        
                        --~ m_address <= std_logic_vector( ir_addr + ( 2 * 1 ) ); -- a_l
                        m_address <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
                        
                        -- i_prev ist noetig damit sich das timing ausgeht.
                        
                        i_prev := i;
                        i := i + 1;
                        
                        proc_state <= MODE_0001;
                        
                    end if;
		end if;
                
                --------------------------------------------------------
                -- 
                -- next block
                -- 
                --------------------------------------------------------
                
	    when MODE_1001 =>
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    -- reset pipeline stuff
                    
                    pre_pipeline <= '1';
                    post_pipeline <= '0';
                    
                    -- wenn alle ir bloecke fertig sind, wird das beendet
                    
                    if ir_pointer = ir_block_max then
                        proc_state <= MODE_00;
                    else
                        ir_pointer := ir_pointer + 1;
                    end if;
                    
                    if in_pointer = in_block_min then
                        in_pointer := in_block_max;
                    else
                        in_pointer := in_pointer - 1;
                    end if;
                    
                    -- zur sicherheit wird der beginn des neuen blocks immer
                    -- berechnet. fuer ir ist er eigentlich schon gesetzt.
                    
                    ir_addr := to_unsigned( ir_pointer * BLOCK_SIZE * 4 * 2, ir_addr'length );
                    in_addr := to_unsigned( in_pointer * BLOCK_SIZE * 4 * 2, in_addr'length );
                    
                    i_prev := i;
                    i := 0;
                    
                    -- explizit a_h anlegen
                    
                    m_address <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
                    
                    proc_state <= MODE_1010;
                    
		end if;
                    
	    when MODE_1010 =>
	    
		if m_waitrequest = '0' then
                
		    m_read <= '1'; -- wir lesen immer
                    
                    -- explizit a_l anlegen
                    
                    --~ m_address <= std_logic_vector( ir_addr + ( 2 * 1 ) ); -- a_l
                    m_address <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a_h
                    
                    proc_state <= MODE_0001;
                    
		end if;
		
	    when others =>
		proc_state <= MODE_00;
		
	end case;
        
    end if;
    
end process;

end architecture;
