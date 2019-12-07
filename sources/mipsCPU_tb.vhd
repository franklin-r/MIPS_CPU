-- File 		:	mipsCPU_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the MIPS CPU
-- Released 	:	09/11/2018
-- Updated		: 	29/11/2019	:	Update to fit the new outputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mipsCPU_tb is	
end entity;

architecture bench of mipsCPU_tb is 
	component mipsCPU is port(
		CLK 		: 	in std_logic;
		RST 		: 	in std_logic;
		DummyOut	:	out std_logic_vector(31 downto 0));
	end component;
	
	signal CLK		:	std_logic := '0';					-- Clock
	signal RST		:	std_logic;							-- Asynchronous reset on high level
	signal DummyOut	:	std_logic_vector(31 downto 0);		-- Output for the top-level synthesis
	
	constant period	: time := 4 ns;							-- Period of the clock

begin

	UUT : mipsCPU port map(	CLK 		=> CLK,
							RST			=> RST,
							DummyOut	=> DummyOut);
							
	-- Clock
	clock : process					
	begin
		for i in 0 to 120 loop
			CLK <= not CLK;
			wait for period / 2;
		end loop;
		wait;
	end process clock;
	
	test : process
	begin
		-- Sets the memories, registers etc...
		RST <= '1', '0' after period / 10;
		wait;
	end process test;
end architecture;