-- File 		:	dataMemory_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 64 * 32-bit data memory
-- Released 	:	19/09/2019
-- Updated		: 	24/09/2019 : 	Refactoring in order to instantiate
--									a component instead of a non-visible entity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataMemory_tb is port( 
	OK: inout boolean := true);
end entity;

architecture bench of dataMemory_tb is	
	component dataMemory is port(
		CLK 	: 	in std_logic;
		RST		:	in std_logic;		
		DataIn 	: 	in std_logic_vector(31 downto 0); 	
		Addr 	: 	in std_logic_vector(5 downto 0); 		
		DataOut : 	out std_logic_vector(31 downto 0);		
		WE 		: 	in std_logic); 
	end component;
	
	signal CLK 		:	std_logic := '0';										-- Clock
	signal RST		:	std_logic;												-- Asynchronous reset on high level
	signal DataIn 	: 	std_logic_vector(31 downto 0)	:= (others => '0'); 	-- 32-bit writing input bus
	signal Addr 	: 	std_logic_vector(5 downto 0) 	:= (others => '0'); 	-- 6-bit address input bus for writing and reading
	signal DataOut 	: 	std_logic_vector(31 downto 0) 	:= (others => '0');		-- 32-bit reading output bus
	signal WE 		: 	std_logic := '0'; 										-- Write Enable
	
	constant period	: time := 10 ns;											-- Period of the clock

begin

	-- Unit Under Test
	UUT : dataMemory port map(	CLK 	=>	CLK,
								RST		=> 	RST,
								DataIn 	=> 	DataIn,
								Addr 	=> 	Addr,
								DataOut => 	DataOut,
								WE 		=> 	WE);
	
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
		RST <= '1', '0' after period / 2;
		wait for period / 2;
		
		-- Writes the value 19 in register n°12
		WE <= '1';										-- Enables writing
		DataIn <= std_logic_vector(to_signed(19, 32));	-- Bus DataIn takes the value 19
		Addr <= std_logic_vector(to_unsigned(63, 6));	-- Addr takes the value 63								
		wait for period;
														-- Here, we should have the value of 19 in register n°12
														
		-- Writes the value 31 in register n°7												
		DataIn <= std_logic_vector(to_signed(31, 32));	-- Bus DataIn takes the value 31
		Addr <= std_logic_vector(to_unsigned(55, 6));	-- Addr takes the value 55
		wait for period;
														-- Here, we should have the value of 31 in register n°7
		
		-- To test the writing operations, we read the value of registers n°12 and n°7
		
		WE <= '0';										-- Disables writing
		Addr <= std_logic_vector(to_unsigned(63, 6));	-- Addr takes the value 63
		wait for period;

		-- We test the value in bus DataOut to check if both the writing and reading operations went well
		OK <= (to_integer(signed(DataOut)) = 19);
		assert OK report "Error in the first writing/reading operation" severity warning;
		
		
		Addr <= std_logic_vector(to_unsigned(55, 6));	-- Addr takes the value 55
		wait for period;
		
		OK <= (to_integer(signed(DataOut)) = 31);
		assert OK report "Error in the second writing/reading operation" severity warning;
		
		-- Now we try to overwrite register n°12
		
		-- Writes the value -27 in register n°12
		WE <= '1';										-- Enables writing
		DataIn <= std_logic_vector(to_signed(-27, 32));	-- Bus DataIn takes the value -27
		Addr <= std_logic_vector(to_unsigned(63, 6));	-- Addr takes the value 63
		wait for period;
														-- Here, we should have the value of -27 in register n°63
														
		-- We check the success by reading the register
		WE <= '0';										-- Disables writing
		Addr <= std_logic_vector(to_unsigned(63, 6));	-- Addr takes the value 63
		wait for period;
		
		OK <= (to_integer(signed(DataOut)) = -27);
		assert OK report "Error in the third writing/reading operation" severity warning;
		
		-- Now we try to write to write while WE = 0
		
		DataIn <= std_logic_vector(to_signed(5, 32));	-- Bus DataIn takes the value 5
		Addr <= std_logic_vector(to_unsigned(57, 6));	-- Addr takes the value 57
		wait for period;
														-- Here, nothing should have happened
			
		-- We read register n°15
		Addr <= std_logic_vector(to_unsigned(57, 6));	-- Addr takes the value 15
		wait for period;
		
		OK <= (to_integer(signed(DataOut)) = 0);
		assert OK report "Error in the fourth writing/reading operation" severity warning;
		
		
		-- We do a reset
		
		RST <= '1', '0' after period / 2;
		
		-- We check registers n°12 is empty now
		Addr <= std_logic_vector(to_unsigned(63, 6));	-- Addr takes the value 12
		wait for period;
		
		OK <= (to_integer(signed(DataOut)) = 0);
		assert OK report "Error in the first reset operation" severity warning;
		
		-- We check registers n°7 is empty
		Addr <= std_logic_vector(to_unsigned(55, 6));	-- Addr takes the value 7
		wait for period;
		
		OK <= (to_integer(signed(DataOut)) = 0);
		assert OK report "Error in the second reset operation" severity warning;

		wait;
	end process test;
end architecture;
