-- File			:	instrDecod.vhd
-- Block 		:	Instruction Decoder
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Finit State Machine generating the control signals from 
--					the instruction and the Processor State Register
-- Context 		:	The block is part of the Control Unit
-- Released		:	09/11/2018
-- Updated		:

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrDecod is port(
	Instr	:	in std_logic_vector(31 downto 0);		-- 32-bit instruction
	PSRout	:	in std_logic_vector(31 downto 0);		-- 32-bit Processor State
	
	-- Output signals to the Processing Unit
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
	
	-- Output signals to the Instruction Management Unit
	PCsel	:	out std_logic;							-- Next address instruction selector for PC register
	Offset	:	out std_logic_vector(25 downto 0);		-- Immediate value on 26 bits
	
	-- Output signal to the Control Unit
	PSRen	:	out std_logic);							-- PSR's Write Enable
end entity;

architecture behaviour of instrDecod is
	-- Type instruction declaration
	type instruction is (NaI, ADD, SUB, ADDI, BEQ, BNE, LW, SW, J);		-- NaI : Not an Instruction
	
	signal curr_instr : instruction;
		
begin
	process(Instr, PSRout)
	begin
		
		-- R-type instructions all have opcode = 000000
		case Instr(31 downto 26) is
		when "000000" =>
			PCsel	<= '0';							-- Go to next address in instruction memory
			RegWr 	<= '1';							-- Writes in registers
			RegSel 	<= '0';							-- Selects Rm
			AluSrc	<= '0';							-- Selects register as second ALU's input
			PSRen	<= '0';							-- Do not use the state flags
			MemWr	<= '0';							-- Does not write in data memory
			WrSrc	<= '0';							-- Write ALU's output in registers
			Rn 		<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rm		<= Instr(20 downto 16);			-- Address of register rd is on bits 20 to 16
			Rd 		<= Instr(15 downto 11);			-- Address of register rt is on bits 15 to 11			
			Imm 	<= (others => '0');				-- Value of Imm does not matter because it is a R-type instruction
			Offset	<= (others => '0');				-- Value of Offset does not matter because we go to next address
			
			-- ADD
			if Instr(5 downto 0) = "100000" then
				curr_instr	<= ADD;
				AluCtr		<= "00";					-- Selects addition in ALU
			
			-- SUB
			elsif Instr(5 downto 0) = "100010" then
				curr_instr	<= SUB;
				AluCtr		<= "10";					-- Selects subtraction in ALU			
			
			else 
				curr_instr <= NaI;
				PCsel		<= '0';							-- Go to next address in instruction memory
				RegWr 		<= '0';							-- Does not write in registers because we do not want to do anything
				RegSel 		<= '0';							-- Value of RegSel does not matter because we do not do anything
				AluSrc		<= '0';							-- Value of AluSrc does not matter because we do not do anything
				AluCtr 		<= "00";						-- Value of AluCtr does not matter because we do not do anything
				PSRen		<= '0';							-- Do not use the state flags
				MemWr		<= '0';							-- Does not write in data memory
				WrSrc		<= '0';							-- Value of WrSrc does not matter because we do not do anything
				Rn 			<= (others => '0');				-- Address of register Rn does not matter we do not do anything
				Rd			<= (others => '0');				-- Address of register Rd does not matter we do not do anything
				Rm 			<= (others => '0');				-- Address of register Rm does not matter we do not do anything
				Imm 		<= (others => '0');				-- Value of Imm does not matter because we do not do anything
				Offset		<= (others => '0');				-- Value of Offset does not matter because we do not do anything
			end if;
		
		
		-- I-type instructions
		-- ADDI
		when "001000" =>
			curr_instr	<= ADDI;
			PCsel		<= '0';							-- Go to next address in instruction memory
			RegWr 		<= '1';							-- Writes in registers
			RegSel 		<= '1';							-- Selects Rd
			AluSrc		<= '1';							-- Selects the immediate value as second ALU's input
			AluCtr 		<= "00";						-- Selects addition in ALU
			PSRen		<= '0';							-- Do not use the state flags
			MemWr		<= '0';							-- Does not write in data memory
			WrSrc		<= '0';							-- Writes ALU's output in registers
			Rn 			<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rd			<= Instr(20 downto 16);			-- Address of register Rd is on bits 20 to 16
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a I-type instruction
			Imm 		<= Instr(15 downto 0);			-- Value of Imm is on bits 15 to 0
			Offset		<= (others => '0');				-- Value of Offset does not matter because we go to next address
			
			
		-- BEQ
		when "000100" =>
			curr_instr 	<= BEQ;
			PCsel		<= PSRout(0);					-- Go to next instruction if Z flag is '1'
			RegWr 		<= '0';							-- Does not write in registers
			RegSel 		<= '1';							-- Selects Rd
			AluSrc		<= '0';							-- Selects the register as second ALU's input
			AluCtr 		<= "10";						-- Selects subtraction in ALU
			PSRen		<= '1';							-- Update the Processor State
			MemWr		<= '0';							-- Does not write in data memory
			WrSrc		<= '0';							-- Value of WrSrc does not matter because it we do not write in the registers
			Rn 			<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rd			<= Instr(20 downto 16);			-- Address of register Rd is on bits 20 to 16
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a I-type instruction
			Imm 		<= Instr(15 downto 0);			-- Value of Imm is on bits 15 to 0
			Offset		<= (others => '0');				-- Value of Offset does not matter because it is a I-type instruction
			
			
		-- BNE
		when "000101" =>
			curr_instr 	<= BNE;
			PCsel		<= not PSRout(0);				-- Go to next instruction if Z flag is '0'
			RegWr 		<= '0';							-- Does not write in registers
			RegSel 		<= '1';							-- Selects Rd
			AluSrc		<= '0';							-- Selects the register as second ALU's input
			AluCtr 		<= "10";						-- Selects subtraction in ALU
			PSRen		<= '1';							-- Update the Processor State
			MemWr		<= '0';							-- Does not write in data memory
			WrSrc		<= '0';							-- Value of WrSrc does not matter because it we do not write in the registers
			Rn 			<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rd			<= Instr(20 downto 16);			-- Address of register Rd is on bits 20 to 16
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a I-type instruction
			Imm 		<= Instr(15 downto 0);			-- Value of Imm is on bits 15 to 0
			Offset		<= (others => '0');				-- Value of Offset does not matter because it is a I-type instruction
			
			
		-- LW
		when "100011" =>
			curr_instr 	<= LW;
			PCsel		<= '0';							-- Go to next address in instruction memory
			RegWr 		<= '1';							-- Writes in registers
			RegSel 		<= '1';							-- Selects Rd
			AluSrc		<= '1';							-- Selects the immediate value as second ALU's input
			AluCtr 		<= "00";						-- Selects the addition
			PSRen		<= '0';							-- Do not use the state flags
			MemWr		<= '0';							-- Does not rite in data memory
			WrSrc		<= '1';							-- Writes data memory's output in registers
			Rn 			<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rd			<= Instr(20 downto 16);			-- Address of register Rd is on bits 20 to 16
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a I-type instruction
			Imm 		<= Instr(15 downto 0);			-- Value of Imm is on bits 15 to 0
			Offset		<= (others => '0');				-- Value of Offset does not matter because it is a I-type instruction
			
			
		-- SW
		when "101011" =>
			curr_instr 	<= SW;
			PCsel		<= '0';							-- Go to next address in instruction memory
			RegWr 		<= '0';							-- Does not write in registers
			RegSel 		<= '1';							-- Selects Rd
			AluSrc		<= '1';							-- Selects the immediate value as second ALU's input
			AluCtr 		<= "00";						-- Selects the addition
			PSRen		<= '0';							-- Do not use the state flags
			MemWr		<= '1';							-- Writes in data memory
			WrSrc		<= '0';							-- Writes ALU's output in registers	
			Rn 			<= Instr(25 downto 21);			-- Address of register Rn is on bits 25 to 21
			Rd			<= Instr(20 downto 16);			-- Address of register Rd is on bits 20 to 16
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a I-type instruction
			Imm 		<= Instr(15 downto 0);			-- Value of Imm is on bits 15 to 0
			Offset		<= (others => '0');				-- Value of Offset does not matter because it is a I-type instruction		
		
		
		-- J-type instruction
		-- J
		when "000010" =>
			curr_instr 	<= J;
			PCsel		<= '1';							-- Skip addresses
			RegWr 		<= '0';							-- Does not write in registers because it is J instruction
			RegSel 		<= '0';							-- Value of RegSel does not matter because it is a J-type instruction
			AluSrc		<= '0';							-- Value of AluSrc does not matter because it is J-type instruction
			AluCtr 		<= "00";						-- Value of AluCtr does not matter because it is J-type instruction
			PSRen		<= '0';							-- Do not use the state flags
			MemWr		<= '0';							-- Does not write in data memory
			WrSrc		<= '0';							-- Value of WrSrc does not matter because it is J-type instruction
			Rn 			<= (others => '0');				-- Address of register Rn does not matter because it is a J-type instruction
			Rd			<= (others => '0');				-- Address of register Rd does not matter because it is a J-type instruction
			Rm 			<= (others => '0');				-- Address of register Rm does not matter because it is a J-type instruction
			Imm 		<= (others => '0');				-- Value of Imm does not matter becaue it is J-type instruction
			Offset		<= Instr(25 downto 0);			-- Value of Offset is on bits 25 to 0
			
		
		when others =>
			-- If it is not an instruction, does nothing, i.e. does not write in registers nor data memory etc...
			curr_instr	<= NaI;	
			PCsel		<= '0';							-- Go to next address in instruction memory
			RegWr 		<= '0';							-- Does not write in registers because we do not want to do anything
			RegSel 		<= '0';							-- Value of RegSel does not matter because we do not do anything
			AluSrc		<= '0';							-- Value of AluSrc does not matter because we do not do anything
			AluCtr 		<= "00";						-- Value of AluCtr does not matter because we do not do anything
			PSRen		<= '0';							-- Do not use the state flags
			MemWr		<= '0';							-- Does not write in data memory
			WrSrc		<= '0';							-- Value of WrSrc does not matter because we do not do anything
			Rn 			<= (others => '0');				-- Address of register Rn does not matter we do not do anything
			Rd			<= (others => '0');				-- Address of register Rd does not matter we do not do anything
			Rm 			<= (others => '0');				-- Address of register Rm does not matter we do not do anything
			Imm 		<= (others => '0');				-- Value of Imm does not matter because we do not do anything
			Offset		<= (others => '0');				-- Value of Offset does not matter because we do not do anything
		end case;	
	end process;
end architecture;