

#supress the shared variable warning
VCOM_ARGS=-check_synthesis -2008 -work libraries/work -suppress 1236

#additional source files can be added here (compilation order is important!)
VHDL_FILES = \
	./src/fft_wrapper/fft_wrapper_header.vhd

#list of source files needed for simulation
TB_FILES = \
	../tb/tb_util_pkg.vhd\
	./tb/fft_tb.vhd

#testbench file to "execute" and simulation time
TB = fft_tb
SIM_TIME = 33000ns
PATH_TO_QUARTUS = /opt/quartus_18.1-18.1.0.625/quartus
QSYS_SIMDIR = /homes/h01325347/TILAB/maintask/vhdl/fft/src/fft_header/fft_header/simulation

compile: 
	rm -f log
	
	# Copy hex files
	cp -f src/fft_header/fft_header/simulation/mentor/*.hex .
		
	# Create compilation libraries
	vlib libraries/;
	vlib libraries/work/;
	vmap work libraries/work/;
	vmap work_lib libraries/work/;
	vlib libraries/altera_ver/;
	vmap altera_ver libraries/altera_ver/
	vlib libraries/lpm_ver/;
	vmap lpm_ver libraries/lpm_ver/;
	vlib libraries/sgate_ver/;
	vmap sgate_ver libraries/sgate_ver/; 
	vlib libraries/altera_mf_ver/;
	vmap altera_mf_ver libraries/altera_mf_ver/;
	vlib libraries/altera_lnsim_ver/;
	vmap altera_lnsim_ver libraries/altera_lnsim_ver/;
	vlib libraries/cycloneive_ver/; 
	vmap cycloneive_ver libraries/cycloneive_ver/; 
	vlib libraries/altera/; 
	vmap altera libraries/altera/; 
	vlib libraries/lpm/; 
	vmap lpm libraries/lpm/; 
	vlib libraries/sgate/; 
	vmap sgate libraries/sgate/; 
	vlib libraries/altera_mf/; 
	vmap altera_mf libraries/altera_mf/; 
	vlib libraries/altera_lnsim/;
	vmap altera_lnsim libraries/altera_lnsim/; 
	vlib libraries/cycloneive/; 
	vmap cycloneive libraries/cycloneive/; 
	vlib libraries/fft_ii_0/;
	vmap fft_ii_0 libraries/fft_ii_0/;

	# Compile device library files
	vlog -work libraries/altera_ver $(PATH_TO_QUARTUS)/eda/sim_lib/altera_primitives.v
	vlog -work libraries/lpm_ver $(PATH_TO_QUARTUS)/eda/sim_lib/220model.v             
	vlog -work libraries/sgate_ver $(PATH_TO_QUARTUS)/eda/sim_lib/sgate.v            
	vlog -work libraries/altera_mf_ver $(PATH_TO_QUARTUS)/eda/sim_lib/altera_mf.v        
	vlog -sv -work libraries/altera_lnsim_ver $(PATH_TO_QUARTUS)/eda/sim_lib/altera_lnsim.sv     
	vlog -work libraries/cyclonev_ver $(PATH_TO_QUARTUS)/eda/sim_lib/mentor/cyclonev_atoms_ncrypt.v         
	vlog -work libraries/cyclonev_ver $(PATH_TO_QUARTUS)/eda/sim_lib/mentor/cyclonev_hmi_atoms_ncrypt.v        
	vlog -work libraries/cyclonev_ver $(PATH_TO_QUARTUS)/eda/sim_lib/cyclonev_atoms.v         
	vlog -work libraries/cyclonev_hssi_ver $(PATH_TO_QUARTUS)/eda/sim_lib/mentor/cyclonev_hssi_atoms_ncrypt.v    
	vlog -work libraries/cyclonev_hssi_ver $(PATH_TO_QUARTUS)/eda/sim_lib/cyclonev_hssi_atoms.v    
	vlog -work libraries/cyclonev_pcie_hip_ver $(PATH_TO_QUARTUS)/eda/sim_lib/mentor/cyclonev_pcie_hip_atoms_ncrypt.v
	vlog -work libraries/cyclonev_pcie_hip_ver $(PATH_TO_QUARTUS)/eda/sim_lib/cyclonev_pcie_hip_atoms.v
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/altera_syn_attributes.vhd               
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/altera_standard_functions.vhd              
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/alt_dspbuilder_package.vhd               
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/altera_europa_support_lib.vhd               
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/altera_primitives_components.vhd               
	vcom -work libraries/altera $(PATH_TO_QUARTUS)/eda/sim_lib/altera_primitives.vhd               
	vcom  -work libraries/lpm $(PATH_TO_QUARTUS)/eda/sim_lib/220pack.vhd                  
	vcom -work libraries/lpm $(PATH_TO_QUARTUS)/eda/sim_lib/220model.vhd                  
	vcom -work libraries/sgate $(PATH_TO_QUARTUS)/eda/sim_lib/sgate_pack.vhd                
	vcom -work libraries/sgate $(PATH_TO_QUARTUS)/eda/sim_lib/sgate.vhd                
	vcom -work libraries/altera_mf $(PATH_TO_QUARTUS)/eda/sim_lib/altera_mf_components.vhd           
	vcom -work libraries/altera_mf $(PATH_TO_QUARTUS)/eda/sim_lib/altera_mf.vhd            
	vlog -sv -work libraries/altera_lnsim $(PATH_TO_QUARTUS)/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv         
	vcom -work libraries/altera_lnsim $(PATH_TO_QUARTUS)/eda/sim_lib/altera_lnsim_components.vhd         
	vcom -work libraries/cyclonev $(PATH_TO_QUARTUS)/eda/sim_lib/cyclonev_atoms.vhd             
	vcom -work libraries/cyclonev $(PATH_TO_QUARTUS)/eda/sim_lib/cyclonev_components.vhd 
	
	# Compile the design files in correct order
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_text_pkg.vhd                             
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_math_pkg.vhd                            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_lib_pkg.vhd                          
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/auk_dspip_avalon_streaming_block_sink.vhd   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/auk_dspip_avalon_streaming_block_source.vhd 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_roundsat.vhd                         
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_avalon_streaming_sink.vhd            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_avalon_streaming_source.vhd          
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/auk_dspip_avalon_streaming_controller.vhd      
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/altera_fft_mult_add.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/altera_fft_dual_port_ram.vhd            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/altera_fft_dual_port_rom.vhd            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/altera_fft_single_port_rom.vhd          
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/auk_fft_pkg.vhd                         
	vlog -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/hyper_pipeline_interface.v              
	vlog -sv -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/counter_module.sv                       
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/fft_pack.vhd                            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_qe_so_bb.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lpp.vhd                         
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_in_write_sgl.vhd                
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/apn_fft_mult_cpx.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_6tdp_rom.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dft_bfp_sgl.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cxb_data.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cxb_data_r.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_wrswgen.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lcm_mult_2m.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/apn_fft_cmult_cpx.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_se_so_bb.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_unbburst_ctrl_qe.vhd            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lpprdadr2gen.vhd                
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_4dp_ram.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_unbburst_ctrl_de.vhd            
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lpprdadgen.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dpi_mram.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_3pi_mram.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cnt_ctrl.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_tdl.vhd                         
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_3tdp_rom.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cxb_data_mram.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_1dp_ram.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_data_ram.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lpp_serial.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_3dp_rom.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_bfp_i_1pt.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dp_mram.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cmult_std.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_burst_ctrl_qe.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_bfp_o.vhd                       
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_mult_add.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twadgen_dual.vhd                
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dualstream.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dataadgen.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_de_so_bb.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_tdl_bit_rst.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_unbburst_sose_ctrl.vhd          
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_data_ram_dp.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_1tdp_rom.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_burst_ctrl_de.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/apn_fft_cmult_cpx2.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lpp_serial_r2.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_bfp_i.vhd                       
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_sglstream.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_wrengen.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cmult_can.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_de_so_b.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_lcm_mult.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twadgen.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_bfp_ctrl.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_dft_bfp.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cxb_addr.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_pround.vhd                      
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_tdl_bit.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_burst_ctrl.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_tdl_rst.vhd                     
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_unbburst_ctrl.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twiddle_ctrl_qe.vhd             
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/apn_fft_mult_can.vhd                    
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_m_k_counter.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twid_rom_tdp.vhd                
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_sose_so_b.vhd                
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_qe_so_b.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twadsogen_q.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_cnt_ctrl_de.vhd                 
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_twadsogen.vhd                   
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_si_se_so_b.vhd                  
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_alt_shift_tdl.vhd               
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/asj_fft_bfp_o_1pt.vhd                      
	vcom -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/twid_rom.vhd                              
	vlog -work fft_ii_0 $(QSYS_SIMDIR)/submodules/mentor/apn_fft_mult_cpx_1825.v
	vlog -sv -work fft_ii_0 $(QSYS_SIMDIR)/submodules/fft_header_fft_ii_0.sv
	vcom $(QSYS_SIMDIR)/fft_header.vhd                                               
	 
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "-- Error and Warning Summary --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'


#this target starts the simulation and the modelsim GUI
sim:	
	vsim -t ps -L work -L work_lib -L fft_ii_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive $(TB) -do "vsim -msgmode both; do scripts/wave.do;run $(SIM_TIME); wave zoom full"

#this target starts the simulation with all signals and the modelsim GUI
sim_all:	
	vsim -t ps -L work -L work_lib -L fft_ii_0 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive $(TB) -do "vsim -msgmode both; do scripts/wave_all.do;run $(SIM_TIME); wave zoom full"

#this target starts a simulation in text mode (i.e. no graphical output)
sim_cl:
	vsim -c -do "vsim $(TB); run $(SIM_TIME);quit"

clean:
	rm -f -r libraries
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
