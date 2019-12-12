# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 extender.vhd
vcom -93 ../simu/extender_tb.vhd

# Choose the entity to simulate
vsim extender_tb(bench)

# Show the signals
view signals
add wave *
add wave -radix signed extender_tb/UUT/I
add wave -radix signed extender_tb/UUT/Y

# Run the simulation
run -all