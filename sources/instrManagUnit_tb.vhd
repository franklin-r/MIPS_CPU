-- File 		:	instrManagUnit_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the Instructions Management Unit
-- Released 	:	08/11/2018
-- Updated		: 	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrManagUnit_tb is port( 
	OK: inout boolean := true);
end entity;

architecture bench of instrManagUnit_tb is
	component instrManagUnit is port(
		CLK		:	in std_logic;
		RST		:	in std_logic;
		Imm_32	:	in std_logic_vector(31 downto 0);
		Offset	:	in std_logic_vector(25 downto 0);
		PCsel	:	in std_logic;
		Instr	:	out std_logic_vector(31 downto 0));	
	end component;
	
	-- Global inputs
	signal CLK		:	std_logic := '0';									-- Clock
	signal RST		:	std_logic;											-- Asynchronous reset on high level
	signal Imm_32	:	std_logic_vector(31 downto 0) := (others => '0');	-- 32-bit immediate value (extend of 16-bit immediate value of Itype instruction)
	
	-- Extender's input
	signal Offset	:	std_logic_vector(25 downto 0) := (others => '0');	-- Address offset
	
	-- Mux21's input
	signal PCsel	:	std_logic := '0';									-- Next address instruction selector for PC register
	
	-- Instructions memory's output
	signal Instr	:	std_logic_vector(31 downto 0) := (others => '0');	-- Instruction to execute	
	
	constant period	: time := 10 ns;										-- Period of the clock
	
begin
	-- Unit Under Test
	UUT : instrManagUnit port map(	CLK 	=>	CLK,
									RST		=> 	RST,
									Imm_32 	=> 	Imm_32,
									Offset 	=> 	Offset,
									PCsel 	=> 	PCsel,
									Instr 	=> 	Instr);
									
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
		
		-- Sets the memory
		RST <= '1', '0' after period / 10;
		
									
		-- In this testbench, we read the output instruction of the instruction memory and check if it 
		-- corresponds to what we are supposed to have at the corresponding address in the instruction memory.
		
		-- At reset, we automatically read the instruction at address n°0.
		-- The inputs we enter are for the next step. 
		-- Hence, the inputs are for step n + 1 and we assert outputs at step n.
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- Here, we are at first step, but we give inputs for the next step.
		-- Next step, we want to read the instruction three addresses further in a J-type instruction way, i.e. using Offset.
		-- It means we skip instructions at address n°1 and n°2 and go to address n°3 which have 0x19121997
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we do not need it.
		Offset 	<=	std_logic_vector(to_signed(2, 26));		-- Offset takes value 2 since we want the instruction 3 addresses further
		PCsel 	<= 	'1';									-- PCsel takes value '1' since we want to skip instructions
		wait for period;
		
		-- Here, we are not asserting the outputs corresponding to the preceding inputs, but the ones at reset, i.e. when
		-- we read instruction at address n°0.
		-- Therefore, we are asserting the instruction at address n°0, i.e. at reset.
		-- Here, we are supposed to have the instruction at address n°0, i.e. 0x12345678.
		OK <= (Instr = x"12345678");
		assert OK report "Error in the first operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- Now, at next step, we want to read the next instruction, which is at address n°4 and has value 0x55555555
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we want the next address
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we want the next address
		PCsel 	<= 	'0';									-- PCsel takes value '0' since we want the next address
		wait for period;
		
		-- Here, we expect to have instruction at address n°3, i.e. 0x19121997
		OK <= (Instr = x"19121997");
		assert OK report "Error in the second operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We try to go back to address n°1 which has value 0x87654321
		-- We do it in a J-type instruction way, i.e. using Offset.
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we do not need it.
		Offset 	<=	std_logic_vector(to_signed(-4, 26));	-- Offset takes value -4 since we want to go 3 addresses back
		PCsel 	<= 	'1';									-- PCsel takes value '1' since we want to make a jump
		wait for period;
		
		-- Here, we expect to have instruction at address n°4, i.e. 0x55555555
		OK <= (Instr = x"55555555");
		assert OK report "Error in the third operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We want to read the next instruction at address n°2 which has the value 0xABCDEF01
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we want the next address
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we want the next address
		PCsel 	<= 	'0';									-- PCsel takes value '0' since we want the next address
		wait for period;
		
		-- Here, we expect to have instruction at address n°1, i.e. 0x87654321
		OK <= (Instr = x"87654321");
		assert OK report "Error in the fourth operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We try to go back to address n°0 which has value 0x12345678
		-- We do it in a I-type instruction way, i.e. using Imm_32.
		Imm_32	<= 	std_logic_vector(to_signed(-3, 32));	-- Imm_32 takes value -3 since we want to go 2 addresses back
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we do not need it.
		PCsel 	<= 	'1';									-- PCsel takes value '1' since we want to make a jump
		wait for period;
		
		-- Here, we expect to have instruction at address n°2, i.e. 0xABCDEF01
		OK <= (Instr = x"ABCDEF01");
		assert OK report "Error in the fifth operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We try to go to address n°4, which has the value 0x55555555
		-- We do it in a I-type instruction way, i.e. using Imm_32.
		Imm_32	<= 	std_logic_vector(to_signed(3, 32));		-- Imm_32 takes value 3 since we want to go 4 addresses further
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we do not need it.
		PCsel 	<= 	'1';									-- PCsel takes value '1' since we want to make a jump
		wait for period;
		
		-- Here, we expect to have instruction at address n°0, i.e. 0x12345678
		OK <= (Instr = x"12345678");
		assert OK report "Error in the sixth operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We want to read the next instruction at address n°5 which has the value 0x00000000
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we want the next address
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we want the next address
		PCsel 	<= 	'0';									-- PCsel takes value '0' since we want the next address
		wait for period;
		
		-- Here, we expect to have instruction at address n°4, i.e. 0x55555555
		OK <= (Instr = x"55555555");
		assert OK report "Error in the seventh operation" severity warning;
		
		-------------------------------------------------------------------------------------------------------------------------------------
		
		-- We want to read the next instruction at address n°6 which has the value 0x00000000
		Imm_32	<= 	std_logic_vector(to_signed(0, 32));		-- Imm_32 takes value 0 since we want the next address
		Offset 	<=	std_logic_vector(to_signed(0, 26));		-- Offset takes value 0 since we want the next address
		PCsel 	<= 	'0';									-- PCsel takes value '0' since we want the next address
		wait for period;
		
		-- Here, we expect to have instruction at address n°5, i.e. 0x00000000
		OK <= (Instr = x"00000000");
		assert OK report "Error in the eigth operation" severity warning;
	
	
		wait;
	end process test;	
end architecture;
	