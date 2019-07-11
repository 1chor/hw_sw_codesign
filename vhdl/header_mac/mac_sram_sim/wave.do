onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mac_sram/clk
add wave -noupdate /tb_mac_sram/res_n
add wave -noupdate /tb_mac_sram/s_address
add wave -noupdate /tb_mac_sram/s_write
add wave -noupdate /tb_mac_sram/s_read
add wave -noupdate /tb_mac_sram/s_writedata
add wave -noupdate /tb_mac_sram/s_readdata
add wave -noupdate /tb_mac_sram/s_readdatavalid
add wave -noupdate /tb_mac_sram/s_waitrequest
add wave -noupdate /tb_mac_sram/dut/clk
add wave -noupdate /tb_mac_sram/dut/res_n
add wave -noupdate /tb_mac_sram/dut/s_address
add wave -noupdate /tb_mac_sram/dut/s_write
add wave -noupdate /tb_mac_sram/dut/s_read
add wave -noupdate /tb_mac_sram/dut/s_writedata
add wave -noupdate /tb_mac_sram/dut/s_readdata
add wave -noupdate /tb_mac_sram/dut/s_readdatavalid
add wave -noupdate /tb_mac_sram/dut/s_waitrequest
add wave -noupdate /tb_mac_sram/dut/m_address
add wave -noupdate /tb_mac_sram/dut/m_write
add wave -noupdate /tb_mac_sram/dut/m_read
add wave -noupdate /tb_mac_sram/dut/m_writedata
add wave -noupdate /tb_mac_sram/dut/m_readdata
add wave -noupdate /tb_mac_sram/dut/m_waitrequest
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/clk
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/res_n
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_address
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_write
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_read
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_writedata
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_readdata
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_waitrequest
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/ram_acc_r/ram_block
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/a
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/c
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/d
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/b
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/a_mul_c
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/b_mul_c
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/b_mul_d
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/a_mul_d
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/new_r
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/new_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {38920 ns} 0}
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
WaveRestoreZoom {0 ns} {8105504 ns}
