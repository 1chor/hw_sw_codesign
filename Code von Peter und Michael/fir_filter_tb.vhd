library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity tb is
end tb;

architecture arch of tb is
--    component fir_filter is
--        generic (
--            NUM_COEFFS : positive := 16;
--            DATA_WIDTH : positive := 32
--        );
--        port (
--            clk			: in	std_logic;
--            res_n		: in	std_logic;
--
--            --m2s (streaming-sink in)
--            stin_ready	: out	std_logic;
--            stin_valid	: in	std_logic;
--            stin_data 	: in	std_logic_vector(DATA_WIDTH-1 downto 0);
--
--            --s2m (streaming-sink out)
--            stout_data	: out	std_logic_vector(DATA_WIDTH-1 downto 0);
--            stout_valid : out	std_logic;
--            stout_ready : in	std_logic; --only needed with backpressure enabled
--
--            --memory mapped slave, used for pushing in the coefficients
--            mm_address	: in	std_logic_vector(integer(ceil(log2(real(NUM_COEFFS))))-1 downto 0);
--            mm_write	: in	std_logic;
--            mm_read		: in	std_logic;
--            mm_waitrequest: out	std_logic;
--            mm_writedata: in	std_logic_vector(DATA_WIDTH-1 downto 0);
--            mm_readdata	: out	std_logic_vector(DATA_WIDTH-1 downto 0)
--        );
--    end component;
--
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : positive := 32;
    constant NUM_COEFFS : positive := 16;
    constant mm_range   : positive := integer(ceil(log2(real(NUM_COEFFS))));

    signal clk              : std_logic;
    signal res_n            : std_logic;
    signal stin_ready       : std_logic;
    signal stin_valid       : std_logic;
    signal stin_data        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stout_data       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stout_valid      : std_logic;
    signal stout_ready      : std_logic;
    signal mm_address       : std_logic_vector(integer(ceil(log2(real(NUM_COEFFS))))-1 downto 0);
    signal mm_write         : std_logic := '0';
    signal mm_read          : std_logic;
    signal mm_waitrequest   : std_logic;
    signal mm_writedata     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mm_readdata      : std_logic_vector(DATA_WIDTH-1 downto 0);


begin
    fir_inst : entity work.fir_filter generic map (NUM_COEFFS => NUM_COEFFS, DATA_WIDTH => DATA_WIDTH) port map (
        clk             => clk,
        res_n           => res_n,
        stin_ready      => stin_ready,
        stin_valid      => stin_valid,
        stin_data       => stin_data,
        stout_data      => stout_data,
        stout_valid     => stout_valid,
        stout_ready     => stout_ready,
        mm_address      => mm_address,
        mm_write        => mm_write,
        mm_read         => mm_read,
        mm_waitrequest  => mm_waitrequest,
        mm_writedata    => mm_writedata,
        mm_readdata     => mm_readdata
    );

    res_n <= '0', '1' after CLK_PERIOD/4 + 3 * CLK_PERIOD;
    stout_ready <= '1';

    clock : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulation : process
    begin
        wait until rising_edge(res_n);
        wait until rising_edge(clk);


        mm_writedata <= X"00010000";
        mm_address <= (others => '0');
        mm_write <= '1';
        wait until rising_edge(clk);
        mm_write <= '0';

        mm_writedata <= X"00020000";
        mm_address <= std_logic_vector(to_unsigned(1, mm_range));
        mm_write <= '1';
        wait until rising_edge(clk);
        mm_write <= '0';

        mm_writedata <= X"00030000";
        mm_address <= std_logic_vector(to_unsigned(2, mm_range));
        mm_write <= '1';
        wait until rising_edge(clk);
        mm_write <= '0';

        mm_writedata <= X"00040000";
        mm_address <= std_logic_vector(to_unsigned(3, mm_range));
        mm_write <= '1';
        wait until rising_edge(clk);
        mm_write <= '0';


        stin_data <= X"00010000";
        stin_valid <= '1';
--        wait until rising_edge(clk);
        wait until rising_edge(stin_ready);
        stin_valid <= '1';
        stin_data <= X"00000000";

        wait until rising_edge(stin_ready);
        stin_valid <= '1';
        stin_data <= X"00000000";

        wait until rising_edge(stin_ready);
        stin_valid <= '1';
        stin_data <= X"00000000";

        wait until rising_edge(stin_ready);
        stin_valid <= '1';
        stin_data <= X"00000000";

        wait until rising_edge(clk);
        stin_valid <= '0';
        wait;
    end process;

end arch;

