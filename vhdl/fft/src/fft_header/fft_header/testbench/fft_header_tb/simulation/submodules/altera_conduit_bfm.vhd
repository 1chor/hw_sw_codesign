-- (C) 2001-2018 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


-- $Id: //acds/main/ip/sopc/components/verification/altera_tristate_conduit_bfm/altera_tristate_conduit_bfm.sv.terp#7 $
-- $Revision: #7 $
-- $Date: 2010/08/05 $
-- $Author: klong $
-------------------------------------------------------------------------------
-- =head1 NAME
-- altera_conduit_bfm
-- =head1 SYNOPSIS
-- Bus Functional Model (BFM) for a Standard Conduit BFM
-------------------------------------------------------------------------------
-- =head1 DESCRIPTION
-- This is a Bus Functional Model (BFM) for a Standard Conduit Master.
-- This BFM sampled the input/bidirection port value or driving user's value to 
-- output ports when user call the API.  
-- This BFM's HDL is been generated through terp file in Qsys/SOPC Builder.
-- Generation parameters:
-- output_name:                  altera_conduit_bfm
-- role:width:direction:         inverse:1:output,sink_eop:1:output,sink_error:2:output,sink_imag:16:output,sink_ready:1:input,sink_real:16:output,sink_sop:1:output,sink_valid:1:output
-- clocked                       1
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.altera_conduit_bfm_vhdl_pkg.all;

entity altera_conduit_bfm is
   port (
      clk              : in    std_logic;
      reset            : in    std_logic;
      sig_inverse      : out   std_logic_vector(0 downto 0);
      sig_sink_eop     : out   std_logic_vector(0 downto 0);
      sig_sink_error   : out   std_logic_vector(1 downto 0);
      sig_sink_imag    : out   std_logic_vector(15 downto 0);
      sig_sink_ready   : in    std_logic_vector(0 downto 0);
      sig_sink_real    : out   std_logic_vector(15 downto 0);
      sig_sink_sop     : out   std_logic_vector(0 downto 0);
      sig_sink_valid   : out   std_logic_vector(0 downto 0)
   );
end altera_conduit_bfm;

architecture altera_conduit_bfm_arch of altera_conduit_bfm is 

   begin

      process (clk) begin
      if (clk'event and clk = '1') then
         sig_inverse      <= out_trans.sig_inverse_out after 1 ps;
         sig_sink_eop     <= out_trans.sig_sink_eop_out after 1 ps;
         sig_sink_error   <= out_trans.sig_sink_error_out after 1 ps;
         sig_sink_imag    <= out_trans.sig_sink_imag_out after 1 ps;
         sig_sink_ready_in <= sig_sink_ready;
         sig_sink_real    <= out_trans.sig_sink_real_out after 1 ps;
         sig_sink_sop     <= out_trans.sig_sink_sop_out after 1 ps;
         sig_sink_valid   <= out_trans.sig_sink_valid_out after 1 ps;
         reset_in         <= reset;
      end if;
      end process;

end altera_conduit_bfm_arch;

