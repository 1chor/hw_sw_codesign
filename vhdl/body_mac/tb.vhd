
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity tb_mac_sdram is
end tb_mac_sdram;

architecture tb of tb_mac_sdram is

    component top
        port (
            clk             : in std_logic;
            res_n           : in std_logic;
            s_address       : in std_logic_vector (15 downto 0);
            s_write         : in std_logic;
            s_read          : in std_logic;
            s_writedata     : in std_logic_vector (31 downto 0);
            s_readdata      : out std_logic_vector (31 downto 0);
            s_readdatavalid : out std_logic;
            s_waitrequest   : out std_logic
        );
    end component;
    
    signal clk             : std_logic;
    signal res_n           : std_logic;
    
    signal s_address       : std_logic_vector (15 downto 0);
    signal s_write         : std_logic;
    signal s_read          : std_logic;
    signal s_writedata     : std_logic_vector (31 downto 0);
    signal s_readdata      : std_logic_vector (31 downto 0);
    signal s_readdatavalid : std_logic;
    signal s_waitrequest   : std_logic;
    
    --~ subtype word_t is std_logic_vector( 31 downto 0 );
    
    --~ file f_body_h : text;
    
    -- constants
    
    -- block
    
    constant BLOCK_NUM : integer := 23;
    constant BLOCK_SIZE : integer := 8192;
    
    -- chunk
    
    constant CHUNK_SIZE : integer := 64;
    constant CHUNK_OFFSET : integer := 2 * 4 * BLOCK_NUM * BLOCK_SIZE;
    
begin
    
    dut : top
    port map (
        clk             => clk,
        res_n           => res_n,
        
        s_address       => s_address,
        s_write         => s_write,
        s_read          => s_read,
        s_writedata     => s_writedata,
        s_readdata      => s_readdata,
        s_readdatavalid => s_readdatavalid,
        s_waitrequest   => s_waitrequest
    );
    
    -- Clock generation
    
    clk_proc : process
    begin
        
        clk <= '1';
        wait for 20 ns;
        clk <= '0';
        wait for 20 ns;
        
    end process;
    
    stimuli : process
    
    type body_block_ram_t is array( (2*BLOCK_SIZE)-1 downto 0 ) of std_logic_vector( 31 downto 0 );
    
    alias ram_h_0 is << signal .tb_mac_sdram.dut.fake_sdram_i.body_block_h_1_0 : body_block_ram_t >>;
    alias ram_h_1 is << signal .tb_mac_sdram.dut.fake_sdram_i.body_block_h_1_1 : body_block_ram_t >>;
    alias ram_i_0 is << signal .tb_mac_sdram.dut.fake_sdram_i.body_block_i_1_0 : body_block_ram_t >>;
    alias ram_i_1 is << signal .tb_mac_sdram.dut.fake_sdram_i.body_block_i_1_1 : body_block_ram_t >>;
    alias ram_acc is << signal .tb_mac_sdram.dut.fake_sdram_i.body_block_acc_1 : body_block_ram_t >>;
    
    --~ variable l_body_h : line;
    --~ variable w_body_h : std_logic_vector( 31 downto 0 );
    
    type body_block_t is array( (2*BLOCK_SIZE)-1 downto 0 ) of std_logic_vector( 31 downto 0 );
    
    variable body_block_h_0 : body_block_t;
    variable body_block_h_1 : body_block_t;
    variable body_block_i_0 : body_block_t;
    variable body_block_i_1 : body_block_t;
    
    variable body_mac_0 : body_block_t;
    
    variable test_read_out_data : std_logic_vector( 31 downto 0 );
    variable test_compare : std_logic_vector( 31 downto 0 ) := (others=>'0');
    
    variable state_read_out : std_logic_vector( 31 downto 0 ) := (others=>'0');
    
    --------------------------------------------------------------------
    -- read_file
    --------------------------------------------------------------------
    
    impure function read_file ( f_name : string ) return body_block_t is
        file f_body_h : text;
        variable l_body_h : line;
        variable w_body_h : std_logic_vector( 31 downto 0 );
        variable body_block_temp : body_block_t;
    begin
        
        file_open( f_body_h, f_name,  read_mode );
        
        for i in 0 to (2*BLOCK_SIZE)-1 loop
            exit when endfile( f_body_h );
            
            readline( f_body_h, l_body_h );
            hread( l_body_h, w_body_h );
            
            body_block_temp( i ) := w_body_h;
        end loop;
        
        file_close( f_body_h );
        return body_block_temp;
        
    end function;
    
    --------------------------------------------------------------------
    -- write_block
    --------------------------------------------------------------------
    
    --~ procedure write_block( body_block_ram : body_block_ram_t; body_block : body_block_t ) is
    --~ begin
        
        --~ for i in 0 to (2*BLOCK_SIZE)-1 loop
            --~ body_block_ram( i ) <= body_block( i );
        --~ end loop;
        
    --~ end procedure;
    
    --------------------------------------------------------------------
    -- set_base_addr - updated
    --------------------------------------------------------------------
    
    procedure set_base_addr is
    begin
        report "----------------------------------------------------------------- set base addr";
        s_write <= '1';
        s_writedata <= "00000000000000000000000000000100";
        s_address <= std_logic_vector( to_unsigned( 13, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- test read out - updated
    --------------------------------------------------------------------
    
    procedure test_read_out is
    begin
        report "----------------------------------------------------------------- test read out";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 9, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- test reset - updated
    --------------------------------------------------------------------
    
    procedure test_reset is
    begin
        report "----------------------------------------------------------------- test reset";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 1, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- test_chunk_inc - updated
    --------------------------------------------------------------------
    
    procedure test_chunk_inc is
    begin
        report "----------------------------------------------------------------- test chunk inc";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 11, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- set left channel - updated
    --------------------------------------------------------------------
    
    procedure set_left_channel is
    begin
        report "----------------------------------------------------------------- set left channel";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 3, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- set right channel - updated
    --------------------------------------------------------------------
    
    procedure set_right_channel is
    begin
        report "----------------------------------------------------------------- set right channel";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 5, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- start - updated
    --------------------------------------------------------------------
    
    procedure start is
    begin
        report "----------------------------------------------------------------- start";
        s_write <= '1';
        s_address <= std_logic_vector( to_unsigned( 7, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- read state
    --------------------------------------------------------------------
    
    procedure read_state is
    begin
        --report "----------------------------------------------------------------- read state";
        s_read <= '1';
        s_address <= std_logic_vector( to_unsigned( 129, s_address'length ) );
        wait for 60 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- remove_write_input
    --------------------------------------------------------------------
    
    procedure rwi is
    begin
        report "----------------------------------------------------------------- remove write input";
        
        s_write <= '0';
        s_writedata <= "00000000000000000000000000000000";
        s_address <= "0000000000000000";
        
        wait for 40 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- remove_read_input
    --------------------------------------------------------------------
    
    procedure rri is
    begin
        --report "----------------------------------------------------------------- remove read input";
        
        s_read <= '0';
        s_address <= "0000000000000000";
        
        wait for 40 ns;
    end procedure;
    
    --------------------------------------------------------------------
    -- wait for read
    --------------------------------------------------------------------
    
    procedure wait_for_read is
    begin
      
        --wait until s_readdatavalid = '1';
        
        if s_readdatavalid /= '1' then
            wait until s_readdatavalid = '1';
        end if;
      
    end procedure;
    
    --------------------------------------------------------------------
    -- wait_until_idle
    --------------------------------------------------------------------
    
    procedure wait_until_idle is
    begin
      
      loop
        
        read_state;
        rri;
        
        wait_for_read;
        
        state_read_out := s_readdata;
        
        if state_read_out = "00000000000000000000000000000001" then
            exit;
        end if;
        
      end loop;
      
      --if s_waitrequest /= '0' then
      --  wait until s_waitrequest = '0';
      --end if;
      
    end procedure;
    
    --------------------------------------------------------------------
    -- begin
    --------------------------------------------------------------------
    
    begin
        
        report "----------------------------------------------------------------- testing";
        
        -- EDIT Adapt initialization as needed
        res_n <= '0';
        s_address <= (others => '0');
        s_write <= '0';
        s_read <= '0';
        s_writedata <= (others => '0');
        
        -- Reset generation
        res_n <= '0';
        wait for 60 ns;
        res_n <= '1';
        wait for 60 ns;
        
        wait_until_idle;
        
        -- wenn ich das in dem fake_sdram resette, dann bekommm ich am anfang
        -- einen haufen XXXX.
        
        for i in 0 to (2*BLOCK_SIZE)-1 loop
            ram_h_0( i ) <= (others => '0');
            ram_h_1( i ) <= (others => '0');
            ram_i_0( i ) <= (others => '0');
            ram_i_1( i ) <= (others => '0');
            --ram_acc( i ) := (others => '0');
        end loop;
        
        -- reading blocks and save them in fake sdram
        
        body_block_h_0 := read_file( "body_H_1_0" );
        body_block_h_1 := read_file( "body_H_1_1" );
        body_block_i_0 := read_file( "body_I_1_0" );
        
        for i in 0 to (2*BLOCK_SIZE)-1 loop
            ram_h_0( i ) <= body_block_h_0( i );
            ram_h_1( i ) <= body_block_h_1( i );
            ram_i_0( i ) <= body_block_i_0( i );
            
            -- diese zeile brauche ich da ich sonst spaeter nichts in den ram schreiben kann.
            -- nur mit konstanten indices ist es dann moeglich.
            
            --ram_acc( i ) := body_block_h_0( i );
        end loop;
        
        -- addr 1 -> reset
        -- addr 3 -> set left channel
        -- addr 5 -> set right channel
        
        -- addr 7 -> mac select latest in block
        
        -- addr 9 -> read out init
        -- addr 11 -> chunk block inc init
        
        -- addr 13 -> base addr
        
        
        ---------------------------
        -- state read out
        ---------------------------
        
        report "----------------------------------------------------------------- TEST: state read test";
        
        read_state;
        rri;
        
        wait_for_read;
        
        state_read_out := s_readdata;
        
        if state_read_out = "00000000000000000000000000000001" then
          report "----------------------------------------------------------------- TEST: state read out test passed";
        else
          report "################################################################# TEST: state read out test failed: " & to_hstring( state_read_out );
        end if;
        
        ---------------------------
        -- base addr
        ---------------------------
        
        set_base_addr;
        rwi;
        
        s_read <= '1';
        s_address <= std_logic_vector( to_unsigned( 128, s_address'length ) );
        wait for 40 ns;
        
        rri;
        
        wait_for_read;
        
        if s_readdata = "00000000000000000000000000000100" then
          report "----------------------------------------------------------------- TEST: base addr test passed";
        else
          report "################################################################# TEST: base addr test failed";
        end if;

        ---------------------------
        -- reset test
        ---------------------------
        
        test_reset;
        rwi;
        
        wait_until_idle;
        
        -- check result
        
        test_compare := (others=>'0');
        
        for i in 0 to CHUNK_SIZE-1 loop
            
            s_read <= '1';
            s_address <= std_logic_vector( to_unsigned( i, s_address'length ) );
            
            wait for 60 ns;
            
            wait_for_read;
            
            test_read_out_data := s_readdata;
            
            s_read <= '0';
            
            if test_compare /= test_read_out_data then
              
              report "############################" & "0" & " - " & to_hstring( test_read_out_data ) & " - " & to_string( i );
              exit;
              
            end if;
        end loop;
        
        report "----------------------------------------------------------------- TEST: reset test passed";
        
        ---------------------------
        -- mac
        ---------------------------
        
        report "----------------------------------------------------------------- MAC: set left channel";
        
        set_left_channel;
        rwi;
        
        wait_until_idle;
        
        report "----------------------------------------------------------------- MAC: start";
        
        start;
        wait for 40 ns;
        
        rwi;
        wait_until_idle;
        
        -- wenn ich fertig bin, dann steht das ergebnis in dem mac buffers, also den chunks.
        
        report "----------------------------------------------------------------- MAC: test mac_0";
        
        body_mac_0 := read_file( "body_mac_0" );
        
        for i in 0 to (2*BLOCK_SIZE)-1 loop
            
            if ram_acc( i ) = body_mac_0( i ) then
              --report "PASSSSSSSSSSSST" & to_hstring( ram_acc( i ) ) & " - " & to_hstring( body_mac_0( i ) ) & " - " & to_string( i );
            else
              report "############################" & to_hstring( ram_acc( i ) ) & " - " & to_hstring( body_mac_0( i ) ) & " - " & to_string( i );
              --exit;
            end if;
            
        end loop;
        
        report "----------------------------------------------------------------- MAC: test mac 0 finished";
        
        
        -- read next in block
        
        report "----------------------------------------------------------------- read new i block";
        
        body_block_i_1 := read_file( "body_I_1_1" );
        
        report "----------------------------------------------------------------- write new i block to fake sdram";
        
        for i in 0 to (2*BLOCK_SIZE)-1 loop
            ram_i_1( i ) <= body_block_i_1( i );
        end loop;
        
        wait for 60 ns;
        
        wait_until_idle;
        
        start; -- noch einmal aktivieren
        
        rwi;
        wait_until_idle;
        
        report "----------------------------------------------------------------- sollte fertig sein.";
        
        
        -- es gibt zur zeit keine moeglichkeit den mac buffer, also die chunks zu loeschen.
        -- das wird dann in sw gemacht.
        
        
        
        ---------------------------
        -- chunk inc test
        ---------------------------
        
        -- check if values are present.
        
--         for i in 0 to CHUNK_SIZE-1 loop
--             
--             test_compare := std_logic_vector( to_unsigned( i, s_writedata'length ) );
--             
--             if ram_acc( i ) /= test_compare then
--                 
--                 report "############################" & to_hstring( ram_acc(i) ) & " - " & to_hstring( test_compare ) & " - " & to_string( i );
--                 exit;
--                 
--             end if;
--             
--         end loop;
--         
--         report "----------------------------------------------------------------- TEST: chunk values correct";
--         
--         test_chunk_inc;
--         rwi;
--         
--         wait for 60 ns;
--         
--         wait_until_idle;
--         
--         -- check result
--         
--         --for i in 0 to CHUNK_SIZE-1 loop
--         for i in 0 to 16384-1 loop
--             
--             test_compare := std_logic_vector( to_unsigned( i+1, test_compare'length ) );
--             
--             if ram_acc( i ) /= test_compare then
--               
--               report "############################" & to_hstring( ram_acc( i ) ) & " - " & to_hstring( test_compare ) & " - " & to_string( i );
--               --exit;
--               
--             end if;
--         end loop;
--         
--         report "----------------------------------------------------------------- TEST: chunk inc test passed";
        
        
        
        
        
        
        
        -- ALT
        
        
        
        
        
        
        
        
        
        
        
        
        
--         ---------------------------
--         -- start left channel
--         ---------------------------
--         
--         wait for 40 ns;
--         
--         select_left_channel;
--         rwi;
--         
--         start;
--         rwi;
--         
--         wait_until_idle;
--         
--         report "----------------------------------------------------------------- first run finished";
--         
--         ---------------------------
--         -- check r
--         ---------------------------
--         
--         output_mode_r;
--         rwi;
--         
--         s_read <= '1';
--         s_address <= "0000000000000000";
--         wait for 40 ns;
--         
--         rri;
--         
--         wait_for_read;
--         
--         if s_readdata = x"1ccd1694" then
--           report "----------------------------------------------------------------- TEST: R test passed";
--         else
--           report "################################################################# TEST: R test failed";
--         end if;
--         
--         wait for 40 ns;
--         
--         ---------------------------
--         -- check i
--         ---------------------------
--         
--         output_mode_i;
--         rwi;
--         
--         s_read <= '1';
--         s_address <= "0000000000000000";
--         wait for 40 ns;
--         
--         rri;
--         
--         wait_for_read;
--         
--         if s_readdata = x"44a17237" then
--           report "----------------------------------------------------------------- TEST: I test passed";
--         else
--           report "################################################################# TEST: I test failed";
--         end if;
--         
--         wait for 40 ns;
--         
--         
--         
--         
--         ---------------------------
--         -- check result
--         ---------------------------
--         
--         report "----------------------------------------------------------------- test mac_0";
--         
--         body_mac_0 := read_file( "body_mac_0" );
--         
--         for i in 0 to (2*BLOCK_SIZE)-1 loop
--             if ram_acc( i ) = body_mac_0( i ) then
--             
--             else
--               report "############################" & to_hstring( ram_acc( i ) ) & " - " & to_hstring( body_mac_0( i ) ) & " - " & to_string( i );
--               exit;
--             end if;
--         end loop;
--         
--         report "----------------------------------------------------------------- test mac 0 finished";
--         
--         --~ report to_hstring( ram_acc( 0 ) ) & " - " & to_hstring( body_mac_0( 0 ) );
--         
--         -- read next in block
--         
--         report "----------------------------------------------------------------- read new i block";
--         
--         body_block_i_1 := read_file( "body_I_1_1" );
--         
--         report "----------------------------------------------------------------- write new i block to fake sdram";
--         
--         for i in 0 to (2*BLOCK_SIZE)-1 loop
--             ram_i_1( i ) <= body_block_i_1( i );
--         end loop;
--         
--         wait for 60 ns;
--         
--         wait_until_idle;
--         
--         start; -- noch einmal aktivieren
--         
--         wait for 4 ms; -- warten bis es fertig wird
--         wait until busy = '0';
--         
--         report "----------------------------------------------------------------- sollte fertig sein.";
        
        wait;
    end process;
    
end tb;
