-- File			:	dataMemory.vhd
-- Block 		:	Data memory
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	64 * 32-bit registers for the data memory. 
--					Reading is combinatorial : 
--						Bus DataOut takes the value of registers n°Addr
--					Writing is synchronous on clock's rising edge. It it controled by WE :
-- 						If WE = 1 at clock's rising edge, register n°Addr takes the value of bus DataIn.
--						If WE = 0 at clock's rising edge, no writing occurs.
-- Context 		:	The block is part of the Processing Unit.
-- Released		:	18/09/2019
-- Updated		: 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataMemory is port(
	CLK 	: 	in std_logic;							-- Clock
	RST		:	in std_logic;							-- Asynchronous reset on high level
	DataIn 	: 	in std_logic_vector(31 downto 0); 		-- 32-bit writing input bus
	Addr 	: 	in std_logic_vector(5 downto 0); 		-- 6-bit address input bus for writing and reading
	DataOut : 	out std_logic_vector(31 downto 0);		-- 32-bit reading output bus
	WE 		: 	in std_logic); 							-- Write Enable
end entity; 


architecture behaviour of dataMemory is 

	-- Type used to define the 64 * 32-bit registers
  	type table is array(63 downto 0) of std_logic_vector(31 downto 0); 
  
	function init_mem return table is 
		variable result : table; 
  	begin 
		for i in 63 downto 0 loop
			result(i) := (others => '0'); 		-- Every register is empty
		end loop; 
		return result; 
	end init_mem; 
  
  	signal MEM : table;							-- Creation of the data memory
  
begin 
    
	-- Combinatorial reading
	DataOut <= MEM(to_integer(unsigned(Addr))); 	-- Bus DataOut takes the value of registers n°Addr
													-- Addr is unsigned since it is and address
	
	-- Synchronous writing on clock's rising edge
    process(CLK, RST)
    begin
        if RST = '1' then							-- Reset the memory by emptying it
			MEM <= init_mem;
			
		elsif rising_edge(CLK) then 
			if WE = '1' then 
				MEM(to_integer(unsigned(Addr))) <= DataIn;  	-- Register n°Addr takes the value of bus DataIn if Write Enable is high
			end if; 
		end if; 
	end process; 
 end architecture;