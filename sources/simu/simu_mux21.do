# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 mux21.vhd
vcom -93 ../simu/mux21_tb.vhd

# Choose the entity to simulate
vsim mux21_tb(bench)

# Show the signals
view signals
add wave mux21_tb/OK
add wave -radix signed mux21_tb/UUT/A
add wave -radix signed mux21_tb/UUT/B
add wave mux21_tb/UUT/COM
add wave -radix signed mux21_tb/UUT/Y

# Run the simulation
run -all