----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.01.2019 19:03:49
-- Design Name: 
-- Module Name: fake_sram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fake_sdram is
    port (
        clk   : in std_logic;
        res_n : in std_logic;
        
        s_address   : in std_logic_vector(31 downto 0);
        s_write     : in  std_logic;
        s_read      : in  std_logic;
        s_writedata : in  std_logic_vector(31 downto 0);
        s_writeresponsevalid : out std_logic; -- neu
        s_response  : out std_logic_vector( 1 downto 0 ); -- neu
        s_readdata  : out std_logic_vector(31 downto 0);
        s_readdatavalid : out std_logic; -- neu
        s_waitrequest : out std_logic
    );
end fake_sdram;

architecture Behavioral of fake_sdram is

-- #define BODY_BLOCK_SIZE_ZE (8192)
-- #define BODY_BLOCK_NUM     (23)

-- 2 * 4 * BODY_BLOCK_NUM * BODY_BLOCK_SIZE_ZE * 4

-- 2 weil jedes sample 2 eintraege braucht.
-- 4 weil wir 4 saetze an bloecke brauchen: ir left/right und in left/right.
-- 4 ( am schluss ) weil es byte addressed ist.

-- => 2 * 4 * 23 * 8192 * 4 = 6029312

-- wir brauchen auch noch platz fuer den acc.

-- das ist nur ein block, da das left/richt hintereinander gemacht wird.

-- => 2 * 8192 * 4 = 65536

-- insgesamt ist das dann:

-- => 6029312 + 65536 = 6094848

-- SO VIEL SPEICHER KANN NICHT VERWENDET WERDEN. WERDE VERSUCHEN DAS IN
-- BLOECKEN AUFZUTEILEN.

--  0 - 22 body left
-- 23 - 45 body right
-- 46 - 68 input left
-- 69 - 91 input right

-- blocks

-- bei den ganzen addr hab ich jetzt das byte addressed nicht beachtet.

-- body_h_1_0 - 0 bis 1

-- start (0*2) * BODY_BLOCK_SIZE_ZE = 0
-- end   (1*2) * BODY_BLOCK_SIZE_ZE = 16384-1

-- body_h_1_1 - 1 bis 2

-- start (1*2) * BODY_BLOCK_SIZE_ZE = 16384
-- end   (2*2) * BODY_BLOCK_SIZE_ZE = 32768-1

-- body_i_1_0 - 46 bis 47

-- start (46*2) * BODY_BLOCK_SIZE_ZE = 753664
-- end   (47*2) * BODY_BLOCK_SIZE_ZE = 770048-1

-- body_i_1_1 - 47 bis 48

-- start (47*2) * BODY_BLOCK_SIZE_ZE = 770048
-- end   (48*2) * BODY_BLOCK_SIZE_ZE = 786432-1

-- mac_1 - 92 bis 93

-- start (92*2) * BODY_BLOCK_SIZE_ZE = 1507328
-- end   (93*2) * BODY_BLOCK_SIZE_ZE = 1523712-1

--~ type block_ram_array_type is array( 1523712 downto 0 ) of std_logic_vector( 31 downto 0 );
--~ signal block_ram_array : block_ram_array_type := (others => (others => '0'));

constant BLOCK_SIZE : integer := 8192;

constant b_h_1_0_min : integer := ( ( 0*2) * BLOCK_SIZE );     --         0
constant b_h_1_0_max : integer := ( ( 1*2) * BLOCK_SIZE ) - 1; --    16.383

constant b_h_1_1_min : integer := ( ( 1*2) * BLOCK_SIZE );     --    16.384
constant b_h_1_1_max : integer := ( ( 2*2) * BLOCK_SIZE ) - 1; --    32.767

constant b_i_1_0_min : integer := ( (68*2) * BLOCK_SIZE );     -- 1.114.112
constant b_i_1_0_max : integer := ( (69*2) * BLOCK_SIZE ) - 1; -- 1.130.495

constant b_i_1_1_min : integer := ( (47*2) * BLOCK_SIZE );     --   770.048
constant b_i_1_1_max : integer := ( (48*2) * BLOCK_SIZE ) - 1; --   786.431

constant b_acc_1_min : integer := ( (92*2) * BLOCK_SIZE );     -- 1.507.328
constant b_acc_1_max : integer := ( (93*2) * BLOCK_SIZE ) - 1; -- 1.523.711

type body_block_ram_t is array( 16384-1 downto 0 ) of std_logic_vector( 31 downto 0 );

signal body_block_h_1_0 : body_block_ram_t;
signal body_block_h_1_1 : body_block_ram_t;
signal body_block_i_1_0 : body_block_ram_t;
signal body_block_i_1_1 : body_block_ram_t;
signal body_block_acc_1 : body_block_ram_t;

begin

proc : process ( clk, res_n )

variable addr_base_aligned : unsigned( 31 downto 0 ); -- without base_addr offset
variable addr_word_aligned : unsigned( 31 downto 0 );
variable addr_word_aligned_int : integer;
variable addr_used : integer;
variable index_used : integer;

begin
    
    if res_n = '0' then
        
        --~ body_block_h_1_0 <= (others => (others => '0'));
        --~ body_block_h_1_1 <= (others => (others => '0'));
        
        --~ body_block_i_1_0 <= (others => (others => '0'));
        --~ body_block_i_1_1 <= (others => (others => '0'));
        
--         body_block_acc_1 <= (others => (others => '0'));
        
        for i in 0 to 16384-1 loop
            body_block_acc_1( i ) <= std_logic_vector( to_unsigned( i, s_writedata'length ) );
        end loop;
        
        
    elsif (clk'event and clk='1') then
        
        s_waitrequest <= '0';
        
        s_readdatavalid <= '0';
        s_writeresponsevalid <= '0';
        
        if s_read = '1' then
            
            -- byte aligned to word aligned
            
            addr_base_aligned := unsigned(s_address) - x"4";
            addr_word_aligned := shift_right( unsigned( addr_base_aligned ), 2 );
--             addr_word_aligned := shift_right( unsigned( s_address ), 2 );
            addr_word_aligned_int := to_integer( addr_word_aligned );
            
            s_readdata <= x"00000000";
            
            -- h_1_0
               if ( addr_word_aligned_int >= b_h_1_0_min ) and ( addr_word_aligned_int <= b_h_1_0_max ) then addr_used := addr_word_aligned_int - b_h_1_0_min ; index_used := addr_word_aligned_int - b_h_1_0_min ; s_readdata <= body_block_h_1_0( index_used );
            elsif ( addr_word_aligned_int >= b_h_1_1_min ) and ( addr_word_aligned_int <= b_h_1_1_max ) then addr_used := addr_word_aligned_int - b_h_1_1_min ; index_used := addr_word_aligned_int - b_h_1_1_min ; s_readdata <= body_block_h_1_1( index_used );
            elsif ( addr_word_aligned_int >= b_i_1_0_min ) and ( addr_word_aligned_int <= b_i_1_0_max ) then addr_used := addr_word_aligned_int - b_i_1_0_min ; index_used := addr_word_aligned_int - b_i_1_0_min ; s_readdata <= body_block_i_1_0( index_used );
            elsif ( addr_word_aligned_int >= b_i_1_1_min ) and ( addr_word_aligned_int <= b_i_1_1_max ) then addr_used := addr_word_aligned_int - b_i_1_1_min ; index_used := addr_word_aligned_int - b_i_1_1_min ; s_readdata <= body_block_i_1_1( index_used );
            elsif ( addr_word_aligned_int >= b_acc_1_min ) and ( addr_word_aligned_int <= b_acc_1_max ) then addr_used := addr_word_aligned_int - b_acc_1_min ; index_used := addr_word_aligned_int - b_acc_1_min ; s_readdata <= body_block_acc_1( index_used );
--             else report ("error" & to_string(addr_word_aligned_int)) severity failure;
            end if;
            
            s_readdatavalid <= '1';
            
            --s_readdata <= "00000000000000000000000000000100";
            
            --~ s_readdata <= block_ram_array( to_integer( shift_right(unsigned( s_address ), 2) ) );
            
        elsif s_write = '1' then
            
            -- - x"4" ist ohne base address.
            
            addr_base_aligned := unsigned(s_address) - x"4";
            addr_word_aligned := shift_right( unsigned( addr_base_aligned ), 2 );
--             addr_word_aligned := shift_right( unsigned( s_address ), 2 );
            addr_word_aligned_int := to_integer( addr_word_aligned );
            
            if ( addr_word_aligned_int >= b_acc_1_min ) and ( addr_word_aligned_int <= b_acc_1_max ) then
                
                addr_used := addr_word_aligned_int - b_acc_1_min;
                index_used := addr_word_aligned_int - b_acc_1_min;
                
                --body_block_acc_1( index_used ) <= "00000000000000000000000000000100";
                body_block_acc_1( index_used ) <= s_writedata;
                
                s_writeresponsevalid <= '1';
                
            end if;
            
        end if;
        
    end if;
    
end process;

end Behavioral;
