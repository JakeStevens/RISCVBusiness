onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_FPU_top_level/DUT/clk
add wave -noupdate /tb_FPU_top_level/DUT/nrst
add wave -noupdate /tb_FPU_top_level/DUT/floating_point1
add wave -noupdate /tb_FPU_top_level/DUT/floating_point2
add wave -noupdate /tb_FPU_top_level/DUT/frm
add wave -noupdate /tb_FPU_top_level/DUT/funct7
add wave -noupdate /tb_FPU_top_level/DUT/floating_point_out
add wave -noupdate /tb_FPU_top_level/DUT/flags
add wave -noupdate /tb_FPU_top_level/DUT/frm2
add wave -noupdate /tb_FPU_top_level/DUT/frm3
add wave -noupdate /tb_FPU_top_level/DUT/funct7_2
add wave -noupdate /tb_FPU_top_level/DUT/funct7_3
add wave -noupdate /tb_FPU_top_level/DUT/sign_shifted
add wave -noupdate /tb_FPU_top_level/DUT/frac_shifted
add wave -noupdate /tb_FPU_top_level/DUT/sign_not_shifted
add wave -noupdate /tb_FPU_top_level/DUT/frac_not_shifted
add wave -noupdate /tb_FPU_top_level/DUT/exp_max
add wave -noupdate /tb_FPU_top_level/DUT/mul_sign1
add wave -noupdate /tb_FPU_top_level/DUT/mul_sign2
add wave -noupdate /tb_FPU_top_level/DUT/mul_exp1
add wave -noupdate /tb_FPU_top_level/DUT/mul_exp2
add wave -noupdate /tb_FPU_top_level/DUT/product
add wave -noupdate /tb_FPU_top_level/DUT/mul_carry_out
add wave -noupdate /tb_FPU_top_level/DUT/step1_to_step2
add wave -noupdate /tb_FPU_top_level/DUT/nxt_step1_to_step2
add wave -noupdate /tb_FPU_top_level/DUT/add_sign_out
add wave -noupdate /tb_FPU_top_level/DUT/add_sum
add wave -noupdate /tb_FPU_top_level/DUT/add_carry_out
add wave -noupdate /tb_FPU_top_level/DUT/add_exp_max
add wave -noupdate /tb_FPU_top_level/DUT/mul_sign_out
add wave -noupdate /tb_FPU_top_level/DUT/sum_exp
add wave -noupdate /tb_FPU_top_level/DUT/mul_ovf
add wave -noupdate /tb_FPU_top_level/DUT/mul_unf
add wave -noupdate /tb_FPU_top_level/DUT/inv
add wave -noupdate /tb_FPU_top_level/DUT/inv2
add wave -noupdate /tb_FPU_top_level/DUT/inv3
add wave -noupdate /tb_FPU_top_level/DUT/step2_to_step3
add wave -noupdate /tb_FPU_top_level/DUT/nxt_step2_to_step3
add wave -noupdate /tb_FPU_top_level/DUT/o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {42 ps}
