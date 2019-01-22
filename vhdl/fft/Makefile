

#supress the shared variable warning
VCOM_ARGS=-check_synthesis -2008 -work work -suppress 1236

#additional source files can be added here (compilation order is important!)
VHDL_FILES = \
	../fft/src/fft_header/fft_header/simulation/fft_header.sip\
	../fft/src/fft_header/fft_header/simulation/fft_header.vhd\
	../fft/src/fft_wrapper/fft_wrapper_header.vhd

#list of source files needed for simulation
TB_FILES = \
	../tb/tb_util_pkg.vhd\
	../fft/tb/fft_tb.vhd

#testbench file to "execute" and simulation time
TB = fft_tb
SIM_TIME = 15000ns

compile: 
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'


#this target starts the simulation and the modelsim GUI
sim:
	# ----------------------------------------
	# create compilation libraries
	mkdir -p ./libraries/work/
	mkdir -p ./libraries/fft_ii_0/
	mkdir -p ./libraries/altera_ver/
	mkdir -p ./libraries/lpm_ver/
	mkdir -p ./libraries/sgate_ver/
	mkdir -p ./libraries/altera_mf_ver/
	mkdir -p ./libraries/altera_lnsim_ver/
	mkdir -p ./libraries/cycloneive_ver/
	mkdir -p ./libraries/altera/
	mkdir -p ./libraries/lpm/
	mkdir -p ./libraries/sgate/
	mkdir -p ./libraries/altera_mf/
	mkdir -p ./libraries/altera_lnsim/
	mkdir -p ./libraries/cycloneive/
	
	# ----------------------------------------
	# copy RAM/ROM files to simulation directory
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_3n512sin.hex ./
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_1n512cos.hex ./
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_1n512sin.hex ./
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_2n512cos.hex ./
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_2n512sin.hex ./
	cp -f /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0_3n512cos.hex ./
	
	# ----------------------------------------
	# compile device library files
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_primitives.v"              -work altera_ver      
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/220model.v"                       -work lpm_ver         
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/sgate.v"                          -work sgate_ver       
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_mf.v"                      -work altera_mf_ver   
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_lnsim.sv"                  -work altera_lnsim_ver
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/cycloneive_atoms.v"               -work cycloneive_ver  
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_syn_attributes.vhd"        -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_standard_functions.vhd"    -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/alt_dspbuilder_package.vhd"       -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_europa_support_lib.vhd"    -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_primitives_components.vhd" -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_primitives.vhd"            -work altera          
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/220pack.vhd"                      -work lpm             
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/220model.vhd"                     -work lpm             
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/sgate_pack.vhd"                   -work sgate           
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/sgate.vhd"                        -work sgate           
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_mf_components.vhd"         -work altera_mf       
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_mf.vhd"                    -work altera_mf       
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_lnsim.sv"                  -work altera_lnsim    
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/altera_lnsim_components.vhd"      -work altera_lnsim    
	"/opt/quartus_18.1-18.1.0.625/quartus/eda/sim_lib/cycloneive_atoms.vhd"             -work cycloneive      
		
	# ----------------------------------------
	# compile design files in correct order
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_text_pkg.vhd"                               -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_math_pkg.vhd"                               -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_lib_pkg.vhd"                                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/auk_dspip_avalon_streaming_block_sink.vhd"   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/auk_dspip_avalon_streaming_block_source.vhd" -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_roundsat.vhd"                               -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_avalon_streaming_sink.vhd"                  -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_avalon_streaming_source.vhd"                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/auk_dspip_avalon_streaming_controller.vhd"            -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/altera_fft_mult_add.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/altera_fft_dual_port_ram.vhd"                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/altera_fft_dual_port_rom.vhd"                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/altera_fft_single_port_rom.vhd"              -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/auk_fft_pkg.vhd"                             -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/hyper_pipeline_interface.v"                  -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/counter_module.sv"                           -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/fft_pack.vhd"                                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_qe_so_bb.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lpp.vhd"                             -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_in_write_sgl.vhd"                    -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/apn_fft_mult_cpx.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_6tdp_rom.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dft_bfp_sgl.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cxb_data.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cxb_data_r.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_wrswgen.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lcm_mult_2m.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/apn_fft_cmult_cpx.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_se_so_bb.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_unbburst_ctrl_qe.vhd"                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lpprdadr2gen.vhd"                    -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_4dp_ram.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_unbburst_ctrl_de.vhd"                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lpprdadgen.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dpi_mram.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_3pi_mram.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cnt_ctrl.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_tdl.vhd"                             -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_3tdp_rom.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cxb_data_mram.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_1dp_ram.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_data_ram.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lpp_serial.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_3dp_rom.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_bfp_i_1pt.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dp_mram.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cmult_std.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_burst_ctrl_qe.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_bfp_o.vhd"                           -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_mult_add.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twadgen_dual.vhd"                    -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dualstream.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dataadgen.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_de_so_bb.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_tdl_bit_rst.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_unbburst_sose_ctrl.vhd"              -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_data_ram_dp.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_1tdp_rom.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_burst_ctrl_de.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/apn_fft_cmult_cpx2.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lpp_serial_r2.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_bfp_i.vhd"                           -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_sglstream.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_wrengen.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cmult_can.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_de_so_b.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_lcm_mult.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twadgen.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_bfp_ctrl.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_dft_bfp.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cxb_addr.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_pround.vhd"                          -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_tdl_bit.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_burst_ctrl.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_tdl_rst.vhd"                         -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_unbburst_ctrl.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twiddle_ctrl_qe.vhd"                 -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/apn_fft_mult_can.vhd"                        -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_m_k_counter.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twid_rom_tdp.vhd"                    -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_sose_so_b.vhd"                    -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_qe_so_b.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twadsogen_q.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_cnt_ctrl_de.vhd"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_twadsogen.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_si_se_so_b.vhd"                      -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_alt_shift_tdl.vhd"                   -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/asj_fft_bfp_o_1pt.vhd"                       -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/twid_rom.vhd"                                -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/synopsys/apn_fft_mult_cpx_1825.v"                     -work fft_ii_0
	"/homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation/submodules/fft_header_fft_ii_0.sv"                               -work fft_ii_0
		
	vsim -do "vsim $(TB) -msgmode both; do scripts/wave.do;run $(SIM_TIME); wave zoom full"

#this target starts a simulation in text mode (i.e. no graphical output)
sim_cl:
	vsim -c -do "vsim $(TB); run $(SIM_TIME);quit"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
