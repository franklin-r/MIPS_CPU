# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 instrMemory.vhd
vcom -93 ../simu/instrMemory_tb.vhd

# Choose the entity to simulate
vsim instrMemory_tb(bench)

# Show the signals
view signals
add wave instrMemory_tb/OK
add wave -radix unsigned instrMemory_tb/UUT/Addr
add wave -radix hexadecimal instrMemory_tb/UUT/Instr
add wave -radix hexadecimal instrMemory_tb/UUT/INSTRMEM

# Run the simulation
run -all