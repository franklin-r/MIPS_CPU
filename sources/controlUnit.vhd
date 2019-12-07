-- File			:	controlUnit.vhd
-- Block 		:	Control Unit
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Generate the signals corresponding to each instruction.
-- Context 		:	The block is part of a MIPS processor.
-- Released		:	09/11/2019

library ieee;
use ieee.std_logic_1164.all;

entity controlUnit is port(
	-- PSR's inputs
	CLK		:	in std_logic;							-- Clock
	RST		:	in std_logic;							-- Asynchronous reset on high level
	StateIn	:	in std_logic_vector(31 downto 0);		-- 32-bit input state bus
	
	-- Instruction Decoder's input/outputs
	Instr	:	in std_logic_vector(31 downto 0);		-- 32-bit instruction
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
	Offset	:	out std_logic_vector(25 downto 0));		-- Immediate value on 26 bits
end entity;

architecture struct of controlUnit is 
	component psr is port(
		CLK 		: 	in std_logic;								-- Clock
		RST 		: 	in std_logic;								-- Asynchronous reset on high level
		WE 			: 	in std_logic;								-- Write Enable
		StateIn 	: 	in std_logic_vector(31 downto 0);			-- 32-bit input state bus
		StateOut	: 	out std_logic_vector(31 downto 0));			
	end component psr;
	
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
		PSRen	:	out std_logic);							
	end component instrDecod;	
	
	signal PSRen	:	std_logic;							-- PSR's Write Enable
	signal StateOut	:	std_logic_vector(31 downto 0);		-- 32-bit PSR's output state bus
	
begin 

	C0 :	psr 	port map(	CLK			=> CLK,
								RST			=> RST,
								WE			=> PSRen,
								StateIn		=> StateIn,
								StateOut	=> StateOut);
								
	C1 :	instrDecod	port map(	Instr	=> Instr,
									PSRout	=> StateOut,
									Imm 	=> Imm,
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
end architecture;