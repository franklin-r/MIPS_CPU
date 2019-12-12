-- File 		:	controlUnit_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the Control Unit
-- Released 	:	09/11/2019
-- Updated		: 	09/11/2019	:	Update the testbench to fit the changes
--									in the Processor State Register block.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity controlUnit_tb is port(
	OK: inout boolean := true);	
end entity;

architecture bench of controlUnit_tb is
	component controlUnit is port(
		CLK		:	in std_logic;						
		RST		:	in std_logic;						
		StateIn	:	in std_logic_vector(31 downto 0);
		Instr	:	in std_logic_vector(31 downto 0);		
		Imm		:	out std_logic_vector(15 downto 0);		
		RegWr	:	out std_logic;							
		RegSel	:	out std_logic;							
		Rn		:	out std_logic_vector(4 downto 0);	
		Rm		: 	out std_logic_vector(4 downto 0);	
		Rd		:	out std_logic_vector(4 downto 0);		
		AluSrc	:	out std_logic;							
		AluCtr	:	out std_logic_vector(1 downto 0);		
		MemWr	:	out std_logic;							
		WrSrc	:	out std_logic;							
		PCsel	:	out std_logic;							
		Offset	:	out std_logic_vector(25 downto 0));		
	end component;
	
	-- PSR's inputs
	signal CLK		:	std_logic := '0';					-- Clock
	signal RST		:	std_logic;							-- Asynchronous reset on high level
	signal StateIn	:	std_logic_vector(31 downto 0);		-- 32-bit input state bus
	
	-- Instruction Decoder's input/outputs
	signal Instr	:	std_logic_vector(31 downto 0);		-- 32-bit instruction
	signal Imm		:	std_logic_vector(15 downto 0);		-- Immediate value on 16 bits
	signal RegWr	:	std_logic;							-- Register's Write Enable
	signal RegSel	:	std_logic;							-- 1-bit input command for mux n°1 at the input of registers for register selection
	signal Rn		:	std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port A
	signal Rm		: 	std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port B
	signal Rd		:	std_logic_vector(4 downto 0);		-- 5-bit input address bus in writing mode
	signal AluSrc	:	std_logic;							-- 1-bit input command for mux n°2 at the output of registers
	signal AluCtr	:	std_logic_vector(1 downto 0);		-- 2-bit input selector
	signal MemWr	:	std_logic;							-- Data Memory's Write Enable
	signal WrSrc	:	std_logic;							-- 1-bit input command for mux n°3 at the output of ALU
	signal PCsel	:	std_logic;							-- Next address instruction selector for PC register
	signal Offset	:	std_logic_vector(25 downto 0);		-- Immediate value on 26 bits
	
	constant period	: time := 10 ns;						-- Period of the clock
	
	-- Signals to make the instructions clearer
	signal R_opcode		:	std_logic_vector(5 downto 0) := "000000";
	signal ADD_func		:	std_logic_vector(5 downto 0) := "100000";
	signal SUB_func 	: 	std_logic_vector(5 downto 0) := "100010";
	signal ADDI_opcode	:	std_logic_vector(5 downto 0) := "001000";
	signal BEQ_opcode	:	std_logic_vector(5 downto 0) := "000100";
	signal BNE_opcode	:	std_logic_vector(5 downto 0) := "000101";
	signal LW_opcode	:	std_logic_vector(5 downto 0) := "100011";
	signal SW_opcode	:	std_logic_vector(5 downto 0) := "101011";
	signal J_opcode		:	std_logic_vector(5 downto 0) := "000010";
	
begin 
	UUT : controlUnit port map(	CLK		=> CLK,
								RST		=> RST,
								StateIn	=> StateIn,
								Instr	=> Instr,
								Imm		=> Imm,
								RegWr	=> RegWr,
								RegSel	=> RegSel,
								Rn		=> Rn,
								Rm		=> Rm,
								Rd		=> Rd,
								AluSrc	=> AluSrc,
								AluCtr	=> AluCtr,
								MemWr	=> MemWr,
								WrSrc	=> WrSrc,
								PCsel	=> PCsel,
								Offset	=> Offset);
								
	-- Clock
	clock : process					
	begin
		for i in 0 to 20 loop
			CLK <= not CLK;
			wait for period / 2;
		end loop;
		wait;
	end process clock;
	
	-- In this testbench, we are going to send instructions and processor states to the Control Unit and check if it produces the right outputs.
	-- This testbench is very similar to the Instruction Decoder one and therefore reuses parts of it.
	test : process
	begin
		-- Sets the PSR
		RST <= '1', '0' after period / 10;
		
		-- R-type instructions
		-- Format :
		-- [31 : 26] 	= opcode (which is always 000000 for R-type instructions)
		-- [25 : 21] 	= Rn 
		-- [20 : 16] 	= Rm
		-- [15 : 11] 	= Rd
		-- [10 : 6] 	= shamt, this one does not matter here
		-- [5 : 0] 		= function
		
		-- ADD $1, $2, $3
		-- Addition of register n°2 and n°3 into register n°1
		-- Here, Rn = 2, Rm = 3 and Rd = 1
		-- Therefore, we have:
		Instr 	<= 	R_opcode & std_logic_vector(to_unsigned(2, 5)) & std_logic_vector(to_unsigned(3, 5)) & std_logic_vector(to_unsigned(1, 5)) & 
					std_logic_vector(to_unsigned(0, 5)) & ADD_func;		-- shamt is set to 0
		StateIn <=	(others => '0');									-- Set to 0, the value does not matter here
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the ADD's ones
		-- We do not check Imm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '0') and (AluSrc = '0') and (AluCtr = "00") and (MemWr = '0') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(2, 5))) and (Rm = std_logic_vector(to_unsigned(3, 5))) and (Rd = std_logic_vector(to_unsigned(1, 5)));
		assert OK report "Error with the ADD" severity warning;
		
		
		-- SUB $4, $5, $6
		-- Subtraction of register n°5 and n°6 into register n°4
		-- Here, Rn = 5, Rm = 6 and Rd = 4
		-- Therefore, we have:
		Instr 	<= 	R_opcode & std_logic_vector(to_unsigned(5, 5)) & std_logic_vector(to_unsigned(6, 5)) & std_logic_vector(to_unsigned(4, 5)) & 
					std_logic_vector(to_unsigned(0, 5)) & SUB_func;		-- shamt is set to 0
		StateIn <=	(others => '0');									-- Set to 0, the value does not matter here
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the SUB's ones
		-- We do not check Imm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '0') and (AluSrc = '0') and (AluCtr = "10") and (MemWr = '0') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(5, 5))) and (Rm = std_logic_vector(to_unsigned(6, 5))) and (Rd = std_logic_vector(to_unsigned(4, 5)));
		assert OK report "Error with the SUB" severity warning;
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		
		-- I-type instructions
		-- Format :
		-- [31 : 26] 	= opcode
		-- [25 : 21] 	= Rn
		-- [20 : 16] 	= Rd
		-- [15 : 0] 	= Imm
		
		-- ADDI $7, $8, 12
		-- Addition of register n°8 and immediate value 12 into register n°7
		-- Here, Rn = 8, Rd = 7 and Imm = 12
		-- Therefore, we have:
		Instr 	<= 	ADDI_opcode & std_logic_vector(to_unsigned(8, 5)) & std_logic_vector(to_unsigned(7, 5)) & std_logic_vector(to_signed(12, 16));
		StateIn	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the ADDI's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (MemWr = '0') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(8, 5))) and (Rd = std_logic_vector(to_unsigned(7, 5))) and (Imm = std_logic_vector(to_signed(12, 16)));
		assert OK report "Error with the ADDI" severity warning;
		
		
		-- BEQ $9, $10, 19
		-- If register n°9 and n°10 have the same value, go to address PC + 4 + 19
		-- Here, Rn = 9, Rd = 10 and Imm = 19
		-- Therefore, we have:
		Instr 	<= 	BEQ_opcode & std_logic_vector(to_unsigned(9, 5)) & std_logic_vector(to_unsigned(10, 5)) & std_logic_vector(to_signed(19, 16));
		StateIn	<=	x"00000001";								-- Set the flag Z to '1', we suppose it was set to this value
																-- Therefore, the BEQ should trigger
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the BEQ's ones
		-- We do not check WrSrc, Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = StateIn(0)) and (RegWr = '0') and (RegSel = '1') and (AluSrc = '0') and (AluCtr = "10") and (MemWr = '0') and
				(Rn = std_logic_vector(to_unsigned(9, 5))) and (Rd = std_logic_vector(to_unsigned(10, 5))) and 
				(Imm = std_logic_vector(to_signed(19, 16)));
		assert OK report "Error with the BEQ" severity warning;
	
		
		-- BNE $11, $12, -5
		-- If register n°11 and n°12 does not have the same value, go to address PC + 4 + (-5)
		-- Here, Rn = 11, Rd = 12 and Imm = -5
		-- Therefore, we have:
		Instr 	<= 	BNE_opcode & std_logic_vector(to_unsigned(11, 5)) & std_logic_vector(to_unsigned(12, 5)) & std_logic_vector(to_signed(-5, 16));
		StateIn	<=	(others => '0');								-- Set to 0, we suppose the register was set to this value.
																	-- Therefore, the BNE should trigger.
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the BNE's ones
		-- We do not check WrSrc, Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = not StateIn(0)) and (RegWr = '0') and (RegSel = '1') and (AluSrc = '0') and (AluCtr = "10") and (MemWr = '0') and
				(Rn = std_logic_vector(to_unsigned(11, 5))) and (Rd = std_logic_vector(to_unsigned(12, 5))) and 
				(Imm = std_logic_vector(to_signed(-5, 16)));
		assert OK report "Error with the BNE" severity warning;
		
		
		-- LW $13, 8($14)
		-- Register n°13 takes the value of the data memory at address $14 + 8
		-- Here, Rn = 14, Rd = 13 and Imm = 8
		-- Therefore, we have:
		Instr 	<= 	LW_opcode & std_logic_vector(to_unsigned(14, 5)) & std_logic_vector(to_unsigned(13, 5)) & std_logic_vector(to_signed(8, 16));
		StateIn	<=	(others => '0');								-- Set to 0, the value does not matter here
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the LW's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (MemWr = '0') and (WrSrc = '1')
				and (Rn = std_logic_vector(to_unsigned(14, 5))) and (Rd = std_logic_vector(to_unsigned(13, 5))) and 
				(Imm = std_logic_vector(to_signed(8, 16)));
		assert OK report "Error with the LW" severity warning;
		
		
		-- SW $15, 4($16)
		-- The value at address $16 + 4 takes the value of the register n°15
		-- Here, Rn = 16, Rd = 15 and Imm = 4
		-- Therefore, we have:
		Instr 	<= 	SW_opcode & std_logic_vector(to_unsigned(16, 5)) & std_logic_vector(to_unsigned(15, 5)) & std_logic_vector(to_signed(4, 16));
		StateIn	<=	(others => '0');								-- Set to 0, the value does not matter here
		wait for period;
		
		-- Checks every outputs to make sure it corresponds to the SW's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '0') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (MemWr = '1') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(16, 5))) and (Rd = std_logic_vector(to_unsigned(15, 5))) and 
				(Imm = std_logic_vector(to_signed(4, 16)));
		assert OK report "Error with the SW" severity warning;
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		
		-- J-type instructions
		-- Format :
		-- [31 : 26] 	= opcode
		-- [25 : 0] 	= Offset
		
		-- J 1912
		-- Go to address PC + 4 + 1912
		-- Here, Offset = 1912
		-- Therefore, we have:
		Instr 	<= 	J_opcode & std_logic_vector(to_signed(1912, 26));
		StateIn	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the J's ones
		-- We only check PCsel and Offset because they are the only significant here
		OK <= 	(PCsel = '1') and (Offset = std_logic_vector(to_signed(1912, 26)));
		assert OK report "Error with the J" severity warning;
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------

		-- We try to send a value which is not an instruction by putting every bit of Instr to '0'
		Instr 	<= 	(others => '0');
		StateIn	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the NaI's ones
		-- We only check PCsel, RegWr and MemWr because they are the only significant here
		OK <= 	(PCsel = '0') and (RegWr = '0') and (MemWr = '0');
		assert OK report "Error with the NaI" severity warning;

		wait;
	end process test;
end architecture;