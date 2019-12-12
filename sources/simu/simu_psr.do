# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 psr.vhd
vcom -93 ../simu/psr_tb.vhd

# Choose the entity to simulate
vsim psr_tb(bench)

# Show the signals
view signals
add wave psr_tb/OK
add wave psr_tb/CLK
add wave psr_tb/RST
add wave psr_tb/WE
add wave -radix unsigned psr_tb/UUT/StateIn
add wave -radix unsigned psr_tb/UUT/StateOut

# Run the simulation
run -all