# TCL File Generated by Component Editor 18.1
# Sat Jan 05 15:27:46 CET 2019
# DO NOT MODIFY


# 
# fft_wrapper "fft_wrapper" v1.0
#  2019.01.05.15:27:46
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module fft_wrapper
# 
set_module_property DESCRIPTION ""
set_module_property NAME fft_wrapper
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME fft_wrapper
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL new_component
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file fft_wrapper.vhd VHDL PATH ../vhdl/fft/fft_wrapper/fft_wrapper.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 

