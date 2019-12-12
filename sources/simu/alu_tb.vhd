-- File 		:	alu_tb.vhd
-- Author 		:	Alexis ROSSI <alexis.rossi.1@ens.etsmtl.ca>
-- Description 	:	Tests the Arithmetic and Logic Unit
-- Released 	:	17/09/2019
-- Updated		: 	21/09/2019 : 	Refactoring to test the flags
--					24/09/2019 : 	Refactoring in order to instantiate
--									a component instead of a non-visible entity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is port(
	OK : inout boolean := true);
end entity;

architecture bench of alu_tb is
	component alu is port(
		A, B 	:	in std_logic_vector(31 downto 0);  
		SEL 	:	in std_logic_vector(1 downto 0);   	
		Y 		:	out std_logic_vector(31 downto 0); 	
		C		: 	out std_logic;						
		N 		:	out std_logic;                     	
		V 		:	out std_logic;											
		Z		:	out std_logic);
	end component;
	
	signal A, B 		:	std_logic_vector(31 downto 0);		-- 32-bit input bus
	signal SEL 			: 	std_logic_vector(1 downto 0);		-- 2-bit input selector
	signal Y 			: 	std_logic_vector(31 downto 0);		-- 32-bit output
	signal C, N, V, Z 	: 	std_logic;							-- Output flags
begin
	
	-- Unit Under Test
	UUT : alu port map(	A => A,
						B => B,
						SEL => SEL,
						Y => Y,
						C => C,
						N => N,
						V => V,
						Z => Z);
												
	-- We first test the operations for signed numbers
	-- We test the output by varying SEL and fixing A and B for different possiblities :
	-- A < 0 and B < 0
	-- A < 0 and B = 0
	-- A < 0 and B > 0
	-- A = 0 and B < 0
	-- A = 0 and B = 0
	-- A = 0 and B > 0
	-- A > 0 and B < 0
	-- A > 0 and B = 0
	-- A > 0 and B > 0	
	process
	begin
		
		----------------------------------- "Normal" operations for signed number -----------------------------------
		report "Signed numbers tests";
		
		-- A < 0 and B < 0
		A <= std_logic_vector(to_signed(-19, 32)); B <= std_logic_vector(to_signed(-12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A<0, B<0 and SEL=00" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B<0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A<0, B<0 and SEL=01" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B<0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A<0, B<0 and SEL=10" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B<0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A<0, B<0 and SEL=11" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B<0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A < 0 and B = 0
		A <= std_logic_vector(to_signed(-19, 32)); B <= std_logic_vector(to_signed(0, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A<0, B=0 and SEL=00" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B=0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A<0, B=0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A<0, B=0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A<0, B=0 and SEL=10" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B=0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A<0, B=0 and SEL=11" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B=0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A < 0 and B > 0
		A <= std_logic_vector(to_signed(-19, 32)); B <= std_logic_vector(to_signed(12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A<0, B>0 and SEL=00" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B>0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A<0, B>0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B>0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A<0, B>0 and SEL=10" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B>0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A<0, B>0 and SEL=11" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A<0, B>0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A = 0 and B < 0
		A <= std_logic_vector(to_signed(0, 32)); B <= std_logic_vector(to_signed(-12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A=0, B<0 and SEL=00" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B<0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A=0, B<0 and SEL=01" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B<0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A=0, B<0 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B<0 and SEL=11" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A=0, B<0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B<0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A = 0 and B = 0
		A <= std_logic_vector(to_signed(0, 32)); B <= std_logic_vector(to_signed(0, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A=0, B=0 and SEL=00" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A=0, B=0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A=0, B=0 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A=0, B=0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A = 0 and B > 0
		A <= std_logic_vector(to_signed(0, 32)); B <= std_logic_vector(to_signed(12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A=0, B>0 and SEL=00" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B>0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A=0, B>0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B>0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A=0, B>0 and SEL=10" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B>0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A=0, B>0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B>0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A > 0 and B < 0
		A <= std_logic_vector(to_signed(19, 32)); B <= std_logic_vector(to_signed(-12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A>0, B<0 and SEL=00" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B<0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A>0, B<0 and SEL=01" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B<0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A>0, B<0 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B<0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A>0, B<0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B<0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A > 0 and B = 0
		A <= std_logic_vector(to_signed(19, 32)); B <= std_logic_vector(to_signed(0, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A>0, B=0 and SEL=00" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B=0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A>0, B=0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '1');
				assert OK report "Error in flags for for A>0, B=0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A>0, B=0 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B=0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A>0, B=0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B=0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A > 0 and B > 0
		A <= std_logic_vector(to_signed(19, 32)); B <= std_logic_vector(to_signed(12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A>0, B>0 and SEL=00" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A>0, B>0 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A>0, B>0 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A>0, B>0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		----------------------------------- Operations to trigger the overflow flag in signed numbers -----------------------------------
		-- We set A to the maximum and minimum signed value
		-- A = max value and B = 1
		A <= x"7FFFFFFF"; B <= std_logic_vector(to_signed(1, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				-- We do not test the result since it will be wrong
				OK <= (N = '1') and (V = '1') and (Z = '0');	-- Since there is an overflow on the maximum value, the result become negative
				assert OK report "Error in flags for A=max value, B=1 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A max value, B=1 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for A=max value, B=1 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(signed(A) - signed(B)));
				assert OK report "Error in result for A max value, B=1 and SEL=10" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for A=max value, B=1 and SEL=01" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A<0, B<0 and SEL=11" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for A=max value, B=1 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A = min value and B = 1
		A <= x"80000000"; B <= std_logic_vector(to_signed(1, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(signed(A) + signed(B)));
				assert OK report "Error in result for A min value, B=1 and SEL=00" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');	-- Since there is an overflow on tha maximum value, the result become negative
				assert OK report "Error in flags for A=min value, B=1 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A min value, B=1 and SEL=01" severity warning;
				OK <= (N = '0') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for A=min value, B=1 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				-- We do not test the result since it will be wrong
				OK <= (N = '0') and (V = '1') and (Z = '0');	-- Since there is an overflow on the minimum value, the result become positive
				assert OK report "Error in flags for A=min value, B=1 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A=min value, B=1 and SEL=11" severity warning;
				OK <= (N = '1') and (V = '0') and (Z = '0');
				assert OK report "Error in flags for A=min value, B=1 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		----------------------------------- "Normal" operations for unsigned number -----------------------------------
		-- We then test the operations for unsigned numbers
		-- We test the output by varying SEL and fixing A and B for different possiblities :
		-- A = 0 and B = 0
		-- A > 0 and B = 0
		-- A > 0 and B > 0	
	
		report "Unsigned numbers tests";
		
		-- A = 0 and B = 0
		A <= std_logic_vector(to_unsigned(0, 32)); B <= std_logic_vector(to_unsigned(0, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(unsigned(A) + unsigned(B)));
				assert OK report "Error in result for A=0, B=0 and SEL=00" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A=0, B=0 and SEL=01" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(unsigned(A) - unsigned(B)));
				assert OK report "Error in result for A=0, B=0 and SEL=10" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A=0, B=0 and SEL=11" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B=0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A > 0 and B = 0
		A <= std_logic_vector(to_unsigned(19, 32)); B <= std_logic_vector(to_unsigned(0, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(unsigned(A) + unsigned(B)));
				assert OK report "Error in result for A>0, B=0 and SEL=00" severity warning;
				OK <= (C = '0') and(Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A>0, B=0 and SEL=01" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for for A=0, B>0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(unsigned(A) - unsigned(B)));
				assert OK report "Error in result for A>0, B=0 and SEL=10" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B>0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A>0, B=0 and SEL=11" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A=0, B>0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A > 0 and B > 0
		A <= std_logic_vector(to_unsigned(19, 32)); B <= std_logic_vector(to_unsigned(12, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(unsigned(A) + unsigned(B)));
				assert OK report "Error in result for A>0, B>0 and SEL=00" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A>0, B>0 and SEL=01" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(unsigned(A) - unsigned(B)));
				assert OK report "Error in result for A>0, B>0 and SEL=10" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A>0, B>0 and SEL=11" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for for A>0, B>0 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		----------------------------------- Operations to trigger the carry flag in unsigned numbers -----------------------------------
		-- We set A to the maximum and minimum unsigned value
		
		-- A max value and B = 1
		A <= x"FFFFFFFF"; B <= std_logic_vector(to_unsigned(1, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				-- We do not test the result since it will be wrong because of the carry
				OK <= (C = '1') and (Z = '1');		-- Because of the values of the operands, the result becomes null
				assert OK report "Error in flags for A max value, B=1 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A max value, B=1 and SEL=01" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for A max value, B=1 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				OK <= (Y = std_logic_vector(unsigned(A) - unsigned(B)));
				assert OK report "Error in result for A max value, B=1 and SEL=10" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for A max value, B=1 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A max value, B=1 and SEL=11" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for A max value, B=1 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		-- A min value and B = 1
		A <= std_logic_vector(to_unsigned(0, 32)); B <= std_logic_vector(to_unsigned(1, 32)); 
		for i in 0 to 3 loop
			SEL <= std_logic_vector(to_unsigned(i, 2));
			wait for 10 ns;
			
			if SEL = "00" then
				OK <= (Y = std_logic_vector(unsigned(A) + unsigned(B)));
				assert OK report "Error in result for A min value, B=1 and SEL=00" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for A min value, B=1 and SEL=00" severity warning;
			
			elsif SEL = "01" then
				OK <= (Y = B);
				assert OK report "Error in result for A min value, B=1 and SEL=01" severity warning;
				OK <= (C = '0') and (Z = '0');
				assert OK report "Error in flags for A min value, B=1 and SEL=01" severity warning;
				
			elsif SEL = "10" then
				-- We do not test the result since it will be wrong because of the carry
				OK <= (C = '1') and (Z = '0');		-- The result will be positive instead of negative beacause it is unsigned
				assert OK report "Error in flags for A min value, B=1 and SEL=10" severity warning;
			
			else
				OK <= (Y = A);
				assert OK report "Error in result for A min value, B=1 and SEL=11" severity warning;
				OK <= (C = '0') and (Z = '1');
				assert OK report "Error in flags for A min value, B=1 and SEL=11" severity warning;
			end if;			
		end loop;
		
		
		wait;
	end process;
end architecture;