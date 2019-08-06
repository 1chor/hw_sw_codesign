

#supress the shared variable warning
VCOM_ARGS=-check_synthesis -2008 -work work -suppress 1236 -novopt

#additional source files can be added here (compilation order is important!)
VHDL_FILES = \
	fake_sdram.vhd\
	mac_sdram_control_interface.vhd\
	top.vhd

#list of source files needed for simulation
TB_FILES = \
	tb.vhd

#testbench file to "execute" and simulation time
TB = tb_mac_sdram
SIM_TIME = 1000ms

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
	vsim -do "vsim $(TB) -novopt -msgmode both; do wave.do;run $(SIM_TIME)" 

#this target starts a simulation in text mode (i.e. no graphical output)
sim_cl:
	vsim -c -do "vsim $(TB) -novopt; run $(SIM_TIME);quit"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
