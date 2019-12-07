-- File			:	processingUnit.vhd
-- Block 		:	Procesing Unit
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Processes the data and the operations.
-- Context 		:	The block is part of a MIPS processor.
-- Released		:	21/09/2019
-- Updated		: 	24/09/2019 	: 	Give variables more explicit names
--					24/09/2019 	: 	Refactoring in order to instantiate
--									components instead of a non-visible entities
--					12/10/2019	:	Update to fit the new number of registers
--					12/10/2019	:	Upgraded the size of the immediate to match the MIPS processor
--					09/11/2019	:	Added the extended 32-bit immediate value in order to connect to the Instruction Management Unit
--					29//11/2019 :	Addition of a dummy output for the top-level synthesis

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processingUnit is port(
	-- Global inputs/output
	CLK 		: 	in std_logic;						-- Clock
	RST 		: 	in std_logic;						-- Asynchronous reset on high level
	DummyOut	:	out std_logic_vector(31 downto 0);	-- Output for the top-level synthesis

	-- Registers' inputs
	Rn			: 	in std_logic_vector(4 downto 0);	-- 5-bit input address bus in reading mode for port A
	Rm			:	in std_logic_vector(4 downto 0);	-- 5-bit input address bus in reading mode for port B
	Rd			:	in std_logic_vector(4 downto 0);	-- 5-bit input address bus in writing mode
	RegWr		:	in std_logic;						-- Register's Write Enable
	
	-- Mux21s' inputs
	RegSel		:	in std_logic;                       -- 1-bit input command for mux n°1 at the input of registers for register selection
	AluSrc 		: 	in std_logic;                       -- 1-bit input command for mux n°2 at the output of registers
	WrSrc 		:	in std_logic;						-- 1-bit input command for mux n°3 at the output of ALU
	
	-- ALU's inputs/outputs
	AluCtr 		: 	in std_logic_vector(1 downto 0);    -- 2-bit input selector
	C			: 	out std_logic;						-- Flag for carry in output
													-- (See alu.vhd for explanations)
	N 			:	out std_logic;                     	-- Flag for negative output
													-- (See alu.vhd for explanations)
	V 			:	out std_logic;						-- Flag for overflow in output
													-- (See alu.vhd for explanations)
	Z			:	out std_logic;						-- Flag for output equals to zero  
													-- (See alu.vhd for explanations)	

	-- Extender's input/output
	Imm 		: 	in std_logic_vector(15 downto 0);   -- Input bus on 16 bits
	Imm_32 		: 	out std_logic_vector(31 downto 0); 	-- Extended immediate value on 32 bits

	-- Data memory's inpupt
	MemWr 		: 	in std_logic);						-- Data Memory's Write Enable
     
end entity;

architecture struct of processingUnit is 
	component alu is port(
		A, B 	:	in std_logic_vector(31 downto 0);  
		SEL 	:	in std_logic_vector(1 downto 0);   	
		Y 		:	out std_logic_vector(31 downto 0); 	
		C		: 	out std_logic;						
		N 		:	out std_logic;                     	
		V 		:	out std_logic;											
		Z		:	out std_logic);
	end component alu;
	
	component registers is port(
		CLK	:	in std_logic;							
		RST	:	in std_logic;							
		W 	: 	in std_logic_vector(31 downto 0);	
		RA	: 	in std_logic_vector(4 downto 0);		
		RB	:	in std_logic_vector(4 downto 0);		
		RW	:	in std_logic_vector(4 downto 0);		
		WE	:	in std_logic;							
		A	:	out std_logic_vector(31 downto 0);		
		B 	:	out std_logic_vector(31 downto 0));	
	end component registers;
	
	component mux21 is
		generic (	N 		: 	integer);										
		port 	(	A, B 	: 	in std_logic_vector((N - 1) downto 0);		
					COM 	: 	in std_logic;                                	
					Y 		: 	out std_logic_vector((N - 1) downto 0));   
	end component mux21;
	
	component extender is 
		generic (	N	: 	integer);									
		port 	(	I 	: 	in std_logic_vector((N - 1) downto 0);   	
					Y 	: 	out std_logic_vector(31 downto 0));       	
	end component extender;
	
	component dataMemory is port(
		CLK 	: 	in std_logic;	
		RST		:	in std_logic;
		DataIn 	: 	in std_logic_vector(31 downto 0); 	
		Addr 	: 	in std_logic_vector(5 downto 0); 		
		DataOut : 	out std_logic_vector(31 downto 0);		
		WE 		: 	in std_logic); 
	end component dataMemory;
	
	-- Register's signals
	signal busW		:	std_logic_vector(31 downto 0);		-- 32-bit input data bus in writing mode
															-- From mux21 n°3 to registers
	signal busA		:	std_logic_vector(31 downto 0);		-- 32-bit output bus in reading mode for port A
															-- From registers to ALU
	signal busB		:	std_logic_vector(31 downto 0);		-- 32-bit output bus in reading mode for port B
															-- From registers to mux n°2 and data memory
														
	-- Mux21s' signals
	signal Y_mux1	:	std_logic_vector(4 downto 0);		-- 5-bit output bus
															-- From mux21 n°1 to registers
	signal Y_mux2	: 	std_logic_vector(31 downto 0);		-- 32-bit output bus
															-- From mux21 n°2 to ALU
	
	-- ALU's signal
	signal AluOut	:	std_logic_vector(31 downto 0);		-- 32-bit output
															-- From ALU to mux21 n°3
															
	-- Extender's signal
	signal Y_ext	:	std_logic_vector(31 downto 0);   	-- 32-bit output bus
															-- From extender to mux21 n°2
															
	-- Data memory's signal
	signal DataOut 	:	std_logic_vector(31 downto 0);		-- 32-bit reading output bus
															-- From data memory to mux21 n°3
begin
	
	A0	:	mux21 	generic map(N	=>	5)
					port map(	A 	=> 	Rm,
								B 	=> 	Rd,
								COM => 	RegSel,
								Y 	=>	Y_mux1);
														
	A1	:	registers port map(	CLK	=>	CLK,
								RST	=> 	RST,
								W 	=> 	busW,
								RA 	=> 	Rn,
								RB 	=> 	Y_mux1,
								RW 	=> 	Rd,
								WE 	=> 	RegWr,
								A 	=> 	busA,
								B 	=> 	busB);
	
	A2 	:	mux21 	generic map(N 	=>	32)
					port map(	A 	=> 	busB,
								B 	=>	Y_ext,
								COM	=> 	AluSrc,
								Y 	=>	Y_mux2);
														
	A3	:	extender 	generic map(	N 	=> 	16)
						port map(		I 	=> 	Imm,
										Y	=> 	Y_ext);
	
	A4	:	alu port map(	A 	=>	busA,
							B 	=>	Y_mux2,
							SEL	=>	AluCtr,
							Y	=> 	AluOut,
							C	=> 	C,
							N 	=> 	N,
							V 	=> 	V,
							Z	=> 	Z);
	
	A5	:	dataMemory port map(	CLK		=>	CLK,
									RST		=>	RST,
									DataIn 	=>	busB,
									Addr	=>	AluOut(5 downto 0),
									DataOut	=>	DataOut,
									WE		=> 	MemWr);
														
	A6	:	mux21 	generic map(N	=>	32)
					port map(	A 	=> 	AluOut,
								B 	=>	DataOut,
								COM =>	WrSrc,
								Y	=>	busW);
	
	Imm_32 <= Y_ext;
	DummyOut <= busB;
end architecture;