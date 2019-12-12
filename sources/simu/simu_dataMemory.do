# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 dataMemory.vhd
vcom -93 ../simu/dataMemory_tb.vhd

# Choose the entity to simulate
vsim dataMemory_tb(bench)

# Show the signals
view signals
add wave dataMemory_tb/OK
add wave dataMemory_tb/UUT/CLK
add wave dataMemory_tb/UUT/RST
add wave -radix signed dataMemory_tb/UUT/DataIn
add wave -radix unsigned dataMemory_tb/UUT/Addr
add wave -radix signed dataMemory_tb/UUT/DataOut
add wave dataMemory_tb/UUT/WE
add wave -radix signed dataMemory_tb/UUT/MEM

# Run the simulation
run -all