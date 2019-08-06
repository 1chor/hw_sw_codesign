
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
    
    component mac_sdram_control_interface
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
    end component;
    
    component fake_sdram
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
    end component;
    
    signal w_address       : std_logic_vector (31 downto 0);
    signal w_write         : std_logic;
    signal w_read          : std_logic;
    signal w_writedata     : std_logic_vector (31 downto 0);
    signal w_writeresponsevalid : std_logic;
    signal w_response      :  std_logic_vector( 1 downto 0 );
    signal w_readdata      : std_logic_vector (31 downto 0);
    signal w_readdatavalid : std_logic;
    signal w_waitrequest   : std_logic;
    
begin
    
    mac_sdram_control_interface_i : mac_sdram_control_interface
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
        
        m_address            => w_address,
        m_write              => w_write,
        m_read               => w_read,
        m_writedata          => w_writedata,
        m_writeresponsevalid => w_writeresponsevalid,
        m_response           => w_response,
        m_readdata           => w_readdata,
        m_readdatavalid      => w_readdatavalid,
        m_waitrequest        => w_waitrequest
    );
    
    fake_sdram_i : fake_sdram
    port map (
        clk             => clk,
        res_n           => res_n,
        
        s_address            => w_address,
        s_write              => w_write,
        s_read               => w_read,
        s_writedata          => w_writedata,
        s_writeresponsevalid => w_writeresponsevalid,
        s_response           => w_response,
        s_readdata           => w_readdata,
        s_readdatavalid      => w_readdatavalid,
        s_waitrequest        => w_waitrequest
    );
    
end arch;
