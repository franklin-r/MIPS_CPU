-- File 		:	pc_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 32-bit Program Counter register
-- Released 	:	08/11/2019
-- Updated		: 	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tb is port(
	OK	: 	inout boolean := true);
end entity;

architecture bench of pc_tb is
	component pc is port(
		CLK 	: 	in std_logic;
		RST		:	in std_logic;	
		AddrIn 	: 	in std_logic_vector(31 downto 0); 		
		AddrOut : 	out std_logic_vector(31 downto 0)); 
	end component;

	signal CLK 		:	std_logic := '0';									-- Clock
	signal RST		:	std_logic;											-- Asynchronous reset on high level
	signal AddrIn	: 	std_logic_vector(31 downto 0) := (others => '0');	-- 32-bit input address
	signal AddrOut	: 	std_logic_vector(31 downto 0);						-- 32-bit output address
	
	constant period	: time := 10 ns;										-- Period of the clock
	
	begin
		UUT : pc port map(	CLK 	=> CLK,
							RST 	=> RST,
							AddrIn 	=> AddrIn,
							AddrOut => AddrOut);
	
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
			-- Sets the initial address
			RST <= '1', '0' after period / 10;
			wait for period / 2;
			
			
			-- We set the input address to a value and check if the output is equal after the clock's rising edge
			
			AddrIn <= std_logic_vector(to_unsigned(19, 32));		-- Bus AddrIn takes the value 19		
			wait for period;
			
			-- We test the value in bus AddrOut to check if the address went from input to output
			OK <= (to_integer(unsigned(AddrOut)) = 19);
			assert OK report "Error in the first operation" severity warning;
			
			
			AddrIn <= std_logic_vector(to_unsigned(12, 32));		-- Bus AddrIn takes the value 12		
			wait for period;
			
			-- We test the value in bus AddrOut to check if the address went from input to output
			OK <= (to_integer(unsigned(AddrOut)) = 12);
			assert OK report "Error in the second operation" severity warning;
			
			
			AddrIn <= std_logic_vector(to_unsigned(31, 32));		-- Bus AddrIn takes the value 31	
			wait for period;
			
			-- We test the value in bus AddrOut to check if the address went from input to output
			OK <= (to_integer(unsigned(AddrOut)) = 31);
			assert OK report "Error in the third operation" severity warning;
						
			wait;
		end process;
end architecture;