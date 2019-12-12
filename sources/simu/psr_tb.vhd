-- File 		:	psr_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the 32-bit Program State Register
-- Released 	:	08/11/2018
-- Updated		: 	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity psr_tb is port(
	OK : inout boolean := true);
end entity;

architecture bench of psr_tb is
	component psr is port(
		CLK 		: 	in std_logic;								
		RST 		: 	in std_logic;								
		WE 			: 	in std_logic;								
		StateIn		: 	in std_logic_vector(31 downto 0);			
		StateOut 	: 	out std_logic_vector(31 downto 0));			
	end component;

	signal CLK		:	std_logic := '1';									-- Clock
	signal RST		:	std_logic;											-- Asynchronous reset on high level
	signal WE		: 	std_logic := '0';									-- Write Enable
	signal StateIn	:	std_logic_vector(31 downto 0) := (others => '0');	-- 32-bit input state bus
	signal StateOut	: 	std_logic_vector(31 downto 0);						-- 32-bit output state bus
	
	constant period	: time := 10 ns;										-- Period of the clock
	
	begin
	
		UUT : psr port map(	CLK 		=> CLK,
							RST 		=> RST,
							WE			=> WE,
							StateIn 	=> StateIn,
							StateOut	=> StateOut);
	
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
			-- Sets the initial value of the PSR
			RST <= '1', '0' after period / 10;
			wait for period / 2;
			
			-- We write value into the register and check if the output corresponds the input afterward.
			-- Note : The value we will write in the register are values we can code on 4 bits since we only 
			-- use the 4 LSB of the input and output. Hence, if for some reasons another bit than the 4 LSB 
			-- is set to '1', we do not write to the output.
			
			-- We write in the register
			WE <= '1';
			StateIn <= std_logic_vector(to_unsigned(7, 32));		-- Bus DataIn takes the value 7
			wait for period;
			
			-- We check that after the clock's rising edge the output equals the input.
			OK <= (to_integer(unsigned(StateOut(3 downto 0))) = 7);
			assert OK report "Error in the first operation" severity warning;
			
			
			-- We try a second update of the register
			StateIn <= std_logic_vector(to_unsigned(12, 32));		-- Bus DataIn takes the value 12
			wait for period;
			
			-- We check that after the clock's rising edge the output equals the input.
			OK <= (to_integer(unsigned(StateOut(3 downto 0))) = 12);
			assert OK report "Error in the second operation" severity warning;
			
			
			-- Now we set WE to '0' and try to write to the register. 
			WE <= '0';
			StateIn <= std_logic_vector(to_unsigned(4, 32));		-- Bus DataIn takes the value 4
			wait for period;
			
			-- Since WE = '0', the register should keep its old value, i.e. 12 in this case.
			OK <= (to_integer(unsigned(StateOut(3 downto 0))) = 12);
			assert OK report "Error in the third operation" severity warning;
			
			wait;
		end process;
end architecture;