library STD;
use STD.textio.all;

--library lib_fft_header;

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
	constant FILE_LENGTH : positive := 256;
	
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
	shared variable line_v : line;
	
	subtype in_word_t is std_logic_vector(15 downto 0);
	type input_t is array(integer range 0 to FILE_LENGTH - 1) of in_word_t;
	
	subtype out_word_t is std_logic_vector(31 downto 0);
	type output_t is array(integer range 0 to FILE_LENGTH - 1) of out_word_t;
	
	shared variable ir_1 : input_t := (others => (others => '0'));
	
	shared variable ir_2 : input_t;
	
	shared variable output_ref_1_real : output_t; 
	shared variable output_ref_1_imag : output_t; 
	
	shared variable output_ref_2_real : output_t;
	shared variable output_ref_2_imag : output_t;
		
	shared variable output_buffer : output_t; 
	shared variable output_buffer_idx : integer := 0; 
begin

	uut : fft_wrapper_header
		port map (
			clk         => clk,
			reset_n     => res_n,
			stin_data   => stin_data,
			stin_valid  => stin_valid,
			stin_ready  => stin_ready,
			stout_data  => stout_data,
			stout_valid => stout_valid,
			stout_ready => stout_ready,
			inverse		=> inverse
		);
		
	stout_ready <= '1'; -- is not checked

	stimulus : process
	
		variable output_1_real : output_t;
		variable output_1_imag : output_t;
		variable output_2_real : output_t;
		variable output_2_imag : output_t;
		
		impure function read_input_file(filename : string) return input_t is
			file FileHandle      : text open read_mode is filename;
			variable CurrentLine : line;
			variable TempWord    : in_word_t;
			variable Result      : input_t := (others => (others => '0'));
		begin
			for i in 0 to FILE_LENGTH - 1 loop
				exit when endfile(FileHandle);

				readline(FileHandle, CurrentLine);
				hread(CurrentLine, TempWord);
				--report "TempWord: " & to_hstring(TempWord);
				Result(i) := TempWord;
			end loop;

			return Result;
		end function;
		
		impure function read_output_file(filename : string) return output_t is
			file FileHandle      : text open read_mode is filename;
			variable CurrentLine : line;
			variable TempWord    : out_word_t;
			variable Result      : output_t := (others => (others => '0'));
		begin
			for i in 0 to FILE_LENGTH - 1 loop
				exit when endfile(FileHandle);

				readline(FileHandle, CurrentLine);
				hread(CurrentLine, TempWord);
				--report "TempWord: " & to_hstring(TempWord);
				Result(i) := TempWord;
			end loop;

			return Result;
		end function;
				
		procedure stream_write(value : std_logic_vector) is 
		begin
            if(stin_ready = '0') then
				wait until stin_ready = '1';
			end if;
			stin_data <= value;
			stin_valid <= '1';
			wait until rising_edge(clk);
			stin_valid <= '0';
			wait for 0 ns;
		end procedure;
		
		procedure compare_buffers(buffer_A, buffer_B : output_t; length : integer) is
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
		--stout_ready <= '0';
		stin_valid <= '0';
		wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
		res_n <= '1';
		wait until rising_edge(clk);
				
		write(my_line, string'("Load Input Buffers"));
		writeline(output, my_line);
		
		ir_1 := read_input_file("tb/l_buf.txt");
		ir_2 := read_input_file("tb/r_buf.txt");
		
		write(my_line, string'("Load Reference Output Buffers"));
		writeline(output, my_line);
		
		output_ref_1_real := read_output_file("tb/result_1_real.txt");
		output_ref_1_imag := read_output_file("tb/result_1_imag.txt");
	
		output_ref_2_real := read_output_file("tb/result_2_real.txt");
		output_ref_2_imag := read_output_file("tb/result_2_imag.txt");
		
		write(my_line, string'("General FFT test"));
		writeline(output, my_line);
		
		output_buffer_idx := 0;
		for i in 0 to FILE_LENGTH - 1 loop
			stream_write(ir_2(i) & ir_2(i)); -- Send both channels at same time
		end loop; 
		stin_valid <= '0';
		
		wait_for_output_buffer_fill_level(FILE_LENGTH);
		
		for i in 0 to FILE_LENGTH - 1 loop
			output_1_real(i) := x"0000" & output_buffer(i)(31 downto 16);
			output_2_real(i) := x"0000" & output_buffer(i)(15 downto 0);
		end loop;
		
		-- Get back both transformed channels
		for i in 1 to FILE_LENGTH/2 loop
			-- imaginary parts of X[f] and X[-f]
			output_1_imag(i) := std_logic_vector( (signed(output_2_real(i)) - signed(output_2_real(512-i))) / 2 );
			output_1_imag(512-i) := not output_1_imag(i);
			
			-- imaginary parts of Y[f] and Y[-f]
			output_2_imag(i) := not std_logic_vector( (signed(output_1_real(i)) - signed(output_1_real(512-i))) / 2 );
			output_2_imag(512-i) := not output_2_imag(i);
			
			-- real parts of X[f] and X[-f]
			output_1_real(i) := std_logic_vector( (signed(output_1_real(i)) + signed(output_1_real(512-i))) / 2 );
			output_1_real(512-i) := output_1_real(i);
			
			-- real parts of Y[f] and Y[-f]
			output_2_real(i) := std_logic_vector( (signed(output_2_real(i)) - signed(output_2_real(512-i))) / 2 );
			output_2_real(512-i) := not output_2_real(i);
		end loop;
		
		write(my_line, string'("Compare results"));
		writeline(output, my_line);
		
		-- Compare result
		compare_buffers(output_1_real, output_ref_1_real, FILE_LENGTH);
		compare_buffers(output_1_imag, output_ref_1_imag, FILE_LENGTH);
		
		compare_buffers(output_2_real, output_ref_2_real, FILE_LENGTH);
		compare_buffers(output_2_imag, output_ref_2_imag, FILE_LENGTH);

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

