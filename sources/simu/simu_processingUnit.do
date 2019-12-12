# Create the work library named work
vlib work

# Compile the VHDL files
vcom -93 registers.vhd
vcom -93 extender.vhd
vcom -93 mux21.vhd
vcom -93 alu.vhd
vcom -93 dataMemory.vhd
vcom -93 processingUnit.vhd
vcom -93 ../simu/processingUnit_tb.vhd

# Choose the entity to simulate
vsim processingUnit_tb(bench)

# Show the signals
view signals
add wave processingUnit_tb/UUT/CLK
add wave processingUnit_tb/UUT/RST
add wave -radix unsigned processingUnit_tb/UUT/Rn
add wave -radix unsigned processingUnit_tb/UUT/Rm
add wave -radix unsigned processingUnit_tb/UUT/Rd
add wave processingUnit_tb/UUT/RegWr
add wave processingUnit_tb/UUT/RegSel
add wave processingUnit_tb/UUT/AluSrc
add wave processingUnit_tb/UUT/WrSrc
add wave processingUnit_tb/UUT/AluCtr
add wave processingUnit_tb/UUT/C
add wave processingUnit_tb/UUT/N
add wave processingUnit_tb/UUT/V
add wave processingUnit_tb/UUT/Z
add wave -radix signed processingUnit_tb/UUT/Imm
add wave -radix signed processingUnit_tb/UUT/Imm_32
add wave processingUnit_tb/UUT/MemWr
add wave -radix signed processingUnit_tb/UUT/A1/REG
add wave -radix signed processingUnit_tb/UUT/A5/MEM

# Run the simulation
run -all