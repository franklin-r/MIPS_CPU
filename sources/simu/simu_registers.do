# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 registers.vhd
vcom -93 ../simu/registers_tb.vhd

# Choose the entity to simulate
vsim registers_tb(bench)

# Show the signals
view signals
add wave registers_tb/OK
add wave registers_tb/UUT/CLK
add wave registers_tb/UUT/RST
add wave -radix signed registers_tb/UUT/W
add wave -radix unsigned registers_tb/UUT/RA
add wave -radix unsigned registers_tb/UUT/RB
add wave -radix unsigned registers_tb/UUT/RW
add wave registers_tb/UUT/WE
add wave -radix signed registers_tb/UUT/A
add wave -radix signed registers_tb/UUT/B
add wave -radix signed registers_tb/UUT/REG

# Run the simulation
run -all