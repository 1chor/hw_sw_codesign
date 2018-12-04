library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.all;
use work.textmode_controller_pkg.all;

entity textmode_controller_avalon is
	generic (
		ROW_COUNT   : integer := 30;
		COLUMN_COUNT : integer := 100;
		CLK_FREQ    : integer := 25000000
	);
	port (
		clk			: in  std_logic;
		reset_n		: in  std_logic;
		
		-- avalon interface
		address   : in  std_logic_vector(3 downto 0);
		write_n   : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		irq       : out std_logic;
		readdata  : out std_logic_vector(31 downto 0);
		
		-- ltm outputs
		hd        : out std_logic;                    -- horizontal sync signal
		vd        : out std_logic;                    -- vertical sync signal
		den       : out std_logic;                    -- data enable 
		r         : out std_logic_vector(7 downto 0); -- pixel color value (red)
		g         : out std_logic_vector(7 downto 0); -- pixel color value (green)
		b         : out std_logic_vector(7 downto 0); -- pixel color value (blue)

		grest     : out std_logic -- display reset
	);
end entity;

architecture arch of textmode_controller_avalon is
	
	component textmode_controller_1c is
	generic (
		ROW_COUNT   : integer := 30;
		COLUMN_COUNT : integer := 100;
		CLK_FREQ    : integer := 25000000
	);
	port (
		clk         : in std_logic;
		res_n      : in  std_logic;
		
		wr         : in std_logic;
		busy       : out std_logic;

		instr      : in std_logic_vector(7 downto 0);
		instr_data : in std_logic_vector(15 downto 0);
		
		hd         : out std_logic;            -- horizontal sync signal
		vd         : out std_logic;            -- vertical sync signal
		den        : out std_logic;            -- data enable 
		r          : out std_logic_vector(7 downto 0); -- pixel color value (red)
		g          : out std_logic_vector(7 downto 0); -- pixel color value (green)
		b          : out std_logic_vector(7 downto 0); -- pixel color value (blue)

		grest      : out std_logic -- display reset
	);
	end component textmode_controller_1c;
	
	signal wr         : std_logic;
	signal busy	      : std_logic;		

	signal instr      : std_logic_vector(7 downto 0);
	signal instr_data : std_logic_vector(15 downto 0);

begin

	tmc_inst: textmode_controller_1c 
	generic map (
		ROW_COUNT   => ROW_COUNT,
		COLUMN_COUNT => COLUMN_COUNT,
		CLK_FREQ    => CLK_FREQ
	)
	port map (
		clk        => clk,
		res_n      => reset_n,
		
		wr         => wr,
		busy       => busy,
		instr      => instr,
		instr_data => instr_data,
		
		hd         => hd,
		vd         => vd,
		den        => den,
		r          => r,
		g          => g,
		b          => b,

		grest      => grest
	);
	
	wr_proc: process(address,write_n,writedata)
	begin
		instr      <= INSTR_NOP;
		instr_data <= (others => '0');
		wr <= '0';
		
		if (address = "0000") and (write_n = '0') then
			instr      <= writedata(7 downto 0);
			instr_data <= writedata(23 downto 8);
			wr <= '1';
		end if;
	
	end process;
	
	readdata <= (0 => busy, others => '0');
	irq      <= '0';

end architecture;
