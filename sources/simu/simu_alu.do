# Creates the work library named work
vlib work

# Compiles the VHDL files
vcom -93 alu.vhd
vcom -93 ../simu/alu_tb.vhd

# Chooses the entity to simulate
vsim alu_tb(bench)

# Shows the signals
view signals
add wave alu_tb/OK
add wave alu_tb/UUT/A
add wave alu_tb/UUT/B
add wave alu_tb/UUT/Y
add wave -radix signed alu_tb/UUT/A
add wave -radix signed alu_tb/UUT/B
add wave -radix signed alu_tb/UUT/Y
add wave -radix unsigned alu_tb/UUT/A
add wave -radix unsigned alu_tb/UUT/B
add wave -radix unsigned alu_tb/UUT/Y
add wave alu_tb/UUT/SEL
add wave alu_tb/UUT/C
add wave alu_tb/UUT/N
add wave alu_tb/UUT/V
add wave alu_tb/UUT/Z

# Runs the simulation
run -all