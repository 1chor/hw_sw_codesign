onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Header Mac}
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/clk
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/res_n
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_address
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_write
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_read
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_writedata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_readdata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_readdatavalid
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_address
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_write
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_read
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_writedata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_readdata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_waitrequest
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/LEDG
add wave -noupdate -divider Testbench
add wave -noupdate /tb_mac_sram/clk
add wave -noupdate /tb_mac_sram/res_n
add wave -noupdate /tb_mac_sram/s_address
add wave -noupdate /tb_mac_sram/s_write
add wave -noupdate /tb_mac_sram/s_read
add wave -noupdate /tb_mac_sram/s_writedata
add wave -noupdate /tb_mac_sram/s_readdata
add wave -noupdate /tb_mac_sram/s_readdatavalid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
configure wave -valuecolwidth 177
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
WaveRestoreZoom {0 ns} {798110 ns}
