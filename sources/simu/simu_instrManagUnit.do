# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 extender.vhd
vcom -93 mux21.vhd
vcom -93 pc.vhd
vcom -93 instrMemory.vhd
vcom -93 instrManagUnit.vhd
vcom -93 ../simu/instrManagUnit_tb.vhd

# Choose the entity to simulate
vsim instrManagUnit_tb(bench)

# Show the signals
view signals
add wave instrManagUnit_tb/OK
add wave instrManagUnit_tb/UUT/CLK
add wave instrManagUnit_tb/UUT/RST
add wave -radix signed instrManagUnit_tb/UUT/Imm_32
add wave -radix signed instrManagUnit_tb/UUT/Offset
add wave instrManagUnit_tb/UUT/PCsel
add wave -radix unsigned instrManagUnit_tb/UUT/B5/Addr
add wave -radix hexadecimal instrManagUnit_tb/UUT/Instr
add wave -radix hexadecimal instrManagUnit_tb/UUT/B5/INSTRMEM

# Run the simulation
run -all