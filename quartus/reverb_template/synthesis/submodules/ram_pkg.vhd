
library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;


package ram_pkg is
	component dp_ram_1c1r1w is
		generic (
			ADDR_WIDTH : integer;
			DATA_WIDTH : integer
		);
		port (
			clk : in std_logic;
			rd_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			rd_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			rd : in std_logic;
			wr_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			wr_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
			wr : in std_logic
		);
	end component;

end package;

