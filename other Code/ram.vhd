-- vim: ts=4 sw=4 ai number
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity ram is
	generic (
		DEPTH		: positive := 32;
		DATA_WIDTH	: positive := 32
	);
	port (
		din		: in	std_logic_vector(DATA_WIDTH-1 downto 0);
		wren	: in	std_logic;
		addr_wr	: in	std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);
		dout	: out	std_logic_vector(DATA_WIDTH-1 downto 0);
		addr_rd	: in	std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);
		clk 	: in	std_logic
	);
end ram;

architecture arch of ram is
	type mem_type is array (DEPTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem : mem_type := (others => (others => '0'));
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if wren = '1' then	
				mem(to_integer(unsigned(addr_wr))) <= din;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
            if wren = '0' then
    			dout <= mem(to_integer(unsigned(addr_rd)));
            end if;
		end if;
	end process;
end architecture;
