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
-- This is a Bus Functional Model (BFM) VHDL package for a Standard Conduit Master.
-- This package provides the API that will be used to get the value of the sampled
-- input/bidirection port or set the value to be driven to the output ports.
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









package altera_conduit_bfm_vhdl_pkg is

   -- output signal register
   type altera_conduit_bfm_out_trans_t is record
      sig_inverse_out        : std_logic_vector(0 downto 0);
      sig_sink_eop_out       : std_logic_vector(0 downto 0);
      sig_sink_error_out     : std_logic_vector(1 downto 0);
      sig_sink_imag_out      : std_logic_vector(15 downto 0);
      sig_sink_real_out      : std_logic_vector(15 downto 0);
      sig_sink_sop_out       : std_logic_vector(0 downto 0);
      sig_sink_valid_out     : std_logic_vector(0 downto 0);
   end record;
   
   shared variable out_trans        : altera_conduit_bfm_out_trans_t;

   -- input signal register
   signal reset_in               : std_logic;
   signal sig_sink_ready_in      : std_logic_vector(0 downto 0);

   -- VHDL Procedure API
   
   -- set inverse value
   procedure set_inverse                (signal_value : in std_logic_vector(0 downto 0));
   
   -- set sink_eop value
   procedure set_sink_eop               (signal_value : in std_logic_vector(0 downto 0));
   
   -- set sink_error value
   procedure set_sink_error             (signal_value : in std_logic_vector(1 downto 0));
   
   -- set sink_imag value
   procedure set_sink_imag              (signal_value : in std_logic_vector(15 downto 0));
   
   -- get sink_ready value
   procedure get_sink_ready             (signal_value : out std_logic_vector(0 downto 0));
   
   -- set sink_real value
   procedure set_sink_real              (signal_value : in std_logic_vector(15 downto 0));
   
   -- set sink_sop value
   procedure set_sink_sop               (signal_value : in std_logic_vector(0 downto 0));
   
   -- set sink_valid value
   procedure set_sink_valid             (signal_value : in std_logic_vector(0 downto 0));
   
   -- VHDL Event API
   procedure event_reset_asserted;

   procedure event_sink_ready_change;   

end altera_conduit_bfm_vhdl_pkg;

package body altera_conduit_bfm_vhdl_pkg is
   
   procedure set_inverse                (signal_value : in std_logic_vector(0 downto 0)) is
   begin
      
      out_trans.sig_inverse_out := signal_value;
      
   end procedure set_inverse;
   
   procedure set_sink_eop               (signal_value : in std_logic_vector(0 downto 0)) is
   begin
      
      out_trans.sig_sink_eop_out := signal_value;
      
   end procedure set_sink_eop;
   
   procedure set_sink_error             (signal_value : in std_logic_vector(1 downto 0)) is
   begin
      
      out_trans.sig_sink_error_out := signal_value;
      
   end procedure set_sink_error;
   
   procedure set_sink_imag              (signal_value : in std_logic_vector(15 downto 0)) is
   begin
      
      out_trans.sig_sink_imag_out := signal_value;
      
   end procedure set_sink_imag;
   
   procedure get_sink_ready             (signal_value : out std_logic_vector(0 downto 0)) is
   begin

      signal_value := sig_sink_ready_in;
   
   end procedure get_sink_ready;
   
   procedure set_sink_real              (signal_value : in std_logic_vector(15 downto 0)) is
   begin
      
      out_trans.sig_sink_real_out := signal_value;
      
   end procedure set_sink_real;
   
   procedure set_sink_sop               (signal_value : in std_logic_vector(0 downto 0)) is
   begin
      
      out_trans.sig_sink_sop_out := signal_value;
      
   end procedure set_sink_sop;
   
   procedure set_sink_valid             (signal_value : in std_logic_vector(0 downto 0)) is
   begin
      
      out_trans.sig_sink_valid_out := signal_value;
      
   end procedure set_sink_valid;
   
   procedure event_reset_asserted is
   begin
   
      wait until (reset_in'event and reset_in = '1');
      
   end event_reset_asserted;
   procedure event_sink_ready_change is
   begin

      wait until (sig_sink_ready_in'event);

   end event_sink_ready_change;

end altera_conduit_bfm_vhdl_pkg;

