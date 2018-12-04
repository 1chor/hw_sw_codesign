# TCL File Generated by Component Editor 18.1
# Wed Oct 24 14:38:56 CEST 2018
# DO NOT MODIFY


# 
# textmode_controller "Textmode Controller" v1.0
#  2018.10.24.14:38:56
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module textmode_controller
# 
set_module_property DESCRIPTION ""
set_module_property NAME textmode_controller
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Textmode Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL textmode_controller_avalon
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file math_pkg.vhd VHDL PATH ../vhdl/math/src/math_pkg.vhd
add_fileset_file sync.vhd VHDL PATH ../vhdl/synchronizer/sync.vhd
add_fileset_file sync_pkg.vhd VHDL PATH ../vhdl/synchronizer/sync_pkg.vhd
add_fileset_file cursor_controller.vhd VHDL PATH ../vhdl/textmode_controller/cursor_controller.vhd
add_fileset_file cursor_controller_pkg.vhd VHDL PATH ../vhdl/textmode_controller/cursor_controller_pkg.vhd
add_fileset_file font_pkg.vhd VHDL PATH ../vhdl/textmode_controller/font_pkg.vhd
add_fileset_file font_rom.vhd VHDL PATH ../vhdl/textmode_controller/font_rom.vhd
add_fileset_file font_rom_beh.vhd VHDL PATH ../vhdl/textmode_controller/font_rom_beh.vhd
add_fileset_file textmode_controller_1c.vhd VHDL PATH ../vhdl/textmode_controller/textmode_controller_1c.vhd
add_fileset_file textmode_controller_avalon.vhd VHDL PATH ../vhdl/textmode_controller/textmode_controller_avalon.vhd TOP_LEVEL_FILE
add_fileset_file textmode_controller_fsm.vhd VHDL PATH ../vhdl/textmode_controller/textmode_controller_fsm.vhd
add_fileset_file textmode_controller_pkg.vhd VHDL PATH ../vhdl/textmode_controller/textmode_controller_pkg.vhd
add_fileset_file video_ram.vhd VHDL PATH ../vhdl/textmode_controller/video_ram.vhd
add_fileset_file video_ram_pkg.vhd VHDL PATH ../vhdl/textmode_controller/video_ram_pkg.vhd
add_fileset_file display_controller.vhd VHDL PATH ../vhdl/textmode_controller/ltm/display_controller.vhd
add_fileset_file display_controller_pkg.vhd VHDL PATH ../vhdl/textmode_controller/ltm/display_controller_pkg.vhd


# 
# parameters
# 
add_parameter ROW_COUNT INTEGER 30
set_parameter_property ROW_COUNT DEFAULT_VALUE 30
set_parameter_property ROW_COUNT DISPLAY_NAME ROW_COUNT
set_parameter_property ROW_COUNT TYPE INTEGER
set_parameter_property ROW_COUNT UNITS None
set_parameter_property ROW_COUNT ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ROW_COUNT HDL_PARAMETER true
add_parameter COLUMN_COUNT INTEGER 100
set_parameter_property COLUMN_COUNT DEFAULT_VALUE 100
set_parameter_property COLUMN_COUNT DISPLAY_NAME COLUMN_COUNT
set_parameter_property COLUMN_COUNT TYPE INTEGER
set_parameter_property COLUMN_COUNT UNITS None
set_parameter_property COLUMN_COUNT ALLOWED_RANGES -2147483648:2147483647
set_parameter_property COLUMN_COUNT HDL_PARAMETER true
add_parameter CLK_FREQ INTEGER 25000000
set_parameter_property CLK_FREQ DEFAULT_VALUE 25000000
set_parameter_property CLK_FREQ DISPLAY_NAME CLK_FREQ
set_parameter_property CLK_FREQ TYPE INTEGER
set_parameter_property CLK_FREQ UNITS None
set_parameter_property CLK_FREQ ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CLK_FREQ HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point avalon_slave
# 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset reset
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave maximumPendingWriteTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave address address Input 4
add_interface_port avalon_slave write_n write_n Input 1
add_interface_port avalon_slave writedata writedata Input 32
add_interface_port avalon_slave readdata readdata Output 32
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point conduits
# 
add_interface conduits conduit end
set_interface_property conduits associatedClock clock
set_interface_property conduits associatedReset ""
set_interface_property conduits ENABLED true
set_interface_property conduits EXPORT_OF ""
set_interface_property conduits PORT_NAME_MAP ""
set_interface_property conduits CMSIS_SVD_VARIABLES ""
set_interface_property conduits SVD_ADDRESS_GROUP ""

add_interface_port conduits b b Output 8
add_interface_port conduits den den Output 1
add_interface_port conduits g g Output 8
add_interface_port conduits hd hd Output 1
add_interface_port conduits r r Output 8
add_interface_port conduits vd vd Output 1
add_interface_port conduits grest grest Output 1


# 
# connection point interrupt
# 
add_interface interrupt interrupt end
set_interface_property interrupt associatedAddressablePoint ""
set_interface_property interrupt associatedClock clock
set_interface_property interrupt associatedReset reset
set_interface_property interrupt bridgedReceiverOffset ""
set_interface_property interrupt bridgesToReceiver ""
set_interface_property interrupt ENABLED true
set_interface_property interrupt EXPORT_OF ""
set_interface_property interrupt PORT_NAME_MAP ""
set_interface_property interrupt CMSIS_SVD_VARIABLES ""
set_interface_property interrupt SVD_ADDRESS_GROUP ""

add_interface_port interrupt irq irq Output 1

