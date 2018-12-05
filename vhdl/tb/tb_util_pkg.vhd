library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_util_pkg is
	function hex_to_slv(hex : string; min_width : integer) return std_logic_vector;
	
	function slv_to_hex(slv : in std_logic_vector) return string;
	
	function is_hex_digit(c : character) return boolean;
	
	function hamming_weight(x : std_logic_vector) return integer;
end package;

package body tb_util_pkg is

	function slv_to_hex(slv : in std_logic_vector) return string is
		constant hex_digits : string(1 to 16) := "0123456789abcdef";
		constant num_hex_digits : integer := integer((slv'length+3)/4);
		variable ret_value : string(1 to num_hex_digits);
		variable zero_padded_slv : std_logic_vector((4*num_hex_digits)-1 downto 0) := (others=>'0');
		variable r : integer := 0;
	begin
		zero_padded_slv(slv'range) := slv;
		loop
			ret_value(num_hex_digits-r) :=  hex_digits(to_integer(unsigned( zero_padded_slv( (r+1)*4-1 downto 4*r) ))+1);
			r := r + 1;
			if num_hex_digits-r = 0 then
				exit;
			end if;
		end loop;
		return ret_value;
	end function;
	
	
	function max(a,b : integer) return integer is
	begin
		if a > b then
			return a;
		else
			return b;
		end if;
	end function;
	
	function is_hex_digit(c : character) return boolean is
	begin
		if c = '0' or c = '1' or c = '2' or c = '3' or
		   c = '4' or c = '5' or c = '6' or c = '7' or 
		   c = '8' or c = '9' or c = 'a' or c = 'b' or 
		   c = 'c' or c = 'd' or c = 'e' or c = 'f' or
		   c = 'A' or c = 'B' or c = 'C' or c = 'D' or
		   c = 'E' or c = 'F' then
			return true;
		else
			return false;
		end if;
	end function;
	
	function hex_to_slv(hex : string; min_width : integer) return std_logic_vector is
		variable ret_value : std_logic_vector(max(hex'length*4-1,min_width-1) downto 0) := (others=>'0');
		variable temp : std_logic_vector(3 downto 0);
		variable r : integer := 0;
	begin
		ret_value := (others=>'0');
		--assert hex'length = hex'high - hex'low + 1 severity failure;
		for i in 0 to hex'length-1 loop
			case hex(hex'high-i) is
				when '0' => temp := x"0";
				when '1' => temp := x"1";	
				when '2' => temp := x"2";
				when '3' => temp := x"3";
				when '4' => temp := x"4";
				when '5' => temp := x"5";
				when '6' => temp := x"6";
				when '7' => temp := x"7";
				when '8' => temp := x"8";
				when '9' => temp := x"9";
				when 'a' | 'A' => temp := x"a";
				when 'b' | 'B' => temp := x"b";
				when 'c' | 'C' => temp := x"c";
				when 'd' | 'D' => temp := x"d";
				when 'e' | 'E' => temp := x"e";
				when 'f' | 'F' => temp := x"f";
				when others => report "Conversion Error: char: " & hex(hex'high-i) severity error;
			end case;
			ret_value((i+1)*4-1 downto i*4) := temp;
		end loop;
		return ret_value;
	end function;


	function hamming_weight(x : std_logic_vector) return integer is
		variable counter : integer := 0;
	begin
		for i in x'range loop
			if ( x(i)='1') then
				counter := counter + 1;
			end if;
		end loop;
		return counter;
	end function;

end package body;

