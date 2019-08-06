
library ieee;
use ieee.std_logic_1164.all;

entity tb_mac_sram is
end tb_mac_sram;

architecture tb of tb_mac_sram is

    component top
        port (
            clk             : in std_logic;
            res_n           : in std_logic;
            s_address       : in std_logic_vector (15 downto 0);
            s_write         : in std_logic;
            s_read          : in std_logic;
            s_writedata     : in std_logic_vector (31 downto 0);
            s_readdata      : out std_logic_vector (31 downto 0);
            s_readdatavalid : out std_logic
        );
    end component;
    
    signal clk             : std_logic;
    signal res_n           : std_logic;
    
    signal s_address       : std_logic_vector (15 downto 0);
    signal s_write         : std_logic;
    signal s_read          : std_logic;
    signal s_writedata     : std_logic_vector (31 downto 0);
    signal s_readdata      : std_logic_vector (31 downto 0);
    signal s_readdatavalid : std_logic;
    signal s_waitrequest   : std_logic;
    
begin
    
    dut : top
    port map (
        clk             => clk,
        res_n           => res_n,
        
        s_address       => s_address,
        s_write         => s_write,
        s_read          => s_read,
        s_writedata     => s_writedata,
        s_readdata      => s_readdata,
        s_readdatavalid => s_readdatavalid
    );
    
    -- Clock generation
    
    clk_proc : process
    begin
        
        clk <= '1';
        wait for 20 ns;
        clk <= '0';
        wait for 20 ns;
        
    end process;
    
    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        res_n <= '0';
        s_address <= (others => '0');
        s_write <= '0';
        s_read <= '0';
        s_writedata <= (others => '0');

        -- Reset generation
        res_n <= '0';
        wait for 60 ns;
        res_n <= '1';
        wait for 60 ns;
        
        wait for 500 ns;
        
        -- left channel selected
        
        s_write <= '1';
        s_writedata <= "00000000000000000000000000000001";
        s_address <= "0000000000000011";
        
        wait for 40 ns;
        
        -- es wird aktiviert
        
        s_write <= '1';
        s_writedata <= "00000000000000000000000000000010";
        s_address <= "0000000000000001";
        
        wait for 40 ns;
        
        -- es wird wieder deaktiviert
        
        s_write <= '0';
        s_writedata <= "00000000000000000000000000000000";
        s_address <= "0000000000000000";
        
        -- warten bis es fertig wird
        
        wait for 4 ms;
        
        -- noch einmal aktivieren
        
        s_write <= '1';
        s_writedata <= "00000000000000000000000000000010";
        s_address <= "0000000000000001";
        
        wait for 40 ns;
        
        s_write <= '0';
        s_writedata <= "00000000000000000000000000000000";
        s_address <= "0000000000000000";
        
        wait for 4 ms;
        
        s_read <= '1';
        s_address <= "0000000000000000";
        
        wait for 80 ns;
        
        s_read <= '0';
        
        --~ s_address <= "0000000000000000";
        --~ s_read <= '1';
        
        wait for 40 ms;
        
        --~ s_read <= '0';
        
        wait;
    end process;
    
end tb;
