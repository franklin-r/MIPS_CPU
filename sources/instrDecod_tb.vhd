-- File 		:	instrDecod_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the instruction decoder
-- Released 	:	09/11/2018
-- Updated		: 	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrDecod_tb is port( 
	OK: inout boolean := true);
end entity;

architecture bench of instrDecod_tb is 
	component instrDecod is port(
		Instr	:	in std_logic_vector(31 downto 0);		-- 32-bit instruction
		PSRout	:	in std_logic_vector(31 downto 0);		-- 32-bit Processor State
		
		Imm		:	out std_logic_vector(15 downto 0);		-- Immediate value on 16 bits
		RegWr	:	out std_logic;							-- Register's Write Enable
		RegSel	:	out std_logic;							-- 1-bit input command for mux n°1 at the input of registers for register selection
		Rn		:	out std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port A
		Rm		: 	out std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port B
		Rd		:	out std_logic_vector(4 downto 0);		-- 5-bit input address bus in writing mode
		AluSrc	:	out std_logic;							-- 1-bit input command for mux n°2 at the output of registers
		AluCtr	:	out std_logic_vector(1 downto 0);		-- 2-bit input selector
		MemWr	:	out std_logic;							-- Data Memory's Write Enable
		WrSrc	:	out std_logic;							-- 1-bit input command for mux n°3 at the output of ALU
		
		PCsel	:	out std_logic;							-- Next address instruction selector for PC register
		Offset	:	out std_logic_vector(25 downto 0);		-- Immediate value on 26 bits
		
		PSRen	:	out std_logic);							-- PSR's Write Enable
	end component;
	
	signal Instr	:	std_logic_vector(31 downto 0);		-- 32-bit instruction
	signal PSRout	:	std_logic_vector(31 downto 0);		-- 32-bit Processor State
	
	-- Output signals to the Processing Unit
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
	
	-- Output signals to the Instruction Management Unit
	signal PCsel	:	std_logic;							-- Next address instruction selector for PC register
	signal Offset	:	std_logic_vector(25 downto 0);		-- Immediate value on 26 bits
	
	-- Output signal to the Control Unit
	signal PSRen	:	std_logic;							-- PSR's Write Enable
	
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
	UUT : instrDecod port map(	Instr	=> Instr,
								PSRout	=> PSRout,
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
								Offset	=> Offset,
								PSRen	=> PSRen);
								
	-- In this testbench, we are going to send instructions to the decoder and check if it produces the right outputs
	test : process
	begin
	
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
		PSRout 	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the ADD's ones
		-- We do not check Imm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '0') and (AluSrc = '0') and (AluCtr = "00") and (PSRen = '0') and (MemWr = '0') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(2, 5))) and (Rm = std_logic_vector(to_unsigned(3, 5))) and (Rd = std_logic_vector(to_unsigned(1, 5)));
		assert OK report "Error with the ADD" severity warning;
		
		
		-- SUB $4, $5, $6
		-- Subtraction of register n°5 and n°6 into register n°4
		-- Here, Rn = 5, Rm = 6 and Rd = 4
		-- Therefore, we have:
		Instr 	<= 	R_opcode & std_logic_vector(to_unsigned(5, 5)) & std_logic_vector(to_unsigned(6, 5)) & std_logic_vector(to_unsigned(4, 5)) & 
					std_logic_vector(to_unsigned(0, 5)) & SUB_func;		-- shamt is set to 0
		PSRout 	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the SUB's ones
		-- We do not check Imm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '0') and (AluSrc = '0') and (AluCtr = "10") and (PSRen = '0') and (MemWr = '0') and (WrSrc = '0')
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
		PSRout 	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the ADDI's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (PSRen = '0') and (MemWr = '0') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(8, 5))) and (Rd = std_logic_vector(to_unsigned(7, 5))) and (Imm = std_logic_vector(to_signed(12, 16)));
		assert OK report "Error with the ADDI" severity warning;
		
		
		-- BEQ $9, $10, 19
		-- If register n°9 and n°10 have the same value, go to address PC + 4 + 19
		-- Here, Rn = 9, Rd = 10 and Imm = 19
		-- Therefore, we have:
		Instr 	<= 	BEQ_opcode & std_logic_vector(to_unsigned(9, 5)) & std_logic_vector(to_unsigned(10, 5)) & std_logic_vector(to_signed(19, 16));
		PSRout 	<=	(others => '0');								-- Set to 0, we suppose the register was set to this value
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the BEQ's ones
		-- We do not check WrSrc, Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = PSRout(0)) and (RegWr = '0') and (RegSel = '1') and (AluSrc = '0') and (AluCtr = "10") and (PSRen = '1') and (MemWr = '0') and
				(Rn = std_logic_vector(to_unsigned(9, 5))) and (Rd = std_logic_vector(to_unsigned(10, 5))) and 
				(Imm = std_logic_vector(to_signed(19, 16)));
		assert OK report "Error with the BEQ" severity warning;
		
		
		-- BNE $11, $12, -5
		-- If register n°11 and n°12 does not have the same value, go to address PC + 4 + (-5)
		-- Here, Rn = 11, Rd = 12 and Imm = -5
		-- Therefore, we have:
		Instr 	<= 	BNE_opcode & std_logic_vector(to_unsigned(11, 5)) & std_logic_vector(to_unsigned(12, 5)) & std_logic_vector(to_signed(-5, 16));
		PSRout 	<=	(others => '0');								-- Set to 0, we suppose the register was set to this value
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the BNE's ones
		-- We do not check WrSrc, Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = not PSRout(0)) and (RegWr = '0') and (RegSel = '1') and (AluSrc = '0') and (AluCtr = "10") and (PSRen = '1') and (MemWr = '0') and
				(Rn = std_logic_vector(to_unsigned(11, 5))) and (Rd = std_logic_vector(to_unsigned(12, 5))) and 
				(Imm = std_logic_vector(to_signed(-5, 16)));
		assert OK report "Error with the BNE" severity warning;
		
		
		-- LW $13, 8($14)
		-- Register n°13 takes the value of the data memory at address $14 + 8
		-- Here, Rn = 14, Rd = 13 and Imm = 8
		-- Therefore, we have:
		Instr 	<= 	LW_opcode & std_logic_vector(to_unsigned(14, 5)) & std_logic_vector(to_unsigned(13, 5)) & std_logic_vector(to_signed(8, 16));
		PSRout 	<=	(others => '0');								-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the LW's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '1') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (PSRen = '0') and (MemWr = '0') and (WrSrc = '1')
				and (Rn = std_logic_vector(to_unsigned(14, 5))) and (Rd = std_logic_vector(to_unsigned(13, 5))) and 
				(Imm = std_logic_vector(to_signed(8, 16)));
		assert OK report "Error with the LW" severity warning;
		
		
		-- SW $15, 4($16)
		-- The value at address $16 + 4 takes the value of the register n°15
		-- Here, Rn = 16, Rd = 15 and Imm = 4
		-- Therefore, we have:
		Instr 	<= 	SW_opcode & std_logic_vector(to_unsigned(16, 5)) & std_logic_vector(to_unsigned(15, 5)) & std_logic_vector(to_signed(4, 16));
		PSRout 	<=	(others => '0');								-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the SW's ones
		-- We do not check Rm and Offset because their value does not matter in a R-type instruction
		OK <= 	(PCsel = '0') and (RegWr = '0') and (RegSel = '1') and (AluSrc = '1') and (AluCtr = "00") and (PSRen = '0') and (MemWr = '1') and (WrSrc = '0')
				and (Rn = std_logic_vector(to_unsigned(16, 5))) and (Rd = std_logic_vector(to_unsigned(15, 5))) and 
				(Imm = std_logic_vector(to_signed(4, 16)));
		assert OK report "Error with the SW" severity warning;
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		
		-- J-type instructions
		-- Format :
		-- [31 : 26] 	= opcode
		-- [25 : 0] 	= Offset
		
		-- J 1912
		-- Go to address PC + 1 + 31
		-- Here, Offset = 31
		-- Therefore, we have:
		Instr 	<= 	J_opcode & std_logic_vector(to_signed(31, 26));
		PSRout 	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the J's ones
		-- We only check PCsel and Offset because they are the only significant here
		OK <= 	(PCsel = '1') and (Offset = std_logic_vector(to_signed(31, 26)));
		assert OK report "Error with the J" severity warning;
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------

		-- We try to send a value which is not an instruction by putting every bit of Instr to '0'
		Instr 	<= 	(others => '0');
		PSRout 	<=	(others => '0');									-- Set to 0, the value does not matter here
		wait for 10 ns;
		
		-- Checks every outputs to make sure it corresponds to the NaI's ones
		-- We only check PCsel, RegWr, PSRen and MemWr because they are the only significant here
		OK <= 	(PCsel = '0') and (RegWr = '0') and (PSRen = '0') and (MemWr = '0');
		assert OK report "Error with the NaI" severity warning;

		wait;
	end process test;
end architecture;
