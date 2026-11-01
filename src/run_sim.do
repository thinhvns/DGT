# ModelSim Intel FPGA Starter Edition 2020.1
# Run from Transcript: do run_sim.do

transcript on
set script_dir [file dirname [file normalize [info script]]]
cd $script_dir

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

vlog -vlog01compat -work work moving_average_filter.v
vlog -vlog01compat -work work tb_moving_average_filter.v

vsim -voptargs=+acc work.tb_moving_average_filter

add wave -noupdate -divider {Clock and Control}
add wave -radix binary sim:/tb_moving_average_filter/clk
add wave -radix binary sim:/tb_moving_average_filter/rst
add wave -radix binary sim:/tb_moving_average_filter/sample_valid
add wave -radix binary sim:/tb_moving_average_filter/sample_out_valid

add wave -noupdate -divider {Fixed-point Input and Output Q4.12}
add wave -radix signed sim:/tb_moving_average_filter/sample_in
add wave -radix signed sim:/tb_moving_average_filter/sample_out

add wave -noupdate -divider {Filter Internal State}
add wave -radix unsigned sim:/tb_moving_average_filter/dut/write_ptr
add wave -radix signed sim:/tb_moving_average_filter/dut/running_sum
add wave -radix signed sim:/tb_moving_average_filter/dut/oldest_sample

update
run -all
