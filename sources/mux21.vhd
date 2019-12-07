-- File			:	mux21.vhd
-- Block 		:	2v1 multiplexer.
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	N-bit 2v1 multiplexer.
--					Y = A if COM = 0
--					Y = B if COM = 1
--					Y is undefined otherwise
-- Context 		:	The block is part of the Processing Unit.
-- Released		:	17/09/2019
-- Updated		: 	


library ieee;
use ieee.std_logic_1164.all;


entity mux21 is
	generic (	N 		: 	integer);										-- Size of inputs/output in bits
	port 	(	A, B 	: 	in std_logic_vector((N - 1) downto 0);			-- N-bit input bus
				COM 	: 	in std_logic;                                	-- 1-bit input command
				Y 		: 	out std_logic_vector((N - 1) downto 0));      	-- N-bit output bus
end entity;

architecture behaviour of mux21 is
begin
  
	with COM select
		Y <=	A when '0',
				B when '1',
				(others => 'X') when others;        
end architecture;