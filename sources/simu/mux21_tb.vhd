-- File 		:	mux21_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the N-bit 2v1 multiplexer
-- Released 	:	17/09/2019
-- Updated		: 	24/09/2019 : 	Refactoring in order to instantiate
--									a component instead of a non-visible entity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux21_tb is port(
	OK : inout boolean := true);
end entity;

architecture bench of mux21_tb is
	component mux21 is
		generic (	N 		: 	integer);										
		port 	(	A, B 	: 	in std_logic_vector((N - 1) downto 0);		
					COM 	: 	in std_logic;                                	
					Y 		: 	out std_logic_vector((N - 1) downto 0));   
	end component;

	constant N : integer := 32;
	
	signal A, B : 	std_logic_vector((N - 1) downto 0);
	signal COM	:	std_logic;
	signal Y	:	std_logic_vector((N - 1) downto 0);

begin

	-- Unit Under Test
	UUT : mux21 	generic map(N => N) 
					port map(	A => A,
								B => B,
								COM => COM,
								Y => Y);
													
	process
	begin
	
		A <= std_logic_vector(to_signed(-19, N));
		B <= std_logic_vector(to_signed(12, N));
		
		-- Checks that the output is A when COM = 0
		COM <= '0';
		wait for 10 ns;
		
		OK <= (Y = A);
		assert OK report "Error for COM=0" severity warning;
		
		
		-- Checks that the output is B when COM = 1
		COM <= '1';
		wait for 10 ns;
		
		OK <= (Y = B);
		assert OK report "Error for COM=1" severity warning;
		
		
		-- Checks the output if the input change
		B <= std_logic_vector(to_signed(31, N));
		wait for 10 ns;
		
		OK <= (Y = B);
		assert OK report "Error for COM=1 and change for B" severity warning;
		
		-- Checks if both COM and input change
		A <= std_logic_vector(to_signed(-7, N));
		COM <= '0';
		wait for 10 ns;
		
		OK <= (Y = A);
		assert OK report "Error for change in COM and input" severity warning;
		
		wait;
	end process;
end architecture;
												