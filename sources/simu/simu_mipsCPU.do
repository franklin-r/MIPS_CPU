# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 registers.vhd
vcom -93 extender.vhd
vcom -93 mux21.vhd
vcom -93 alu.vhd
vcom -93 dataMemory.vhd
vcom -93 processingUnit.vhd
vcom -93 pc.vhd
vcom -93 instrMemory.vhd
vcom -93 instrManagUnit.vhd
vcom -93 psr.vhd
vcom -93 instrDecod.vhd
vcom -93 controlUnit.vhd
vcom -93 mipsCPU.vhd
vcom -93 ../simu/mipsCPU_tb.vhd

# Choose the entity to simulate
vsim mipsCPU_tb(bench)

# Show the signals
view signals
add wave mipsCPU_tb/UUT/CLK
add wave mipsCPU_tb/UUT/RST
add wave -radix unsigned mipsCPU_tb/UUT/D1/B5/Addr
add wave mipsCPU_tb/UUT/D2/C1/curr_instr
add wave -radix unsigned mipsCPU_tb/UUT/D0/Rn
add wave -radix unsigned mipsCPU_tb/UUT/D0/Rm
add wave -radix unsigned mipsCPU_tb/UUT/D0/Rd
add wave -radix signed mipsCPU_tb/UUT/D0/Imm
add wave -radix signed mipsCPU_tb/UUT/D1/Offset
add wave -radix signed mipsCPU_tb/UUT/D0/DummyOut
add wave -radix signed mipsCPU_tb/UUT/D0/A1/REG
add wave -radix signed mipsCPU_tb/UUT/D0/A5/MEM

# Run the simulation
run -all