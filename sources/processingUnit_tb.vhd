-- File 		:	processingUnit_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the processing unit
-- Released 	:	21/09/2019
-- Updated		: 	24/09/2019 	: 	Variables names update
--					24/09/2019 	: 	Refactoring in order to instantiate
--									a component instead of a non-visible entity
--					30/09/2019 	:	Add signal initialisations
--					12/10/2019	:	Update to fit the new number of registers
--					12/10/2019	:	Update to fit the new size of the extender's input
--					09/11/2019	:	Update to fit the new outputs
--					29/11/2019	:	Update to fit the new outputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processingUnit_tb is 
end entity;

architecture bench of processingUnit_tb is
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
		Imm_32		: 	out std_logic_vector(31 downto 0);
		MemWr 		: 	in std_logic);						
	end component;

	-- Global inputs
	signal CLK 		: 	std_logic := '0';										-- Clock
	signal RST 		: 	std_logic;												-- Asynchronous reset on high level
	signal DummyOut	:	std_logic_vector(31 downto 0);							-- Output for the top-level synthesis

	-- Registers' inputs
	signal Rn		: 	std_logic_vector(4 downto 0)	:= (others => '0');		-- 5-bit input address bus in reading mode for port A
	signal Rm		:	std_logic_vector(4 downto 0)	:= (others => '0');		-- 5-bit input address bus in reading mode for port B
	signal Rd		:	std_logic_vector(4 downto 0)	:= (others => '0');		-- 5-bit input address bus in writing mode
	signal RegWr	:	std_logic	:= '0';										-- Register's Write Enable
	
	-- Mux21s' inputs
	signal RegSel 	:	std_logic	:= '0';                   					-- 1-bit input command for mux n°1 at the input of registers for register selection
	signal AluSrc 	: 	std_logic	:= '0';                      				-- 1-bit input command for mux n°2 at the output of registers
	signal WrSrc 	:	std_logic	:= '0';										-- 1-bit input command for mux n°3 at the output of ALU
	
	-- ALU's inputs/outputs
	signal AluCtr 	: 	std_logic_vector(1 downto 0)	:= (others => '0');  	-- 2-bit input selector
	signal C		: 	std_logic;												-- Flag for carry in output
																				-- (See alu.vhd for explanations)
	signal N 		:	std_logic;                     							-- Flag for negative output
																				-- (See alu.vhd for explanations)
	signal V 		:	std_logic;												-- Flag for overflow in output
																				-- (See alu.vhd for explanations)
	signal Z		:	std_logic;												-- Flag for output equals to zero  
																				-- (See alu.vhd for explanations)	

	-- Extender's input
	signal Imm 		: 	std_logic_vector(15 downto 0)	:= (others => '0'); 	-- Input bus on 16 bits
	signal Imm_32 	: 	std_logic_vector(31 downto 0)	:= (others => '0');		-- Extended immediate value on 32 bits

	-- Data memory's inpupt
	signal MemWr 	: 	std_logic	:= '0';										-- Data Memory's Write Enable
	
	constant period	: 	time := 10 ns;											-- Period of the clock

begin

	UUT : processingUnit port map(	CLK			=>	CLK,
									RST			=>	RST,
									DummyOut	=>	DummyOut,
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
	
	
	-- Clock
	clock : process					
	begin
		for i in 0 to 20 loop
			CLK <= not CLK;
			wait for period / 2;
		end loop;
		wait;
	end process clock;
	
	test : process
	begin
	
		-- Sets the registers
		RST <= '1', '0' after 1 ns;
		wait for period / 2;
		
		-- Writing an immediate value in a register
		-- It is similar to the addition of an empty register with an immediate value
		-- R(1) = R(1) + 19 = 0 + 19 = 19
		Rn		<=	std_logic_vector(to_unsigned(1, 5));		-- Rn is the regiter n°1
		Rm		<=	std_logic_vector(to_unsigned(0, 5));		-- Value of Rm does not matter at this point
		Rd		<=	std_logic_vector(to_unsigned(1, 5));		-- Rd is the register n°1
		Imm		<=	std_logic_vector(to_signed(19, 16));		-- Imm is 19
		RegWr 	<=	'1'; 										-- Enables writing in registers
		RegSel 	<= 	'1';										-- Chooses Rd at the input of the registers
		AluSrc 	<= 	'1';										-- Chooses the immediate value for mux21 n°2
		AluCtr 	<= 	"00"; 										-- Addition in ALU
		MemWr 	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc	<= 	'0'; 										-- Chooses the ALU's output
		wait for period; 	
		
		
		-- Writing an immediate value in a register
		-- R(5) = R(5) + (-31) = 0 + (-31) = -31
		Rn		<=	std_logic_vector(to_unsigned(5, 5));		-- Rn is the regiter n°5
		Rd		<=	std_logic_vector(to_unsigned(5, 5));		-- Rd is the register n°5
		Imm		<=	std_logic_vector(to_signed(-31, 16));		-- Imm is -31
		RegWr 	<=	'1'; 										-- Enables writing in registers
		RegSel 	<= 	'1';										-- Chooses Rd at the input of the registers
		AluSrc 	<= 	'1';										-- Chooses the immediate value for mux21 n°2
		AluCtr 	<= 	"00"; 										-- Addition in ALU
		MemWr 	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
		
		-- Addition of 2 registers
		-- R(9) = R(1) + R(5) = 19 + (-31) = -12
		Rn 		<= 	std_logic_vector(to_unsigned(1, 5));		-- Rn is the regiter n°1
		Rm 		<= 	std_logic_vector(to_unsigned(5, 5));		-- Rm is the regiter n°5
		Rd 		<= 	std_logic_vector(to_unsigned(9, 5));		-- Rd is the regiter n°9
		RegWr 	<= 	'1'; 										-- Enables writing in registers
		RegSel 	<= 	'0';										-- Chooses Rm at the input of the registers
		AluSrc 	<= 	'0';										-- Chooses the register for mux21 n°2
		AluCtr 	<= 	"00"; 										-- Addition in ALU
		MemWr 	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
		
		-- Substraction of 2 registers
		-- R(7) = R(5) - R(9) = (-31) - (-12) = -19 
		Rn 		<= 	std_logic_vector(to_unsigned(5, 5));		-- Rn is the regiter n°5
		Rm 		<= 	std_logic_vector(to_unsigned(9, 5));		-- Rm is the regiter n°9
		Rd 		<= 	std_logic_vector(to_unsigned(7, 5));		-- Rd is the regiter n°7
		RegWr 	<= 	'1'; 										-- Enables writing in registers
		RegSel 	<= 	'0';										-- Chooses Rm at the input of the registers
		AluSrc 	<= 	'0';										-- Chooses the register for mux21 n°2
		AluCtr 	<= 	"10"; 										-- Substraction in ALU
		MemWr 	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
		
		-- Substraction of an immediate value with a register 
		-- R(2) = R(1) - 11 = 19 - 11 = 8
		Rn		<=	std_logic_vector(to_unsigned(1, 5));		-- Rn is the regiter n°1
		Rd		<=	std_logic_vector(to_unsigned(2, 5));		-- Rd is the register n°2
		Imm		<=	std_logic_vector(to_signed(11, 16));		-- Imm is 11
		RegWr 	<=	'1'; 										-- Enables writing in registers
		RegSel 	<= 	'1';										-- Chooses Rd at the input of the registers
		AluSrc 	<= 	'1';										-- Chooses the immediate value for mux21 n°2
		AluCtr 	<= 	"10"; 										-- Substraction in ALU
		MemWr	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
		
		-- Copy a register in another register
		-- R(15) = R(2) = 8
		Rn 		<= 	std_logic_vector(to_unsigned(2, 5));		-- Rn is the regiter n°2
		Rd 		<= 	std_logic_vector(to_unsigned(15, 5));		-- RW is the regiter n°15
		RegWr 	<=	'1'; 										-- Enables writing in registers
		AluCtr 	<= 	"11"; 										-- Chooses Rn at the output of the ALU
		MemWr 	<= 	'0'; 										-- Chooses not to write in the data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
	
		-- Writing the value of a register in the data memory
		-- M(63) = R(1) = 19
		Rm 		<= 	std_logic_vector(to_unsigned(1, 5));		-- Rm is the regiter n°1
		Imm		<= 	std_logic_vector(to_unsigned(63, 16)); 		-- Imm is 63
		RegWr 	<= 	'0'; 										-- Disables writing in registers
		RegSel 	<= 	'0';										-- Chooses Rm at the input of the registers
		AluSrc 	<= 	'1'; 										-- Chooses the immediate value for mux21 n°2
		AluCtr 	<= 	"01"; 										-- Chooses Imm at the output of the ALU	
		MemWr 	<= 	'1'; 										-- Enables writing in data memory
		WrSrc 	<= 	'0'; 										-- Chooses the ALU's output
		wait for period;
		
		
		-- Reading the value from a word of the the data memory to a register
		-- R(12) = M(63) = 19
		Rd 		<= 	std_logic_vector(to_unsigned(12, 5));		-- Rd is the regiter n°12
		Imm		<= 	std_logic_vector(to_unsigned(63, 16)); 		-- Imm is 63
		RegWr 	<= 	'1'; 										-- Enables writing in registers
		AluSrc 	<= 	'1'; 										-- Chooses the immediate value for mux21 n°2
		AluCtr 	<= 	"01"; 										-- Chooses Imm at the output of the ALU	
		MemWr 	<= 	'0'; 										-- Disables writing in data memory
		WrSrc 	<= 	'1'; 										-- Chooses the data memory's output
		wait for period;		
	
		wait;
	end process test;
end architecture;