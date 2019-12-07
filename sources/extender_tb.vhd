-- File 		:	extender_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 32-bit extender
-- Released 	:	18/09/2019
-- Updated		: 	24/09/2019 : 	Refactoring in order to instantiate
--									a component instead of a non-visible entity

library ieee;
use ieee.std_logic_1164.all;
use std.standard.all;
use ieee.numeric_std.all; 

entity extender_tb is port(
	OK	: 	inout boolean := true);
end entity;

architecture bench of extender_tb is
	component extender is 
		generic (	N	: 	integer);									
		port 	(	I 	: 	in std_logic_vector((N - 1) downto 0);   	
					Y 	: 	out std_logic_vector(31 downto 0));       	
	end component;
   
	constant N	:	integer := 12;							-- Input's size in bits
	
  	signal I	: 	std_logic_vector((N - 1) downto 0);		-- N-bit input bus
  	signal Y 	: 	std_logic_vector(31 downto 0);    		-- 32-bit output bus

begin

	-- Unit Under Test
	UUT : extender	generic map(N => N)
					port map(	I => I,
								Y => Y);
	
	process
	begin
		
		-- Extension of a negative number
		I <= std_logic_vector(to_signed(-19, N)); 				-- I takes the value -19
		wait for 10 ns;
		
		-- Checks that the input and output are the same number
		OK <= (signed(Y) = signed(I));
		assert OK report "Error while extending a negative number" severity warning;
		
		
		-- Extension of a positive number
		I <= std_logic_vector(to_signed(12, N)); 				-- I takes the value 12
		wait for 10 ns;
		
		-- Checks that the input and output are the same number
		OK <= (signed(Y) = signed(I));
		assert OK report "Error while extending a positive number" severity warning;
		
		
		-- Extension of zero
		I <= std_logic_vector(to_signed(0, N)); 				-- I takes the value 0
		wait for 10 ns;
		
		-- Checks that the input and output are the same number
		OK <= (signed(Y) = signed(I));
		assert OK report "Error while extending zero" severity warning;
		
		wait;
	end process;
end architecture;