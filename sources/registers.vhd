-- File			:	registers.vhd
-- Block 		:	Registers
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	32 * 32-bit registers. 
--					Reading is combinatorial : 
--						Bus A takes the value of register n°RA.
--						Bus B takes the value of register n°RB.
--					Writing is synchronous on clock's rising edge. It it controled by WE :
-- 						If WE = 1 at clock's rising edge, register n°RW takes the value of bus W.
--						If WE = 0 at clock's rising edge, no writing occurs.
-- Context 		:	The block is part of the Processing Unit.
-- Released		:	17/09/2019
-- Updated		: 	12/10/2019	:	Upgraded the number of registers from 16 to 32 in order to match a MIPS processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is port(
	CLK	:	in std_logic;							-- Clock
	RST	:	in std_logic;							-- Asynchronous reset on high level
	W 	: 	in std_logic_vector(31 downto 0);		-- 32-bit input data bus in writing mode
	RA	: 	in std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port A
	RB	:	in std_logic_vector(4 downto 0);		-- 5-bit input address bus in reading mode for port B
	RW	:	in std_logic_vector(4 downto 0);		-- 5-bit input address bus in writing mode
	WE	:	in std_logic;							-- Write Enable
	A	:	out std_logic_vector(31 downto 0);		-- 32-bit output bus in reading mode for port A
	B 	:	out std_logic_vector(31 downto 0));		-- 32-bit output bus in reading mode for port B
end entity;

architecture behaviour of registers is 

	-- Type used to define the 16 * 32-bit registers
	type table is array(31 downto 0) of std_logic_vector(31 downto 0); 

	-- Initialization function for the registers
	function init_registers return table is 
		variable result : table; 
	begin 
		for i in 31 downto 0 loop
			result(i) := (others => '0'); 			-- Every register is empty
		end loop; 
		return result; 
	end init_registers; 

	signal REG : table;								-- Creation of the registers
  
begin 

	-- Combinatorial reading
	A <= REG(to_integer(unsigned(RA)));				-- Bus A takes the value of registers n°RA
	B <= REG(to_integer(unsigned(RB)));				-- RA/RB are unsigned since they are addresses

	-- Synchronous writing on clock's rising edge
	process(CLK, RST)
	begin
		if RST = '1' then							-- Reset the registers by emptying them
			REG <= init_registers;

		elsif rising_edge(CLK) then 
			if WE = '1' then 
				REG(to_integer(unsigned(RW))) <= W;	-- Register n°RW takes the value of bus W if Write Enable is high
			end if; 
		end if; 
	end process; 
end architecture;  
          