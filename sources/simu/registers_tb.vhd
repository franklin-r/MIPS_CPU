-- File 		:	registers_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 32 * 32-but registers
-- Released 	:	17/09/2019
-- Updated		: 	24/09/2019 	: 	Refactoring in order to instantiate
--									a component instead of a non-visible entity
--					12/10/2019	:	Updated the testbench to fit the new number of registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_tb is port( 
	OK: inout boolean := true);
end entity;

architecture bench of registers_tb is
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
	end component;

	signal CLK	:	std_logic := '0';									-- Clock
	signal RST	:	std_logic;											-- Asynchronous reset on high level
	signal W 	: 	std_logic_vector(31 downto 0)	:= (others => '0');	-- 32-bit input data bus in writing mode
	signal RA	: 	std_logic_vector(4 downto 0) 	:= (others => '0');	-- 5-bit input address bus in reading mode for port A
	signal RB	:	std_logic_vector(4 downto 0) 	:= (others => '0');	-- 5-bit input address bus in reading mode for port B
	signal RW	:	std_logic_vector(4 downto 0) 	:= (others => '0');	-- 5-bit input address bus in writing mode
	signal WE	:	std_logic := '0';									-- Write Enable
	signal A	:	std_logic_vector(31 downto 0) 	:= (others => '0');	-- 32-bit output bus in reading mode for port A
	signal B 	:	std_logic_vector(31 downto 0) 	:= (others => '0');	-- 32-bit output bus in reading mode for port B
	
	constant period	: time := 10 ns;									-- Period of the clock

begin

	-- Unit Under Test
	UUT : registers port map(	CLK => CLK,
								RST => RST,
								W => W, 
								RA => RA, 
								RB => RB, 
								RW => RW, 
								WE => WE, 
								A => A, 
								B => B);
	
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
		RST <= '1', '0' after period / 2;
		wait for period / 2;
		
		-- Writes the value 19 in register n°12
		WE <= '1';										-- Enables writing
		W <= std_logic_vector(to_signed(19, 32));		-- Bus W takes the value 19
		RW <= std_logic_vector(to_unsigned(12, 5));		-- RW takes the value 12								
		wait for period;
														-- Here, we should have the value of 19 in register n°12
														
		-- Writes the value 31 in register n°7												
		W <= std_logic_vector(to_signed(31, 32));		-- Bus W takes the value 31
		RW <= std_logic_vector(to_unsigned(7, 5));		-- RW takes the value 7
		wait for period;
														-- Here, we should have the value of 31 in register n°7
		
		-- To test the writing operations, we read the value of registers n°12 and n°7
		
		WE <= '0';										-- Disables writing
		RA <= std_logic_vector(to_unsigned(12, 5));		-- RA takes the value 12
		RB <= std_logic_vector(to_unsigned(7, 5));		-- RB takes the value 7
		wait for period;

		-- We test the value got in bus A and B to check if both the writing and reading operations went well
		OK <= (to_integer(signed(A)) = 19);
		assert OK report "Error in the first writing/reading operation" severity warning;
		
		OK <= (to_integer(signed(B)) = 31);
		assert OK report "Error in the second writing/reading operation" severity warning;
		
		-- Now we try to overwrite register n°7
		
		-- Writes the value -27 in register n°7
		WE <= '1';										-- Enables writing
		W <= std_logic_vector(to_signed(-27, 32));		-- Bus W takes the value -27
		RW <= std_logic_vector(to_unsigned(7, 5));		-- RW takes the value 7
		wait for period;
														-- Here, we should have the value of -27 in register n°7
														
		-- We check the success by reading the register
		WE <= '0';										-- Disables writing
		RA <= std_logic_vector(to_unsigned(7, 5));		-- RA takes the value 7
		wait for period;
		
		OK <= (to_integer(signed(A)) = -27);
		assert OK report "Error in the third writing/reading operation" severity warning;
		
		-- Now we try to write while WE = 0
		
		W <= std_logic_vector(to_signed(5, 32));		-- Bus W takes the value 5
		RW <= std_logic_vector(to_unsigned(15, 5));		-- RW takes the value 15
		wait for period;
														-- Here, nothing should have happened
			
		-- We read register n°15
		RA <= std_logic_vector(to_unsigned(15, 5));		-- RA takes the value 15
		wait for period;
		
		OK <= (to_integer(signed(A)) = 0);
		assert OK report "Error in the fourth writing/reading operation" severity warning;
		
		-- We do a reset
		
		RST <= '1', '0' after period / 2;
		RA <= std_logic_vector(to_unsigned(12, 5));		-- RA takes the value 12
		RB <= std_logic_vector(to_unsigned(7, 5));		-- RB takes the value 7
		wait for period;								-- Registers n°12 and n°7 should be empty after reset
		
		OK <= (to_integer(signed(A)) = 0) and (to_integer(signed(B)) = 0);
		assert OK report "Error in the reset operation" severity warning;

		wait;
	end process test;
end architecture;
