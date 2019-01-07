onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fir_tb/clk
add wave -noupdate /fir_tb/res_n
add wave -noupdate -divider {Streaming IN}
add wave -noupdate -radix hexadecimal /fir_tb/stin_data
add wave -noupdate /fir_tb/stin_valid
add wave -noupdate /fir_tb/stin_ready
add wave -noupdate -divider {Streaming OUT}
add wave -noupdate -radix hexadecimal /fir_tb/stout_data
add wave -noupdate /fir_tb/stout_valid
add wave -noupdate /fir_tb/stout_ready
add wave -noupdate -divider {Avalon MM}
add wave -noupdate /fir_tb/mm_address
add wave -noupdate /fir_tb/mm_write
#add wave -noupdate /fir_tb/mm_read
add wave -noupdate /fir_tb/mm_writedata
add wave -noupdate /fir_tb/mm_readdata
add wave -noupdate -divider other
add wave -noupdate /fir_tb/NUM_COEFFICIENTS
add wave -noupdate /fir_tb/DATA_WIDTH
add wave -noupdate /fir_tb/ADDR_WIDTH
add wave -noupdate /fir_tb/CLK_PERIOD
add wave -noupdate /fir_tb/stop_clock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {120612 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 115
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2825560 ps} {3009182 ps}
