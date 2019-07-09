
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        clk   : in std_logic;
        res_n : in std_logic;
        
        s_address       : in std_logic_vector (15 downto 0);
        s_write         : in std_logic;
        s_read          : in std_logic;
        s_writedata     : in std_logic_vector (31 downto 0);
        s_readdata      : out std_logic_vector (31 downto 0);
        s_readdatavalid : out std_logic;
        s_waitrequest   : out std_logic
    );
end top;

architecture arch of top is

    component mac_sram
    port (
        clk             : in std_logic;
        res_n           : in std_logic;
        s_address       : in std_logic_vector (15 downto 0);
        s_write         : in std_logic;
        s_read          : in std_logic;
        s_writedata     : in std_logic_vector (31 downto 0);
        s_readdata      : out std_logic_vector (31 downto 0);
        s_readdatavalid : out std_logic;
        s_waitrequest   : out std_logic;
        m_address       : out std_logic_vector (31 downto 0);
        m_write         : out std_logic;
        m_read          : out std_logic;
        m_writedata     : out std_logic_vector (15 downto 0);
        m_readdata      : in std_logic_vector (15 downto 0);
        m_waitrequest   : in std_logic
    );
    end component;
    
    component fake_sram
    port (
        clk   : in std_logic;
        res_n : in std_logic;
        
        s_address   : in  std_logic_vector(31 downto 0);
        s_write     : in  std_logic;
        s_read      : in  std_logic;
        s_writedata : in  std_logic_vector(15 downto 0);
        s_readdata  : out std_logic_vector(15 downto 0);
        s_waitrequest : out std_logic
    );
    end component;
    
    --~ signal clk             : std_logic;
    --~ signal res_n           : std_logic;
    --~ signal s_address       : std_logic_vector (15 downto 0);
    --~ signal s_write         : std_logic;
    --~ signal s_read          : std_logic;
    --~ signal s_writedata     : std_logic_vector (31 downto 0);
    --~ signal s_readdata      : std_logic_vector (31 downto 0);
    --~ signal s_readdatavalid : std_logic;
    --~ signal s_waitrequest   : std_logic;
    signal m_address       : std_logic_vector (31 downto 0);
    signal m_write         : std_logic;
    signal m_read          : std_logic;
    signal m_writedata     : std_logic_vector (15 downto 0);
    signal m_readdata      : std_logic_vector (15 downto 0);
    signal m_waitrequest   : std_logic;
    
begin
    
    mac_sram_i : mac_sram
    port map (
        clk             => clk,
        res_n           => res_n,
        s_address       => s_address,
        s_write         => s_write,
        s_read          => s_read,
        s_writedata     => s_writedata,
        s_readdata      => s_readdata,
        s_readdatavalid => s_readdatavalid,
        s_waitrequest   => s_waitrequest,
        m_address       => m_address,
        m_write         => m_write,
        m_read          => m_read,
        m_writedata     => m_writedata,
        m_readdata      => m_readdata,
        m_waitrequest   => m_waitrequest
    );
    
    fake_sram_i : fake_sram
    port map (
        clk             => clk,
        res_n           => res_n,
        
        s_address       => m_address,
        s_write         => m_write,
        s_read          => m_read,
        s_writedata     => m_writedata,
        s_readdata      => m_readdata,
        s_waitrequest   => m_waitrequest
    );
    
end arch;
