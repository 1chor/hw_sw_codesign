

#supress the shared variable warning
VCOM_ARGS=-check_synthesis -2008 -work work -suppress 1236

#additional source files can be added here (compilation order is important!)
VHDL_FILES = \
	../math/src/math_pkg.vhd\
	../ram/ram_pkg.vhd\
	../ram/dp_ram_1c1r1w.vhd\
	../mac/mac.vhd\
	../fir/src/fir.vhd

#list of source files needed for simulation
TB_FILES = \
	../tb/tb_util_pkg.vhd\
	../fir/tb/fir_tb.vhd

#testbench file to "execute" and simulation time
TB = fir_tb
SIM_TIME = 8500ns

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
	vsim -do "vsim $(TB) -msgmode both; do scripts/wave.do;run $(SIM_TIME); wave zoom full"

#this target starts a simulation in text mode (i.e. no graphical output)
sim_cl:
	vsim -c -do "vsim $(TB); run $(SIM_TIME);quit"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
