# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 psr.vhd
vcom -93 instrDecod.vhd
vcom -93 controlUnit.vhd
vcom -93 ../simu/controlUnit_tb.vhd

# Choose the entity to simulate
vsim controlUnit_tb(bench)

# Show the signals
view signals
add wave controlUnit_tb/OK
add wave controlUnit_tb/UUT/CLK
add wave controlUnit_tb/UUT/RST
add wave controlUnit_tb/UUT/C1/curr_instr
add wave controlUnit_tb/UUT/Instr
add wave controlUnit_tb/UUT/StateIn
add wave controlUnit_tb/UUT/PCsel
add wave controlUnit_tb/UUT/RegWr
add wave controlUnit_tb/UUT/RegSel
add wave controlUnit_tb/UUT/AluSrc
add wave controlUnit_tb/UUT/AluCtr
add wave controlUnit_tb/UUT/MemWr
add wave controlUnit_tb/UUT/WrSrc
add wave -radix unsigned controlUnit_tb/UUT/Rn
add wave -radix unsigned controlUnit_tb/UUT/Rm
add wave -radix unsigned controlUnit_tb/UUT/Rd
add wave -radix signed controlUnit_tb/UUT/Imm
add wave -radix signed controlUnit_tb/UUT/Offset

# Run the simulation
run -all