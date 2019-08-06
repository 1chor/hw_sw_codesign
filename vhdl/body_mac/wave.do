onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mac_sdram/dut/clk
add wave -noupdate /tb_mac_sdram/dut/res_n
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/pre_pipeline
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/post_pipeline
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/i_chunk
add wave -noupdate -radix unsigned /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/i_block
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/chunk_pointer
add wave -noupdate -divider fake_sdram
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/proc/addr_base_aligned
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/proc/addr_word_aligned
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/proc/addr_word_aligned_int
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/proc/addr_used
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/proc/index_used
add wave -noupdate -divider s
add wave -noupdate -radix decimal /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_address
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_read
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_readdata
add wave -noupdate /tb_mac_sdram/stimuli/state_read_out
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_readdatavalid
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_waitrequest
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_write
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/s_writedata
add wave -noupdate /tb_mac_sdram/dut/fake_sdram_i/body_block_h_1_0
add wave -noupdate -divider m
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_address
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_read
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_readdata
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_readdatavalid
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_response
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_waitrequest
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_write
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_writedata
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/m_writeresponsevalid
add wave -noupdate -divider mac
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/read_state
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/base_addr
add wave -noupdate -radix unsigned /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/base
add wave -noupdate -divider debug
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/base_addr
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/base
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/debug_s_write
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/debug_state_is_idle
add wave -noupdate /tb_mac_sdram/dut/mac_sdram_control_interface_i/proc/debug_s_write_im_if
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {102244204 ns} 0} {{Cursor 3} {6942021 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 459
configure wave -valuecolwidth 128
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {6917921 ns} {7020173 ns}
