onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_writedata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_write
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_waitrequest
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_readdatavalid
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_readdata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_read
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/s_address
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/res_n
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/output_state
add wave -noupdate -color Plum -radix decimal /tb_mac_sram/dut/mac_sram_i/new_r
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/new_i
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_writedata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_write
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_waitrequest
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/clk
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/fucking_start
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/fucking_reset
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/busy
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/resetting
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/pre_pipeline
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/post_pipeline
add wave -noupdate -color {Medium Slate Blue} -radix hexadecimal /tb_mac_sram/dut/mac_sram_i/a
add wave -noupdate -color {Medium Slate Blue} -radix decimal /tb_mac_sram/dut/mac_sram_i/c
add wave -noupdate -color {Medium Slate Blue} -radix hexadecimal /tb_mac_sram/dut/mac_sram_i/d
add wave -noupdate -color {Medium Slate Blue} -radix hexadecimal /tb_mac_sram/dut/mac_sram_i/b
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/clk
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_address
add wave -noupdate /tb_mac_sram/dut/fake_sram_i/s_readdata
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/a_mul_d
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/a_mul_c
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/b_mul_d
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/b_mul_c
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/acc_r_array
add wave -noupdate -color {Medium Slate Blue} -radix decimal /tb_mac_sram/dut/mac_sram_i/acc_r_array(0)
add wave -noupdate -color {Dark Orchid} /tb_mac_sram/dut/mac_sram_i/fake_output_array(0)
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/acc_i_array
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/result_test
add wave -noupdate /tb_mac_sram/s_readdata
add wave -noupdate /tb_mac_sram/s_address
add wave -noupdate -divider pointer
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/mms/channel
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/mms/latest_in_block_1
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/mms/latest_in_block_2
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/mms/latest_in_block_tmp
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/ir_pointer
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/in_pointer
add wave -noupdate -divider variables
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/trigger
add wave -noupdate -radix unsigned /tb_mac_sram/dut/mac_sram_i/proc/i
add wave -noupdate -radix unsigned /tb_mac_sram/dut/mac_sram_i/proc/i_prev
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/acc_r_temp
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/acc_i_temp
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/ir_addr
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/in_addr
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/mode
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/proc/state
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_read
add wave -noupdate -radix decimal /tb_mac_sram/dut/mac_sram_i/m_address
add wave -noupdate /tb_mac_sram/dut/mac_sram_i/m_readdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1862839 ns} 0}
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
WaveRestoreZoom {0 ns} {8882231 ns}
