-- File 		:	instrMemory_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 64 * 32-bit instructions memory
-- Released 	:	08/11/2018
-- Updated		: 	09/11/2019	:	Update the edge sensitivity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrMemory_tb is port( 
	OK: inout boolean := true);
end entity;

architecture bench of instrMemory_tb is	
	component instrMemory is port(
		Addr 	: 	in std_logic_vector(31 downto 0); 		
		Instr	: 	out std_logic_vector(31 downto 0)); 
	end component;
	
	signal Addr 	: 	std_logic_vector(31 downto 0) := (others => '0'); 		-- 32-bit instruction's address
	signal Instr 	: 	std_logic_vector(31 downto 0);							-- 32-bit output instruction

begin

	-- Unit Under Test
	UUT : instrMemory port map(	Addr 		=> 	Addr,
								Instr 		=> 	Instr);

	test : process
	begin
		
		-- In this test, we check the output value of the instruction memory and compare with 
		-- what we set in the cell architecture.
		-- We are supposed to have : INSTRMEM(0) = 0x12345678; INSTRMEM(1) = 0x87654321; 
		-- INSTRMEM(2) = 0xABCDEF01; INSTRMEM(3) = 0x19121997
		
		-- Reads value at Addr n°0
		Addr <= std_logic_vector(to_unsigned(0, 32));		-- Addr takes value 0
		wait for 10 ns;

		OK <= (Instr = x"12345678");
		assert OK report "Error in the first operation" severity warning;
		
		
		-- Reads value at Addr n°1
		Addr <= std_logic_vector(to_unsigned(1, 32));		-- Addr takes value 1
		wait for 10 ns;

		OK <= (Instr = x"87654321");
		assert OK report "Error in the second operation" severity warning;
		
		
		-- Reads value at Addr n°2
		Addr <= std_logic_vector(to_unsigned(2, 32));		-- Addr takes value 2
		wait for 10 ns;

		OK <= (Instr = x"ABCDEF01");
		assert OK report "Error in the third operation" severity warning;
		
		
		-- Reads value at Addr n°3
		Addr <= std_logic_vector(to_unsigned(3, 32));		-- Addr takes value 3
		wait for 10 ns;

		OK <= (Instr = x"19121997");
		assert OK report "Error in the fourth operation" severity warning;
		
		
		-- Reads value at Addr n°4
		Addr <= std_logic_vector(to_unsigned(4, 32));		-- Addr takes value 4
		wait for 10 ns;

		OK <= (Instr = x"55555555");
		assert OK report "Error in the fifth operation" severity warning;
		
		
		-- From here, every storage space has the value 0
		-- Reads value at Addr n°5
		Addr <= std_logic_vector(to_unsigned(5, 32));		-- Addr takes value 5
		wait for 10 ns;

		OK <= (Instr = x"00000000");
		assert OK report "Error in the fifth operation" severity warning;

		wait;
	end process test;
end architecture;
