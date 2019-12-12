-- File			:	mipsCPU.vhd
-- Block 		:	MIPS CPU
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Central Processing Unit
-- Context 		:	The block is composed of a Processing Unit, an Instruction Management Unit and a Control Unit.
-- Released		:	09/11/2019
-- Updated		: 	29/11/2019	:	Addition of a dummy output for the top-level synthesis

library ieee;
use ieee.std_logic_1164.all;

entity mipsCPU is port(
	-- Global inputs
	CLK 		: 	in std_logic;							-- Clock
	RST 		: 	in std_logic;							-- Asynchronous reset on high level
	DummyOut	:	out std_logic_vector(31 downto 0));		-- Output for the top-level synthesis
end entity;

architecture struct of mipsCPU is 
	component processingUnit is port(
		CLK 		: 	in std_logic;						
		RST 		: 	in std_logic;
		DummyOut	:	out std_logic_vector(31 downto 0);
		Rn			: 	in std_logic_vector(4 downto 0);	
		Rm			:	in std_logic_vector(4 downto 0);	
		Rd			:	in std_logic_vector(4 downto 0);	
		RegWr		:	in std_logic;
		RegSel		:	in std_logic;                     
		AluSrc 		: 	in std_logic;                     
		WrSrc 		:	in std_logic;
		AluCtr 		: 	in std_logic_vector(1 downto 0);    
		C			: 	out std_logic;				
		N 			:	out std_logic;					
		V 			:	out std_logic;					
		Z			:	out std_logic;	
		Imm 		: 	in std_logic_vector(15 downto 0);  
		Imm_32		:	out std_logic_vector(31 downto 0);
		MemWr 		: 	in std_logic);						
	end component processingUnit;
	
	component instrManagUnit is port(
		CLK		:	in std_logic;
		RST		:	in std_logic;
		Imm_32	:	in std_logic_vector(31 downto 0);
		Offset	:	in std_logic_vector(25 downto 0);
		PCsel	:	in std_logic;
		Instr	:	out std_logic_vector(31 downto 0));	
	end component instrManagUnit;
	
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
	end component controlUnit;
	
	
	signal Rn		:	std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode
	signal Rm		:	std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode
	signal Rd		:	std_logic_vector(4 downto 0);		-- 5-bit input address bus in writing mode
	signal RegWr	:	std_logic;							-- Register's Write Enable
	signal RegSel	:	std_logic;                       	-- 1-bit selector for input read registers
	signal AluSrc 	: 	std_logic;                       	-- 1-bit selector for ALU's inputs
	signal WrSrc 	:	std_logic;							-- 1-bit selector for input write register
	signal AluCtr 	: 	std_logic_vector(1 downto 0);    	-- 2-bit selector for the ALU's operation
	signal C		: 	std_logic;							-- Flag for carry in ALU's output
	signal N 		:	std_logic;                     		-- Flag for negative ALU's output
	signal V 		:	std_logic;							-- Flag for overflow in ALU's output
	signal Z		:	std_logic;							-- Flag for ALU's output equals to zero
	signal Imm 		: 	std_logic_vector(15 downto 0);   	-- Input bus on 16 bits for I-type instructions
	signal Imm_32 	: 	std_logic_vector(31 downto 0); 		-- Extended immediate value on 32 bits for I-type instrutions
	signal MemWr 	: 	std_logic;							-- Data Memory's Write Enable
	signal Offset	:	std_logic_vector(25 downto 0);		-- Address offset
	signal PCsel	:	std_logic;							-- Next address instruction selector for PC register
	signal Instr	:	std_logic_vector(31 downto 0);		-- Instruction to execute
	signal StateIn	:	std_logic_vector(31 downto 0);		-- 32-bit Processor State
	
	
	
begin

	D0 :	processingUnit port map(	CLK			=>	CLK,
										RST			=>	RST,
										DummyOut	=> DummyOut,
										Rn			=> 	Rn,
										Rm			=>	Rm,
										Rd			=> 	Rd,
										RegWr		=>	RegWr,
										RegSel		=> 	RegSel,
										AluSrc 		=>	AluSrc,
										WrSrc		=>	WrSrc,
										AluCtr		=>	AluCtr,
										C			=>	C,
										N			=> 	N,
										V			=>	V,
										Z			=>	Z,
										Imm			=>	Imm,
										Imm_32		=> 	Imm_32,
										MemWr		=>	MemWr);
	
	D1 : 	instrManagUnit port map(	CLK 	=>	CLK,
										RST		=> 	RST,
										Imm_32 	=> 	Imm_32,
										Offset 	=> 	Offset,
										PCsel 	=> 	PCsel,
										Instr 	=>  Instr);
										
	D2 :	controlUnit port map(	CLK		=> CLK,
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
									
	D3 :	StateIn <= x"0000000" & C & N & V & Z;
end architecture;