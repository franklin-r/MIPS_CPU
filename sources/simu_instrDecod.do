# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 instrDecod.vhd
vcom -93 ../simu/instrDecod_tb.vhd

# Choose the entity to simulate
vsim instrDecod_tb(bench)

# Show the signals
view signals
add wave instrDecod_tb/OK
add wave instrDecod_tb/UUT/curr_instr
add wave instrDecod_tb/UUT/Instr
add wave instrDecod_tb/UUT/PSRout
add wave instrDecod_tb/UUT/PCsel
add wave instrDecod_tb/UUT/RegWr
add wave instrDecod_tb/UUT/RegSel
add wave instrDecod_tb/UUT/AluSrc
add wave instrDecod_tb/UUT/AluCtr
add wave instrDecod_tb/UUT/PSRen
add wave instrDecod_tb/UUT/MemWr
add wave instrDecod_tb/UUT/WrSrc
add wave -radix unsigned instrDecod_tb/UUT/Rn
add wave -radix unsigned instrDecod_tb/UUT/Rm
add wave -radix unsigned instrDecod_tb/UUT/Rd
add wave -radix signed instrDecod_tb/UUT/Imm
add wave -radix signed instrDecod_tb/UUT/Offset

# Run the simulation
run -all