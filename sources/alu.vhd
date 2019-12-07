-- File			:	alu.vhd
-- Block 		:	Arithmetic and Logic Unit
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Executes the different possible operations :
-- 					According to a 2-bit input selector, the output is whether
--					The first input, the second input, the addition of the two inputs
--					or the substration of the two inputs.
-- Context 		:	The block is part of the Processing Unit.
-- Released		:	17/09/2019
-- Updated		: 	21/09/2019 : Add functionalities for C and V flags	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is port(
	A, B 	:	in std_logic_vector(31 downto 0);  	-- 32-bit input bus
	SEL 	:	in std_logic_vector(1 downto 0);   	-- 2-bit input selector
	Y 		:	out std_logic_vector(31 downto 0); 	-- 32-bit output
	C		: 	out std_logic;						-- Flag for carry in output
													-- (Only relevant for unsigned numbers)
													-- C = 1 if Y < A + B in case of addition or
													-- if Y > A - B in case of substraction,
													-- C = 0 otherwise
	N 		:	out std_logic;                     	-- Flag for negative output
													-- N = 1 if S < 0, N = 0 otherwise
	V 		:	out std_logic;						-- Flag for overflow in output
													-- (Only relevant to signed numbers)
													-- V = 1 if the MSB(A) = MSB(B) /= MSB(Y) in case of addition or
													-- if MSB(A) /= MSB(B) = MSB(Y), V = 0 otherwise
	Z		:	out std_logic);						-- Flag for output equals to zero
													-- Z = 1 if Y = 0, Z = 0 otherwise
end entity; 

architecture behaviour of alu is
	signal Y_temp :	std_logic_vector(31 downto 0);
begin
	
	process(A, B, SEL)
	begin
	
		case SEL is
			when "00" => Y_temp <= std_logic_vector(signed(A) + signed(B));		-- It does not matter whether we convert to signed 
																				-- or unsigned since the operations are the same for 
																				-- two's complement. The same goes for the subtraction.
			when "01" => Y_temp <= B;
			when "10" => Y_temp <= std_logic_vector(signed(A) - signed(B));
			when "11" => Y_temp <= A;
			when others => Y_temp <= (others => 'X');
		end case;		
	end process;
	 
	C <=	'1' when ((SEL = "00") and (unsigned(Y_temp) < unsigned(A) or unsigned(Y_temp) < unsigned(B))) else
			'1' when ((SEL = "10") and (unsigned(Y_temp) > unsigned(A) and unsigned(Y_temp) > unsigned(B))) else
			'0';	
	N <= 	Y_temp(31);
	V <= 	'1' when ((SEL = "00") and (A(31) = B(31)) and (A(31) /= Y_temp(31))) else
			'1' when ((SEL = "10") and (A(31) /= B(31)) and (A(31) /= Y_temp(31))) else
			'0';
	Z <= 	'1' when (Y_temp = x"00000000") else
			'0';
	Y <= 	Y_temp;
	
end architecture;		