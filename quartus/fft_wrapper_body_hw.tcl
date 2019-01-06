# TCL File Generated by Component Editor 18.1
# Sun Jan 06 16:12:28 CET 2019
# DO NOT MODIFY


# 
# fft_wrapper_body "fft_wrapper_body" v1.0
#  2019.01.06.16:12:28
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module fft_wrapper_body
# 
set_module_property DESCRIPTION ""
set_module_property NAME fft_wrapper_body
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME fft_wrapper_body
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL fft_wrapper_body
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file fft_wrapper_body.vhd VHDL PATH ../vhdl/fft/fft_wrapper/fft_wrapper_body.vhd TOP_LEVEL_FILE


# 
# parameters
# 


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
# connection point avalon_streaming_source
# 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock
set_interface_property avalon_streaming_source associatedReset reset
set_interface_property avalon_streaming_source dataBitsPerSymbol 8
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0
set_interface_property avalon_streaming_source ENABLED true
set_interface_property avalon_streaming_source EXPORT_OF ""
set_interface_property avalon_streaming_source PORT_NAME_MAP ""
set_interface_property avalon_streaming_source CMSIS_SVD_VARIABLES ""
set_interface_property avalon_streaming_source SVD_ADDRESS_GROUP ""

add_interface_port avalon_streaming_source stout_data data Output 32
add_interface_port avalon_streaming_source stout_empty empty Output 2
add_interface_port avalon_streaming_source stout_eop endofpacket Output 1
add_interface_port avalon_streaming_source stout_error error Output 2
add_interface_port avalon_streaming_source stout_ready ready Input 1
add_interface_port avalon_streaming_source stout_sop startofpacket Output 1
add_interface_port avalon_streaming_source stout_valid valid Output 1


# 
# connection point avalon_streaming_sink
# 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink associatedClock clock
set_interface_property avalon_streaming_sink associatedReset reset
set_interface_property avalon_streaming_sink dataBitsPerSymbol 8
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_sink maxChannel 0
set_interface_property avalon_streaming_sink readyLatency 0
set_interface_property avalon_streaming_sink ENABLED true
set_interface_property avalon_streaming_sink EXPORT_OF ""
set_interface_property avalon_streaming_sink PORT_NAME_MAP ""
set_interface_property avalon_streaming_sink CMSIS_SVD_VARIABLES ""
set_interface_property avalon_streaming_sink SVD_ADDRESS_GROUP ""

add_interface_port avalon_streaming_sink stin_data data Input 32
add_interface_port avalon_streaming_sink stin_valid valid Input 1
add_interface_port avalon_streaming_sink stin_ready ready Output 1
add_interface_port avalon_streaming_sink stin_sop startofpacket Input 1
add_interface_port avalon_streaming_sink stin_eop endofpacket Input 1
add_interface_port avalon_streaming_sink stin_empty empty Input 2
add_interface_port avalon_streaming_sink stin_error error Input 2


# 
# connection point external_connection
# 
add_interface external_connection conduit end
set_interface_property external_connection associatedClock ""
set_interface_property external_connection associatedReset ""
set_interface_property external_connection ENABLED true
set_interface_property external_connection EXPORT_OF ""
set_interface_property external_connection PORT_NAME_MAP ""
set_interface_property external_connection CMSIS_SVD_VARIABLES ""
set_interface_property external_connection SVD_ADDRESS_GROUP ""

add_interface_port external_connection inverse export Input 2

