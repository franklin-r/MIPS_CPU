-- File			:	instrManagUnit.vhd
-- Block 		:	Instructions Management Unit
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Generate the instructions to execute.
-- Context 		:	The block is part of a MIPS processor.
-- Released		:	08/11/2018
-- Updated		: 	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrManagUnit is port(
	-- Global inputs
	CLK		:	in std_logic;							-- Clock
	RST		:	in std_logic;							-- Asynchronous reset on high level
	Imm_32	:	in std_logic_vector(31 downto 0);		-- 32-bit immediate value (extend of 16-bit immediate value of I-type instructions)
	
	-- Extender's input
	Offset	:	in std_logic_vector(25 downto 0);		-- Address offset
	
	-- Mux21's input
	PCsel	:	in std_logic;							-- Next address instruction selector for PC register
	
	-- Instructions memory's output
	Instr	:	out std_logic_vector(31 downto 0));		-- Instruction to execute
end entity;

architecture struct of instrManagUnit is
	component extender is 
		generic (	N	: 	integer);									
		port 	(	I 	: 	in std_logic_vector((N - 1) downto 0);   	
					Y 	: 	out std_logic_vector(31 downto 0));       	
	end component extender;
	
	component mux21 is
		generic (	N 		: 	integer);										
		port 	(	A, B 	: 	in std_logic_vector((N - 1) downto 0);		
					COM 	: 	in std_logic;                                	
					Y 		: 	out std_logic_vector((N - 1) downto 0));   
	end component mux21;
	
	component pc is port(
		CLK 	: 	in std_logic;
		RST		:	in std_logic;	
		AddrIn 	: 	in std_logic_vector(31 downto 0); 		
		AddrOut : 	out std_logic_vector(31 downto 0)); 
	end component pc;
	
	component instrMemory is port(
		Addr 	: 	in std_logic_vector(31 downto 0); 		
		Instr 	: 	out std_logic_vector(31 downto 0)); 
	end component instrMemory;
	
	-- Extender's signal
	signal Offset_ext	:	std_logic_vector(31 downto 0);		-- 32-bit output bus
																-- From extender's output to mux21's second input
																
	-- Mux21's signal
	signal mux_in1 		:	std_logic_vector(31 downto 0);		-- First 32-bit input bus
	signal mux_in2		: 	std_logic_vector(31 downto 0);		-- Second 32-bit input bus
	signal mux_out		:	std_logic_vector(31 downto 0);		-- 32-bit output bus
																-- From mux21's output to PC's input
																
	-- PC's signal
	signal pc_out		:	std_logic_vector(31 downto 0);		-- 32-bit output bus
																-- From PC's output to mux21's first input and 
																-- instructions memory's Addr input	
																	
	constant one : signed(31 downto 0) := x"00000001";			
	
begin

	B0 :	extender 	generic map(	N 	=> 	26)
						port map(		I 	=> 	Offset,
										Y	=> 	Offset_ext);
										
	B1 : 	pc		port map(	CLK		=> CLK,
								RST		=> RST,
								AddrIn	=> mux_out,
								AddrOut	=> pc_out);
								
	B2 : 	mux_in1 <= std_logic_vector(signed(pc_out) + one);
	
	B3 : 	mux_in2 <= std_logic_vector(signed(pc_out) + one + signed(Offset_ext) + signed(Imm_32));
										
	-- Offset_ext can be negative so we need to convert it to signed.
	-- Moreover, we need to convert everything into signed because we cannot make an addition between a signed and an unsigned. 								
	B4 :	mux21 	generic map(N 	=>	32)
					port map(	A 	=> 	mux_in1,
								B 	=>	mux_in2,		
								COM	=> 	PCsel,
								Y 	=>	mux_out);
								
	
								
	B5 :	instrMemory port map(	Addr		=> pc_out,
									Instr		=> Instr);
end architecture;

	
	
	