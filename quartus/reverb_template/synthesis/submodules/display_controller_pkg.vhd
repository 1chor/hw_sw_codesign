
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;


package display_controller_pkg is

	constant DISPLAY_WIDTH : integer := 800;
	constant DISPLAY_HEIGHT : integer := 480;
	
	type COLOR_TYPE is array (0 to 15) of std_logic_vector(23 downto 0);
	
	constant COLOR_TABLE : COLOR_TYPE :=
	(
		x"000000", -- black
		x"0000AA", -- blue
		x"00AA00", -- green
		x"00AAAA", -- cyan
		x"AA0000", -- red
		x"AA00AA", -- pink
		x"AA5500", -- brown
		x"AAAAAA", -- gray
		x"555555", -- dark gray
		x"5555FF", -- light blue
		x"55FF55", -- light green
		x"55FFFF", -- light cyan
		x"FF5555", -- light red
		x"FF55FF", -- 
		x"FFFF55", -- yellow
		x"FFFFFF"  -- white
	);
	
	
	component display_controller is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			vram_addr_row : out std_logic_vector(log2c(30)-1 downto 0);
			vram_addr_column : out std_logic_vector(log2c(100)-1 downto 0);
			vram_data : in std_logic_vector(15 downto 0);
			vram_rd : out std_logic;
			char : out std_logic_vector(log2c(256) - 1 downto 0);
			char_height_pixel : out std_logic_vector(log2c(16) - 1 downto 0);
			decoded_char : in std_logic_vector(0 to 8 - 1);
			hd : out std_logic;
			vd : out std_logic;
			den : out std_logic;
			r : out std_logic_vector(7 downto 0);
			g : out std_logic_vector(7 downto 0);
			b : out std_logic_vector(7 downto 0);
			grest : out std_logic
		);
	end component;


end display_controller_pkg;



