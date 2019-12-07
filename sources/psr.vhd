-- File			:	psr.vhd
-- Block 		:	Program State Register
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	32-bit Program State Register storing the value of the processor's state flags. 
--					At clock's rising edge :
--						If WE = 0 then the PSR keeps its value.
--						If WE = 1 then the PSR memorizes the value of the bus DataIn.
--					Flags C, N, V and Z are respectively stored on PSR's bits n° 3, 2, 1 and 0.
-- Context 		:	The block is part of the Control Unit
-- Released		:	08/11/2018
-- Updated		: 	09/11/2019	:	Changed the clock's edge sensitivity in order to avoid a double 
--									cycle for instructions

library ieee;
use ieee.std_logic_1164.all;

entity psr is port(	
	CLK 		: 	in std_logic;								-- Clock
	RST 		: 	in std_logic;								-- Asynchronous reset on high level
	WE 			: 	in std_logic;								-- Write Enable
	StateIn 	: 	in std_logic_vector(31 downto 0);			-- 32-bit input state bus
	StateOut	: 	out std_logic_vector(31 downto 0));			-- 32-bit output state bus
end entity;
  
architecture behaviour of psr is
	begin
		process(CLK, RST)
		begin
			if RST = '1' then
				StateOut <= (others => '0');						-- Resets the states to their initial value
				
			elsif falling_edge(CLK) then
				if WE = '1' then
					StateOut <= StateIn;
				end if;
			end if;
		end process;
end architecture;