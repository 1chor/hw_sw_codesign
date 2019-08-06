
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity mac_sdram_control_interface is
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
        m_writedata : out  std_logic_vector(31 downto 0);
        m_writeresponsevalid : in std_logic;
        m_response  : in std_logic_vector( 1 downto 0 );
        m_readdata  : in std_logic_vector(31 downto 0);
        m_readdatavalid : in std_logic;
        m_waitrequest : in std_logic
    );
begin

end entity;

architecture arch of mac_sdram_control_interface is

type read_fsm_t is (

IDLE
,READ_GET_DATA
,READ_OUTPUT_DATA

);

type fsm_t is (

IDLE
,RESET

-- channels

,SET_LEFT_CHANNEL
,SET_RIGHT_CHANNEL

-- mac

,MAC_SELECT_LATEST_IN_BLOCK
,MAC_INIT
,MAC_A_ADDR
,MAC_A
,MAC_B
,MAC_C
,MAC_D
,MAC_NEXT_BLOCK

-- chunks

,CHUNK_WRITE_INIT
,CHUNK_WRITE_1
,CHUNK_WRITE_1_WAIT
,CHUNK_WRITE_2
,CHUNK_WRITE_2_WAIT
,CHUNK_NEXT
,CHUNK_GET_INIT
,CHUNK_GET
,CHUNK_GET_SET_ADDR
,CHUNK_GET_GET_DATA
,CHUNK_DONE

);

type execution_mode_t is (
    MAC
    ,CHUNK_BLOCK_INC
);

function mapping (x : fsm_t) return std_logic_vector is
begin
    case x is 
        when IDLE => return x"00000001";
        when RESET => return x"00000002";
        when SET_LEFT_CHANNEL => return x"00000003";
        when SET_RIGHT_CHANNEL => return x"00000004";
        when MAC_SELECT_LATEST_IN_BLOCK => return x"00000005";
        when MAC_INIT => return x"00000006";
        when MAC_A_ADDR => return x"00000007";
        when MAC_A => return x"00000008";
        when MAC_B => return x"00000009";
        when MAC_C => return x"0000000A";
        when MAC_D => return x"0000000B";
        when MAC_NEXT_BLOCK => return x"0000000C";
        when CHUNK_WRITE_INIT => return x"0000000D";
        when CHUNK_WRITE_1 => return x"0000000E";
        when CHUNK_WRITE_1_WAIT => return x"0000000F";
        when CHUNK_WRITE_2 => return x"00000010";
        when CHUNK_WRITE_2_WAIT => return x"00000011";
        when CHUNK_NEXT => return x"00000012";
        when CHUNK_GET_INIT => return x"00000013";
        when CHUNK_GET => return x"00000014";
        when CHUNK_GET_SET_ADDR => return x"00000015";
        when CHUNK_GET_GET_DATA => return x"00000016";
        when CHUNK_DONE => return x"00000017";
        when others => return x"000000FF";
    end case;
end function;

constant BYTE_ADDRESSED : integer := 4;

-- BLOCKS

-- 0 - 13 header left
-- 14 - 27 header right
-- 28 - 41 input left
-- 42 - 55 input right

--  0 - 22 body left
-- 23 - 45 body right
-- 46 - 68 input left
-- 69 - 91 input right

constant BLOCK_NUM : integer := 23; -- blocks fuer z.b. ir left.
constant BLOCK_NUM_TOTAL : integer := BLOCK_NUM * 4; -- alle blocks

-- header left

constant IR_BLOCK_1_MIN : integer := 0;
constant IR_BLOCK_1_MAX : integer := 22;

-- header right

constant IR_BLOCK_2_MIN : integer := 23;
constant IR_BLOCK_2_MAX : integer := 45;

-- input left

constant IN_BLOCK_1_MIN : integer := 46;
constant IN_BLOCK_1_MAX : integer := 68;

-- input right

constant IN_BLOCK_2_MIN : integer := 69;
constant IN_BLOCK_2_MAX : integer := 91;

-- blocks

constant BLOCK_MAX : integer := IN_BLOCK_2_MAX;

-- block size

constant BLOCK_SIZE : integer := 8192;

-- chunk

constant CHUNK_SIZE : integer := 64;
constant CHUNK_OFFSET : integer := 2 * BYTE_ADDRESSED * BLOCK_NUM_TOTAL * BLOCK_SIZE;

-- block signals

-- die signale sind alle ums 1 groesser, da beim schreiben des letzten
-- chunks die pointer einen weiteren wert annehmen.
-- in der simulation scheint das kein problem zu sein, aber auf der hw
-- moechte ich auf der sicheren seite sein.

signal ir_block_min : integer range 0 to BLOCK_MAX+1 := IR_BLOCK_1_MIN;
signal ir_block_max : integer range 0 to BLOCK_MAX+1 := IR_BLOCK_1_MAX;

signal in_block_min : integer range 0 to BLOCK_MAX+1 := IN_BLOCK_1_MIN;
signal in_block_max : integer range 0 to BLOCK_MAX+1 := IN_BLOCK_1_MAX;

-- array type ist um 1 zu gross.
-- das ist wegen der pipeline so.
-- TODO - das sollte nicht mehr noetig sein.

--~ type acc_array_type is array( CHUNK_SIZE-1 downto 0 ) of signed( 31 downto 0 );
type acc_array_t is array( CHUNK_SIZE downto 0 ) of signed( 31 downto 0 );
signal acc_r_array : acc_array_t;
signal acc_i_array : acc_array_t;
signal fake_output_array : acc_array_t;

--~ type fake_output_array_type is array( 8193 downto 0 ) of signed( 31 downto 0 );
--~ signal fake_output_array : fake_output_array_type;

signal base_addr : integer := 0;

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

-- wir beginnen eigentlich bei 41, aber wenn das zum ersten mal
-- aufgerufen wird, dann wird das gleich erhoeht.

signal latest_in_block : integer range 0 to BLOCK_MAX := IN_BLOCK_1_MAX-1; -- TODO - kann kleiner sein

signal state : fsm_t;
-- signal state : fsm_t;

begin

------------------------------------------------------------------------
-- proc
------------------------------------------------------------------------

-- ich kann m_readdata im signal tap nicht finden.

proc : process ( clk, res_n )

-- read

variable output_index : integer;
--~ variable output_value : std_logic_vector( 63 downto 0 );
variable output_value : std_logic_vector( 31 downto 0 );



variable latest_in_block_1 : integer range 0 to BLOCK_MAX := IN_BLOCK_1_MAX-1;
variable latest_in_block_2 : integer range 0 to BLOCK_MAX := IN_BLOCK_2_MAX-1;

variable latest_in_block_tmp : integer range 0 to BLOCK_MAX;

variable channel : std_logic; -- 0 - left channel; 1 - right channel



variable i : integer range 0 to BLOCK_SIZE;
variable i_prev : integer range 0 to BLOCK_SIZE;

variable i_chunk : integer := 0;
variable i_chunk_prev : integer := 0;

variable i_block : integer := 0;

-- beide muessen gesetzt werden bevor sie abgefragt werden.

variable go_on : std_logic;
variable new_addr : std_logic;

-- pointer

variable ir_pointer : integer range 0 to BLOCK_MAX; -- TODO - kann kleiner sein.
variable in_pointer : integer range 0 to BLOCK_MAX;

variable chunk_pointer : integer;

-- temp for storing mul

variable acc_r_temp : signed( 63 downto 0 );
variable acc_i_temp : signed( 63 downto 0 );

-- addresses

variable ir_addr : unsigned( 31 downto 0 );
variable in_addr : unsigned( 31 downto 0 );

variable chunk_addr : unsigned( 31 downto 0 );
--~ variable chunk_cnt : integer range 0 to CHUNK_SIZE-1;
variable chunk_cnt : integer;
variable curr_chunk_r : std_logic;

-- state

variable read_state : read_fsm_t;
-- variable state : fsm_t;

variable execution_mode : execution_mode_t;

variable ram_readout : signed( 63 downto 0 );
variable result_test : std_logic_vector( 31 downto 0 );

-- block chunk inc test

variable chunk_inc_r_temp : signed( 31 downto 0 );
variable chunk_inc_i_temp : signed( 31 downto 0 );

-- skip

variable use_skip : std_logic := '0';
variable skip : std_logic;

variable base : integer;

variable debug_s_write    : std_logic;

variable debug_state_is_idle : std_logic;
variable debug_s_write_im_if : std_logic;

variable goto_idle_after_write : std_logic;

begin
    if res_n = '0' then
        
        state <= RESET;
        
        a <= (others=>'0');
        m_read <= '0';
        
        skip := '1';
        
        output_index := 0;
        output_value := (others=>'0');
        
        i := 0;
        
        chunk_pointer := 0;
        
    elsif (clk'event and clk='1') then
        
        if m_waitrequest = '0' then
            m_write <= '0';
            m_read <= '0';
        end if;
        
        -- skip
        
        if use_skip = '1' and skip = '1' then skip := '0';
        else skip := '1';
        
        -- default
        
        s_waitrequest <= '1';
        
        s_readdatavalid <= '0';
        
        --------------------------------------------------------
        -- 
        -- READ STATE
        -- 
        --------------------------------------------------------
        
        if read_state = IDLE then
            
            if s_read = '1' then
                
                read_state := READ_GET_DATA;
                output_index := to_integer(unsigned(s_address));
                
            end if;
            
        
        -- READ_GET_DATA
        ----------------
        
        elsif read_state = READ_GET_DATA then
            
            output_value := (others=>'1');
            
--             if    output_index <  64 then output_value := std_logic_vector( acc_r_array( output_index )                   ); --   0 -  63 -> acc_r_array
--             elsif output_index < 128 then output_value := std_logic_vector( acc_i_array( output_index-64 )                ); --  64 - 127 -> acc_i_array
            elsif output_index < 129 then output_value := std_logic_vector( to_unsigned( base_addr, output_value'length ) ); -- 128       -> base_addr
--             elsif output_index < 130 then output_value := std_logic_vector( to_unsigned( fsm_t'POS(state), output_value'length ) );
            elsif output_index < 130 then output_value := mapping(state);
            end if;
            
            read_state := READ_OUTPUT_DATA;
            
        
        -- READ_OUTPUT_DATA
        -------------------
        
        elsif read_state = READ_OUTPUT_DATA then
            
            s_readdatavalid <= '1'; -- jetzt ist das read valid
            s_readdata <= output_value;
            
            read_state := IDLE;
            
        end if;
        
        --------------------------------------------------------
        -- 
        -- IDLE
        -- 
        --------------------------------------------------------
        
        -- debug_s_write    := s_write;
        
        -- debug_state_is_idle := '0';
        -- debug_s_write_im_if := '0';
        
        if state = IDLE then
            
            -- debug_state_is_idle := '1';
            
            s_waitrequest <= '0'; -- bereit etwas zu empfangen
            
            if s_write = '1' then -- hier komme ich nicht hinein
                
                -- debug_s_write_im_if := '1';
                
                i := 0;
                
                if    ( to_integer(unsigned(s_address( 4 downto 0 ))) =  1 ) then state <=RESET;
                
                -- channels
                
                elsif ( to_integer(unsigned(s_address( 4 downto 0 ))) =  3 ) then state <=SET_LEFT_CHANNEL;
                elsif ( to_integer(unsigned(s_address( 4 downto 0 ))) =  5 ) then state <=SET_RIGHT_CHANNEL;
                
                -- mac
                
                elsif ( to_integer(unsigned(s_address( 4 downto 0 ))) =  7 ) then state <=MAC_SELECT_LATEST_IN_BLOCK;
                
                -- base_addr
                
                elsif ( to_integer(unsigned(s_address( 7 downto 0 ))) = 13 ) then base_addr <= to_integer(unsigned(s_writedata));
                
                end if;
                
            end if;
        
        --------------------------------------------------------
        -- 
        -- RESET
        -- 
        --------------------------------------------------------
        
        elsif state = RESET then
            
            acc_r_array( i ) <= (others => '0');
            acc_i_array( i ) <= (others => '0');
            
            if i = ( CHUNK_SIZE - 1 ) then
                
                i := 0;
                
                latest_in_block_1 := ( IN_BLOCK_1_MAX - 1 );
                latest_in_block_2 := ( IN_BLOCK_2_MAX - 1 );
                
                state <=IDLE;
                
            else
                i := i + 1;
            end if;
        
        ------------------------------------------------------------
        -- 
        -- CHANNEL
        -- 
        ------------------------------------------------------------
        
        -- SET_LEFT_CHANNEL
        -------------------
        
        elsif state = SET_LEFT_CHANNEL then
            
            ir_block_min <= IR_BLOCK_1_MIN; ir_block_max <= IR_BLOCK_1_MAX;
            in_block_min <= IN_BLOCK_1_MIN; in_block_max <= IN_BLOCK_1_MAX;
            
            channel := '0';
            
            state <=IDLE;
        
        -- SET_RIGHT_CHANNEL
        -------------------
        
        elsif state = SET_RIGHT_CHANNEL then
            
            ir_block_min <= IR_BLOCK_2_MIN; ir_block_max <= IR_BLOCK_2_MAX;
            in_block_min <= IN_BLOCK_2_MIN; in_block_max <= IN_BLOCK_2_MAX;
            
            channel := '1';
            
            state <=IDLE;
        
        --------------------------------------------------------
        -- 
        -- MAC
        -- 
        --------------------------------------------------------
        
        -- MAC_SELECT_LATEST_IN_BLOCK
        -----------------------------
        
        elsif state = MAC_SELECT_LATEST_IN_BLOCK then
            
            -- define the next block
            
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
            
            state <=MAC_INIT;
            
        
        -- MAC_INIT
        -----------
        
        elsif state = MAC_INIT then
            
            -- wenn ich hier bin mach ich ganz neue bloecke.
            -- also eine ganz neue fft berechnung.
            
            pre_pipeline  <= '1';
            post_pipeline <= '0';
            
            i             := 0;
            i_prev        := 0;
            
            i_chunk       := 0;
            i_chunk_prev  := 0;
            
            i_block       := 0;
            
            in_pointer    := latest_in_block;
            ir_pointer    := ir_block_min;
            
            chunk_pointer := 0;
            
            ir_addr := to_unsigned( base_addr + ( ir_pointer * BLOCK_SIZE * 4 * 2 ), ir_addr'length ); -- frueher hatte ich hier 4 * 2
            in_addr := to_unsigned( base_addr + ( in_pointer * BLOCK_SIZE * 4 * 2 ), in_addr'length ); --~ in_addr := x"00029000";
            
            execution_mode := MAC;
            
            -- eigentlich muss ich mir hier keinen chunk holen.
            -- wir beginnen hier ja wieder von vorne.
            -- wir muessen hier eigentlich den mac acc auf 0 setzen.
            
            state <=CHUNK_GET_INIT;
        
        -- MAC_A_ADDR
        --------------------------------------------------------
        
        elsif state = MAC_A_ADDR then
            
            -- wenn wir schon in der post_pipeline sind, dann lesen wir nichts mehr
            
            if post_pipeline = '0' then
                m_read <= '1';
                m_address <= std_logic_vector( ir_addr + ( 2 * 0 ) ); -- a
            end if;
            
            state <=MAC_A;
        
        -- a - available
        --------------------------------------------------------
        
        -- prev b*c
        -- prev b*d
        -- prev r_i
        
        -- curr a
        
        -- addr c
        
        elsif state = MAC_A then
            
            -- wenn wir in der post_pipeline sind, dann lesen wir nichts mehr
            -- und muessen daher nicht auf das m_readdatavalid achten.
            
            if ( ( m_readdatavalid = '1' ) or ( post_pipeline = '1' ) ) then
                
                if post_pipeline = '0' then
                    
                    m_read <= '1';
                    m_address <= std_logic_vector( in_addr + ( 4 * 0 ) ); -- addr c
                    a <= m_readdata; -- curr a
                    
                end if;
                
                if pre_pipeline = '0' then
                    
                    b_mul_c <= signed( b ) * signed( c ); -- prev b*c
                    b_mul_d <= signed( b ) * signed( d ); -- prev b*d
                    
                    -- FUCK
                    
--                     acc_i_temp( 63 downto 55 ) := (others=>'0');
--                     acc_i_temp( 54 downto 23 ) := acc_i_array( i_chunk_prev ); -- prev r_r
--                     acc_i_temp( 22 downto  0 ) := (others=>'0');
                    
                    acc_i_temp( 31 downto 0 ) := acc_i_array( i_chunk_prev );
                    
                end if;
                
                state <=MAC_C;
                
            end if;
            
        
        -- c - available
        --------------------------------------------------------
        
        -- prev a*c - b*d
        -- prev a*d + b*c
        -- prev r_r
        
        -- curr c
        
        -- addr d
        
        elsif state = MAC_C then
            
            if ( ( m_readdatavalid = '1' ) or ( post_pipeline = '1' ) ) then
                
                if post_pipeline = '0' then
                    
                    m_read <= '1';
                    m_address <= std_logic_vector( in_addr + ( 4 * 1 ) ); -- addr d
                    c <= m_readdata; -- curr c
                    
                end if;
                
                if pre_pipeline = '0' then
                    
                    new_r <= a_mul_c - b_mul_d; -- prev a*c - b*d
                    new_i <= a_mul_d + b_mul_c; -- prev a*d + b*c
                    
                    -- FUCK
                    
--                     acc_r_temp( 63 downto 55 ) := (others=>'0');
--                     acc_r_temp( 54 downto 23 ) := acc_r_array( i_chunk_prev ); -- prev r_r
--                     acc_r_temp( 22 downto  0 ) := (others=>'0');
                    
                    acc_r_temp( 31 downto 0 ) := acc_r_array( i_chunk_prev );
                    
                end if;
                
                state <=MAC_D;
                
            end if;
        
        -- d - available
        --------------------------------------------------------
        
        -- prev acc_i
        -- prev acc_r
        
        -- curr d
        -- curr a*c
        
        -- addr b
        
        elsif state = MAC_D then
            
            if ( ( m_readdatavalid = '1' ) or ( post_pipeline = '1' ) ) then
                
                if post_pipeline = '0' then
                    
                    m_read <= '1';
                    m_address <= std_logic_vector( ir_addr + ( 4 * 1 ) ); -- addr b
                    d <= m_readdata; -- curr d
                    a_mul_c <= signed( a ) * signed( c ); -- curr a*c
                    
                end if;
                
                if pre_pipeline = '0' then
                    
                    acc_i_temp := acc_i_temp + new_i; -- prev acc_i
                    acc_r_temp := acc_r_temp + new_r; -- prev acc_r
                    
                end if;
                
                state <=MAC_B;
                
            end if;
        
        -- b - available
        --------------------------------------------------------
        
        -- prev w_i
        -- prev w_r
        
        -- curr b
        -- curr a*d
        
        -- addr a
        
        elsif state = MAC_B then
            
            if ( ( m_readdatavalid = '1' ) or ( post_pipeline = '1' ) ) then
                
                if pre_pipeline = '1' then
                    pre_pipeline <= '0';
                end if;
                
                if post_pipeline = '0' then
                    
    --                 m_address <= std_logic_vector( ir_addr + ( 4 * 2 ) ); -- addr a
                    b <= m_readdata; -- curr b
                    a_mul_d <= signed( a ) * signed( d ); -- curr a*d
                    
                end if;
                
                if pre_pipeline = '0' then
                    
                    -- FUCK
                    
--                     acc_i_array( i_chunk_prev ) <= acc_i_temp( 54 downto 23 ); -- prev w_i
--                     acc_r_array( i_chunk_prev ) <= acc_r_temp( 54 downto 23 ); -- prev w_r

                    acc_i_array( i_chunk_prev ) <= acc_i_temp( 31 downto 0 ); -- prev w_i
                    acc_r_array( i_chunk_prev ) <= acc_r_temp( 31 downto 0 ); -- prev w_r
                    
                    fake_output_array( i_chunk_prev ) <= acc_r_temp( 54 downto 23 );
                    
                end if;
                
                -- hier gibt es 3 optionen.
                -- 1. ende der pipeline. letzter durchlauf wird begonnen.
                -- 2. wir holen den naechsten chunk.
                -- 3. wir holen den naechsten block.
                -- 4. wir gehen einfach weiter.
                
                if (
                    ( i = ( BLOCK_SIZE - 1 ) ) or
                    ( i = ( CHUNK_SIZE*chunk_pointer -1 ) )
                ) then
                    
                    go_on := '1';
                    new_addr := '0';
                    
                    -- start post pipeline
                    post_pipeline <= '1';
                    
                elsif i = BLOCK_SIZE then -- diese abfrage muss vor der naechsten sein
                    
                    go_on := '0';
                    new_addr := '0';
                    
                    -- hier dann auch naechsten chunk holen
                    state <=MAC_NEXT_BLOCK;
                    
                elsif i = ( CHUNK_SIZE*chunk_pointer ) then
                    
                    go_on := '0';
                    new_addr := '1'; --l
                    
                    pre_pipeline <= '1';
                    post_pipeline <= '0';
                    
                    state <=CHUNK_WRITE_INIT;
                    
                else
                    
                    go_on := '1';
                    new_addr := '1';
                    
                end if;
                
                -- wir holen uns eine neue addr es sein denn wir
                -- sind gerade mit einem block fertig geworden.
                
                if new_addr = '1' then
                    
                    ir_addr := ir_addr + ( 4 * 2 );
                    in_addr := in_addr + ( 4 * 2 );
                    
--                     m_address <= std_logic_vector( ir_addr + ( 4 * 0 ) ); -- a
                    
                end if;
                
                if go_on = '1' then
                    
                    i_prev := i;
                    i := i + 1;
                    
                    i_chunk_prev := i_chunk;
                    i_chunk := i_chunk + 1;
                    
                    state <=MAC_A_ADDR;
                    
                end if;
                
            end if;
            
        -- next block
        --------------------------------------------------------
        
        elsif state = MAC_NEXT_BLOCK then
            
            i_block := i_block + 1;
            
            -- reset pipeline stuff
            
            pre_pipeline <= '1';
            post_pipeline <= '0';
            
            -- wenn alle ir bloecke fertig sind, wird das beendet.
            -- keine ahnung warum ich hier auch das +1 brauche.
            -- es sollte aber nur ganz am schluss beim schreiben des letzen
            -- chunks einen zu grossen wert annehmen.
            
            if ir_pointer = ir_block_max+1 then
--             if ir_pointer = ir_block_max then
                -- hier noch nicht auf idle gehen, da wir noch einen block spreichern muessen
                
                goto_idle_after_write := '1';
            else
                ir_pointer := ir_pointer + 1;
            end if;
            
            if in_pointer = in_block_min then
                in_pointer := in_block_max;
            else
                in_pointer := in_pointer - 1;
            end if;
            
            -- FUGG
            
            --chunk_pointer := 0; --l
            
            -- zur sicherheit wird der beginn des neuen blocks immer
            -- berechnet. fuer ir ist er eigentlich schon gesetzt.
            
            -- TODO
            -- das mit den addr koennte man auch irgendwo in dem chunk zeugs machen
            
            --~ ir_addr := to_unsigned( ir_pointer * BLOCK_SIZE * 4 * 2, ir_addr'length );
            --~ in_addr := to_unsigned( in_pointer * BLOCK_SIZE * 4 * 2, in_addr'length );
            ir_addr := to_unsigned( base_addr + ( ir_pointer * BLOCK_SIZE * 4 * 2 ), ir_addr'length );
            in_addr := to_unsigned( base_addr + ( in_pointer * BLOCK_SIZE * 4 * 2 ), in_addr'length ); --~ in_addr := x"00029000";
            
            i_prev := i;
            i := 0;
            
            i_chunk_prev := 0;
            i_chunk := 0;
            
            -- wenn wir einen neuen block holen muessen wir auch den letzten chunk schreiben.
            
            state <=CHUNK_WRITE_INIT;
        
        --------------------------------------------------------
        -- 
        -- chunk write
        -- 
        --------------------------------------------------------
        
        elsif state = CHUNK_WRITE_INIT then
            
            -- bei chunk get wird der pointer erhoeht. daher werd er hier wieder -1 genommen.
            
            chunk_addr := to_unsigned( base_addr + CHUNK_OFFSET + ( (chunk_pointer-1) * CHUNK_SIZE * 4 * 2 ), chunk_addr'length );
            
            --if chunk_pointer = CHUNK_SIZE then
            --  chunk_pointer := 0;
            --end if;
            
            --if i = BLOCK_SIZE then
            --chunk_pointer := 0;
            --end if;
            
            chunk_cnt := 0;
            curr_chunk_r := '1';
            
            state <=CHUNK_WRITE_1;
            
        elsif state = CHUNK_WRITE_1 then
            
            m_write <= '1';
            
            -- wenn ich hier konstanten auf m_writedata schreibe, dann kann ich das in c raus lesen.
            -- den chunk_cnt kann ich auch hinaus schreiben.
            
            m_address <= std_logic_vector( chunk_addr + ( 4 * 0 ) );
            m_writedata <= std_logic_vector( acc_r_array( chunk_cnt ) ); -- write data from r chunk
            --m_writedata <= "00000000000000001111100000000111"; -- funktioniert
            --m_writedata <= std_logic_vector( to_unsigned( chunk_cnt, m_writedata'length ) ); -- funktioniert
            
            state <=CHUNK_WRITE_1_WAIT;
            
        elsif state = CHUNK_WRITE_1_WAIT then
            
            if m_writeresponsevalid = '1' then
                
                state <=CHUNK_WRITE_2;
                
            end if;
            
        elsif state = CHUNK_WRITE_2 then
            
            m_write <= '1';
            
            m_address <= std_logic_vector( chunk_addr + ( 4 * 1 ) );
            m_writedata <= std_logic_vector( acc_i_array( chunk_cnt ) ); -- write data from i chunk
            --m_writedata <= "00000000000000001111100000000110"; -- funktioniert
            --m_writedata <= std_logic_vector( to_unsigned( chunk_cnt, m_writedata'length ) ); -- funktioniert
            
            state <=CHUNK_WRITE_2_WAIT;
            
        elsif state = CHUNK_WRITE_2_WAIT then
            
            if m_writeresponsevalid = '1' then
                
                state <=CHUNK_WRITE_1;
                
                -- wenn ich mit dem chunk fertig bin
                
                if chunk_cnt = CHUNK_SIZE-1 then
                    chunk_cnt := 0;
                        
                        state <=CHUNK_GET_INIT;
                        
                        -- das hier kling nach dem durchlaufen von einem block
                        -- werde das mal so drinnen lassen.
                        
                        if chunk_pointer = 128 then
                            chunk_pointer := 0;
                        end if;
                        
                        if goto_idle_after_write = '1' then
                            
                            goto_idle_after_write := '0';
                            
                            chunk_pointer := 0;
                            state <=IDLE;
                        end if;
                else
                    chunk_cnt := chunk_cnt + 1;
                end if;
                
                -- damit schreiben wird dann den naechsten wert
                
                chunk_addr := chunk_addr + ( 4 * 2 ); -- update chunk addr
                
            end if;
            
        --------------------------------------------------------
        -- 
        -- chunk get
        -- 
        --------------------------------------------------------
        
        elsif state = CHUNK_GET_INIT then
            
            chunk_addr := to_unsigned( base_addr + CHUNK_OFFSET + ( chunk_pointer * CHUNK_SIZE * 4 * 2 ), chunk_addr'length );
            chunk_pointer := chunk_pointer + 1;
            
            chunk_cnt := 0;
            curr_chunk_r := '1';
            
            state <=CHUNK_GET_SET_ADDR;
        
        elsif state = CHUNK_GET_SET_ADDR then
            
            m_read <= '1';
            
            if curr_chunk_r = '1' then
                m_address <= std_logic_vector( chunk_addr + ( 4 * 0 ) ); -- addr fuer r chunk
            else
                m_address <= std_logic_vector( chunk_addr + ( 4 * 1 ) ); -- addr fuer i chunk
            end if;
            
            state <=CHUNK_GET_GET_DATA;
            
        elsif state = CHUNK_GET_GET_DATA then
            
            if m_readdatavalid = '1' then
                
                state <=CHUNK_GET_SET_ADDR; -- davon gehen wir aus. kann ueberschrieben werden.
                
                if curr_chunk_r = '1' then
                    
                    acc_r_array( chunk_cnt ) <= signed( m_readdata );
                    
                else
                    
                    acc_i_array( chunk_cnt ) <= signed( m_readdata );
                    
                    if chunk_cnt = CHUNK_SIZE-1 then
                        chunk_cnt := 0;
                        
                        state <=CHUNK_DONE;
                    else
                        chunk_cnt := chunk_cnt + 1;
                    end if;
                    
                    chunk_addr := chunk_addr + ( 4 * 2 ); -- update chunk addr
                    
                end if;
                
                curr_chunk_r := not curr_chunk_r; -- toggle
                
            end if;
            
        
        elsif state = CHUNK_DONE then
            
            i_chunk_prev := 0;
            i_chunk := 0;
            
            if    execution_mode = MAC             then state <=MAC_A_ADDR;
            end if;
            
        end if; -- fsm
        end if; -- skip
        
        
        
    end if; --clk
    
end process;

end architecture;
