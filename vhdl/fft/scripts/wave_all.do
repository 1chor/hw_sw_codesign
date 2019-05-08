onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench}
add wave -noupdate /fft_tb/clk
add wave -noupdate /fft_tb/res_n
add wave -noupdate /fft_tb/stin_data
add wave -noupdate /fft_tb/stin_valid
add wave -noupdate /fft_tb/stin_ready
add wave -noupdate /fft_tb/stout_data
add wave -noupdate /fft_tb/stout_valid
add wave -noupdate /fft_tb/stout_ready
add wave -noupdate /fft_tb/inverse
add wave -noupdate -divider {Wrapper}
add wave -noupdate /fft_tb/uut/stin_data
add wave -noupdate /fft_tb/uut/stout_data
add wave -noupdate /fft_tb/uut/inverse
add wave -noupdate /fft_tb/uut/si_valid
add wave -noupdate /fft_tb/uut/si_valid_next
add wave -noupdate /fft_tb/uut/si_ready
add wave -noupdate /fft_tb/uut/si_error
add wave -noupdate /fft_tb/uut/si_sop
add wave -noupdate /fft_tb/uut/si_sop_next
add wave -noupdate /fft_tb/uut/si_eop
add wave -noupdate /fft_tb/uut/si_eop_next
add wave -noupdate /fft_tb/uut/si_real
add wave -noupdate /fft_tb/uut/si_imag
add wave -noupdate /fft_tb/uut/src_valid
add wave -noupdate /fft_tb/uut/src_ready
add wave -noupdate /fft_tb/uut/src_error
add wave -noupdate /fft_tb/uut/src_sop
add wave -noupdate /fft_tb/uut/src_eop
add wave -noupdate /fft_tb/uut/src_real
add wave -noupdate /fft_tb/uut/src_imag
add wave -noupdate /fft_tb/uut/src_exp
add wave -noupdate /fft_tb/uut/temp_in
add wave -noupdate /fft_tb/uut/temp_in_next
add wave -noupdate /fft_tb/uut/temp_out
add wave -noupdate /fft_tb/uut/temp_out_next
add wave -noupdate /fft_tb/uut/index
add wave -noupdate /fft_tb/uut/receive_index
add wave -noupdate /fft_tb/uut/receive_index_next
add wave -noupdate /fft_tb/uut/state
add wave -noupdate /fft_tb/uut/state_next
add wave -noupdate /fft_tb/uut/input_state
add wave -noupdate /fft_tb/uut/input_state_next
add wave -noupdate /fft_tb/uut/output_state
add wave -noupdate /fft_tb/uut/output_state_next
add wave -noupdate -divider {IP core}
add wave -noupdate /fft_tb/uut/FFT_H/clk
add wave -noupdate /fft_tb/uut/FFT_H/reset_n
add wave -noupdate /fft_tb/uut/FFT_H/sink_valid
add wave -noupdate /fft_tb/uut/FFT_H/sink_ready
add wave -noupdate /fft_tb/uut/FFT_H/sink_error
add wave -noupdate /fft_tb/uut/FFT_H/sink_sop
add wave -noupdate /fft_tb/uut/FFT_H/sink_eop
add wave -noupdate /fft_tb/uut/FFT_H/sink_real
add wave -noupdate /fft_tb/uut/FFT_H/sink_imag
add wave -noupdate /fft_tb/uut/FFT_H/inverse
add wave -noupdate /fft_tb/uut/FFT_H/source_valid
add wave -noupdate /fft_tb/uut/FFT_H/source_ready
add wave -noupdate /fft_tb/uut/FFT_H/source_error
add wave -noupdate /fft_tb/uut/FFT_H/source_sop
add wave -noupdate /fft_tb/uut/FFT_H/source_eop
add wave -noupdate /fft_tb/uut/FFT_H/source_real
add wave -noupdate /fft_tb/uut/FFT_H/source_imag
add wave -noupdate /fft_tb/uut/FFT_H/source_exp
add wave -noupdate -divider {IP core internal}
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/clk
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/reset_n
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/inverse
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_valid
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_sop
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_eop
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_real
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_imag
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_error
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_ready
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_exp
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/sink_ready
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_error
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_sop
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_eop
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_valid
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_real
add wave -noupdate /fft_tb/uut/FFT_H/fft_ii_0/source_imag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21629 ps} 0}
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
WaveRestoreZoom {0 ps} {211849 ps}
