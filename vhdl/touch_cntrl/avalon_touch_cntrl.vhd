


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity avalon_touch_cntrl is
	generic (
		SYS_CLK : integer := 100000000
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(1 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0);
		
		-- interrupt interface
		irq : out std_logic;
		
		--interface to adc
		adc_din       :   out std_logic;      -- data signal: touch_controller -> adc
		adc_dclk      :   out std_logic;      -- adc clock signal
		adc_cs        :   out std_logic;      -- chip select for the adc
		adc_dout      :   in std_logic;       -- data signal: adc -> touch_contoller
		adc_penirq_n  :   in std_logic       -- touch interrupt signal 
	);
end entity;


architecture arch of avalon_touch_cntrl is
	signal last_coord_x : std_logic_vector(11 downto 0);
	signal last_coord_y : std_logic_vector(11 downto 0);
	
	signal last_coord_x_next : std_logic_vector(11 downto 0);
	signal last_coord_y_next : std_logic_vector(11 downto 0);
	
	signal y_buffer : std_logic_vector(11 downto 0);
	signal y_buffer_next : std_logic_vector(11 downto 0);
	signal interrupt_mask : std_logic;
	signal interrupt_mask_next : std_logic;
	
	signal adc_penirq_n_sync : std_logic;
	
	constant SYNC_STAGES : integer := 3;
	signal shift_register : std_logic_vector(SYNC_STAGES-1 downto 0);
	
	signal new_point_data : std_logic;
	signal point_data : std_logic_vector(23 downto 0);
	signal screen_touched : std_logic;
	
	signal new_point_data_reg : std_logic;
	signal new_point_data_reg_next : std_logic;
	
	signal readdata_int : std_logic_vector(31 downto 0);
	

	
	component touch_controller is
		generic (
			SYS_CLK : integer := 25000000;
			ADC_CLK : integer := 50000
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			adc_din : out std_logic;
			adc_dclk : out std_logic;
			adc_cs : out std_logic;
			adc_dout : in std_logic;
			adc_penirq_n : in std_logic;
			point_data : out std_logic_vector(23 downto 0);
			screen_touched : out std_logic;
			new_point_data : out std_logic
		);
	end component;
	
begin

	irq <= new_point_data_reg and interrupt_mask;

	mm_slave : process (address,write,read,writedata,y_buffer,last_coord_x,last_coord_y)
	begin
		readdata_int <= (others=>'0');
		y_buffer_next <= y_buffer;
		new_point_data_reg_next <= new_point_data_reg;
		last_coord_y_next <= last_coord_y;
		last_coord_x_next <= last_coord_x;

		if (write = '1') then
			case address is
				when "00" =>
					if ( writedata(0) = '1') then
						new_point_data_reg_next <= '0';
					end if;
				when "01" =>
					interrupt_mask_next <= writedata(0);
				when others =>
					null;
			end case;
		end if; 
		
		if (read = '1') then
			case address is
				when "00" =>
					readdata_int <= (others=>'0');
					readdata_int(0) <= new_point_data_reg;
				when "01" =>
					readdata_int(0) <= interrupt_mask;
				when "10" =>
					readdata_int(11 downto 0) <= last_coord_x;
					y_buffer_next <= last_coord_y;
				when "11" =>
					readdata_int(11 downto 0) <= y_buffer;
				when others => null;
			end case;
		end if;
		
		if (new_point_data = '1') then
			last_coord_x_next <= point_data(11 downto 0);
			last_coord_y_next <= point_data(23 downto 12);
			new_point_data_reg_next <= '1';
		end if;
		
	end process;

	readdata <= readdata_int;

	process (clk,res_n)
	begin
		if (res_n = '0') then
			shift_register <= (others=>'0');
		elsif (rising_edge(clk)) then
			shift_register(0) <= adc_penirq_n;
			shift_register(SYNC_STAGES-1 downto 1) <= shift_register(SYNC_STAGES-2 downto 0);
			y_buffer <= y_buffer_next;
			
			last_coord_x <= last_coord_x_next;
			last_coord_y <= last_coord_y_next;
			new_point_data_reg <= new_point_data_reg_next;
		end if;
	end process;


	adc_penirq_n_sync <= shift_register(SYNC_STAGES-1);

	touch_controller_inst : touch_controller
	generic map (
		SYS_CLK => SYS_CLK,
		ADC_CLK => 50000
	)
	port map (
		clk            => clk,
		res_n          => res_n,
		adc_din        => adc_din,
		adc_dclk       => adc_dclk,
		adc_cs         => adc_cs,
		adc_dout       => adc_dout,
		adc_penirq_n   => adc_penirq_n_sync,
		point_data     => point_data,
		screen_touched => screen_touched,
		new_point_data => new_point_data
	);


end architecture;



