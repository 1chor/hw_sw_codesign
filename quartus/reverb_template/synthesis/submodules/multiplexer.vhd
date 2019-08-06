
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexer is
    port (
        clk   : in std_logic;
        res_n : in std_logic;
        
        sel : in std_logic;
        
        -- memory mapped slave 0 (MAC)
        s0_address   : in  std_logic_vector(19 downto 0);
        s0_write     : in  std_logic;
        s0_writedata : in  std_logic_vector(15 downto 0);
        s0_read      : in  std_logic;
        s0_readdata  : out std_logic_vector(15 downto 0);
        s0_readdatavalid : out std_logic;
        
        -- memory mapped slave 1 (NIOS)
        s1_address   : in  std_logic_vector(19 downto 0);
        s1_byteanable : in std_logic_vector(1 downto 0);
        s1_write     : in  std_logic;
        s1_writedata : in  std_logic_vector(15 downto 0);
        s1_read      : in  std_logic;
        s1_readdata  : out std_logic_vector(15 downto 0);
	s1_readdatavalid : out std_logic;
	        
        -- memory mapped master (SRAM)
        m_address   : out  std_logic_vector(19 downto 0);
        m_byteanable : out std_logic_vector(1 downto 0);
        m_write     : out  std_logic;
        m_writedata : out  std_logic_vector(15 downto 0);
        m_read      : out  std_logic;
        m_readdata  : in std_logic_vector(15 downto 0);
        m_readdatavalid : in std_logic    
    );
begin
    
end entity;

architecture arch of multiplexer is

begin

------------------------------------------------------------------------
-- multiplexer_proc
------------------------------------------------------------------------

multiplexer_proc : process (sel, s0_address, s0_write, s0_writedata, s0_read, m_readdata, m_readdatavalid, s1_address, s1_byteanable, s1_write, s1_writedata, s1_read)

begin

	s0_readdatavalid <= '0';
	s1_readdatavalid <= '0';
	s0_readdata <= m_readdata;
	s1_readdata <= m_readdata;
            
	m_address <= s0_address;
	m_byteanable <= "11";
	m_write <= s0_write;
	m_writedata <= s0_writedata;
	m_read <= s0_read;
	  
	if sel='0' then
	  s0_readdatavalid <= m_readdatavalid;
	end if;
	    
	if sel = '1' then
	
	    m_address <= s1_address;
	    m_byteanable <= s1_byteanable;	
	    m_write <= s1_write;
	    m_writedata <= s1_writedata;
	    m_read <= s1_read;
	    s1_readdatavalid <= m_readdatavalid;
	   
	end if;
	
end process multiplexer_proc;

end architecture;
