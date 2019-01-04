

--------------------------------------------------------------------------------
--                                LIBRARIES                                   --
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------

entity dp_ram_1c1r1w is
	generic (
		ADDR_WIDTH : integer; -- Address bus width
		DATA_WIDTH : integer  -- Data bus width
	);
	port (
		clk    : in  std_logic; -- Connection for the clock signal.
		
		-- read port
		rd_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- The address bus for a reader of the dual port RAM.
		rd_data : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- The data bus for a reader of the dual port RAM.
		rd      : in  std_logic; -- The indicator signal for a reader of the dual port RAM (must  be set high in order to be able to read).
		
		-- write port
		wr_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- The address bus for a writer of the dual port RAM.
		wr_data : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- The data bus for a writer of the dual port RAM.
		wr      : in  std_logic  -- The indicator signal for a writer of the dual port RAM (must be set high in order to be able to write).
	);
end entity;


--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------

architecture beh of dp_ram_1c1r1w is
	signal rd_addr_reg: integer range 0 to 2**ADDR_WIDTH-1;
	type ram_type is array(0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ram_block : ram_type := (others => (others => '0'));
begin
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (wr = '1') then
				ram_block(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
			if (rd='1') then
				rd_addr_reg <= to_integer(unsigned(rd_addr));
			end if;
		end if;
	end process;
	rd_data <= ram_block(rd_addr_reg);
end architecture;


