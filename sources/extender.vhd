-- File			:	extender.vhd
-- Block 		:	Extender
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Extends the sign of an N-bit input to a
--					32-bit output.
-- Context 		:	The block is part of the Processing Unit.
-- Released		:	18/09/2019
-- Updated		: 	19/11/2019	:	Modified the code to avoid using std_logic_arith

library ieee;
use ieee.std_logic_1164.all;


entity extender is
	generic (	N	: 	integer);									-- Input's size in bits
	port 	(	I 	: 	in std_logic_vector((N - 1) downto 0);   	-- N-bit input bus
				Y 	: 	out std_logic_vector(31 downto 0));   		-- 32-bit output bus
end entity;


architecture behaviour of extender is 
begin 
	Y((N - 1) downto 0) <= I;
	Y(31 downto N) <= (others => I(N - 1));
end architecture;