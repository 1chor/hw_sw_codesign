-- vim: ts=4 sw=4 ai number
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;


entity fir_filter is
    generic (
        NUM_COEFFS : positive := 16;
        DATA_WIDTH : positive := 32
    );
    port (
        clk			: in	std_logic;
        res_n		: in	std_logic;

        --m2s (streaming-sink in)
        stin_ready	: out	std_logic;
        stin_valid	: in	std_logic;
        stin_data 	: in	std_logic_vector(DATA_WIDTH-1 downto 0);

        --s2m (streaming-sink out)
        stout_data	: out	std_logic_vector(DATA_WIDTH-1 downto 0);
        stout_valid : out	std_logic;
        stout_ready : in	std_logic; --only needed with backpressure enabled

        --memory mapped slave, used for pushing in the coefficients
        mm_address	: in	std_logic_vector(integer(ceil(log2(real(NUM_COEFFS))))-1 downto 0);
--		mm_address	: in	std_logic_vector(11-1 downto 0);
        mm_write	: in	std_logic;
        mm_read		: in	std_logic;
        mm_waitrequest: out	std_logic;
        mm_writedata: in	std_logic_vector(DATA_WIDTH-1 downto 0);
        mm_readdata	: out	std_logic_vector(DATA_WIDTH-1 downto 0)
        );
end fir_filter;

architecture arch of fir_filter is
    --TODO: rename
    constant depth_addr     : integer := integer(ceil(log2(real(NUM_COEFFS))));
    type t_state is (m2s_wait, multiply, s2m_wait);
    signal state, state_next : t_state;

    subtype t_depth_cnt is integer range 0 to (NUM_COEFFS-1);
    signal mul_num          : t_depth_cnt;
    signal mul_num_next     : t_depth_cnt;
    signal oldest_data_addr : t_depth_cnt;
    signal oldest_data_addr_next : t_depth_cnt;

    signal coeff_dout       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_dout        : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal coeff_wren       : std_logic;
    signal data_wren        : std_logic;

    signal acc              : signed(2*DATA_WIDTH-1 downto 0);
    signal acc_next         : signed(2*DATA_WIDTH-1 downto 0);

    signal data_addr_wr          : std_logic_vector(depth_addr-1 downto 0);
    signal data_addr_rd          : std_logic_vector(depth_addr-1 downto 0);
    signal coeff_addr_rd          : std_logic_vector(depth_addr-1 downto 0);
begin

    assert false report "get values: " & integer'image(t_depth_cnt'high) severity warning;

    mem_coeff : entity work.ram generic map (DEPTH => NUM_COEFFS, DATA_WIDTH => DATA_WIDTH) port map (
        din     => mm_writedata,
        wren    => coeff_wren,
        addr_wr => mm_address,
        dout    => coeff_dout,
        addr_rd => coeff_addr_rd,
        clk     => clk
    );

    --need to use mul_num_next because of one latency cycle inside the RAM
    coeff_addr_rd <= std_logic_vector(to_unsigned(mul_num_next + 1, depth_addr));

    mem_data : entity work.ram generic map (DEPTH => NUM_COEFFS, DATA_WIDTH => DATA_WIDTH) port map (
        din     => stin_data,
        wren    => data_wren,
        addr_wr => data_addr_wr,
        dout    => data_dout,
        addr_rd => data_addr_rd,
        clk     => clk
    );

    --need to use mul_num_next because of one latency cycle inside the RAM
    data_addr_rd <= std_logic_vector(to_unsigned(oldest_data_addr + mul_num_next + 1, depth_addr));
    data_addr_wr <= std_logic_vector(to_unsigned(oldest_data_addr, depth_addr));

    seq : process (clk)
    begin
        if rising_edge(clk) then
            if res_n = '0' then
                state <= m2s_wait;
                mul_num <= 0;
                acc <= (others => '0');
                oldest_data_addr <= 0;
            else
                state <= state_next;
                oldest_data_addr <= oldest_data_addr_next;
                mul_num <= mul_num_next;
                acc <= acc_next;
            end if;
        end if;
    end process;

    comb : process (state, stin_valid, stout_ready, mul_num, acc, coeff_dout, data_dout, oldest_data_addr)
    begin
        --default values to prevent latches
        state_next <= state;
        oldest_data_addr_next <= oldest_data_addr;
        mul_num_next <= 0;
        acc_next <= acc;
        stin_ready <= '0';
        stout_valid <= '0';
        stout_data <= (others => '0');
        data_wren <= '0';

        case state is
            when m2s_wait =>
                stin_ready <= '1';

                --write the newest data-value over value pointed to by oldest_ptr
                if stin_valid = '1' then
                    data_wren <= '1';
                    state_next <= multiply;
                end if;
            when multiply =>
                acc_next <= acc + signed(coeff_dout) * signed(data_dout);

                if mul_num = t_depth_cnt'high then --catch overflow
                    state_next <= s2m_wait;
                else
                    mul_num_next <= mul_num + 1;
                end if;
            when s2m_wait =>
                if stout_ready = '1' then
                    stout_data <= std_logic_vector(acc(47 downto 16));
                    acc_next <= (others => '0');
                    stout_valid <= '1';

                    if oldest_data_addr = 0 then
                        oldest_data_addr_next <= t_depth_cnt'high;
                    else
                        oldest_data_addr_next <= oldest_data_addr - 1;
                    end if;

                    state_next <= m2s_wait;
               end if;
            end case;
        end process;

        coeff_wren <= mm_write;
        mm_waitrequest <= '0'; --don't stall the cpu
        mm_readdata <= (others => '0');

end arch;
