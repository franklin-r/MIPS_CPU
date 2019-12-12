-- File			:	pc.vhd
-- Block 		:	Program Counter
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	32-bit Program Counter register storing the next instruction's address. 
--					At each clock's rising edge, the register sends the input address
--					to the instruction memory.
-- Context 		:	The block is part of the Instructions Management Unit.
-- Released		:	08/11/2019
-- Updated		: 

library ieee;
use ieee.std_logic_1164.all;

entity pc is port(	
	CLK		: 	in std_logic;								-- Clock
	RST 	: 	in std_logic;								-- Asynchronous reset on high level
	AddrIn 	: 	in std_logic_vector(31 downto 0);			-- 32-bit input address
	AddrOut : 	out std_logic_vector(31 downto 0)); 		-- 32-bit output address
end entity; 


architecture behaviour of pc is 
  
	begin 
		process(CLK, RST)
		begin
			if RST = '1' then
				AddrOut <= (others => '0');		-- Output address is the first one in the instruction memory
				
			elsif rising_edge(CLK) then 
				AddrOut <= AddrIn;				-- Copy the input address to output
			end if; 
		end process; 
 end architecture;