library STD;
use STD.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.tb_util_pkg.all;

entity fft_tb is
end entity;

architecture bench of fft_tb is

	component fft_wrapper_header is
		port (
			clk  	  	: in std_logic;
			reset_n 	: in std_logic;

			-- streaming sink (input)
			stin_data   : in std_logic_vector(31 downto 0);
			stin_valid  : in std_logic;
			stin_ready  : out std_logic;
			
			-- streaming source (output)
			stout_data  : out std_logic_vector(31 downto 0);
			stout_valid : out std_logic;
			stout_ready : in std_logic; -- back pressure from FIFO
					
			inverse     : in std_logic_vector(0 downto 0) -- pio(0) is used for fft header
		);
	end component;

	constant DATA_WIDTH : positive := 32;
	
	signal clk : std_logic;
	signal res_n : std_logic;
	signal stin_data : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stin_valid : std_logic;
	signal stin_ready : std_logic;
	signal stout_data : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stout_valid : std_logic;
	signal stout_ready : std_logic;
	signal inverse : std_logic_vector(0 downto 0);
	
	constant CLK_PERIOD : time := 10 ns;
	constant stop_clock : boolean := false;
	shared variable my_line : line;
	
	
	type buffer_t is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- Use ocatve to obtain these values
	-- filter([2,3,4,5,6,7,8,9], 1, [0,1,0,-1,0,1,0,-1,0,1,0,-1,0,1,0,-1])
	-- alternatvly you can also use the "conv" function
	shared variable ir_1 : buffer_t(0 to 7) := (
		x"00020000", x"00030000", x"00040000", x"00050000",
		x"00060000", x"00070000", x"00080000", x"00090000"
	); 
	
	shared variable ir_2 : buffer_t(0 to 7) := (
		x"00020000", x"00030000", x"00040000", x"00050000",
		x"00060000", x"00070000", x"00080000", x"00090000"
	); 
	
	shared variable test_input : buffer_t(0 to 15) := (
		x"00000000", x"00010000", x"00000000", x"ffff0000",
		x"00000000", x"00010000", x"00000000", x"ffff0000",
		x"00000000", x"00010000", x"00000000", x"ffff0000",
		x"00000000", x"00010000", x"00000000", x"ffff0000"
	); 
	
	shared variable test_output_ref : buffer_t(0 to 15) := (
		x"00000000", x"00020000", x"00030000", x"00020000",
		x"00020000", x"00040000", x"00050000", x"00040000",
		x"00040000", x"FFFC0000", x"FFFC0000", x"00040000",
		x"00040000", x"FFFC0000", x"FFFC0000", x"00040000"
	); 
	
	shared variable output_buffer : buffer_t(0 to 63); 
	shared variable output_buffer_idx : integer := 0; 
begin

	uut : fir
		generic map (
			NUM_COEFFICIENTS => NUM_COEFFICIENTS,
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map (
			clk          => clk,
			res_n        => res_n,
			stin_data    => stin_data,
			stin_valid   => stin_valid,
			stin_ready   => stin_ready,
			stout_data   => stout_data,
			stout_valid  => stout_valid,
			stout_ready  => stout_ready,
			mm_address   => mm_address,
			mm_write     => mm_write,
			mm_read      => mm_read,
			mm_writedata => mm_writedata,
			mm_readdata  => mm_readdata
		);
		
	stout_ready <= '1'; -- is not checked

	stimulus : process
		procedure write_coefficient(index : integer; value : std_logic_vector) is
		begin
			mm_address <= std_logic_vector(to_unsigned(index, mm_address'length));
			mm_writedata <= value;
			mm_write <= '1';
			wait until rising_edge(clk);
			mm_write <= '0';
		end procedure;
		
		--~ procedure read_coefficient(index : integer; value : out std_logic_vector) is
		--~ begin
			--~ mm_address <= std_logic_vector(to_unsigned(index, mm_address'length));
			--~ mm_read <= '1';
			--~ wait until rising_edge(clk);
			--~ mm_read <= '0';
			--~ wait for CLK_PERIOD/4;
			--~ value := mm_readdata;
			--~ wait until rising_edge(clk);
		--~ end procedure;
		
		procedure stream_write(value : std_logic_vector) is 
		begin
            -- stin_data <= value;
            -- stin_valid <= '1';
            -- wait until rising_edge(stin_ready);
			if(stin_ready = '0') then
				wait until stin_ready = '1';
			end if;
			stin_data <= value;
			stin_valid <= '1';
			wait until rising_edge(clk);
			stin_valid <= '0';
			wait for 0 ns;
		end procedure;
		
		procedure compare_buffers(buffer_A, buffer_B : buffer_t; length : integer) is
		begin
			for i in 0 to length-1 loop
				if (buffer_A(i) /= buffer_B(i) ) then
					report ("Buffers don't match (index = " & integer'image(i) & ", " & slv_to_hex(buffer_A(i)) & " vs. " & slv_to_hex(buffer_B(i))) severity error;
				end if;
			end loop;
		end procedure;
		
		procedure wait_for_output_buffer_fill_level(fill_level : integer) is
		begin
			loop
				wait for 100 ns;
				if(output_buffer_idx = fill_level) then
					exit;
				end if;
			end loop;
		end procedure;
	begin
	
		write(my_line, string'("----------------------------------"));
		writeline(output, my_line);
	
		res_n <= '0';
		stin_data <= (others=>'0');
		mm_address <= (others=>'0');
		mm_writedata <= (others=>'0');
		mm_write <= '0';
		--mm_read <= '0';
		--stout_ready <= '0';
		stin_valid <= '0';
		wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
		res_n <= '1';
		wait until rising_edge(clk);
				
		write(my_line, string'("Writing coefficients to memory"));
		writeline(output, my_line);
		for i in 0 to 7 loop
			write_coefficient(i, coefficients(i));
		end loop; 

		--~ write(my_line, string'("Coefficients read-back test"));
		--~ writeline(output, my_line);
		--~ for i in 0 to 7 loop
			--~ read_coefficient(i, output_buffer(i));
		--~ end loop; 

		--~ wait until rising_edge(clk);
		--~ compare_buffers(coefficients, output_buffer, 8);
		
		-- the impulse response of an FIR filter must match it's coefficients
		write(my_line, string'("Impulse response test"));
		writeline(output, my_line);
		stream_write(x"00010000");
		for i in 1 to 7 loop
			stream_write(x"00000000");
		end loop; 
		stin_valid <= '0';
		
		wait_for_output_buffer_fill_level(8);
		compare_buffers(coefficients, output_buffer, 8);
		

		write(my_line, string'("General filter test"));
		writeline(output, my_line);
		output_buffer_idx := 0;
		for i in 0 to 15 loop
			stream_write(test_input(i));
		end loop; 
		stin_valid <= '0';
		
		wait_for_output_buffer_fill_level(16);
		compare_buffers(output_buffer, test_output_ref, 16);

		write(my_line, string'("Done"));
		writeline(output, my_line);
		
		write(my_line, string'("----------------------------------"));
		writeline(output, my_line);
		
		wait;
		
	end process;
	
	read_output_stream : process(clk)
	begin
		if (rising_edge(clk)) then
			if (stout_valid = '1') then
				output_buffer(output_buffer_idx) := stout_data;
				output_buffer_idx := output_buffer_idx + 1;
			end if;
		end if;
	end process; 


	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;

