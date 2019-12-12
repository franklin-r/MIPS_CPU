# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 pc.vhd
vcom -93 ../simu/pc_tb.vhd

# Choose the entity to simulate
vsim pc_tb(bench)

# Show the signals
view signals
add wave pc_tb/OK
add wave pc_tb/CLK
add wave pc_tb/RST
add wave -radix unsigned pc_tb/UUT/AddrIn
add wave -radix unsigned pc_tb/UUT/AddrOut

# Run the simulation
run -all