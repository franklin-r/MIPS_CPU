-- File			:	instrMemory.vhd
-- Block 		:	Instruction memory
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	64 * 32-bit registers for the instructions memory. 
--					Reading is synchronous : 
--						Bus Instr takes the value of registers n°Addr at clock's rising edge.
-- Context 		:	The block is part of the Instructions Management Unit.
-- Released		:	08/11/2019
-- Updated		: 	09/11/2019	:	Change the block to be combinatorial in order to avoid the 
--									double clock positive edge needed to get an instruction

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instrMemory is port(
	Addr 		: 	in std_logic_vector(31 downto 0); 			-- 32-bit instruction's address
	Instr		: 	out std_logic_vector(31 downto 0));			-- 32-bit output instruction
end entity; 


architecture behaviour of instrMemory is 

	-- Type used to define the 64 * 32-bit registers
  	type table is array(63 downto 0) of std_logic_vector(31 downto 0); 
  
	function init_mem return table is 
  	variable result : table; 
 
  	begin 
		for i in 63 downto 5 loop
			result(i) := (others => '0'); 	-- Instructions memory is empty from storage space 63 to 5
		end loop;
		-- Sets value in storage spaces for test purpose only
		--result(0) := x"12345678";
		--result(1) := x"87654321";
		--result(2) := x"ABCDEF01";
		--result(3) := x"19121997";
		--result(4) := x"55555555";
		
		-- Test program. For test purpose only.
		-- Address		Label 	Instruction			Meaning
		-- 0x0			fib:	addi $3, $0, 8		# $3 <= $0 + 8 ($0 always holds the value 0)
		result(0) := "001000" & std_logic_vector(to_unsigned(0, 5)) & std_logic_vector(to_unsigned(3, 5)) & std_logic_vector(to_signed(8, 16));
		
		-- 0x1					addi $4, $0, 1		# $4 <= $0 + 1
		result(1) := "001000" & std_logic_vector(to_unsigned(0, 5)) & std_logic_vector(to_unsigned(4, 5)) & std_logic_vector(to_signed(1, 16));
		
		-- 0x2					addi $5, $0, -1		# $5 <= $0 + (-1)
		result(2) := "001000" & std_logic_vector(to_unsigned(0, 5)) & std_logic_vector(to_unsigned(5, 5)) & std_logic_vector(to_signed(-1, 16));
		
		-- 0x3					addi $6, $0, 63		# $6 <= $0 + 63
		result(3) := "001000" & std_logic_vector(to_unsigned(0, 5)) & std_logic_vector(to_unsigned(6, 5)) & std_logic_vector(to_signed(63, 16));
		
		-- 0x4			loop:	beq $3, $0, end		# if $3 == $0 then go to the address labeled end
		result(4) := "000100" & std_logic_vector(to_unsigned(3, 5)) & std_logic_vector(to_unsigned(0, 5)) & std_logic_vector(to_signed(5, 16));
		
		-- 0x5					add $4, $4, $5		# $4 <= $4 + $5
		result(5) := "000000" & std_logic_vector(to_unsigned(4, 5)) & std_logic_vector(to_unsigned(5, 5)) & std_logic_vector(to_unsigned(4, 5)) &
						std_logic_vector(to_unsigned(0, 5)) & "100000";
					
		-- 0x6					sub $5, $4, $5		# $5 <= $4 - $5
		result(6) := "000000" & std_logic_vector(to_unsigned(4, 5)) & std_logic_vector(to_unsigned(5, 5)) & std_logic_vector(to_unsigned(5, 5)) &
						std_logic_vector(to_unsigned(0, 5)) & "100010";
						
		-- 0x7					addi $3, $3, -1		# $3 <= $3 + (-1)
		result(7) := "001000" & std_logic_vector(to_unsigned(3, 5)) & std_logic_vector(to_unsigned(3, 5)) & std_logic_vector(to_signed(-1, 16));
		
		-- 0x8					sw $4, 0($6)		# MEM[0 + $6] <= $4
		result(8) := "101011" & std_logic_vector(to_unsigned(6, 5)) & std_logic_vector(to_unsigned(4, 5)) & std_logic_vector(to_signed(0, 16));		
		
		-- 0x9					j loop				# Go to address labeled loop
		result(9):= "000010" & std_logic_vector(to_signed(-6, 26));		
		
		-- 0xA			end:						# End of program
		
		
		
		return result; 
	end init_mem; 
  
	-- Creation of the instructions memory
  	constant INSTRMEM : table := init_mem;
		
	begin 
		Instr <= INSTRMEM(to_integer(unsigned(Addr)));		-- Bus Instr takes the value of registers n°Addr
															-- Addr is unsigned since it is and address
 end architecture;